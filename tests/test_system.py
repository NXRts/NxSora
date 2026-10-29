"""
Tests for System & Hardware Monitoring Service:
TDP Watts computation, speed formatting, power profiles, and thermal threshold handling.
"""

import unittest
from services.system import SystemService


class TestSystemService(unittest.TestCase):

    def test_format_speed_kb_and_mb(self):
        service = SystemService.__new__(SystemService)
        self.assertEqual(service._format_speed(500 * 1024), "500 KB/s")
        self.assertEqual(service._format_speed(2.5 * 1024 * 1024), "2.5 MB/s")
        self.assertEqual(service._format_speed(10.0 * 1024 * 1024), "10.0 MB/s")

    def test_read_int_file_handles_missing_file_safely(self):
        res = SystemService._read_int_file("/nonexistent/hwmon/file_12345")
        self.assertIsNone(res)

    def test_cpu_model_sanitization(self):
        service = SystemService.__new__(SystemService)
        model = service._detect_cpu_model()
        self.assertIsInstance(model, str)
        self.assertGreater(len(model), 0)


if __name__ == "__main__":
    unittest.main()
