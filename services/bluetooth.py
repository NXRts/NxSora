"""
Bluetooth Audio & Device Monitor Service (BlueZ D-Bus)
Monitors org.bluez for Headphones / TWS / Bluetooth device connection changes
and battery levels to trigger the Nusa-style 310x60px Headphones Peek HUD
complete with interactive TWS Case & Earbuds Pop-Out / Put-In animations.
"""

import os
import subprocess
from PyQt6.QtCore import QObject, pyqtSignal, QTimer
from PyQt6.QtDBus import QDBusConnection, QDBusInterface


class BluetoothService(QObject):
    bluetoothChanged = pyqtSignal()
    bluetoothPeekTriggered = pyqtSignal(str, bool, int)  # name, connected, battery_pct

    def __init__(self, parent=None):
        super().__init__(parent)
        self.bus = QDBusConnection.systemBus()

        self.device_name = "soundcore R50i"
        self.device_connected = False
        self.device_battery = 85
        self.device_icon = "audio-headset"
        self.device_type = "tws"  # "tws", "headphones", "speaker"
        self.anim_serial = 0

        # Map of dbus_object_path -> {"name": str, "connected": bool, "battery": int, "icon": str}
        self._known_devices = {}
        self._initialized = False
        self._demo_override = False

        # Poll BlueZ ObjectManager every 1.5 seconds
        self.poll_timer = QTimer(self)
        self.poll_timer.setInterval(1500)
        self.poll_timer.timeout.connect(self._poll_bluez)
        self.poll_timer.start()

        self._poll_bluez()

    @staticmethod
    def _classify_device(name: str, icon: str) -> str:
        lower = f"{name} {icon}".lower()
        if any(k in lower for k in ("r50i", "bud", "airpod", "tws", "earbud", "wf-", "dots", "pod", "freebuds")):
            return "tws"
        if any(k in lower for k in ("speaker", "jbl", "boom", "soundbar")):
            return "speaker"
        return "tws"

    @staticmethod
    def _play_connect_sfx(connected: bool):
        candidates = (
            [
                "/usr/share/sounds/ocean/stereo/device-added.oga",
                "/usr/share/sounds/freedesktop/stereo/device-added.oga",
                "/usr/share/sounds/freedesktop/stereo/service-login.oga",
            ]
            if connected
            else [
                "/usr/share/sounds/ocean/stereo/device-removed.oga",
                "/usr/share/sounds/freedesktop/stereo/device-removed.oga",
                "/usr/share/sounds/freedesktop/stereo/service-logout.oga",
            ]
        )
        for snd in candidates:
            if os.path.exists(snd):
                try:
                    subprocess.Popen(
                        ["paplay", snd],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                    )
                    return
                except Exception:
                    pass

    def _poll_bluez(self):
        if not self.bus.isConnected():
            return

        try:
            iface = QDBusInterface(
                "org.bluez",
                "/",
                "org.freedesktop.DBus.ObjectManager",
                self.bus,
            )
            if not iface.isValid():
                return

            reply = iface.call("GetManagedObjects")
            if not reply.arguments():
                return

            objs = reply.arguments()[0]
            if not isinstance(objs, dict):
                return

            current_devices = {}
            active_audio_dev = None
            any_paired_dev = None

            for path, ifaces in objs.items():
                if not isinstance(ifaces, dict) or "org.bluez.Device1" not in ifaces:
                    continue

                dev = ifaces["org.bluez.Device1"]
                bat_iface = ifaces.get("org.bluez.Battery1", {})

                name = str(dev.get("Alias") or dev.get("Name") or "Bluetooth Audio")
                connected = bool(dev.get("Connected", False))
                icon = str(dev.get("Icon") or "audio-headset")
                bat_val = bat_iface.get("Percentage", None)
                if isinstance(bat_val, (bytes, bytearray)) and len(bat_val) > 0:
                    battery = int(bat_val[0])
                elif bat_val is not None:
                    battery = int(bat_val)
                else:
                    battery = -1

                info = {
                    "name": name,
                    "connected": connected,
                    "battery": battery,
                    "icon": icon,
                }
                current_devices[path] = info

                if any_paired_dev is None or "audio" in icon or "head" in icon:
                    any_paired_dev = info

                if connected and (active_audio_dev is None or "audio" in icon or "head" in icon):
                    active_audio_dev = info

                # Check for real hardware connection state transitions after initial scan
                if self._initialized and path in self._known_devices:
                    prev = self._known_devices[path]
                    if prev["connected"] != connected:
                        self._demo_override = False
                        self.device_name = name
                        self.device_connected = connected
                        self.device_battery = battery if battery >= 0 else 85
                        self.device_icon = icon
                        self.device_type = self._classify_device(name, icon)
                        self.anim_serial += 1
                        self._play_connect_sfx(connected)
                        self.bluetoothChanged.emit()
                        self.bluetoothPeekTriggered.emit(
                            self.device_name,
                            self.device_connected,
                            self.device_battery,
                        )
                    elif connected and prev["battery"] != battery and battery >= 0 and not self._demo_override:
                        self.device_battery = battery
                        self.bluetoothChanged.emit()

            self._known_devices = current_devices

            if not self._initialized:
                self._initialized = True
                if active_audio_dev is not None:
                    self.device_name = active_audio_dev["name"]
                    self.device_connected = True
                    self.device_battery = (
                        active_audio_dev["battery"]
                        if active_audio_dev["battery"] >= 0
                        else 90
                    )
                    self.device_icon = active_audio_dev["icon"]
                    self.device_type = self._classify_device(self.device_name, self.device_icon)
                    self.bluetoothChanged.emit()
                    QTimer.singleShot(
                        500,
                        lambda: self.bluetoothPeekTriggered.emit(
                            self.device_name,
                            self.device_connected,
                            self.device_battery,
                        ),
                    )
                elif any_paired_dev is not None:
                    self.device_name = any_paired_dev["name"]
                    self.device_connected = False
                    self.device_battery = (
                        any_paired_dev["battery"]
                        if any_paired_dev["battery"] >= 0
                        else 85
                    )
                    self.device_icon = any_paired_dev["icon"]
                    self.device_type = self._classify_device(self.device_name, self.device_icon)
                    self.bluetoothChanged.emit()

        except Exception as e:
            print(f"[Bluetooth] Poll warning: {e}")

    def trigger_demo_peek(self, force_connected=None):
        """
        Trigger a preview of the 310x60px Headphones Peek.
        Alternates between Connected (TWS Pop-Out from Case) and Disconnected (TWS Put-In to Case)
        when clicked repeatedly so the user can experience both animations.
        """
        self._demo_override = True
        name = self.device_name if self.device_name and self.device_name != "Tidak ada TWS" else "soundcore R50i"
        bat = self.device_battery if self.device_battery > 0 else 85

        if force_connected is not None:
            new_connected = bool(force_connected)
        else:
            new_connected = not self.device_connected

        self.device_name = name
        self.device_battery = bat
        self.device_connected = new_connected
        self.device_type = self._classify_device(name, self.device_icon)
        self.anim_serial += 1
        self._play_connect_sfx(new_connected)
        self.bluetoothChanged.emit()
        self.bluetoothPeekTriggered.emit(name, new_connected, bat)
