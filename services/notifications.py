"""
Desktop Notification Listener Service
Eavesdrops DBus org.freedesktop.Notifications to display notifications dynamically in the island.
"""

from PyQt6.QtCore import QObject, pyqtSignal, QThread
import subprocess
import re


class NotificationWatcherThread(QThread):
    notificationReceived = pyqtSignal(str, str, str)  # app_name, summary, body

    def run(self):
        try:
            proc = subprocess.Popen(
                ["dbus-monitor", "type='method_call',interface='org.freedesktop.Notifications',member='Notify'"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True
            )
            
            # State machine for parsing dbus-monitor output
            # Signature: Notify(string app_name, uint32 replaces_id, string app_icon, string summary, string body, ...)
            strings_collected = []
            capturing = False

            for line in proc.stdout:
                line = line.strip()
                if "member=Notify" in line:
                    capturing = True
                    strings_collected = []
                    continue

                if capturing:
                    if line.startswith("string \""):
                        val = line[8:-1]
                        strings_collected.append(val)
                        if len(strings_collected) >= 4:
                            # 0: app_name, 1: app_icon, 2: summary, 3: body
                            app_name = strings_collected[0] or "Notification"
                            summary = strings_collected[2] or "New Alert"
                            body = strings_collected[3] or ""
                            self.notificationReceived.emit(app_name, summary, body)
                            capturing = False
                            strings_collected = []
                    elif "method_return" in line or "error" in line:
                        capturing = False
        except Exception:
            pass


class NotificationService(QObject):
    notificationReceived = pyqtSignal(str, str, str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.watcher = NotificationWatcherThread(self)
        self.watcher.notificationReceived.connect(self._on_notification)
        self.watcher.start()

    def _on_notification(self, app_name, summary, body):
        self.notificationReceived.emit(app_name, summary, body)

    def trigger_test(self, title="Test Notification", body="Dynamic Island is working smoothly on KDE Wayland!"):
        self.notificationReceived.emit("Antigravity", title, body)
