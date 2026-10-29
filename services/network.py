"""
NxSora (Nx空) — Network & Wi-Fi Monitoring Service
Tracks Wi-Fi and Ethernet connection lifecycle, signal strength, and SSID changes.
Triggers the 310x60px Network Peek HUD on connection and disconnection events.
"""

import subprocess
import shutil
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer
from PyQt6.QtDBus import QDBusConnection, QDBusInterface


class NetworkService(QObject):
    networkChanged = pyqtSignal()
    networkPeekTriggered = pyqtSignal(str, bool, int, str)  # name, connected, signal_pct, type

    def __init__(self, parent=None):
        super().__init__(parent)
        self._ssid = ""
        self._connected = False
        self._signal_pct = 0
        self._net_type = "wifi"  # "wifi" or "ethernet"
        self._prev_state = None
        self._demo_override = False

        self._has_nmcli = shutil.which("nmcli") is not None

        # Listen to NetworkManager D-Bus system signals
        self.bus = QDBusConnection.systemBus()
        if self.bus.isConnected():
            self.bus.connect(
                "org.freedesktop.NetworkManager",
                "/org/freedesktop/NetworkManager",
                "org.freedesktop.NetworkManager",
                "StateChanged",
                self._on_nm_state_changed
            )

        # Periodic check timer (polls every 5s with low overhead)
        self._poll_timer = QTimer(self)
        self._poll_timer.timeout.connect(self.check_status)
        self._poll_timer.start(5000)

        # Initial probe
        self.check_status(emit_peek=False)

    @pyqtProperty(str, notify=networkChanged)
    def ssid(self):
        return self._ssid

    @pyqtProperty(bool, notify=networkChanged)
    def connected(self):
        return self._connected

    @pyqtProperty(int, notify=networkChanged)
    def signalPercent(self):
        return self._signal_pct

    @pyqtProperty(str, notify=networkChanged)
    def netType(self):
        return self._net_type

    @pyqtSlot()
    def check_status(self, emit_peek=True):
        if self._demo_override:
            return

        if not self._has_nmcli:
            return

        try:
            # Query device status
            res = subprocess.run(
                ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"],
                capture_output=True,
                text=True,
                timeout=1.5
            )
            lines = res.stdout.strip().splitlines()

            found_connected = False
            active_ssid = ""
            active_type = "wifi"
            active_signal = 80

            for line in lines:
                parts = line.split(":")
                if len(parts) >= 3:
                    dev_type, state, conn_name = parts[0], parts[1], parts[2]
                    if state == "connected" and dev_type in ("wifi", "ethernet"):
                        found_connected = True
                        active_type = dev_type
                        active_ssid = conn_name
                        break

            # If wifi is active, get exact signal strength
            if found_connected and active_type == "wifi":
                try:
                    w_res = subprocess.run(
                        ["nmcli", "-t", "-f", "active,ssid,signal", "dev", "wifi"],
                        capture_output=True,
                        text=True,
                        timeout=1.5
                    )
                    for w_line in w_res.stdout.strip().splitlines():
                        if w_line.startswith("yes:"):
                            w_parts = w_line.split(":")
                            if len(w_parts) >= 3 and w_parts[2].isdigit():
                                active_signal = int(w_parts[2])
                            if len(w_parts) >= 2 and w_parts[1]:
                                active_ssid = w_parts[1]
                            break
                except Exception:
                    pass

            # Detect state transitions
            current_state_key = (found_connected, active_ssid)
            if self._prev_state is not None and self._prev_state != current_state_key:
                # State changed!
                self._connected = found_connected
                self._ssid = active_ssid if found_connected else "Wi-Fi Terputus"
                self._net_type = active_type
                self._signal_pct = active_signal if found_connected else 0
                self.networkChanged.emit()

                if emit_peek:
                    self.networkPeekTriggered.emit(
                        self._ssid,
                        self._connected,
                        self._signal_pct,
                        self._net_type
                    )
            else:
                self._connected = found_connected
                self._ssid = active_ssid if found_connected else "Wi-Fi Terputus"
                self._net_type = active_type
                self._signal_pct = active_signal if found_connected else 0
                self.networkChanged.emit()

            self._prev_state = current_state_key

        except Exception as e:
            # Fallback gracefully
            pass

    @pyqtSlot(int)
    def _on_nm_state_changed(self, state):
        # NetworkManager state change notification
        self.check_status(emit_peek=True)

    @pyqtSlot()
    def trigger_demo(self):
        """Simulate a Wi-Fi connection peek for UI testing & demonstration."""
        self._demo_override = True
        self._connected = True
        self._ssid = "Starlink Ultra 5G"
        self._signal_pct = 92
        self._net_type = "wifi"
        self.networkChanged.emit()
        self.networkPeekTriggered.emit(self._ssid, self._connected, self._signal_pct, self._net_type)

        # Restore real status after 5 seconds
        def restore():
            self._demo_override = False
            self.check_status(emit_peek=False)

        QTimer.singleShot(5000, restore)

    @pyqtSlot()
    def trigger_disconnect_demo(self):
        """Simulate a Wi-Fi disconnect peek."""
        self._demo_override = True
        self._connected = False
        self._ssid = "Wi-Fi Terputus"
        self._signal_pct = 0
        self._net_type = "wifi"
        self.networkChanged.emit()
        self.networkPeekTriggered.emit(self._ssid, self._connected, self._signal_pct, self._net_type)

        def restore():
            self._demo_override = False
            self.check_status(emit_peek=False)

        QTimer.singleShot(5000, restore)
