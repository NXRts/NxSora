"""
Volume Service
Handles real-time volume & mute monitoring for PipeWire / PulseAudio via wpctl and pactl.
"""

from PyQt6.QtCore import QObject, pyqtSignal, QThread
import subprocess
import re


class VolumeWatcherThread(QThread):
    sinkChanged = pyqtSignal()

    def run(self):
        try:
            proc = subprocess.Popen(
                ["pactl", "subscribe"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True
            )
            for line in proc.stdout:
                if "sink" in line.lower() or "server" in line.lower():
                    self.sinkChanged.emit()
        except Exception:
            pass


class VolumeService(QObject):
    volumeChanged = pyqtSignal(float, bool)  # volume (0.0 - 1.0), is_muted

    def __init__(self, parent=None):
        super().__init__(parent)
        self.volume = 0.5
        self.is_muted = False
        
        # Initial read
        self._read_volume()

        # Start watcher thread
        self.watcher = VolumeWatcherThread(self)
        self.watcher.sinkChanged.connect(self._read_volume)
        self.watcher.start()

    def _read_volume(self):
        try:
            out = subprocess.check_output(
                ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"],
                stderr=subprocess.DEVNULL
            ).decode().strip()
            
            # Formats:
            # Volume: 0.49
            # Volume: 0.49 [MUTED]
            parts = out.split()
            if len(parts) >= 2:
                vol = float(parts[1])
                muted = "[MUTED]" in out
                if abs(vol - self.volume) > 0.005 or muted != self.is_muted:
                    self.volume = vol
                    self.is_muted = muted
                    self.volumeChanged.emit(self.volume, self.is_muted)
        except Exception:
            pass

    def set_volume(self, value):
        """Set volume to float 0.0 - 1.0"""
        val = max(0.0, min(1.0, float(value)))
        try:
            subprocess.run(
                ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", f"{val:.2f}"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            self.volume = val
            self.volumeChanged.emit(self.volume, self.is_muted)
        except Exception:
            pass

    def change_volume(self, delta):
        """Increase or decrease volume by delta (e.g. +0.05 or -0.05)"""
        new_vol = max(0.0, min(1.0, self.volume + delta))
        self.set_volume(new_vol)

    def toggle_mute(self):
        try:
            subprocess.run(
                ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            self._read_volume()
        except Exception:
            pass
