#!/usr/bin/env python3
"""
Dynamic Island for KDE Plasma 6 (Wayland)
Main Application Entry Point
"""

import sys
import os
import signal
from pathlib import Path

from PyQt6.QtCore import QUrl, QObject, pyqtProperty, QTimer, QLockFile, QDir
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine

import config
from services.controller import IslandController


class AppConfig(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)
        self._top_margin = config.CONFIG.get("top_margin", 0)
        self._assets_dir = str(config.ASSETS_DIR)
        self._qml_dir = str(config.QML_DIR)
        self._auto_collapse_enabled = bool(config.CONFIG.get("auto_collapse_on_leave", True))
        self._auto_collapse_timeout = int(config.CONFIG.get("auto_collapse_leave_timeout", 3500))

    @pyqtProperty(int, constant=True)
    def topMargin(self):
        return self._top_margin

    @pyqtProperty(str, constant=True)
    def assetsDir(self):
        return self._assets_dir

    @pyqtProperty(str, constant=True)
    def qmlDir(self):
        return self._qml_dir

    @pyqtProperty(bool, constant=True)
    def autoCollapseEnabled(self):
        return self._auto_collapse_enabled

    @pyqtProperty(int, constant=True)
    def autoCollapseTimeout(self):
        return self._auto_collapse_timeout


def main():
    # Graceful exit on Ctrl+C in terminal
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    if hasattr(signal, "SIGHUP"):
        signal.signal(signal.SIGHUP, signal.SIG_IGN)

    # Force Wayland platform
    os.environ["QT_QPA_PLATFORM"] = "wayland"

    app = QGuiApplication(sys.argv)
    app.setApplicationName("Dynamic Island")
    app.setOrganizationName("KDE Dynamic Island")

    # Handle SIGTERM gracefully (e.g. systemctl stop / pkill)
    def handle_sigterm(signum, frame):
        QGuiApplication.quit()

    signal.signal(signal.SIGTERM, handle_sigterm)

    # Periodic timer to allow Python interpreter to process POSIX signals during app.exec()
    sig_timer = QTimer()
    sig_timer.timeout.connect(lambda: None)
    sig_timer.start(500)
    app._sig_timer = sig_timer

    # Single-instance lock with stale lock recovery
    lock_path = QDir.tempPath() + "/dynamic_island_kde.lock"
    lock_file = QLockFile(lock_path)
    lock_file.setStaleLockTime(3000)
    if not lock_file.tryLock(200):
        # Stale lock check
        lock_file.removeStaleLockFile()
        if not lock_file.tryLock(200):
            print("Dynamic Island is already running!")
            sys.exit(0)

    # Keep lock file reference alive
    app._lock_file = lock_file

    # Instantiate QML Engine and bridges
    engine = QQmlApplicationEngine()

    controller = IslandController()
    app_cfg = AppConfig()

    app._controller = controller
    app._app_cfg = app_cfg
    app._engine = engine

    engine.rootContext().setContextProperty("IslandController", controller)
    engine.rootContext().setContextProperty("AppConfig", app_cfg)

    # Add QML import path
    engine.addImportPath(str(config.QML_DIR))

    # Load main window
    main_qml_path = config.QML_DIR / "Main.qml"
    engine.load(QUrl.fromLocalFile(str(main_qml_path)))

    if not engine.rootObjects():
        print(f"Error: Failed to load QML from {main_qml_path}")
        sys.exit(1)

    print("Dynamic Island successfully launched on KDE Plasma Wayland!")
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
