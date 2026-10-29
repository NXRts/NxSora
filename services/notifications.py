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
import time
from datetime import datetime, timedelta
from PyQt6.QtCore import QObject, pyqtSignal, QThread
from PyQt6.QtGui import QGuiApplication
import config


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

            call_buffer = []
            capturing = False

            for line in proc.stdout:
                if "member=Notify" in line:
                    if capturing and call_buffer:
                        self._process_call("".join(call_buffer))
                    capturing = True
                    call_buffer = [line]
                    continue

                if capturing:
                    call_buffer.append(line)
                    # When 'array [' is reached (parameter 6: actions), all parameters 1-5
                    # (app_name, replaces_id, app_icon, summary, body) have been received.
                    if "array [" in line:
                        self._process_call("".join(call_buffer))
                        capturing = False
                        call_buffer = []
        except Exception as e:
            print(f"[Notifications] Watcher error: {e}")

    def _process_call(self, block: str):
        try:
            m_uint = re.search(r'uint32\s+\d+', block)
            if not m_uint:
                return

            pre_uint = block[:m_uint.start()]
            post_uint = block[m_uint.end():]

            m_app = re.search(r'string\s+\"(.*?)\"', pre_uint, re.DOTALL)
            app_name = m_app.group(1).strip() if m_app else "Sistem"

            m_arr = re.search(r'array\s*\[', post_uint)
            params_text = post_uint[:m_arr.start()] if m_arr else post_uint

            parts = re.split(r'\n\s*string\s+\"', '\n' + params_text.strip())
            if len(parts) >= 4:
                def clean_val(v):
                    v = v.rstrip()
                    if v.endswith('"'):
                        v = v[:-1]
                    return v.strip()

                summary = clean_val(parts[2])
                body = clean_val('"'.join(parts[3:]))
                if summary or body:
                    self.notificationReceived.emit(app_name, summary, body)
        except Exception as e:
            print(f"[Notifications] Parse error: {e}")


