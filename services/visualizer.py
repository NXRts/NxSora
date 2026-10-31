"""
Real-time PipeWire Audio Spectrum Visualizer Service for NxSora (Fase 5)
Captures system audio output monitor via ffmpeg PCM pipe, computes 12-band FFT spectrum,
and emits normalized frequency magnitudes [0.0..1.0] for reactive equalizer animations.
"""

import os
import subprocess
import threading
import time
import numpy as np

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot


class AudioVisualizerService(QObject):
    spectrumChanged = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._num_bands = 12
        self._bands = [0.08] * self._num_bands
        self._smooth_bands = [0.08] * self._num_bands
        self._is_enabled = False
        self._is_running = False
        self._thread = None
        self._proc = None

        # Precompute logarithmic band index ranges for 16kHz sample rate & 512 FFT
        self._sample_rate = 16000
        self._n_fft = 512
        freqs = np.fft.rfftfreq(self._n_fft, 1.0 / self._sample_rate)
        band_edges = np.logspace(np.log10(60), np.log10(7000), self._num_bands + 1)
        self._band_indices = []
        for i in range(self._num_bands):
            low, high = band_edges[i], band_edges[i + 1]
            idx = np.where((freqs >= low) & (freqs < high))[0]
            if len(idx) == 0:
                idx = np.array([min(len(freqs) - 1, int(round(low / (self._sample_rate / self._n_fft))))])
            self._band_indices.append(idx)

    @pyqtProperty(list, notify=spectrumChanged)
    def bands(self) -> list:
        return self._smooth_bands

    @pyqtProperty(bool)
    def isEnabled(self) -> bool:
        return self._is_enabled

    @pyqtSlot(bool)
    def setEnabled(self, enabled: bool):
        if self._is_enabled == enabled:
            return
        self._is_enabled = enabled
        if self._is_enabled:
            self._start_worker()
        else:
            self._stop_worker()

    def _start_worker(self):
        if self._is_running:
            return
        self._is_running = True
        self._thread = threading.Thread(target=self._worker_loop, daemon=True)
        self._thread.start()

    def _stop_worker(self):
        self._is_running = False
        if self._proc:
            try:
                self._proc.terminate()
            except Exception:
                pass
            self._proc = None

    def _worker_loop(self):
        cmd = [
            "ffmpeg",
            "-nostdin",
            "-loglevel", "quiet",
            "-f", "pulse",
            "-i", "default.monitor",
            "-f", "s16le",
            "-ac", "1",
            "-ar", str(self._sample_rate),
            "pipe:1"
        ]

        try:
            self._proc = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                bufsize=1024
            )
        except Exception:
            self._proc = None

        bytes_to_read = self._n_fft * 2  # 512 samples * 2 bytes (s16le)

        while self._is_running:
            if not self._proc or self._proc.poll() is not None:
                # If ffmpeg couldn't open default.monitor, fallback to gentle breathing bars
                time.sleep(0.05)
                continue

            try:
                raw = self._proc.stdout.read(bytes_to_read)
                if not raw or len(raw) < bytes_to_read:
                    time.sleep(0.02)
                    continue

                samples = np.frombuffer(raw, dtype=np.int16).astype(np.float32)
                # Apply Hann window to reduce spectral leakage
                windowed = samples * np.hanning(len(samples))
                fft_vals = np.abs(np.fft.rfft(windowed))

                # Normalize FFT magnitudes
                max_val = np.max(fft_vals) if len(fft_vals) > 0 else 1.0
                scale = max(1000.0, max_val)

                new_bands = []
                for idx in self._band_indices:
                    val = np.mean(fft_vals[idx]) / scale if len(idx) > 0 else 0.0
                    val = min(1.0, max(0.05, float(val)))
                    new_bands.append(val)

                # Exponential smoothing (attack fast, decay smooth)
                for i in range(self._num_bands):
                    target = new_bands[i]
                    cur = self._smooth_bands[i]
                    if target > cur:
                        self._smooth_bands[i] = round(cur * 0.4 + target * 0.6, 3)
                    else:
                        self._smooth_bands[i] = round(cur * 0.75 + target * 0.25, 3)

                self.spectrumChanged.emit()

            except Exception:
                time.sleep(0.05)

        if self._proc:
            try:
                self._proc.terminate()
            except Exception:
                pass
            self._proc = None
