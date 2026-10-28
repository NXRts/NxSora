"""
Bluetooth Audio & Device Monitor Service (BlueZ D-Bus)
Monitors org.bluez for Headphones / TWS / Bluetooth device connection changes
and battery levels to trigger the Nusa-style 310x60px Headphones Peek HUD.
"""

from PyQt6.QtCore import QObject, pyqtSignal, QTimer
from PyQt6.QtDBus import QDBusConnection, QDBusInterface


class BluetoothService(QObject):
    bluetoothChanged = pyqtSignal()
    bluetoothPeekTriggered = pyqtSignal(str, bool, int)  # name, connected, battery_pct

    def __init__(self, parent=None):
        super().__init__(parent)
        self.bus = QDBusConnection.systemBus()

        self.device_name = "Tidak ada TWS"
        self.device_connected = False
        self.device_battery = -1
        self.device_icon = "audio-headset"

        # Map of dbus_object_path -> {"name": str, "connected": bool, "battery": int, "icon": str}
        self._known_devices = {}
        self._initialized = False

        # Poll BlueZ ObjectManager every 1.5 seconds
        self.poll_timer = QTimer(self)
        self.poll_timer.setInterval(1500)
        self.poll_timer.timeout.connect(self._poll_bluez)
        self.poll_timer.start()

        self._poll_bluez()

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
                battery = int(bat_val) if bat_val is not None else -1

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

                # Check for connection state transitions after initial scan
                if self._initialized and path in self._known_devices:
                    prev = self._known_devices[path]
                    if prev["connected"] != connected:
                        self.device_name = name
                        self.device_connected = connected
                        self.device_battery = battery if battery >= 0 else 100
                        self.device_icon = icon
                        self.bluetoothChanged.emit()
                        self.bluetoothPeekTriggered.emit(
                            self.device_name,
                            self.device_connected,
                            self.device_battery,
                        )
                    elif connected and prev["battery"] != battery and battery >= 0:
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
                        else 100
                    )
                    self.device_icon = active_audio_dev["icon"]
                    self.bluetoothChanged.emit()
                elif any_paired_dev is not None:
                    self.device_name = any_paired_dev["name"]
                    self.device_connected = False
                    self.device_battery = (
                        any_paired_dev["battery"]
                        if any_paired_dev["battery"] >= 0
                        else 85
                    )
                    self.device_icon = any_paired_dev["icon"]
                    self.bluetoothChanged.emit()

        except Exception as e:
            print(f"[Bluetooth] Poll warning: {e}")

    def trigger_demo_peek(self):
        """Trigger a preview of the 310x60px Headphones Peek using real paired device info."""
        name = self.device_name if self.device_name != "Tidak ada TWS" else "soundcore R50i"
        bat = self.device_battery if self.device_battery >= 0 else 85
        self.device_name = name
        self.device_battery = bat
        self.device_connected = True
        self.bluetoothChanged.emit()
        self.bluetoothPeekTriggered.emit(name, True, bat)

