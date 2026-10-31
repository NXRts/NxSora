"""
Clipboard History & Quick Paste Service for NxSora (Fase 5)
Tracks recent copied clips, supports pinning, searching, deleting, and 1-click restore.
Persisted in $XDG_CACHE_HOME/nxsora/clipboard_history.json
"""

import json
import os
import subprocess
import threading
import time
from datetime import datetime
from pathlib import Path

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer
from PyQt6.QtGui import QGuiApplication
import config


class ClipboardService(QObject):
    clipboardChanged = pyqtSignal()
    itemCopied = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)

        self._cache_file = config.CACHE_DIR / "clipboard_history.json"
        self._max_items = 25
        self._items = []
        self._last_text = ""
        self._search_query = ""

        self._load_history()

        # Connect to Qt clipboard if available
        qapp = QGuiApplication.instance()
        if qapp:
            clipboard = qapp.clipboard()
            if clipboard:
                clipboard.dataChanged.connect(self._on_qt_clipboard_changed)

        # Polling fallback check every 1.5 seconds for external app copies on Wayland
        self._poll_timer = QTimer(self)
        self._poll_timer.setInterval(1500)
        self._poll_timer.timeout.connect(self._check_wayland_clipboard)
        self._poll_timer.start()

    def _load_history(self):
        try:
            if self._cache_file.exists():
                with open(self._cache_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    if isinstance(data, list):
                        self._items = data[:self._max_items]
        except Exception:
            self._items = []

    def _save_history(self):
        try:
            self._cache_file.parent.mkdir(parents=True, exist_ok=True)
            with open(self._cache_file, "w", encoding="utf-8") as f:
                json.dump(self._items, f, ensure_ascii=False, indent=2)
        except Exception:
            pass

    def _detect_type(self, text: str) -> str:
        s = text.strip()
        if s.startswith(("http://", "https://", "ftp://")):
            return "link"
        if any(tok in s for tok in ["{", "}", "def ", "class ", "function", "import ", "const ", "let ", "var "]):
            return "code"
        if s.startswith("#") and len(s) in (4, 7, 9) and all(c in "#0123456789abcdefABCDEF" for c in s):
            return "color"
        return "text"

    def _add_text_entry(self, text: str):
        cleaned = text.strip()
        if not cleaned or len(cleaned) < 2 or cleaned == self._last_text:
            return

        self._last_text = cleaned

        # Ignore sensitive keywords or transient passwords
        if len(cleaned) > 10000:
            # Clip very large text
            cleaned = cleaned[:10000]

        # Check if already in history; if so, move to top
        existing_idx = -1
        for idx, item in enumerate(self._items):
            if item.get("text") == cleaned:
                existing_idx = idx
                break

        now_str = datetime.now().strftime("%H:%M")
        clip_type = self._detect_type(cleaned)
        preview = " ".join(cleaned.split())[:80]

        if existing_idx >= 0:
            item = self._items.pop(existing_idx)
            item["timestamp"] = now_str
            self._items.insert(0, item)
        else:
            new_item = {
                "id": f"clip_{int(time.time() * 1000)}",
                "text": cleaned,
                "preview": preview,
                "type": clip_type,
                "pinned": False,
                "timestamp": now_str,
                "length": len(cleaned)
            }
            # Maintain maximum items, keeping pinned ones
            self._items.insert(0, new_item)
            if len(self._items) > self._max_items:
                # Remove oldest unpinned item
                for i in range(len(self._items) - 1, -1, -1):
                    if not self._items[i].get("pinned", False):
                        self._items.pop(i)
                        break

        self._save_history()
        self.clipboardChanged.emit()

    def _on_qt_clipboard_changed(self):
        try:
            qapp = QGuiApplication.instance()
            if qapp and qapp.clipboard():
                text = qapp.clipboard().text()
                if text:
                    self._add_text_entry(text)
        except Exception:
            pass

    def _check_wayland_clipboard(self):
        try:
            res = subprocess.run(
                ["wl-paste", "--no-newline"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                timeout=0.4
            )
            if res.returncode == 0 and res.stdout:
                self._add_text_entry(res.stdout)
        except Exception:
            pass

    @pyqtProperty(list, notify=clipboardChanged)
    def history(self) -> list:
        if not self._search_query:
            return self._items
        q = self._search_query.lower()
        return [item for item in self._items if q in item.get("text", "").lower()]

    @pyqtProperty(int, notify=clipboardChanged)
    def count(self) -> int:
        return len(self._items)

    @pyqtProperty(int, notify=clipboardChanged)
    def pinnedCount(self) -> int:
        return sum(1 for item in self._items if item.get("pinned", False))

    @pyqtSlot(str)
    def copyItem(self, item_id: str):
        target = None
        for item in self._items:
            if item.get("id") == item_id:
                target = item
                break

        if not target:
            return

        text = target.get("text", "")
        self._last_text = text

        # Set to Qt clipboard
        qapp = QGuiApplication.instance()
        if qapp and qapp.clipboard():
            qapp.clipboard().setText(text)

        # Also set via wl-copy for Wayland consistency
        try:
            subprocess.run(
                ["wl-copy"],
                input=text.encode("utf-8"),
                stderr=subprocess.DEVNULL,
                timeout=0.5
            )
        except Exception:
            pass

        self.itemCopied.emit(target.get("preview", ""))

    @pyqtSlot(str)
    def togglePin(self, item_id: str):
        for item in self._items:
            if item.get("id") == item_id:
                item["pinned"] = not item.get("pinned", False)
                self._save_history()
                self.clipboardChanged.emit()
                break

    @pyqtSlot(str)
    def deleteItem(self, item_id: str):
        self._items = [item for item in self._items if item.get("id") != item_id]
        self._save_history()
        self.clipboardChanged.emit()

    @pyqtSlot()
    def clearUnpinned(self):
        self._items = [item for item in self._items if item.get("pinned", False)]
        self._save_history()
        self.clipboardChanged.emit()

    @pyqtSlot(str)
    def setSearchQuery(self, query: str):
        self._search_query = query.strip()
        self.clipboardChanged.emit()
