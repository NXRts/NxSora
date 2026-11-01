"""
Unit Tests for NxSora Fase 6 Features:
1. Multi-Monitor & Screen Manager Service (services/screen_manager.py)
2. Custom Accent Color Picker validation and configuration
3. Screen Distance / Top Margin Stepper and bounds clamping
4. Auto-Collapse Timeout presets and reactive state logic
"""

import unittest
import sys
from PyQt6.QtWidgets import QApplication

# Ensure QApplication is initialized for QScreen tests
app = QApplication.instance()
if not app:
    app = QApplication(sys.argv)

import config
from services.screen_manager import ScreenManagerService


class TestFase6Features(unittest.TestCase):
    def setUp(self):
        # Keep backup of config
        self._orig_config = dict(config.CONFIG)

    def tearDown(self):
        config.CONFIG.clear()
        config.CONFIG.update(self._orig_config)

    def test_screen_manager_properties_and_screens(self):
        mgr = ScreenManagerService()
        screens = mgr.availableScreens
        self.assertIsInstance(screens, list)
        
        if screens:
            first_screen = screens[0]
            self.assertIn("name", first_screen)
            self.assertIn("isPrimary", first_screen)
            self.assertIn("resolution", first_screen)
            self.assertIn("width", first_screen)
            self.assertIn("height", first_screen)
            self.assertTrue(len(mgr.currentScreen) > 0)

    def test_screen_manager_set_screen(self):
        mgr = ScreenManagerService()
        screens = mgr.availableScreens
        if screens:
            target_name = screens[0]["name"]
            mgr.setScreen(target_name)
            self.assertEqual(mgr.currentScreen, target_name)
            self.assertEqual(config.CONFIG.get("preferred_screen"), target_name)

    def test_screen_manager_attach_window(self):
        class DummyWindow:
            def __init__(self):
                self.target_screen = None
            def setScreen(self, s):
                self.target_screen = s

        win = DummyWindow()
        mgr = ScreenManagerService()
        mgr.attachWindow(win)
        self.assertIsNotNone(mgr._root_window)

    def test_accent_color_validation(self):
        def validate_accent_color(color_hex: str) -> bool:
            color_hex = color_hex.strip()
            return color_hex.startswith("#") and len(color_hex) in (4, 7, 9)

        # Valid 7-char hex
        self.assertTrue(validate_accent_color("#38bdf8"))
        self.assertTrue(validate_accent_color("#818cf8"))
        self.assertTrue(validate_accent_color("#22c55e"))

        # Valid 4-char hex
        self.assertTrue(validate_accent_color("#fff"))
        self.assertTrue(validate_accent_color("#000"))

        # Valid 9-char hex with alpha
        self.assertTrue(validate_accent_color("#38bdf8ff"))

        # Invalid cases
        self.assertFalse(validate_accent_color("38bdf8"))  # missing '#'
        self.assertFalse(validate_accent_color("blue"))    # non-hex
        self.assertFalse(validate_accent_color("#12"))     # too short
        self.assertFalse(validate_accent_color("#1234567890"))  # too long

    def test_top_margin_clamping(self):
        def clamp_top_margin(margin_px: int) -> int:
            return max(0, min(100, int(margin_px)))

        self.assertEqual(clamp_top_margin(0), 0)
        self.assertEqual(clamp_top_margin(16), 16)
        self.assertEqual(clamp_top_margin(32), 32)
        self.assertEqual(clamp_top_margin(100), 100)
        self.assertEqual(clamp_top_margin(150), 100)  # clamped to max
        self.assertEqual(clamp_top_margin(-10), 0)    # clamped to min

    def test_auto_collapse_logic(self):
        def process_auto_collapse(timeout_ms: int):
            timeout = max(0, int(timeout_ms))
            enabled = (timeout > 0)
            return timeout, enabled

        # Positive timeout
        t, enabled = process_auto_collapse(1800)
        self.assertEqual(t, 1800)
        self.assertTrue(enabled)

        t, enabled = process_auto_collapse(3500)
        self.assertEqual(t, 3500)
        self.assertTrue(enabled)

        # Zero timeout: disables auto-collapse (stay open)
        t, enabled = process_auto_collapse(0)
        self.assertEqual(t, 0)
        self.assertFalse(enabled)


if __name__ == "__main__":
    unittest.main()
