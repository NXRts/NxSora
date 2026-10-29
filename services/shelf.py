"""
Wayland File Shelf Service (Wayland File Shelf Style)
Stores dropped file/folder paths persistently in ~/.config/dynamic_island/shelf.json
without copying file contents into memory, and supports native Wayland Drag-Out (QDrag).
"""

import json
import os
import subprocess
from pathlib import Path
from urllib.parse import unquote, urlparse

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QMimeData, QUrl, Qt
from PyQt6.QtGui import QDrag, QGuiApplication, QPixmap, QPainter, QColor, QFont


IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp", ".svg"}
ARCHIVE_EXTS = {".zip", ".tar", ".gz", ".xz", ".zst", ".7z", ".rar"}
CODE_EXTS = {".py", ".qml", ".js", ".ts", ".rs", ".c", ".cpp", ".h", ".json", ".md", ".sh", ".html", ".css"}
AUDIO_EXTS = {".mp3", ".flac", ".wav", ".ogg", ".m4a", ".opus"}
VIDEO_EXTS = {".mp4", ".mkv", ".webm", ".mov", ".avi"}


import config


class ShelfService(QObject):
    shelfChanged = pyqtSignal()
    shelfGulpTriggered = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._config_file = str(config.CONFIG_DIR / "shelf.json")

        self._paths = []
        self._items = []
        self._load_shelf()

    @staticmethod
    def _format_size(num_bytes: int) -> str:
        if num_bytes < 1024:
            return f"{num_bytes} B"
        elif num_bytes < 1024 * 1024:
            return f"{num_bytes / 1024:.1f} KB"
        elif num_bytes < 1024 * 1024 * 1024:
            return f"{num_bytes / (1024 * 1024):.1f} MB"
        return f"{num_bytes / (1024 ** 3):.2f} GB"

    @classmethod
    def _build_item(cls, file_path: str):
        p = Path(file_path)
        if not p.exists():
            return None

        is_dir = p.is_dir()
        ext_lower = p.suffix.lower()

        if is_dir:
            kind = "folder"
            size_str = "Folder"
            ext_badge = "DIR"
        else:
            try:
                size_str = cls._format_size(p.stat().st_size)
            except Exception:
                size_str = "0 B"

            ext_badge = (ext_lower.lstrip(".")[:4] or "FILE").upper()
            if ext_lower in IMAGE_EXTS:
                kind = "image"
            elif ext_lower in ARCHIVE_EXTS:
                kind = "archive"
            elif ext_lower in CODE_EXTS:
                kind = "code"
            elif ext_lower in AUDIO_EXTS:
                kind = "audio"
            elif ext_lower in VIDEO_EXTS:
                kind = "video"
            else:
                kind = "doc"

        return {
            "path": str(p.resolve()),
            "url": QUrl.fromLocalFile(str(p.resolve())).toString(),
            "name": p.name,
            "size": size_str,
            "kind": kind,
            "ext": ext_badge,
        }

    def _rebuild_items(self):
        valid_paths = []
        built = []
        for path_str in self._paths:
            item = self._build_item(path_str)
            if item is not None:
                valid_paths.append(item["path"])
                built.append(item)
        self._paths = valid_paths
        self._items = built

    def _load_shelf(self):
        if os.path.exists(self._config_file):
            try:
                with open(self._config_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                if isinstance(data, list):
                    self._paths = [str(p) for p in data if isinstance(p, str)]
            except Exception as e:
                print(f"[ShelfService] Error loading shelf.json: {e}")
        self._rebuild_items()

    def _save_shelf(self):
        config.safe_write_private_json(self._config_file, self._paths)

    @pyqtProperty(list, notify=shelfChanged)
    def items(self):
        return self._items

    @pyqtProperty(int, notify=shelfChanged)
    def count(self):
        return len(self._items)

    @staticmethod
    def _normalize_url_or_path(raw) -> str:
        if hasattr(raw, "toLocalFile"):
            local = raw.toLocalFile()
            if local:
                return local
            raw = raw.toString()

        s = str(raw).strip()
        if not s:
            return ""
        if s.startswith("file://"):
            parsed = urlparse(s)
            return unquote(parsed.path)
        return s

    @pyqtSlot("QVariant")
    def addDroppedUrls(self, raw_urls):
        """Add one or more dropped URLs/paths to the Shelf."""
        if raw_urls is None:
            return

        if isinstance(raw_urls, (str, QUrl)):
            candidates = [raw_urls]
        elif hasattr(raw_urls, "toVariant"):
            val = raw_urls.toVariant()
            candidates = val if isinstance(val, list) else [val]
        elif isinstance(raw_urls, (list, tuple)):
            candidates = list(raw_urls)
        else:
            try:
                candidates = list(raw_urls)
            except Exception:
                candidates = [raw_urls]

        added_any = False
        for c in candidates:
            # Handle multi-line text/uri-list strings if passed as a single string
            for line in str(self._normalize_url_or_path(c)).splitlines():
                norm_path = self._normalize_url_or_path(line)
                if not norm_path:
                    continue
                p = Path(norm_path)
                if p.exists():
                    resolved = str(p.resolve())
                    if resolved not in self._paths:
                        self._paths.insert(0, resolved)
                        added_any = True

        if added_any:
            self._rebuild_items()
            self._save_shelf()
            self.shelfChanged.emit()
            self.shelfGulpTriggered.emit()

    @pyqtSlot(int)
    def removeItem(self, index: int):
        if 0 <= index < len(self._paths):
            self._paths.pop(index)
            self._rebuild_items()
            self._save_shelf()
            self.shelfChanged.emit()

    @pyqtSlot()
    def clearShelf(self):
        if self._paths:
            self._paths = []
            self._items = []
            self._save_shelf()
            self.shelfChanged.emit()

    @pyqtSlot(int)
    def openItem(self, index: int):
        if 0 <= index < len(self._items):
            target_path = self._items[index]["path"]
            subprocess.Popen(
                ["xdg-open", target_path],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

    @pyqtSlot(int)
    def startDragOut(self, index: int):
        """Start native OS / Wayland drag-out for a single file card."""
        if not (0 <= index < len(self._items)):
            return
        item = self._items[index]
        self._execute_drag([item])

    @pyqtSlot()
    def startDragAll(self):
        """Start native OS / Wayland drag-out for all files currently on the shelf."""
        if not self._items:
            return
        self._execute_drag(self._items)

    def _execute_drag(self, target_items: list):
        try:
            app = QGuiApplication.instance()
            if not app:
                return

            drag = QDrag(app)
            mime = QMimeData()

            urls = [QUrl.fromLocalFile(it["path"]) for it in target_items if os.path.exists(it["path"])]
            if not urls:
                return

            mime.setUrls(urls)
            mime.setText("\n".join(it["path"] for it in target_items))
            drag.setMimeData(mime)

            # Build a clean drag preview badge pixmap
            pix = QPixmap(136, 42)
            pix.fill(Qt.GlobalColor.transparent)
            painter = QPainter(pix)
            painter.setRenderHint(QPainter.RenderHint.Antialiasing)
            painter.setBrush(QColor("#16192b"))
            painter.setPen(QColor("#38bdf8"))
            painter.drawRoundedRect(1, 1, 134, 40, 10, 10)

            painter.setPen(QColor("#ffffff"))
            font = QFont("Inter", 9, QFont.Weight.Bold)
            painter.setFont(font)
            label = (
                target_items[0]["name"][:16]
                if len(target_items) == 1
                else f"{len(target_items)} File (Shelf)"
            )
            painter.drawText(12, 25, f"📦 {label}")
            painter.end()

            drag.setPixmap(pix)
            drag.exec(Qt.DropAction.CopyAction | Qt.DropAction.MoveAction, Qt.DropAction.CopyAction)
        except Exception as e:
            print(f"[ShelfService] Warning in _execute_drag: {e}")

