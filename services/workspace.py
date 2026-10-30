"""
KDE Virtual Desktop / Workspace Service for NxSora
Connects to org.kde.KWin /VirtualDesktopManager via D-Bus
Provides active desktop name, count, and 1-click workspace switching.
"""

import subprocess
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QVariant
from PyQt6.QtDBus import QDBusConnection, QDBusInterface, QDBusMessage


class WorkspaceService(QObject):
    workspaceChanged = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._count = 1
        self._current_id = ""
        self._current_index = 0
        self._current_name = "Desktop 1"
        self._desktops = []

        self._bus = QDBusConnection.sessionBus()
        self._init_dbus()

    def _init_dbus(self):
        """Initializes connection to KWin VirtualDesktopManager."""
        if not self._bus.isConnected():
            return

        # Listen for KWin VirtualDesktopManager signals
        self._bus.connect(
            "org.kde.KWin",
            "/VirtualDesktopManager",
            "org.kde.KWin.VirtualDesktopManager",
            "currentChanged",
            self._on_current_changed,
        )
        self._bus.connect(
            "org.kde.KWin",
            "/VirtualDesktopManager",
            "org.kde.KWin.VirtualDesktopManager",
            "countChanged",
            self._on_count_changed,
        )
        self._bus.connect(
            "org.kde.KWin",
            "/VirtualDesktopManager",
            "org.kde.KWin.VirtualDesktopManager",
            "desktopDataChanged",
            self._on_data_changed,
        )

        self.refresh()

    def refresh(self):
        """Queries the current virtual desktops state from KWin."""
        try:
            iface = QDBusInterface(
                "org.kde.KWin",
                "/VirtualDesktopManager",
                "org.kde.KWin.VirtualDesktopManager",
                self._bus,
            )
            if not iface.isValid():
                # Fallback to busctl query if interface validation is delayed
                self._fallback_query()
                return

            # Read count
            count_val = iface.property("count")
            if count_val is not None:
                self._count = max(1, int(count_val))

            # Read current
            curr_val = iface.property("current")
            if curr_val is not None:
                self._current_id = str(curr_val)

            # Read desktops list (a(uss) or a(iss): position, id, name)
            desktops_val = iface.property("desktops")
            new_desktops = []

            if desktops_val:
                # Can be delivered as list of tuples/lists or QDBusArgument
                try:
                    for item in desktops_val:
                        if isinstance(item, (list, tuple)) and len(item) >= 3:
                            pos = int(item[0])
                            d_id = str(item[1])
                            name = str(item[2])
                            new_desktops.append({
                                "index": pos,
                                "id": d_id,
                                "name": name,
                                "isCurrent": (d_id == self._current_id),
                            })
                except Exception:
                    pass

            if not new_desktops:
                # If desktops property couldn't be parsed directly, generate default entries
                for i in range(self._count):
                    new_desktops.append({
                        "index": i,
                        "id": f"desktop-{i+1}",
                        "name": f"Desktop {i+1}",
                        "isCurrent": (i == self._current_index),
                    })

            self._desktops = new_desktops

            # Determine current index and name
            found = False
            for d in self._desktops:
                if d["id"] == self._current_id:
                    self._current_index = d["index"]
                    self._current_name = d["name"]
                    d["isCurrent"] = True
                    found = True
                else:
                    d["isCurrent"] = False

            if not found and self._desktops:
                self._current_index = 0
                self._current_name = self._desktops[0]["name"]
                self._desktops[0]["isCurrent"] = True

            self.workspaceChanged.emit()
        except Exception:
            self._fallback_query()

    def _fallback_query(self):
        """Fallback to busctl to read KWin virtual desktop properties."""
        try:
            # Query count
            res = subprocess.run(
                ["busctl", "--user", "get-property", "org.kde.KWin", "/VirtualDesktopManager", "org.kde.KWin.VirtualDesktopManager", "count"],
                capture_output=True, text=True, timeout=1.5
            )
            if res.returncode == 0 and res.stdout.strip():
                parts = res.stdout.strip().split()
                if len(parts) >= 2:
                    self._count = max(1, int(parts[1]))

            # Query current
            res = subprocess.run(
                ["busctl", "--user", "get-property", "org.kde.KWin", "/VirtualDesktopManager", "org.kde.KWin.VirtualDesktopManager", "current"],
                capture_output=True, text=True, timeout=1.5
            )
            if res.returncode == 0 and res.stdout.strip():
                val = res.stdout.strip().replace('"', '').split()
                if len(val) >= 2:
                    self._current_id = val[1]

            # Query desktops
            res = subprocess.run(
                ["busctl", "--user", "get-property", "org.kde.KWin", "/VirtualDesktopManager", "org.kde.KWin.VirtualDesktopManager", "desktops"],
                capture_output=True, text=True, timeout=1.5
            )
            desktops = []
            if res.returncode == 0 and res.stdout.strip():
                out = res.stdout.strip()
                # Output looks like: a(uss) 2 0 "id-1" "Desktop 1" 1 "id-2" "Desktop 2"
                import re
                matches = re.findall(r'(\d+)\s+"([^"]+)"\s+"([^"]+)"', out)
                for pos_str, d_id, name in matches:
                    pos = int(pos_str)
                    desktops.append({
                        "index": pos,
                        "id": d_id,
                        "name": name,
                        "isCurrent": (d_id == self._current_id),
                    })

            if not desktops:
                for i in range(self._count):
                    desktops.append({
                        "index": i,
                        "id": f"desktop-{i+1}",
                        "name": f"Desktop {i+1}",
                        "isCurrent": (i == self._current_index),
                    })

            self._desktops = desktops
            for d in self._desktops:
                if d["id"] == self._current_id:
                    self._current_index = d["index"]
                    self._current_name = d["name"]
                    break

            self.workspaceChanged.emit()
        except Exception:
            pass

    @pyqtSlot(str)
    def _on_current_changed(self, new_id: str):
        self._current_id = str(new_id)
        self.refresh()

    @pyqtSlot(int)
    def _on_count_changed(self, new_count: int):
        self._count = max(1, int(new_count))
        self.refresh()

    @pyqtSlot()
    def _on_data_changed(self):
        self.refresh()

    # --- Actions ---

    @pyqtSlot(int)
    def switchToIndex(self, index: int):
        """Switches to workspace by 0-based index."""
        if 0 <= index < len(self._desktops):
            target_id = self._desktops[index]["id"]
            self.switchToId(target_id)

    @pyqtSlot(str)
    def switchToId(self, desktop_id: str):
        """Switches to workspace by KWin desktop ID."""
        try:
            msg = QDBusMessage.createMethodCall(
                "org.kde.KWin",
                "/VirtualDesktopManager",
                "org.freedesktop.DBus.Properties",
                "Set",
            )
            # Signature: ssv (interface, property, variant)
            from PyQt6.QtDBus import QDBusVariant
            msg.setArguments([
                "org.kde.KWin.VirtualDesktopManager",
                "current",
                QDBusVariant(desktop_id),
            ])
            self._bus.send(msg)
            # Local eager update
            self._current_id = desktop_id
            self.refresh()
        except Exception:
            # Fallback to busctl
            try:
                subprocess.Popen([
                    "busctl", "--user", "set-property",
                    "org.kde.KWin", "/VirtualDesktopManager",
                    "org.kde.KWin.VirtualDesktopManager",
                    "current", "s", desktop_id,
                ])
                self._current_id = desktop_id
                self.refresh()
            except Exception:
                pass

    @pyqtSlot()
    def nextDesktop(self):
        """Cycles to the next virtual desktop."""
        if self._count <= 1:
            return
        next_idx = (self._current_index + 1) % len(self._desktops)
        self.switchToIndex(next_idx)

    @pyqtSlot()
    def previousDesktop(self):
        """Cycles to the previous virtual desktop."""
        if self._count <= 1:
            return
        prev_idx = (self._current_index - 1 + len(self._desktops)) % len(self._desktops)
        self.switchToIndex(prev_idx)

    # --- Properties ---

    @pyqtProperty(int, notify=workspaceChanged)
    def count(self) -> int:
        return self._count

    @pyqtProperty(int, notify=workspaceChanged)
    def currentIndex(self) -> int:
        return self._current_index

    @pyqtProperty(str, notify=workspaceChanged)
    def currentName(self) -> str:
        return self._current_name

    @pyqtProperty(str, notify=workspaceChanged)
    def currentId(self) -> str:
        return self._current_id

    @pyqtProperty("QVariantList", notify=workspaceChanged)
    def desktops(self):
        return self._desktops
