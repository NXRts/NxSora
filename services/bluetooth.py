"""
Bluetooth Audio & Device Manager Service (BlueZ D-Bus)
Monitors org.bluez for Adapter status, Connected/Paired Bluetooth devices,
and battery levels. Powers both the 310x60px Headphones Peek HUD
(with TWS Case & Earbuds Pop-Out / Put-In animations) and the dedicated
Bluetooth & Perangkat Hub Page.
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

        self.adapter_powered = True
        self.device_name = "soundcore R50i"
        self.device_connected = False
        self.device_battery = 85
        self.device_icon = "audio-headset"
        self.device_type = "tws"  # "tws", "headphones", "speaker", etc.
        self.anim_serial = 0

        self.devices_list = []
        self.connected_count = 0

        # Map of dbus_object_path -> {"name": str, "connected": bool, "battery": int, "icon": str}
        self._known_devices = {}
        self._busy_addresses = {}  # address -> remaining poll ticks
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
        if any(k in lower for k in ("th30", "thinkplus", "wh-", "head", "audio-headset", "audio-headphones")):
            return "headphones"
        if any(k in lower for k in ("speaker", "jbl", "boom", "soundbar", "audio-card")):
            return "speaker"
        if "mouse" in lower:
            return "mouse"
        if "keyboard" in lower:
            return "keyboard"
        if "phone" in lower:
            return "phone"
        return "device"

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

            # Decrement busy counters
            expired = [addr for addr, t in self._busy_addresses.items() if t <= 1]
            for addr in expired:
                self._busy_addresses.pop(addr, None)
            for addr in list(self._busy_addresses.keys()):
                self._busy_addresses[addr] -= 1

            adapter_powered = True
            current_devices = {}
            parsed_list = []
            active_audio_dev = None
            any_paired_dev = None

            for path, ifaces in objs.items():
                if not isinstance(ifaces, dict):
                    continue

                if "org.bluez.Adapter1" in ifaces:
                    adapter_powered = bool(ifaces["org.bluez.Adapter1"].get("Powered", True))

                if "org.bluez.Device1" not in ifaces:
                    continue

                dev = ifaces["org.bluez.Device1"]
                bat_iface = ifaces.get("org.bluez.Battery1", {})

                name = str(dev.get("Alias") or dev.get("Name") or "Bluetooth Device")
                address = str(dev.get("Address") or "")
                connected = bool(dev.get("Connected", False))
                paired = bool(dev.get("Paired", False))
                icon = str(dev.get("Icon") or "audio-headset")

                bat_val = bat_iface.get("Percentage", None)
                if isinstance(bat_val, (bytes, bytearray)) and len(bat_val) > 0:
                    battery = int(bat_val[0])
                elif bat_val is not None:
                    battery = int(bat_val)
                else:
                    battery = -1

                category = self._classify_device(name, icon)

                # Clear busy flag if state changed
                if self._initialized and path in self._known_devices:
                    if self._known_devices[path]["connected"] != connected:
                        self._busy_addresses.pop(address, None)

                info = {
                    "path": str(path),
                    "address": address,
                    "name": name,
                    "connected": connected,
                    "paired": paired,
                    "battery": battery,
                    "icon": icon,
                    "category": category,
                    "busy": address in self._busy_addresses,
                }
                current_devices[path] = info

                if paired or connected:
                    parsed_list.append(info)

                if any_paired_dev is None or category in ("tws", "headphones", "speaker"):
                    any_paired_dev = info

                if connected and (active_audio_dev is None or category in ("tws", "headphones", "speaker")):
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
                        self.device_type = category
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

            # Sort: connected first, then audio devices, then alphabetical
            parsed_list.sort(
                key=lambda d: (
                    0 if d["connected"] else 1,
                    0 if d["category"] in ("tws", "headphones", "speaker") else 1,
                    d["name"].lower(),
                )
            )

            connected_cnt = sum(1 for d in parsed_list if d["connected"])
            list_changed = (
                parsed_list != self.devices_list
                or adapter_powered != self.adapter_powered
                or connected_cnt != self.connected_count
            )

            self.adapter_powered = adapter_powered
            self.devices_list = parsed_list
            self.connected_count = connected_cnt
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
                    self.device_type = active_audio_dev["category"]
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
                    self.device_type = any_paired_dev["category"]
                    self.bluetoothChanged.emit()
            elif list_changed:
                if not self._demo_override and active_audio_dev is not None:
                    self.device_name = active_audio_dev["name"]
                    self.device_connected = True
                    if active_audio_dev["battery"] >= 0:
                        self.device_battery = active_audio_dev["battery"]
                    self.device_type = active_audio_dev["category"]
                self.bluetoothChanged.emit()

        except Exception as e:
            print(f"[Bluetooth] Poll warning: {e}")

    def toggle_device_connection(self, address: str):
        """Connect or disconnect a paired Bluetooth device by MAC address via bluetoothctl."""
        if not address:
            return
        target_dev = next((d for d in self.devices_list if d["address"] == address), None)
        is_currently_connected = target_dev["connected"] if target_dev else False
        cmd = "disconnect" if is_currently_connected else "connect"

        self._busy_addresses[address] = 5
        for d in self.devices_list:
            if d["address"] == address:
                d["busy"] = True
        self.bluetoothChanged.emit()

        try:
            subprocess.Popen(
                ["bluetoothctl", cmd, address],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except Exception as e:
            print(f"[Bluetooth] toggle_device_connection error: {e}")

    def toggle_adapter_power(self):
        """Turn the Bluetooth adapter on or off."""
        new_state = "off" if self.adapter_powered else "on"
        self.adapter_powered = not self.adapter_powered
        self.bluetoothChanged.emit()
        try:
            subprocess.Popen(
                ["bluetoothctl", "power", new_state],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except Exception as e:
            print(f"[Bluetooth] toggle_adapter_power error: {e}")

    def open_bluetooth_settings(self):
        """Open KDE Plasma Bluetooth Settings."""
        for cmd in (["kcmshell6", "kcm_bluetooth"], ["systemsettings", "kcm_bluetooth"]):
            try:
                subprocess.Popen(
                    cmd,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                return
            except Exception:
                continue

    def trigger_demo_peek(self, force_connected=None):
        """
        Trigger a preview of the 310x60px Headphones Peek.
        Alternates between Connected (TWS Pop-Out from Case) and Disconnected (TWS Put-In to Case)
        when clicked repeatedly so the user can experience both animations.
        """
        self._demo_override = True
        name = self.device_name if self.device_name and self.device_name != "Tidak ada TWS" else "soundcore R50i"
        bat = self.device_battery if self.device_battery > 0 else 80

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
