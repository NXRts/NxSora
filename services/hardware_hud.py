"""
Hardware Indicators & HUD Service (Brightness, Caps Lock, Microphone Mute)
Monitors screen backlight (/sys/class/backlight + KDE PowerDevil D-Bus),
keyboard Caps Lock LED (/sys/class/leds/*::capslock/brightness), and
PipeWire Microphone Mute (@DEFAULT_AUDIO_SOURCE@) to trigger smooth Dynamic Island HUDs.
"""

from PyQt6.QtCore import QObject, pyqtSignal, QTimer
from PyQt6.QtDBus import QDBusConnection, QDBusInterface
import glob
import os
import subprocess


class HardwareHudService(QObject):
    brightnessChanged = pyqtSignal(int)                 # 0..100
    capsLockChanged = pyqtSignal(bool)                  # True = ON, False = OFF
    micMuteChanged = pyqtSignal(bool, int)              # is_muted, mic_pct
    hardwareHudTriggered = pyqtSignal(str, str, int, bool)  # hud_type, label, value_pct, is_active

    def __init__(self, parent=None):
        super().__init__(parent)
        self.bus = QDBusConnection.sessionBus()

        # Current states
        self.brightness_percent = 100
        self.caps_lock_on = False
        self.mic_muted = False
        self.mic_percent = 100

        # Active HUD payload for HudHardware.qml
        self.hud_type = "brightness"     # "brightness" | "capslock" | "mic"
        self.hud_label = "Kecerahan Layar"
        self.hud_value = 100
        self.hud_active = True

        # Discover sysfs nodes for zero-overhead polling
        self._backlight_cur_path = None
        self._backlight_max_path = None
        self._backlight_max_val = 100
        self._capslock_paths = []
        self._discover_paths()

        # Read initial values silently (without firing HUD pop-ups on startup)
        self._read_brightness(emit_hud=False)
        self._read_capslock(emit_hud=False)
        self._read_mic(emit_hud=False)

        # Fast poll timer (180ms) for sysfs Backlight & Caps Lock LED
        self._fast_timer = QTimer(self)
        self._fast_timer.setInterval(180)
        self._fast_timer.timeout.connect(self._poll_fast)
        self._fast_timer.start()

        # Medium poll timer (900ms) for PipeWire Microphone Mute state
        self._mic_timer = QTimer(self)
        self._mic_timer.setInterval(900)
        self._mic_timer.timeout.connect(lambda: self._read_mic(emit_hud=True))
        self._mic_timer.start()

    def _discover_paths(self):
        for b_dir in sorted(glob.glob("/sys/class/backlight/*")):
            cur_p = os.path.join(b_dir, "brightness")
            max_p = os.path.join(b_dir, "max_brightness")
            if os.path.isfile(cur_p) and os.path.isfile(max_p):
                self._backlight_cur_path = cur_p
                self._backlight_max_path = max_p
                try:
                    with open(max_p, "r", encoding="utf-8") as f:
                        self._backlight_max_val = max(1, int(f.read().strip()))
                except Exception:
                    self._backlight_max_val = 100
                break

        self._capslock_paths = [
            p for p in sorted(glob.glob("/sys/class/leds/*capslock*/brightness"))
            if os.path.isfile(p)
        ]

    def _poll_fast(self):
        self._read_brightness(emit_hud=True)
        self._read_capslock(emit_hud=True)

    def _read_brightness(self, emit_hud=True):
        if not self._backlight_cur_path:
            return
        try:
            with open(self._backlight_cur_path, "r", encoding="utf-8") as f:
                cur_val = int(f.read().strip())
            pct = max(1, min(100, int(round((cur_val / self._backlight_max_val) * 100.0))))
            if pct != self.brightness_percent:
                self.brightness_percent = pct
                self.brightnessChanged.emit(pct)
                if emit_hud:
                    self._trigger_hud("brightness", "Kecerahan Layar", pct, True)
        except Exception:
            pass

    def _read_capslock(self, emit_hud=True):
        if not self._capslock_paths:
            return
        try:
            is_on = False
            for p in self._capslock_paths:
                with open(p, "r", encoding="utf-8") as f:
                    if int(f.read().strip()) > 0:
                        is_on = True
                        break
            if is_on != self.caps_lock_on:
                self.caps_lock_on = is_on
                self.capsLockChanged.emit(is_on)
                if emit_hud:
                    self._trigger_hud(
                        "capslock",
                        "Caps Lock",
                        100 if is_on else 0,
                        is_on,
                    )
        except Exception:
            pass

    def _read_mic(self, emit_hud=True):
        try:
            res = subprocess.run(
                ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"],
                capture_output=True,
                text=True,
                timeout=0.4,
            )
            if res.returncode != 0:
                return
            out = res.stdout.strip()
            # Format: "Volume: 0.75" or "Volume: 0.00 [MUTED]"
            muted = "[MUTED]" in out
            parts = out.replace("[MUTED]", "").replace("Volume:", "").strip().split()
            vol_pct = self.mic_percent
            if parts:
                try:
                    vol_pct = int(round(float(parts[0]) * 100.0))
                except ValueError:
                    pass

            if muted != self.mic_muted or abs(vol_pct - self.mic_percent) >= 2:
                mute_toggled = muted != self.mic_muted
                self.mic_muted = muted
                self.mic_percent = vol_pct
                self.micMuteChanged.emit(self.mic_muted, self.mic_percent)
                if emit_hud and mute_toggled:
                    self._trigger_hud(
                        "mic",
                        "Mikrofon",
                        0 if muted else max(10, self.mic_percent),
                        not muted,
                    )
        except Exception:
            pass

    def _trigger_hud(self, hud_type: str, label: str, val: int, active: bool):
        self.hud_type = hud_type
        self.hud_label = label
        self.hud_value = val
        self.hud_active = active
        self.hardwareHudTriggered.emit(hud_type, label, val, active)

    def set_brightness(self, ratio: float):
        """Set screen brightness (0.05..1.0) via KDE PowerManagement D-Bus."""
        clamped = max(0.05, min(1.0, float(ratio)))
        pct = int(round(clamped * 100.0))
        try:
            iface = QDBusInterface(
                "org.kde.Solid.PowerManagement",
                "/org/kde/Solid/PowerManagement/Actions/BrightnessControl",
                "org.kde.Solid.PowerManagement.Actions.BrightnessControl",
                self.bus,
            )
            if iface.isValid():
                max_reply = iface.call("brightnessMax")
                max_b = int(max_reply.arguments()[0]) if max_reply.arguments() else 10000
                iface.call("setBrightnessSilent", int(round(clamped * max_b)))
                self.brightness_percent = pct
                self.brightnessChanged.emit(pct)
        except Exception as e:
            print(f"[HardwareHUD] Brightness set warning: {e}")

    def toggle_mic_mute(self):
        """Toggle microphone mute via PipeWire wpctl and trigger HUD if collapsed."""
        try:
            subprocess.run(
                ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=0.5,
            )
            # If unmuting and mic volume was 0.00, restore to 75% so mic works
            self._read_mic(emit_hud=False)
            if not self.mic_muted and self.mic_percent == 0:
                subprocess.run(
                    ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", "0.75"],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=0.5,
                )
                self._read_mic(emit_hud=False)
            self._trigger_hud(
                "mic",
                "Mikrofon",
                0 if self.mic_muted else max(10, self.mic_percent),
                not self.mic_muted,
            )
        except Exception as e:
            print(f"[HardwareHUD] Mic toggle warning: {e}")

