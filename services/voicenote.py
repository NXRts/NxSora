"""
Quick Voice Note Recorder Service for NxSora (Fase 5)
Records audio notes from microphone and automatically saves to ~/Music/NxSora_VoiceNotes/
and adds them directly into the Shelf (Rak File) ready for drag-and-drop.
"""

import os
import subprocess
import time
from datetime import datetime
from pathlib import Path

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer
import config


class VoiceNoteService(QObject):
    recordingStateChanged = pyqtSignal()
    recordingFinished = pyqtSignal(str)

    def __init__(self, shelf_service=None, parent=None):
        super().__init__(parent)

        self._shelf_service = shelf_service
        self._is_recording = False
        self._start_time = 0.0
        self._duration_sec = 0
        self._proc = None
        self._current_file = None

        self._save_dir = Path.home() / "Music" / "NxSora_VoiceNotes"
        self._save_dir.mkdir(parents=True, exist_ok=True)

        self._timer = QTimer(self)
        self._timer.setInterval(1000)
        self._timer.timeout.connect(self._on_tick)

    @pyqtProperty(bool, notify=recordingStateChanged)
    def isRecording(self) -> bool:
        return self._is_recording

    @pyqtProperty(int, notify=recordingStateChanged)
    def durationSeconds(self) -> int:
        return self._duration_sec

    @pyqtProperty(str, notify=recordingStateChanged)
    def durationFormatted(self) -> str:
        mm = self._duration_sec // 60
        ss = self._duration_sec % 60
        return f"{mm:02d}:{ss:02d}"

    @pyqtProperty(str, notify=recordingStateChanged)
    def lastSavedPath(self) -> str:
        return str(self._current_file) if self._current_file else ""

    def _on_tick(self):
        if self._is_recording:
            self._duration_sec = int(time.time() - self._start_time)
            self.recordingStateChanged.emit()

    @pyqtSlot()
    def toggleRecording(self):
        if self._is_recording:
            self.stopRecording()
        else:
            self.startRecording()

    @pyqtSlot()
    def startRecording(self):
        if self._is_recording:
            return

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self._current_file = self._save_dir / f"VoiceNote_{timestamp}.m4a"

        cmd = [
            "ffmpeg",
            "-y",
            "-f", "pulse",
            "-i", "default",
            "-c:a", "aac",
            "-b:a", "128k",
            str(self._current_file)
        ]

        try:
            self._proc = subprocess.Popen(
                cmd,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            self._is_recording = True
            self._start_time = time.time()
            self._duration_sec = 0
            self._timer.start()
            self.recordingStateChanged.emit()
        except Exception:
            self._is_recording = False
            self._proc = None

    @pyqtSlot()
    def stopRecording(self):
        if not self._is_recording:
            return

        self._is_recording = False
        self._timer.stop()

        if self._proc:
            try:
                # Send SIGINT to ffmpeg so it cleanly writes container headers
                self._proc.terminate()
                self._proc.wait(timeout=1.5)
            except Exception:
                try:
                    self._proc.kill()
                except Exception:
                    pass
            self._proc = None

        if self._current_file and self._current_file.exists():
            file_path_str = str(self._current_file)
            # Check minimum size (ensure non-empty file)
            if self._current_file.stat().st_size > 1024:
                # Add to ShelfService automatically!
                if self._shelf_service:
                    try:
                        self._shelf_service.addItem(file_path_str)
                    except Exception:
                        pass
                self.recordingFinished.emit(file_path_str)

        self.recordingStateChanged.emit()

    @pyqtSlot()
    def cancelRecording(self):
        if not self._is_recording:
            return

        self._is_recording = False
        self._timer.stop()

        if self._proc:
            try:
                self._proc.kill()
            except Exception:
                pass
            self._proc = None

        if self._current_file and self._current_file.exists():
            try:
                self._current_file.unlink()
            except Exception:
                pass

        self.recordingStateChanged.emit()
