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
        self._top_margin = config.CONFIG.get("top_margin", 10)
        self._assets_dir = str(config.ASSETS_DIR)
        self._qml_dir = str(config.QML_DIR)

    @pyqtProperty(int, constant=True)
    def topMargin(self):
        return self._top_margin

    @pyqtProperty(str, constant=True)
    def assetsDir(self):
        return self._assets_dir

    @pyqtProperty(str, constant=True)
    def qmlDir(self):
        return self._qml_dir


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
