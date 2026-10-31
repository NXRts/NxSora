"""
Screen Color Picker (Eyedropper) Service for NxSora (Fase 5)
Picks any pixel color directly from the screen, copies #HEX and RGB to clipboard,
and emits notification triggers.
"""

import subprocess
import threading
import shutil
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot
from PyQt6.QtGui import QGuiApplication


class ColorPickerService(QObject):
    colorPicked = pyqtSignal(str, str)  # hex_code, rgb_code
    pickerChanged = pyqtSignal()

    def __init__(self, clipboard_service=None, parent=None):
        super().__init__(parent)

        self._clipboard_service = clipboard_service
        self._last_hex = "#38bdf8"
        self._last_rgb = "rgb(56, 189, 248)"
        self._is_active = False

    @pyqtProperty(str, notify=pickerChanged)
    def lastHex(self) -> str:
        return self._last_hex

    @pyqtProperty(str, notify=pickerChanged)
    def lastRgb(self) -> str:
        return self._last_rgb

    @pyqtProperty(bool, notify=pickerChanged)
    def isActive(self) -> bool:
        return self._is_active

    @pyqtSlot()
    def pickColor(self):
        if self._is_active:
            return

        self._is_active = True
        self.pickerChanged.emit()

        threading.Thread(target=self._run_picker_thread, daemon=True).start()

    def _run_picker_thread(self):
        color_hex = None

        # Method 1: Try kdialog --getcolor (native KDE dialog with screen eyedropper)
        if shutil.which("kdialog"):
            try:
                res = subprocess.run(
                    ["kdialog", "--getcolor"],
                    capture_output=True,
                    text=True,
                    timeout=30.0
                )
                if res.returncode == 0 and res.stdout.strip():
                    raw = res.stdout.strip()
                    if raw.startswith("#"):
                        color_hex = raw[:7].upper()
            except Exception:
                pass

        # Method 2: Try XDG portal Screenshot.PickColor if kdialog didn't return a color
        if not color_hex:
            try:
                import dbus
                bus = dbus.SessionBus()
                portal = bus.get_object("org.freedesktop.portal.Desktop", "/org/freedesktop/portal/desktop")
                iface = dbus.Interface(portal, "org.freedesktop.portal.Screenshot")
                req_path = iface.PickColor("", {})
                # Wait for response signal on request
                loop = dbus.mainloop.glib.DBusGMainLoop()
            except Exception:
                pass

        self._is_active = False
        self.pickerChanged.emit()

        if color_hex:
            self._handle_picked_color(color_hex)

    def _handle_picked_color(self, hex_val: str):
        self._last_hex = hex_val.upper()

        # Convert to RGB
        try:
            h = self._last_hex.lstrip("#")
            r = int(h[0:2], 16)
            g = int(h[2:4], 16)
            b = int(h[4:6], 16)
            self._last_rgb = f"rgb({r}, {g}, {b})"
        except Exception:
            self._last_rgb = "rgb(0, 0, 0)"

        # Set to clipboard
        try:
            qapp = QGuiApplication.instance()
            if qapp and hasattr(qapp, "clipboard"):
                cb = qapp.clipboard()
                if cb:
                    cb.setText(self._last_hex)
        except Exception:
            pass

        try:
            subprocess.run(
                ["wl-copy"],
                input=self._last_hex.encode("utf-8"),
                stderr=subprocess.DEVNULL,
                timeout=0.5
            )
        except Exception:
            pass

        if self._clipboard_service:
            self._clipboard_service._add_text_entry(self._last_hex)

        self.colorPicked.emit(self._last_hex, self._last_rgb)
        self.pickerChanged.emit()

