"""
Privacy & Fullscreen Monitor Service
Tracks PipeWire audio capture (Microphone In-Use), V4L2 video capture (Camera In-Use),
and Fullscreen inhibitions (Video/Game Fullscreen Auto-Hide).
"""

import glob
import os
import subprocess
from PyQt6.QtCore import QObject, pyqtSignal, QTimer
from PyQt6.QtDBus import QDBusConnection, QDBusInterface
import config


class PrivacyService(QObject):
    micInUseChanged = pyqtSignal(bool)
    camInUseChanged = pyqtSignal(bool)
    fullscreenActiveChanged = pyqtSignal(bool)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.bus = QDBusConnection.sessionBus()

        self._mic_in_use = False
        self._cam_in_use = False
        self._fullscreen_active = False

        self._poll_timer = QTimer(self)
        self._poll_timer.setInterval(1200)
        self._poll_timer.timeout.connect(self._poll_status)
        self._poll_timer.start()

        # Run initial check
        self._poll_status()

    @property
    def micInUse(self) -> bool:
        return self._mic_in_use

    @property
    def camInUse(self) -> bool:
        return self._cam_in_use

    @property
    def fullscreenActive(self) -> bool:
        return self._fullscreen_active

    def _poll_status(self):
        # 1. Microphone capture check via pactl
        try:
            res = subprocess.run(
                ["pactl", "list", "source-outputs"],
                capture_output=True,
                text=True,
                timeout=0.3,
            )
            has_mic = bool(res.stdout.strip())
        except Exception:
            has_mic = False

        if has_mic != self._mic_in_use:
            self._mic_in_use = has_mic
            self.micInUseChanged.emit(self._mic_in_use)

        # 2. Camera capture check via /proc/*/fd/ pointing to /dev/video*
        has_cam = False
        for link in glob.glob("/proc/[0-9]*/fd/*"):
            try:
                target = os.readlink(link)
                if target.startswith("/dev/video"):
                    has_cam = True
                    break
            except (OSError, FileNotFoundError):
                continue

        if has_cam != self._cam_in_use:
            self._cam_in_use = has_cam
            self.camInUseChanged.emit(self._cam_in_use)

        # 3. Fullscreen / Media playback inhibition check via Solid PolicyAgent
        has_fs = False
        if config.CONFIG.get("fullscreen_autohide_enabled", True):
            try:
                iface = QDBusInterface(
                    "org.kde.Solid.PowerManagement",
                    "/org/kde/Solid/PowerManagement/PolicyAgent",
                    "org.freedesktop.DBus.Properties",
                    self.bus,
                )
                if iface.isValid():
                    reply = iface.call(
                        "Get",
                        "org.kde.Solid.PowerManagement.PolicyAgent",
                        "ActiveInhibitions",
                    )
                    if reply.arguments():
                        inhibitions = reply.arguments()[0]
                        # Each entry: ('idle', 'app_name', 'reason', 'block', 3)
                        for item in inhibitions:
                            if isinstance(item, (list, tuple)) and len(item) >= 3:
                                reason = str(item[2]).lower()
                                if any(k in reason for k in ("fullscreen", "full screen", "in full screen", "is fullscreen")):
                                    has_fs = True
                                    break
            except Exception:
                pass

        if has_fs != self._fullscreen_active:
            self._fullscreen_active = has_fs
            self.fullscreenActiveChanged.emit(self._fullscreen_active)