class NotificationService(QObject):
    notificationReceived = pyqtSignal(str, str, str)  # Emitted for popup HUD (when DND is off)
    historyChanged = pyqtSignal()

    MAX_HISTORY = 40

    PASSWORD_MANAGER_APPS = (
        "keepassxc", "keepass", "bitwarden", "1password", "proton pass",
        "protonpass", "enpass", "authpass", "lastpass", "dashlane", "nordpass"
    )

    def __init__(self, parent=None):
        super().__init__(parent)
        self._storage_path = str(config.CONFIG_DIR / "notifications.json")
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

    @staticmethod
    def _normalize_chat_notification(app_name: str, summary: str, body: str):
        app = app_name.strip()
        title = summary.strip()
        msg = body.strip()

        combined_header = f"{app} {title}".lower()

        # WhatsApp detection (from Chrome/Firefox web, Electron apps, or KDE Connect)
        if "whatsapp" in combined_header or "whatsapp" in msg[:40].lower():
            if "whatsapp" in app.lower() or any(b in app.lower() for b in ("chrome", "firefox", "brave", "chromium", "zen", "edge", "kde connect", "kdeconnect")):
                app = "WhatsApp"

            # Clean title: e.g. "WhatsApp • Budi Santoso" -> "Budi Santoso"
            title = re.sub(r'^WhatsApp\s*[\:\•\-\|]\s*', '', title, flags=re.IGNORECASE).strip()

            # If title is just 'WhatsApp' / 'WhatsApp Web' and msg contains 'Sender: Text'
            if title.lower() in ("whatsapp", "whatsapp web", "") and ":" in msg:
                sender_part, msg_part = msg.split(":", 1)
                if len(sender_part) < 35:
                    title = sender_part.strip()
                    msg = msg_part.strip()

        # Telegram detection
        elif "telegram" in combined_header or "telegram" in msg[:40].lower():
            if any(b in app.lower() for b in ("chrome", "firefox", "brave", "chromium", "zen", "edge")):
                app = "Telegram"
            title = re.sub(r'^Telegram\s*[\:\•\-\|]\s*', '', title, flags=re.IGNORECASE).strip()

        # Discord detection
        elif "discord" in combined_header or "discord" in msg[:40].lower():
            if any(b in app.lower() for b in ("chrome", "firefox", "brave", "chromium", "zen", "edge")):
                app = "Discord"
            title = re.sub(r'^Discord\s*[\:\•\-\|]\s*', '', title, flags=re.IGNORECASE).strip()

        return app, title, msg

    @staticmethod
    def format_relative_time(ts: float | int | None) -> str:
        """Format a UNIX timestamp into a human-friendly relative time in Indonesian.
        - Hari ini: "07:15"
        - Kemarin: "Kemarin, 21:30"
        - Hari-hari sebelumnya: "27 Okt, 14:10" (atau "27/10/25, 14:10" jika tahun berbeda)
        """
        if not ts:
            return "--:--"
        try:
            dt = datetime.fromtimestamp(ts)
            now = datetime.now()
            today = now.date()
            entry_date = dt.date()
            diff_days = (today - entry_date).days

            time_str = dt.strftime("%H:%M")

            if diff_days == 0:
                return time_str
            elif diff_days == 1:
                return f"Kemarin, {time_str}"
            elif diff_days > 1:
                indo_months = [
                    "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
                    "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
                ]
                month_str = indo_months[dt.month - 1]
                if dt.year == now.year:
                    return f"{dt.day} {month_str}, {time_str}"
                else:
                    return f"{dt.day}/{dt.month}/{dt.year % 100:02d}, {time_str}"
            else:
                # Waktu sedikit di depan sekarang karena clock jitter
                return time_str
        except Exception:
            return "--:--"

    def refresh_relative_times(self) -> bool:
        """Refresh human-readable time strings for all items based on current time."""
        changed = False
        for item in self.history:
            ts = item.get("timestamp")
            if ts:
                new_time = self.format_relative_time(ts)
                if item.get("time") != new_time:
                    item["time"] = new_time
                    changed = True
        return changed

    def _load_history(self):
        persist = config.CONFIG.get("persist_notifications", True)
        if not persist:
            self.history = []
            return

        try:
            if os.path.exists(self._storage_path):
                with open(self._storage_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                if isinstance(data, dict):
                    loaded_items = data.get("items", [])
                    self.dnd_enabled = bool(data.get("dnd_enabled", False))

                    expire_hours = config.CONFIG.get("notification_auto_expire_hours", 48)
                    now_ts = time.time()
                    cutoff_ts = now_ts - (expire_hours * 3600) if expire_hours > 0 else 0

                    valid_items = []
                    for item in loaded_items:
                        item_ts = item.get("timestamp")
                        # Kompatibilitas mundur: jika belum punya timestamp, berikan fallback timestamp sekarang
                        if not item_ts:
                            item_ts = now_ts
                            item["timestamp"] = item_ts

                        # Filter auto-expire: buang notifikasi yang lebih lama dari cutoff
                        if cutoff_ts > 0 and item_ts < cutoff_ts:
                            continue

                        # Format ulang waktu agar sesuai dengan hari ini / kemarin
                        item["time"] = self.format_relative_time(item_ts)
                        valid_items.append(item)

                    self.history = valid_items[: self.MAX_HISTORY]
                    if self.history:
                        self._next_id = max(int(item.get("id", 0)) for item in self.history) + 1
        except Exception as e:
            print(f"[Notifications] Load history warning: {e}")

        # Seed a welcome notification if history is completely empty on first run
        if not self.history:
            now_dt = datetime.now()
            now_ts = now_dt.timestamp()
            self.history = [
                {
                    "id": self._next_id,
                    "timestamp": now_ts,
                    "app": "NxSora",
                    "title": "Pusat Notifikasi Aktif 🔔",
                    "body": "Semua notifikasi masuk dari sistem, chat, browser, dan pengingat kini tersimpan di sini secara pintar dengan masa aktif 48 jam.",
                    "time": self.format_relative_time(now_ts),
                    "category": "system",
                    "unread": False,
                }
            ]
            self._next_id += 1
            self._save_history()

    def _save_history(self):
        payload = {
            "dnd_enabled": self.dnd_enabled,
            "items": self.history[: self.MAX_HISTORY],
        }
        config.safe_write_private_json(self._storage_path, payload)

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

        # Normalize chat notifications (WhatsApp, Telegram, Discord, etc.)
        clean_app, clean_title, clean_body = self._normalize_chat_notification(
            clean_app, clean_title, clean_body
        )

        # Privacy & Data Security: Do not store or process credentials/tokens from password managers
        lowered_source = f"{clean_app} {clean_title}".lower()
        if any(pm in lowered_source for pm in self.PASSWORD_MANAGER_APPS):
            print(f"[Notifications] Privacy guard: Ignored notification from password manager ({clean_app})")
            return

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

        now_dt = datetime.now()
        now_ts = now_dt.timestamp()
        category = self._classify_app(clean_app, clean_title)

        entry = {
            "id": self._next_id,
            "timestamp": now_ts,
            "app": clean_app,
            "title": clean_title,
            "body": clean_body if clean_body else clean_title,
            "time": self.format_relative_time(now_ts),
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
        body="Halo! Ini adalah contoh notifikasi panjang di NxSora. Klik notifikasi ini untuk membaca seluruh isi pesan secara utuh di Pusat Notifikasi.",
        app_name="Telegram Desktop",
    ):
        self._on_notification(app_name, title, body)
