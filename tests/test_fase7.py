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
        self.assertFalse(
            component.isError(),
            f"QML Component errors: {[e.toString() for e in component.errors()]}"
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


if __name__ == "__main__":
    unittest.main()

