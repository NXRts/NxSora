"""
Unit Tests for NxSora Fase 5 Features:
1. Prayer & Sun Arc Service (services/prayer.py)
2. Audio Spectrum Visualizer (services/visualizer.py)
3. Clipboard History & Quick Paste (services/clipboard.py)
4. Audio Device Switcher (services/audio_devices.py)
5. Quick Voice Note Recorder (services/voicenote.py)
6. Color Picker (services/colorpicker.py)
7. To-Do Edit & Due Reminder (services/todo.py)
"""

import unittest
from datetime import date
from services.prayer import PrayerService, PRAYER_CITIES
from services.visualizer import AudioVisualizerService
from services.clipboard import ClipboardService
from services.audio_devices import AudioDeviceService
from services.voicenote import VoiceNoteService
from services.colorpicker import ColorPickerService
from services.todo import TodoService


class TestFase5Features(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from PyQt6.QtCore import QCoreApplication
        cls.app = QCoreApplication.instance() or QCoreApplication([])

    def test_prayer_astronomical_calculation(self):
        """Verify 100% offline mathematical prayer times calculation."""
        d = date(2026, 10, 31)
        lat, lon, tz = PRAYER_CITIES["Jakarta"]
        times = PrayerService.calculate_times_for_date(d, lat, lon, tz)

        # Validate prayer keys exist and format is HH:MM
        for key in ["imsak", "subuh", "terbit", "dzuhur", "ashar", "maghrib", "isya"]:
            self.assertIn(key, times)
            val = times[key]
            self.assertEqual(len(val), 5)
            self.assertIn(":", val)
            hh, mm = map(int, val.split(":"))
            self.assertTrue(0 <= hh <= 23)
            self.assertTrue(0 <= mm <= 59)

        # Logical sequential order: Subuh < Terbit < Dzuhur < Ashar < Maghrib < Isya
        self.assertLess(times["subuh"], times["terbit"])
        self.assertLess(times["terbit"], times["dzuhur"])
        self.assertLess(times["dzuhur"], times["ashar"])
        self.assertLess(times["ashar"], times["maghrib"])
        self.assertLess(times["maghrib"], times["isya"])

    def test_prayer_service_properties_and_checklist(self):
        svc = PrayerService()
        self.assertIn(svc.city, PRAYER_CITIES)
        self.assertTrue(0.0 <= svc.sunPosition <= 1.0)
        self.assertTrue(0 <= svc.activePrayerIndex <= 4)
        self.assertIn(svc.nextPrayerName, ["Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"])

        # Test checklist toggle
        svc.setPrayerChecked("subuh", True)
        self.assertTrue(svc.checklist.get("subuh"))
        svc.setPrayerChecked("subuh", False)
        self.assertFalse(svc.checklist.get("subuh"))

    def test_audio_visualizer_bands(self):
        vis = AudioVisualizerService()
        self.assertEqual(len(vis.bands), 12)
        for b in vis.bands:
            self.assertTrue(0.0 <= b <= 1.0)

    def test_clipboard_history_and_detection(self):
        cb = ClipboardService()
        cb._add_text_entry("https://cachyos.org")
        self.assertEqual(cb._detect_type("https://cachyos.org"), "link")

        cb._add_text_entry("def calculate_sum(a, b): return a + b")
        self.assertEqual(cb._detect_type("def calculate_sum(a, b): return a + b"), "code")

        cb._add_text_entry("#38bdf8")
        self.assertEqual(cb._detect_type("#38bdf8"), "color")

        cb._add_text_entry("Hello World Dynamic Island")
        self.assertEqual(cb._detect_type("Hello World Dynamic Island"), "text")

        self.assertGreaterEqual(cb.count, 4)

    def test_audio_device_service(self):
        dev = AudioDeviceService()
        self.assertIsInstance(dev.sinks, list)
        self.assertIsInstance(dev.sources, list)
        self.assertIsInstance(dev.currentSinkName, str)
        self.assertIsInstance(dev.currentSourceName, str)

    def test_voicenote_service(self):
        vn = VoiceNoteService()
        self.assertFalse(vn.isRecording)
        self.assertEqual(vn.durationSeconds, 0)
        self.assertEqual(vn.durationFormatted, "00:00")

    def test_colorpicker_service(self):
        cp = ColorPickerService()
        self.assertFalse(cp.isActive)
        cp._handle_picked_color("#38BDF8")
        self.assertEqual(cp.lastHex, "#38BDF8")
        self.assertEqual(cp.lastRgb, "rgb(56, 189, 248)")

    def test_todo_edit_and_due(self):
        todo = TodoService()
        init_count = todo.totalCount
        todo.addTask("Belajar Algoritma Baru", "17:30")
        self.assertEqual(todo.totalCount, init_count + 1)

        # Check due time
        new_task = todo.tasks[-1]
        self.assertEqual(new_task.get("due"), "17:30")

        # Edit task
        idx = len(todo.tasks) - 1
        todo.editTask(idx, "Belajar Algoritma DeepMind")
        self.assertEqual(todo.tasks[-1].get("text"), "Belajar Algoritma DeepMind")

        # Set new due time
        todo.setDueTime(idx, "18:00")
        self.assertEqual(todo.tasks[-1].get("due"), "18:00")

        # Clean up
        todo.removeTask(idx)
        self.assertEqual(todo.totalCount, init_count)


if __name__ == "__main__":
    unittest.main()

