"""
System & Hardware Monitoring Service
Tracks CPU, RAM, Battery, Network, and System Utilities.
"""

from PyQt6.QtCore import QObject, pyqtSignal, QTimer
from PyQt6.QtDBus import QDBusConnection, QDBusInterface
import psutil
import time
import subprocess
import platform


class SystemService(QObject):
    statsUpdated = pyqtSignal(float, float, str)    # cpu%, ram%, ram_text
    batteryChanged = pyqtSignal(float, bool)        # percent, power_plugged
    powerPluggedEvent = pyqtSignal(bool, float)     # plugged_in, battery_percent (event trigger)
    networkUpdated = pyqtSignal(str, str)           # down_speed, up_speed
    nightLightChanged = pyqtSignal(bool)            # is_active

    def __init__(self, parent=None):
        super().__init__(parent)
        self.cpu_percent = 0.0
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
            self.battery_percent = batt.percent
            self.power_plugged = batt.power_plugged
            self._last_plugged_state = self.power_plugged

        # Timer to poll stats every 1 second
        self.timer = QTimer(self)
        self.timer.setInterval(1000)
        self.timer.timeout.connect(self._poll)
        self.timer.start()

        self._poll()

    def _format_speed(self, bytes_per_sec):
        if bytes_per_sec < 1024 * 1024:
            return f"{bytes_per_sec / 1024:.0f} KB/s"
        return f"{bytes_per_sec / (1024 * 1024):.1f} MB/s"

    def _poll(self):
        # CPU
        self.cpu_percent = psutil.cpu_percent(interval=None)

        # RAM
        vmem = psutil.virtual_memory()
        self.ram_percent = vmem.percent
        used_gb = vmem.used / (1024 ** 3)
        total_gb = vmem.total / (1024 ** 3)
        self.ram_text = f"{used_gb:.1f}/{total_gb:.1f} GB"

        self.statsUpdated.emit(self.cpu_percent, self.ram_percent, self.ram_text)

        # Battery
        batt = psutil.sensors_battery()
        if batt is not None:
            self.has_battery = True
            self.battery_percent = batt.percent
            current_plugged = batt.power_plugged
            
            # Check for plug/unplug transition
            if self._last_plugged_state is not None and self._last_plugged_state != current_plugged:
                self.powerPluggedEvent.emit(current_plugged, self.battery_percent)

            self._last_plugged_state = current_plugged
            self.power_plugged = current_plugged
            self.batteryChanged.emit(self.battery_percent, self.power_plugged)

        # Network
        now = time.time()
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
