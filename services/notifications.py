"""
Desktop Notification Listener & Notification Center Service
Eavesdrops DBus org.freedesktop.Notifications to display notifications dynamically
in the island and maintains a persistent Notification Center history with
unread tracking, Do Not Disturb (DND), HTML stripping, and clipboard copy.
"""

import html
import json
import os
import re
import subprocess
from datetime import datetime
from PyQt6.QtCore import QObject, pyqtSignal, QThread
from PyQt6.QtGui import QGuiApplication


class NotificationWatcherThread(QThread):
    notificationReceived = pyqtSignal(str, str, str)  # app_name, summary, body

    def run(self):
        try:
            proc = subprocess.Popen(
                [
                    "dbus-monitor",
                    "type='method_call',interface='org.freedesktop.Notifications',member='Notify'",
                ],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
            )

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
                    if line.startswith('string "'):
                        val = line[8:]
                        if val.endswith('"'):
                            val = val[:-1]
                        strings_collected.append(val)
                        if len(strings_collected) >= 4:
                            # 0: app_name, 1: app_icon, 2: summary, 3: body
                            app_name = strings_collected[0] or "Sistem"
                            summary = strings_collected[2] or "Notifikasi Baru"
                            body = strings_collected[3] or ""
                            self.notificationReceived.emit(app_name, summary, body)
                            capturing = False
                            strings_collected = []
                    elif "method_return" in line or "error" in line:
                        capturing = False
        except Exception as e:
            print(f"[Notifications] Watcher error: {e}")


