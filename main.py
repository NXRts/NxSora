#!/usr/bin/env python3
"""
NxSora (Nx空) — The Living Sky-Notch for KDE Plasma 6 (Wayland)
Main Application Entry Point, Single-Instance Guardian & System Tray Manager
"""

import sys
import os
import signal
from pathlib import Path

from PyQt6.QtCore import QUrl, QObject, pyqtProperty, pyqtSlot, QTimer, QLockFile, QDir
from PyQt6.QtGui import QIcon
from PyQt6.QtWidgets import QApplication, QSystemTrayIcon, QMenu
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtDBus import QDBusConnection, QDBusInterface

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


class IslandDBusService(QObject):
    """Exposes global D-Bus interface org.nxsora.Island at /Island."""

    def __init__(self, controller, parent=None):
        super().__init__(parent)
        self.c = controller

    @pyqtSlot()
    def toggle(self):
        self.c.toggleExpand()

    @pyqtSlot()
    def expand(self):
        self.c.expandHub()

    @pyqtSlot()
    def collapse(self):
        self.c.collapse()

    @pyqtSlot()
    def settings(self):
        self.c.openSettingsView()

    @pyqtSlot()
    def next(self):
        next_idx = (self.c._active_hub_page + 1) % 9
        self.c.openHubPage(next_idx)

    @pyqtSlot()
    def prev(self):
        prev_idx = (self.c._active_hub_page - 1) % 9
        self.c.openHubPage(prev_idx)

    @pyqtSlot()
    def mascot(self):
        self.c.toggleMascotMode()

    @pyqtSlot()
    def dnd(self):
        self.c.toggleNotifDnd()

    @pyqtSlot()
    def wifiPeek(self):
        self.c.triggerWifiPeekDemo()

    @pyqtSlot()
    def lowBatteryPeek(self):
        self.c.triggerLowBatteryDemo()

    @pyqtSlot()
    def camera(self):
        self.c.openCameraMirror()

    @pyqtSlot()
    def mirror(self):
        self.c.openCameraMirror()

    @pyqtSlot()
    def weather(self):
        self.c.refreshWeather()


def main():
    # Graceful exit on Ctrl+C in terminal
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    if hasattr(signal, "SIGHUP"):
        signal.signal(signal.SIGHUP, signal.SIG_IGN)

    # Force Wayland platform
    os.environ["QT_QPA_PLATFORM"] = "wayland"

    app = QApplication(sys.argv)
    app.setApplicationName("NxSora")
    app.setApplicationDisplayName("NxSora (Nx空)")
    app.setOrganizationName("NXRts")

    # CLI Forwarding to running instance via D-Bus
    cli_flags = {"--toggle", "--settings", "--expand", "--collapse", "--next", "--prev", "--dnd", "--mascot", "--camera", "--mirror", "--weather"}
    invoked = [arg for arg in sys.argv[1:] if arg in cli_flags]
    if invoked:
        probe_bus = QDBusConnection.sessionBus()
        if probe_bus.isConnected():
            iface = QDBusInterface("org.nxsora.Island", "/Island", "", probe_bus)
            if iface.isValid():
                for flag in invoked:
                    method_name = flag.lstrip("-")
                    iface.call(method_name)
                print(f"[NxSora CLI] Forwarded action(s) {invoked} to active instance.")
                sys.exit(0)

    # Set Window Icon
    logo_path = config.ASSETS_DIR / "logo.svg"
    if logo_path.exists():
        app.setWindowIcon(QIcon(str(logo_path)))

    # Handle SIGTERM gracefully (e.g. systemctl stop / pkill)
    def handle_sigterm(signum, frame):
        QApplication.quit()

    signal.signal(signal.SIGTERM, handle_sigterm)

    # Periodic timer to allow Python interpreter to process POSIX signals during app.exec()
    sig_timer = QTimer()
    sig_timer.timeout.connect(lambda: None)
    sig_timer.start(500)
    app._sig_timer = sig_timer

    # Single-instance lock in XDG_RUNTIME_DIR
    lock_path = str(config.RUNTIME_DIR / "nxsora.lock")
    lock_file = QLockFile(lock_path)
    lock_file.setStaleLockTime(3000)
    if not lock_file.tryLock(200):
        lock_file.removeStaleLockFile()
        if not lock_file.tryLock(200):
            print("NxSora is already running!")
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

    # Register Global D-Bus service org.nxsora.Island at /Island
    session_bus = QDBusConnection.sessionBus()
    dbus_service = IslandDBusService(controller, app)
    app._dbus_service = dbus_service
    session_bus.registerService("org.nxsora.Island")
    session_bus.registerObject("/Island", dbus_service, QDBusConnection.RegisterOption.ExportAllSlots)

    # Initial CLI action trigger
    if "--settings" in sys.argv:
        controller.openSettingsView()
    elif "--expand" in sys.argv or "--toggle" in sys.argv:
        controller.expandHub()

    # Setup System Tray Icon
    if QSystemTrayIcon.isSystemTrayAvailable():
        tray = QSystemTrayIcon(app)
        if logo_path.exists():
            tray.setIcon(QIcon(str(logo_path)))
        else:
            tray.setIcon(QIcon(str(config.ASSETS_DIR / "settings.svg")))
        tray.setToolTip("NxSora (Nx空) — The Living Sky-Notch")

        menu = QMenu()

        title_act = menu.addAction("🌌 NxSora v0.1.0 (Aktif)")
        title_act.setEnabled(False)
        menu.addSeparator()

        toggle_act = menu.addAction("Buka / Tutup Hub")
        toggle_act.triggered.connect(controller.toggleExpand)

        mascot_act = menu.addAction("Mode Maskot (Mata)")
        mascot_act.setCheckable(True)
        mascot_act.setChecked(controller.mascotMode)
        mascot_act.triggered.connect(controller.toggleMascotMode)
        controller.mascotModeChanged.connect(mascot_act.setChecked)

        pin_act = menu.addAction("Sematkan Hub (Pin)")
        pin_act.setCheckable(True)
        pin_act.setChecked(controller.isPinned)
        pin_act.triggered.connect(controller.togglePin)
        controller.isPinnedChanged.connect(pin_act.setChecked)

        dnd_act = menu.addAction("Jangan Ganggu (DND)")
        dnd_act.setCheckable(True)
        dnd_act.setChecked(controller.notifications.dnd_enabled)
        dnd_act.triggered.connect(controller.toggleNotifDnd)

        menu.addSeparator()

        def open_settings_page():
            controller.openSettingsView()

        settings_act = menu.addAction("⚙️ Pengaturan...")
        settings_act.triggered.connect(open_settings_page)

        menu.addSeparator()

        def restart_app():
            import subprocess
            subprocess.Popen([str(config.BASE_DIR / "run.sh"), "--restart"])

        restart_act = menu.addAction("🔄 Restart NxSora")
        restart_act.triggered.connect(restart_app)

        quit_act = menu.addAction("❌ Keluar")
        quit_act.triggered.connect(QApplication.quit)

        tray.setContextMenu(menu)
        tray.activated.connect(
            lambda reason: controller.toggleExpand()
            if reason == QSystemTrayIcon.ActivationReason.Trigger
            else None
        )
        tray.show()
        app._tray = tray

    print("🌌 NxSora (Nx空) successfully launched on KDE Plasma Wayland!")
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
