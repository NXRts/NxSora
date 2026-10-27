"""
Timer / Pomodoro Service (Nusa Focus Timer Style)
Supports Focus Time (25:00), Short Break (05:00), circular ring progress ratio,
and non-blocking soft chime audio notification when a session completes.
"""

import os
import subprocess
from PyQt6.QtCore import QObject, pyqtSignal, QTimer


class TimerService(QObject):
    timerTick = pyqtSignal(int, str)          # remaining_seconds, "MM:SS"
    timerFinished = pyqtSignal(str)           # completed_mode ("focus" or "short_break")
    timerStateChanged = pyqtSignal(bool)      # is_running

    MODE_DURATIONS = {
        "focus": 25 * 60,        # 25:00
        "short_break": 5 * 60,   # 05:00
    }

    def __init__(self, parent=None):
        super().__init__(parent)
        self.mode = "focus"
        self.total_seconds = self.MODE_DURATIONS["focus"]
        self.remaining_seconds = self.total_seconds
        self.is_running = False

        self.timer = QTimer(self)
        self.timer.setInterval(1000)
        self.timer.timeout.connect(self._tick)

    @property
    def progress_ratio(self) -> float:
        if self.total_seconds <= 0:
            return 1.0
        return min(1.0, max(0.0, self.remaining_seconds / float(self.total_seconds)))

    @property
    def mode_label(self) -> str:
        if self.mode == "short_break":
            return "Short Break"
        return "Focus Time"

    def set_mode(self, mode: str, auto_start: bool = False):
        if mode not in self.MODE_DURATIONS:
            mode = "focus"
        self.mode = mode
        self.total_seconds = self.MODE_DURATIONS[mode]
        self.remaining_seconds = self.total_seconds
        if auto_start:
            self.is_running = True
            self.timer.start()
            self.timerStateChanged.emit(True)
        else:
            self.is_running = False
            self.timer.stop()
            self.timerStateChanged.emit(False)
        self._emit_current()

    def start_timer(self, seconds: int):
        sec = int(seconds)
        if sec == 300:
            self.mode = "short_break"
        elif sec == 1500:
            self.mode = "focus"
        self.total_seconds = max(1, sec)
        self.remaining_seconds = self.total_seconds
        self.is_running = True
        self.timer.start()
        self.timerStateChanged.emit(True)
        self._emit_current()

    def toggle(self):
        if self.is_running:
            self.pause()
        else:
            if self.remaining_seconds <= 0:
                self.remaining_seconds = self.total_seconds or self.MODE_DURATIONS.get(self.mode, 1500)
            self.resume()

    def pause(self):
        self.is_running = False
        self.timer.stop()
        self.timerStateChanged.emit(False)
        self._emit_current()

    def resume(self):
        if self.remaining_seconds > 0:
            self.is_running = True
            self.timer.start()
            self.timerStateChanged.emit(True)
            self._emit_current()

    def reset(self):
        self.is_running = False
        self.timer.stop()
        self.total_seconds = self.MODE_DURATIONS.get(self.mode, 1500)
        self.remaining_seconds = self.total_seconds
        self.timerStateChanged.emit(False)
        self._emit_current()

    @staticmethod
    def _play_soft_chime():
        """Play a non-blocking freedesktop notification chime."""
        sound_candidates = [
            "/usr/share/sounds/freedesktop/stereo/complete.oga",
            "/usr/share/sounds/freedesktop/stereo/bell.oga",
            "/usr/share/sounds/ocean/stereo/outcome-success.oga",
        ]
        for snd in sound_candidates:
            if os.path.exists(snd):
                try:
                    subprocess.Popen(
                        ["paplay", snd],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                    )
                    return
                except Exception:
                    break
        try:
            subprocess.Popen(
                ["canberra-gtk-play", "-i", "complete"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except Exception:
            pass

    def _tick(self):
        if self.remaining_seconds > 0:
            self.remaining_seconds -= 1
            self._emit_current()
            if self.remaining_seconds == 0:
                completed_mode = self.mode
                self.is_running = False
                self.timer.stop()
                self.timerStateChanged.emit(False)
                self._play_soft_chime()
                self.timerFinished.emit(completed_mode)

                # Prepare next complementary session (Focus <-> Short Break)
                next_mode = "short_break" if completed_mode == "focus" else "focus"
                self.mode = next_mode
                self.total_seconds = self.MODE_DURATIONS[next_mode]
                self.remaining_seconds = self.total_seconds
                self._emit_current()

    def _emit_current(self):
        mins = self.remaining_seconds // 60
        secs = self.remaining_seconds % 60
        formatted = f"{mins:02d}:{secs:02d}"
        self.timerTick.emit(self.remaining_seconds, formatted)
