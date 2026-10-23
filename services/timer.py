"""
Timer / Pomodoro Service
"""

from PyQt6.QtCore import QObject, pyqtSignal, QTimer


class TimerService(QObject):
    timerTick = pyqtSignal(int, str)  # remaining_seconds, "MM:SS"
    timerFinished = pyqtSignal()
    timerStateChanged = pyqtSignal(bool)  # is_running

    def __init__(self, parent=None):
        super().__init__(parent)
        self.remaining_seconds = 0
        self.total_seconds = 0
        self.is_running = False

        self.timer = QTimer(self)
        self.timer.setInterval(1000)
        self.timer.timeout.connect(self._tick)

    def start_timer(self, seconds):
        self.total_seconds = int(seconds)
        self.remaining_seconds = int(seconds)
        self.is_running = True
        self.timer.start()
        self.timerStateChanged.emit(True)
        self._emit_current()

    def toggle(self):
        if self.is_running:
            self.pause()
        elif self.remaining_seconds > 0:
            self.resume()

    def pause(self):
        self.is_running = False
        self.timer.stop()
        self.timerStateChanged.emit(False)

    def resume(self):
        if self.remaining_seconds > 0:
            self.is_running = True
            self.timer.start()
            self.timerStateChanged.emit(True)

    def reset(self):
        self.is_running = False
        self.timer.stop()
        self.remaining_seconds = 0
        self.total_seconds = 0
        self.timerStateChanged.emit(False)
        self._emit_current()

    def _tick(self):
        if self.remaining_seconds > 0:
            self.remaining_seconds -= 1
            self._emit_current()
            if self.remaining_seconds == 0:
                self.is_running = False
                self.timer.stop()
                self.timerStateChanged.emit(False)
                self.timerFinished.emit()

    def _emit_current(self):
        mins = self.remaining_seconds // 60
        secs = self.remaining_seconds % 60
        formatted = f"{mins:02d}:{secs:02d}"
        self.timerTick.emit(self.remaining_seconds, formatted)
