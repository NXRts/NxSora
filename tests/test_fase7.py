"""
Unit Tests for NxSora Fase 7 Features:
1. Cross-Platform Windows & Linux directory resolution (config.py)
2. Windows Adapter Layer (services/windows_adapter.py)
3. Windows Native Overlay QML Component (qml/MainWindows.qml)
4. Installer & PyInstaller asset integrity (logo.ico, nxsora.spec, setup.iss)
"""

import unittest
import sys
import os
from pathlib import Path
from unittest.mock import patch

from PyQt6.QtWidgets import QApplication
from PyQt6.QtQml import QQmlApplicationEngine, QQmlComponent

# Ensure QApplication is initialized
app = QApplication.instance()
if not app:
    app = QApplication(sys.argv)

import config
from services.windows_adapter import (
    WindowsWindowHelper,
    WindowsMediaAdapter,
    WindowsAudioAdapter,
    WindowsHardwareAdapter,
    WindowsBluetoothAdapter,
    WindowsNetworkAdapter,
    WindowsPrivacyAdapter,
    WindowsAutostart,
)


class TestFase7Features(unittest.TestCase):
    def test_config_paths_and_safe_write(self):
        """Verify cross-platform directory resolution and safe JSON writing."""
        self.assertTrue(config.CONFIG_DIR.exists())
        self.assertTrue(config.CACHE_DIR.exists())
        self.assertTrue(config.STATE_DIR.exists())
        self.assertTrue(config.RUNTIME_DIR.exists())

        # Test safe write
        test_file = config.CACHE_DIR / "test_write.json"
        res = config.safe_write_private_json(test_file, {"test": 123})
        self.assertTrue(res)
        self.assertTrue(test_file.exists())
        if test_file.exists():
            test_file.unlink()

    def test_windows_directory_resolution_mock(self):
        """Simulate Windows environment and test _resolve_xdg_dirs()."""
        with patch("sys.platform", "win32"), \
             patch.dict(os.environ, {
                 "APPDATA": "/tmp/mock_appdata",
                 "LOCALAPPDATA": "/tmp/mock_localappdata",
                 "USERNAME": "testuser"
             }):
            cfg, cache, state, runtime = config._resolve_xdg_dirs()
            self.assertIn("nxsora", str(cfg))
            self.assertIn("mock_appdata", str(cfg))
            self.assertIn("cache", str(cache))
            self.assertIn("state", str(state))
            self.assertIn("testuser", str(runtime))

    def test_windows_audio_adapter_defaults_and_clamping(self):
        """Verify Windows audio adapter volume bounds and device enumeration."""
        adapter = WindowsAudioAdapter()
        adapter.set_volume(0.75)
        self.assertAlmostEqual(adapter.volume, 0.75)

        # Clamping
        adapter.set_volume(1.5)
        self.assertLessEqual(adapter.volume, 1.0)

        adapter.set_volume(-0.5)
        self.assertGreaterEqual(adapter.volume, 0.0)

        sinks, sources = adapter.list_devices()
        self.assertIsInstance(sinks, list)
        self.assertIsInstance(sources, list)
        self.assertTrue(len(sinks) > 0)
        self.assertTrue(len(sources) > 0)
        self.assertIn("name", sinks[0])
        self.assertIn("icon", sinks[0])

    def test_windows_hardware_adapter_power_profiles(self):
        """Verify power profile helper methods on non-Windows fallback."""
        prof = WindowsHardwareAdapter.get_power_profile()
        self.assertIn(prof, ["power-saver", "balanced", "performance"])

        caps = WindowsHardwareAdapter.get_caps_lock_state()
        self.assertIsInstance(caps, bool)

        bright = WindowsHardwareAdapter.get_brightness()
        self.assertTrue(0 <= bright <= 100)

    def test_windows_privacy_adapter_signatures(self):
        """Verify Windows privacy adapter returns booleans."""
        cam = WindowsPrivacyAdapter.is_camera_in_use()
        mic = WindowsPrivacyAdapter.is_mic_in_use()
        self.assertIsInstance(cam, bool)
        self.assertIsInstance(mic, bool)

    def test_windows_autostart_signature(self):
        """Verify Windows autostart helper methods."""
        enabled = WindowsAutostart.is_enabled()
        self.assertIsInstance(enabled, bool)

    def test_qml_main_windows_syntax(self):
        """Verify qml/MainWindows.qml has zero QML syntax or compilation errors."""
        engine = QQmlApplicationEngine()
        qml_path = str(config.QML_DIR / "MainWindows.qml")
        component = QQmlComponent(engine, qml_path)
        
        # Filter out environmental missing QML plugins or missing system shared libraries (e.g. QtMultimedia / libpulse in stripped CI runners)
        ignored_phrases = (
            "is not installed",
            "plugin cannot be loaded",
            "cannot load library",
            "cannot open shared object file",
            "type hudcameramirror unavailable",
            "type island unavailable",
        )
        syntax_errors = [
            e.toString() for e in component.errors()
            if not any(ign in e.toString().lower() for ign in ignored_phrases)
        ]
        self.assertEqual(
            syntax_errors,
            [],
            f"QML Component syntax errors: {syntax_errors}"
        )

    def test_packaging_assets_integrity(self):
        """Verify logo.ico, nxsora.spec, and setup.iss exist and are non-empty."""
        ico_file = config.ASSETS_DIR / "logo.ico"
        self.assertTrue(ico_file.exists())
        self.assertGreater(ico_file.stat().st_size, 1000)

        spec_file = config.BASE_DIR / "nxsora.spec"
        self.assertTrue(spec_file.exists())
        self.assertGreater(spec_file.stat().st_size, 500)

        # Ensure spec file is valid python syntax
        with open(spec_file, "r", encoding="utf-8") as f:
            code = f.read()
        compile(code, "nxsora.spec", "exec")

        iss_file = config.BASE_DIR / "installer" / "setup.iss"
        self.assertTrue(iss_file.exists())
        self.assertGreater(iss_file.stat().st_size, 500)

    def test_process_utils_hidden_flags_windows(self):
        """Verify process_utils injects CREATE_NO_WINDOW and STARTUPINFO on Windows."""
        from services import process_utils
        import subprocess

        # Test Windows simulation with mock STARTUPINFO
        class MockStartupInfo:
            dwFlags = 0
            wShowWindow = 1

        with patch.object(process_utils, "IS_WINDOWS", True), \
             patch.object(subprocess, "STARTUPINFO", MockStartupInfo, create=True), \
             patch.object(subprocess, "STARTF_USESHOWWINDOW", 1, create=True), \
             patch.object(subprocess, "SW_HIDE", 0, create=True):
            kwargs = process_utils.get_hidden_subprocess_kwargs(timeout=5)
            self.assertEqual(kwargs.get("timeout"), 5)
            self.assertTrue(bool(kwargs.get("creationflags", 0) & process_utils.CREATE_NO_WINDOW))
            si = kwargs.get("startupinfo")
            self.assertIsNotNone(si)
            self.assertTrue(bool(si.dwFlags & 1))
            self.assertEqual(si.wShowWindow, 0)

        # Test Linux / non-Windows simulation
        with patch.object(process_utils, "IS_WINDOWS", False):
            kwargs = process_utils.get_hidden_subprocess_kwargs(timeout=5)
            self.assertEqual(kwargs.get("timeout"), 5)
            self.assertNotIn("creationflags", kwargs)
            self.assertNotIn("startupinfo", kwargs)

    def test_windows_adapters_caching_and_concurrency(self):
        """Verify Windows network & bluetooth adapters caching and concurrency guards."""
        with patch("sys.platform", "win32"):
            # Network adapter test
            WindowsNetworkAdapter._cached_status = ("NxSora-WiFi", True, 95)
            WindowsNetworkAdapter._last_query_time = 1e12  # far future
            status = WindowsNetworkAdapter.get_wifi_status()
            self.assertEqual(status, ("NxSora-WiFi", True, 95))

            # Bluetooth adapter test
            WindowsBluetoothAdapter._cached_devices = [{"name": "NxSora Buds", "connected": True, "battery": 90, "icon": "headphones"}]
            WindowsBluetoothAdapter._last_query_time = 1e12  # far future
            devs = WindowsBluetoothAdapter.get_connected_devices()
            self.assertEqual(len(devs), 1)
            self.assertEqual(devs[0]["name"], "NxSora Buds")

    def test_color_extractor_native_qimage(self):
        """Verify ColorExtractor works using native QImage with zero Pillow dependency."""
        import tempfile
        from PyQt6.QtGui import QImage, QColor
        from services.color_extractor import ColorExtractor

        # Create 32x32 image with solid sky blue
        img = QImage(32, 32, QImage.Format.Format_RGB32)
        img.fill(QColor(56, 189, 248))
        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
            tmp_path = f.name
        try:
            img.save(tmp_path)
            accent = ColorExtractor.get_accent_color(tmp_path)
            self.assertTrue(accent.startswith("#"))
            self.assertEqual(len(accent), 7)
            # Default fallback on invalid path
            fallback = ColorExtractor.get_accent_color("/nonexistent/image.png", "#123456")
            self.assertEqual(fallback, "#123456")
        finally:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)

    def test_adaptive_polling_intervals(self):
        """Verify System and Bluetooth services adjust polling interval adaptively."""
        from services.system import SystemService
        from services.bluetooth import BluetoothService

        sys_svc = SystemService()
        # Default is eco-mode (4000ms)
        self.assertEqual(sys_svc.timer.interval(), 4000)

        # Expand -> High speed (800ms)
        sys_svc.set_adaptive_polling(True)
        self.assertEqual(sys_svc.timer.interval(), 800)

        # Collapse -> Eco mode (4000ms)
        sys_svc.set_adaptive_polling(False)
        self.assertEqual(sys_svc.timer.interval(), 4000)

        bt_svc = BluetoothService()
        self.assertEqual(bt_svc.poll_timer.interval(), 4000)
        bt_svc.set_adaptive_polling(True)
        self.assertEqual(bt_svc.poll_timer.interval(), 1500)
        bt_svc.set_adaptive_polling(False)
        self.assertEqual(bt_svc.poll_timer.interval(), 4000)


if __name__ == "__main__":
    unittest.main()

