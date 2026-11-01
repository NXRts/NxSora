"""
Multi-Monitor & Screen Manager Service for NxSora (Fase 6)
Scans connected monitors, tracks primary vs secondary screens,
and allows dynamic on-the-fly moving of the Dynamic Island to any display.
"""

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot
from PyQt6.QtWidgets import QApplication
import config


class ScreenManagerService(QObject):
    screenChanged = pyqtSignal(str)
    screensListChanged = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._root_window = None
        self._preferred_screen = config.CONFIG.get("preferred_screen", "")
        self._current_screen = ""
        self._screens = []

        self.refreshScreens()

    def attachWindow(self, window):
        """Attaches root QQuickWindow to manage screen placement."""
        self._root_window = window
        self.applyPreferredScreen()

    @pyqtProperty(str, notify=screenChanged)
    def currentScreen(self) -> str:
        return self._current_screen

    @pyqtProperty(list, notify=screensListChanged)
    def availableScreens(self) -> list:
        return self._screens

    @pyqtSlot()
    def refreshScreens(self):
        """Scans QApplication.screens() and builds structured monitor metadata."""
        app = QApplication.instance()
        screens_data = []

        if app:
            primary = app.primaryScreen()
            for idx, s in enumerate(app.screens()):
                name = s.name() or f"Screen-{idx + 1}"
                geom = s.geometry()
                is_pri = (s == primary)
                screens_data.append({
                    "name": name,
                    "isPrimary": is_pri,
                    "width": geom.width(),
                    "height": geom.height(),
                    "resolution": f"{geom.width()}x{geom.height()}",
                    "label": f"{name} ({'Utama' if is_pri else 'Sekunder'})"
                })

        self._screens = screens_data
        self.screensListChanged.emit()

        # Update current screen name
        if not self._current_screen and self._screens:
            matching = next((s for s in self._screens if s["name"] == self._preferred_screen), None)
            if matching:
                self._current_screen = matching["name"]
            else:
                self._current_screen = self._screens[0]["name"]
            self.screenChanged.emit(self._current_screen)

    @pyqtSlot(str)
    def setScreen(self, screen_name: str):
        """Switches Dynamic Island to the specified monitor."""
        if not screen_name:
            return

        app = QApplication.instance()
        if not app:
            return

        target_screen = None
        for idx, s in enumerate(app.screens()):
            s_name = s.name() or f"Screen-{idx + 1}"
            if s_name == screen_name:
                target_screen = s
                break

        if target_screen:
            self._current_screen = screen_name
            self._preferred_screen = screen_name
            config.CONFIG["preferred_screen"] = screen_name
            config.save_user_config(config.CONFIG)

            if self._root_window:
                try:
                    self._root_window.setScreen(target_screen)
                except Exception as e:
                    print(f"[NxSora Screen] Warning setting window screen: {e}")

            self.screenChanged.emit(self._current_screen)

    def applyPreferredScreen(self):
        if not self._root_window:
            return

        app = QApplication.instance()
        if not app:
            return

        target = None
        if self._preferred_screen:
            for idx, s in enumerate(app.screens()):
                s_name = s.name() or f"Screen-{idx + 1}"
                if s_name == self._preferred_screen:
                    target = s
                    break

        if not target and app.screens():
            target = app.primaryScreen() or app.screens()[0]

        if target:
            idx = app.screens().index(target) if target in app.screens() else 0
            self._current_screen = target.name() or f"Screen-{idx + 1}"
            try:
                self._root_window.setScreen(target)
            except Exception:
                pass
            self.screenChanged.emit(self._current_screen)
