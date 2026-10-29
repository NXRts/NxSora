"""
System, Thermal, TDP & Hardware Monitoring Service
Tracks CPU (%, Temp, Clock GHz, TDP Watts), GPU (%, Temp, Clock, VRAM),
NVMe SSD (Temp, Disk Usage), RAM, Battery, Network, Top Process, and Power Profiles.
"""

from PyQt6.QtCore import QObject, pyqtSignal, QTimer
from PyQt6.QtDBus import QDBusConnection, QDBusInterface
import glob
import os
import platform
import re
import shutil
import subprocess
import time
import psutil


class SystemService(QObject):
    statsUpdated = pyqtSignal(float, float, str)    # cpu%, ram%, ram_text
    batteryChanged = pyqtSignal(float, bool)        # percent, power_plugged
    powerPluggedEvent = pyqtSignal(bool, float)     # plugged_in, battery_percent (event trigger)
    networkUpdated = pyqtSignal(str, str)           # down_speed, up_speed
    nightLightChanged = pyqtSignal(bool)            # is_active
    powerProfileChanged = pyqtSignal(str)           # power-saver | balanced | performance
    overheatAlert = pyqtSignal(int, str)            # temp_c, top_process

    def __init__(self, parent=None):
        super().__init__(parent)
        self.cpu_percent = 0.0
        self.cpu_temp = 0.0
        self.cpu_freq_ghz = 0.0
        self.cpu_freq_text = "0.00 GHz"
        self.cpu_model = self._detect_cpu_model()

        # Processor TDP / Package Power (PPT in Watts)
        self.cpu_tdp_watts = 0.0
        self.cpu_tdp_max_watts = 30.0
        self._ppt_hwmon_path = None
        self._gpu_freq_path = None
        self._gpu_busy_path = None
        self._vram_used_path = None
        self._vram_total_path = None
        self._discover_sysfs_paths()

        # GPU & VRAM telemetry
        self.gpu_percent = 0
        self.gpu_temp = 0.0
        self.gpu_freq_mhz = 0
        self.vram_used_mb = 0
        self.vram_total_mb = 0
        self.vram_percent = 0
        self.vram_text = "0 / 0 MB"

        # NVMe & Disk telemetry
        self.nvme_temp = 0.0
        self.disk_percent = 0
        self.disk_text = "0/0 GB"

        # Top resource culprit & Overheat cooldown
        self.top_process = "Idle"
        self._poll_tick_count = 0
        self._last_overheat_time = 0.0

        # Power Profile (power-saver | balanced | performance)
        self.power_profile = "balanced"
        self._refresh_power_profile()

        self.ram_percent = 0.0
        self.ram_text = "0/0 GB"
        self.battery_percent = 100.0
        self.power_plugged = True
        self.has_battery = False

        self._last_plugged_state = None

        # Network tracking
        self.net_down_str = "0 KB/s"
        self.net_up_str = "0 KB/s"
        self._last_net = psutil.net_io_counters()
        self._last_net_time = time.time()

        # System info
        self.kernel_info = platform.release()
        self.os_info = "CachyOS (KDE Plasma 6)"

        # Night Light state
        self.bus = QDBusConnection.sessionBus()
        self.night_light_active = False
        self._night_light_cookie = 0
        self._check_night_light()

        # Check initial battery
        batt = psutil.sensors_battery()
        if batt is not None:
            self.has_battery = True
            self.battery_percent = float(batt.percent)
            self.power_plugged = bool(batt.power_plugged) if batt.power_plugged is not None else True
            self._last_plugged_state = self.power_plugged

        # Prime process cpu_percent counters
        self._prime_process_cpu()

        # Timer to poll stats every 1 second
        self.timer = QTimer(self)
        self.timer.setInterval(1000)
        self.timer.timeout.connect(self._poll)
        self.timer.start()

        self._poll()

    def _detect_cpu_model(self):
        try:
            with open("/proc/cpuinfo", "r", encoding="utf-8") as f:
                for line in f:
                    if line.startswith("model name"):
                        raw = line.split(":", 1)[1].strip()
                        # Clean up common verbose suffixes
                        raw = re.sub(r"\s+with\s+.*$", "", raw, flags=re.IGNORECASE)
                        raw = re.sub(r"\(R\)|\(TM\)|Processor|\d+-Core", "", raw, flags=re.IGNORECASE)
                        raw = re.sub(r"\s+", " ", raw).strip()
                        return raw or "Linux CPU"
        except Exception:
            pass
        return platform.processor() or "Linux CPU"

    def _discover_sysfs_paths(self):
        """Locate hwmon PPT power sensor, GPU busy_percent, and VRAM sysfs nodes once."""
        for hw in sorted(glob.glob("/sys/class/hwmon/hwmon*")):
            for p_name in ("power1_input", "power1_average"):
                candidate = os.path.join(hw, p_name)
                if os.path.isfile(candidate):
                    self._ppt_hwmon_path = candidate
                    break
            f_cand = os.path.join(hw, "freq1_input")
            if os.path.isfile(f_cand):
                self._gpu_freq_path = f_cand

        for busy in sorted(glob.glob("/sys/class/drm/card*/device/gpu_busy_percent")):
            if os.path.isfile(busy):
                self._gpu_busy_path = busy
                dev_dir = os.path.dirname(busy)
                vu = os.path.join(dev_dir, "mem_info_vram_used")
                vt = os.path.join(dev_dir, "mem_info_vram_total")
                if os.path.isfile(vu) and os.path.isfile(vt):
                    self._vram_used_path = vu
                    self._vram_total_path = vt
                break

    @staticmethod
    def _read_int_file(path):
        if not path:
            return None
        try:
            with open(path, "r", encoding="utf-8") as f:
                return int(f.read().strip())
        except Exception:
            return None

    def _prime_process_cpu(self):
        try:
            for p in psutil.process_iter(["name", "cpu_percent"]):
                pass
        except Exception:
            pass

    def _update_top_process(self):
        try:
            best_name = "Idle"
            best_cpu = 0.0
            my_pid = os.getpid()
            for p in psutil.process_iter(["pid", "name", "cpu_percent"]):
                info = p.info
                if info.get("pid") == my_pid:
                    continue
                cpu_val = info.get("cpu_percent") or 0.0
                if cpu_val > best_cpu:
                    best_cpu = cpu_val
                    best_name = info.get("name") or "proc"
            if best_cpu >= 1.0:
                short_name = best_name[:14]
                self.top_process = f"{short_name} ({best_cpu:.0f}%)"
            else:
                self.top_process = "Sistem Santai"
        except Exception:
            pass

    def _refresh_power_profile(self):
        try:
            res = subprocess.run(
                ["powerprofilesctl", "get"],
                capture_output=True,
                text=True,
                timeout=0.6,
            )
            if res.returncode == 0 and res.stdout.strip():
                prof = res.stdout.strip()
                if prof != self.power_profile:
                    self.power_profile = prof
                    self.powerProfileChanged.emit(self.power_profile)
        except Exception:
            pass

    def set_power_profile(self, profile: str):
        if profile not in ("power-saver", "balanced", "performance"):
            return
        try:
            subprocess.Popen(
                ["powerprofilesctl", "set", profile],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            self.power_profile = profile
            self.powerProfileChanged.emit(self.power_profile)
        except Exception as e:
            print(f"[System] Warning setting power profile: {e}")

    def cycle_power_profile(self):
        order = ["power-saver", "balanced", "performance"]
        try:
            idx = order.index(self.power_profile)
            next_prof = order[(idx + 1) % len(order)]
        except ValueError:
            next_prof = "balanced"
        self.set_power_profile(next_prof)

    def _format_speed(self, bytes_per_sec):
        if bytes_per_sec < 1024 * 1024:
            return f"{bytes_per_sec / 1024:.0f} KB/s"
        return f"{bytes_per_sec / (1024 * 1024):.1f} MB/s"

    def _poll_hardware_sensors(self):
        # 1. Temperatures (CPU, GPU, NVMe)
        try:
            temps = psutil.sensors_temperatures()
            # CPU Temp (k10temp / coretemp / zenpower / cpu_thermal / acpitz)
            found_cpu = False
            for key in ("k10temp", "coretemp", "zenpower", "cpu_thermal", "acpitz", "soc_thermal"):
                if key in temps and temps[key]:
                    self.cpu_temp = float(temps[key][0].current)
                    found_cpu = True
                    break
            # Fallback to any thermal sensor if specific names not matched
            if not found_cpu and temps:
                for k, v in temps.items():
                    if v and ("temp" in k.lower() or "thermal" in k.lower() or "cpu" in k.lower()):
                        self.cpu_temp = float(v[0].current)
                        found_cpu = True
                        break
                if not found_cpu and temps:
                    first_list = next(iter(temps.values()))
                    if first_list:
                        self.cpu_temp = float(first_list[0].current)

            # GPU Temp (amdgpu / nouveau / nvidia)
            found_gpu = False
            for key in ("amdgpu", "nouveau", "nvidia"):
                if key in temps and temps[key]:
                    self.gpu_temp = float(temps[key][0].current)
                    found_gpu = True
                    break
            # NVIDIA proprietary fallback via nvidia-smi if not found in sysfs
            if not found_gpu and shutil.which("nvidia-smi"):
                try:
                    nv_out = subprocess.check_output(
                        ["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"],
                        timeout=0.4,
                        stderr=subprocess.DEVNULL
                    ).decode().strip()
                    if nv_out.isdigit():
                        self.gpu_temp = float(nv_out)
                        found_gpu = True
                except Exception:
                    pass

            # NVMe SSD Temp
            if "nvme" in temps and temps["nvme"]:
                self.nvme_temp = float(temps["nvme"][0].current)
        except Exception:
            pass

        # 2. CPU Frequency (GHz)
        try:
            freq = psutil.cpu_freq()
            if freq and freq.current > 0:
                # Some kernels report MHz (e.g. 3450), others kHz
                mhz = freq.current if freq.current < 10000 else freq.current / 1000.0
                self.cpu_freq_ghz = mhz / 1000.0
                self.cpu_freq_text = f"{self.cpu_freq_ghz:.2f} GHz"
        except Exception:
            pass

        # 3. Processor TDP / Package Power (PPT in Watts)
        raw_uw = self._read_int_file(self._ppt_hwmon_path)
        if raw_uw is not None and raw_uw > 0:
            self.cpu_tdp_watts = round(raw_uw / 1_000_000.0, 1)
            if self.cpu_tdp_watts > self.cpu_tdp_max_watts:
                self.cpu_tdp_max_watts = float(int(round(self.cpu_tdp_watts)))
        else:
            # Fallback estimation based on CPU load if sensor unavailable
            self.cpu_tdp_watts = round(4.0 + (self.cpu_percent / 100.0) * 21.0, 1)

        # 4. GPU Load (%), GPU Clock (MHz) & VRAM (MB)
        gpu_busy = self._read_int_file(self._gpu_busy_path)
        if gpu_busy is not None:
            self.gpu_percent = max(0, min(100, gpu_busy))

        gpu_hz = self._read_int_file(self._gpu_freq_path)
        if gpu_hz is not None and gpu_hz > 0:
            self.gpu_freq_mhz = int(round(gpu_hz / 1_000_000.0))

        v_used = self._read_int_file(self._vram_used_path)
        v_tot = self._read_int_file(self._vram_total_path)
        if v_used is not None and v_tot is not None and v_tot > 0:
            self.vram_used_mb = int(round(v_used / (1024 * 1024)))
            self.vram_total_mb = int(round(v_tot / (1024 * 1024)))
            self.vram_percent = int(round((v_used / v_tot) * 100.0))
            self.vram_text = f"{self.vram_used_mb}/{self.vram_total_mb} MB"

    def _poll(self):
        self._poll_tick_count += 1

        # CPU & RAM
        self.cpu_percent = psutil.cpu_percent(interval=None)
        vmem = psutil.virtual_memory()
        self.ram_percent = vmem.percent
        used_gb = vmem.used / (1024 ** 3)
        total_gb = vmem.total / (1024 ** 3)
        self.ram_text = f"{used_gb:.1f}/{total_gb:.1f} GB"

        # Hardware Thermal, TDP, GPU & NVMe sensors
        self._poll_hardware_sensors()

        # Every 3 seconds: update Disk, Top Process, and Power Profile
        if self._poll_tick_count % 3 == 1:
            try:
                du = psutil.disk_usage("/")
                self.disk_percent = int(round(du.percent))
                d_used = du.used / (1024 ** 3)
                d_tot = du.total / (1024 ** 3)
                self.disk_text = f"{d_used:.0f}/{d_tot:.0f} GB"
            except Exception:
                pass
            self._update_top_process()

        if self._poll_tick_count % 5 == 0:
            self._refresh_power_profile()

        # Overheat Warning Check (>= 85°C with 120s cooldown)
        peak_temp = max(self.cpu_temp, self.gpu_temp)
        now = time.time()
        if peak_temp >= 85.0 and (now - self._last_overheat_time) > 120.0:
            self._last_overheat_time = now
            self.overheatAlert.emit(int(round(peak_temp)), self.top_process)

        self.statsUpdated.emit(self.cpu_percent, self.ram_percent, self.ram_text)

        # Battery
        try:
            batt = psutil.sensors_battery()
            if batt is not None:
                self.has_battery = True
                self.battery_percent = float(batt.percent)
                current_plugged = bool(batt.power_plugged) if batt.power_plugged is not None else False

                # Check for plug/unplug transition
                if self._last_plugged_state is not None and self._last_plugged_state != current_plugged:
                    self.powerPluggedEvent.emit(current_plugged, self.battery_percent)

                self._last_plugged_state = current_plugged
                self.power_plugged = current_plugged
                self.batteryChanged.emit(self.battery_percent, self.power_plugged)
            else:
                self.has_battery = False
        except Exception as e:
            print(f"[System] Warning in battery poll: {e}")

        # Network
        dt = max(0.5, now - self._last_net_time)
        current_net = psutil.net_io_counters()

        down_bps = (current_net.bytes_recv - self._last_net.bytes_recv) / dt
        up_bps = (current_net.bytes_sent - self._last_net.bytes_sent) / dt

        self.net_down_str = self._format_speed(down_bps)
        self.net_up_str = self._format_speed(up_bps)
        self.networkUpdated.emit(self.net_down_str, self.net_up_str)

        self._last_net = current_net
        self._last_net_time = now

    # System Actions
    def take_screenshot(self):
        """Take rectangle/area screenshot via Spectacle"""
        subprocess.Popen(["spectacle", "-r"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def lock_screen(self):
        """Lock desktop session"""
        subprocess.Popen(["loginctl", "lock-session"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def open_terminal(self):
        """Open default KDE terminal (Konsole)"""
        subprocess.Popen(["konsole"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def open_settings(self):
        """Open KDE System Settings"""
        subprocess.Popen(["systemsettings"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def _check_night_light(self):
        iface = QDBusInterface("org.kde.KWin", "/org/kde/KWin/NightLight", "org.freedesktop.DBus.Properties", self.bus)
        reply = iface.call("Get", "org.kde.KWin.NightLight", "inhibited")
        if reply.arguments():
            inhibited = bool(reply.arguments()[0])
            self.night_light_active = not inhibited
            self.nightLightChanged.emit(self.night_light_active)

    def toggle_night_light(self):
        """Toggle KDE Night Light"""
        iface = QDBusInterface("org.kde.KWin", "/org/kde/KWin/NightLight", "org.kde.KWin.NightLight", self.bus)
        if self.night_light_active:
            # Inhibit / Turn off
            reply = iface.call("inhibit")
            if reply.arguments():
                self._night_light_cookie = reply.arguments()[0]
                self.night_light_active = False
                self.nightLightChanged.emit(False)
        else:
            # Uninhibit / Turn on
            if self._night_light_cookie:
                iface.call("uninhibit", self._night_light_cookie)
                self._night_light_cookie = 0
            self.night_light_active = True
            self.nightLightChanged.emit(True)