class NotificationService(QObject):
    notificationReceived = pyqtSignal(str, str, str)  # Emitted for popup HUD (when DND is off)
    historyChanged = pyqtSignal()

    MAX_HISTORY = 40

    def __init__(self, parent=None):
        super().__init__(parent)
        self._storage_path = os.path.expanduser("~/.config/dynamic-island/notifications.json")
        self.history = []
        self.dnd_enabled = False
        self.selected_index = 0
        self._next_id = 1
        self._last_sig = ("", "", "", 0.0)

        self._load_history()

        self.watcher = NotificationWatcherThread(self)
        self.watcher.notificationReceived.connect(self._on_notification)
        self.watcher.start()

    @staticmethod
    def _clean_text(raw: str) -> str:
        if not raw:
            return ""
        text = re.sub(r"<br\s*/?>", "\n", raw, flags=re.IGNORECASE)
        text = re.sub(r"<[^>]+>", "", text)
        text = html.unescape(text)
        return text.strip()

    @staticmethod
    def _classify_app(app_name: str, summary: str) -> str:
        combined = f"{app_name} {summary}".lower()
        if any(k in combined for k in ("whatsapp", "telegram", "discord", "signal", "slack", "pesan", "chat", "mail", "thunderbird")):
            return "chat"
        if any(k in combined for k in ("spotify", "elisa", "vlc", "mpv", "musik", "media", "youtube")):
            return "media"
        if any(k in combined for k in ("suhu", "panas", "thermal", "baterai", "power", "bluetooth", "tws")):
            return "thermal"
        if any(k in combined for k in ("fokus", "pomodoro", "break", "air", "minum", "mata", "istirahat", "kesehatan")):
            return "focus"
        if any(k in combined for k in ("firefox", "chrome", "brave", "chromium", "zen", "edge", "browser")):
            return "browser"
        return "system"

    def _load_history(self):
        try:
            if os.path.exists(self._storage_path):
                with open(self._storage_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                if isinstance(data, dict):
                    self.history = data.get("items", [])[: self.MAX_HISTORY]
                    self.dnd_enabled = bool(data.get("dnd_enabled", False))
                    if self.history:
                        self._next_id = max(int(item.get("id", 0)) for item in self.history) + 1
        except Exception as e:
            print(f"[Notifications] Load history warning: {e}")

        # Seed a welcome notification if history is completely empty on first run
        if not self.history:
            now_str = datetime.now().strftime("%H:%M")
            self.history = [
                {
                    "id": self._next_id,
                    "app": "Dynamic Island",
                    "title": "Pusat Notifikasi Aktif 🔔",
                    "body": "Semua notifikasi masuk dari sistem, chat, browser, dan pengingat kini tersimpan di sini agar Anda bisa membaca pesan penuh kapan saja.",
                    "time": now_str,
                    "category": "system",
                    "unread": False,
                }
            ]
            self._next_id += 1

    def _save_history(self):
        try:
            os.makedirs(os.path.dirname(self._storage_path), exist_ok=True)
            with open(self._storage_path, "w", encoding="utf-8") as f:
                json.dump(
                    {
                        "dnd_enabled": self.dnd_enabled,
                        "items": self.history[: self.MAX_HISTORY],
                    },
                    f,
                    ensure_ascii=False,
                    indent=2,
                )
        except Exception as e:
            print(f"[Notifications] Save history warning: {e}")

    @property
    def unread_count(self) -> int:
        return sum(1 for item in self.history if item.get("unread", False))

    @property
    def selected_item(self) -> dict:
        if not self.history:
            return {
                "id": 0,
                "app": "",
                "title": "Belum Ada Notifikasi",
                "body": "Notifikasi yang masuk ke sistem akan muncul dan tersimpan secara otomatis di sini.",
                "time": "--:--",
                "category": "system",
                "unread": False,
            }
        idx = max(0, min(self.selected_index, len(self.history) - 1))
        return self.history[idx]

    def _on_notification(self, app_name: str, summary: str, body: str):
        clean_app = self._clean_text(app_name) or "Sistem"
        clean_title = self._clean_text(summary) or "Notifikasi Baru"
        clean_body = self._clean_text(body)

        # Deduplicate identical notifications within 1.5 seconds
        now_ts = datetime.now().timestamp()
        prev_app, prev_title, prev_body, prev_ts = self._last_sig
        if (
            clean_app == prev_app
            and clean_title == prev_title
            and clean_body == prev_body
            and (now_ts - prev_ts) < 1.5
        ):
            return
        self._last_sig = (clean_app, clean_title, clean_body, now_ts)

        now_str = datetime.now().strftime("%H:%M")
        category = self._classify_app(clean_app, clean_title)

        entry = {
            "id": self._next_id,
            "app": clean_app,
            "title": clean_title,
            "body": clean_body if clean_body else clean_title,
            "time": now_str,
            "category": category,
            "unread": True,
        }
        self._next_id += 1

        self.history.insert(0, entry)
        if len(self.history) > self.MAX_HISTORY:
            self.history = self.history[: self.MAX_HISTORY]

        self.selected_index = 0
        self._save_history()
        self.historyChanged.emit()

        # Only trigger popup HUD if Do Not Disturb (DND) is disabled
        if not self.dnd_enabled:
            self.notificationReceived.emit(clean_app, clean_title, clean_body)

    def select_notification(self, index: int):
        if 0 <= index < len(self.history):
            self.selected_index = index
            if self.history[index].get("unread", False):
                self.history[index]["unread"] = False
                self._save_history()
            self.historyChanged.emit()

    def mark_all_read(self):
        changed = False
        for item in self.history:
            if item.get("unread", False):
                item["unread"] = False
                changed = True
        if changed:
            self._save_history()
            self.historyChanged.emit()

    def remove_notification(self, index: int):
        if 0 <= index < len(self.history):
            self.history.pop(index)
            if self.selected_index >= len(self.history):
                self.selected_index = max(0, len(self.history) - 1)
            self._save_history()
            self.historyChanged.emit()

    def clear_all(self):
        self.history = []
        self.selected_index = 0
        self._save_history()
        self.historyChanged.emit()

    def toggle_dnd(self):
        self.dnd_enabled = not self.dnd_enabled
        self._save_history()
        self.historyChanged.emit()

    def copy_selected(self) -> bool:
        if not self.history:
            return False
        item = self.selected_item
        title = item.get("title", "")
        body = item.get("body", "")
        full_text = f"{title}\n{body}".strip() if body and body != title else title
        if not full_text:
            return False

        try:
            cb = QGuiApplication.clipboard()
            if cb is not None:
                cb.setText(full_text)
        except Exception:
            pass

        try:
            subprocess.Popen(
                ["wl-copy", full_text],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except Exception:
            pass
        return True

    def trigger_test(
        self,
        title="Pesan Masuk Baru 💬",
        body="Halo! Ini adalah contoh notifikasi panjang di Dynamic Island. Klik notifikasi ini untuk membaca seluruh isi pesan secara utuh di Pusat Notifikasi.",
        app_name="Telegram Desktop",
    ):
        self._on_notification(app_name, title, body)
