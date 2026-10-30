"""
Tests for KDE Connect Quick Share Service (Fase 4):
CLI parsing, reachable device discovery, and safe fallback handling.
"""

import unittest
from services.kdeconnect import KdeConnectService


class TestKdeConnectService(unittest.TestCase):

    def test_parse_device_output_single_device(self):
        sample_output = "- POCO X7 PRO: a6a213e4b476e33e (paired and reachable)\n"
        devs = KdeConnectService.parse_device_output(sample_output)
        self.assertEqual(len(devs), 1)
        self.assertEqual(devs[0]["name"], "POCO X7 PRO")
        self.assertEqual(devs[0]["id"], "a6a213e4b476e33e")
        self.assertTrue(devs[0]["isReachable"])
        self.assertTrue(devs[0]["isPaired"])

    def test_parse_device_output_multiple_devices(self):
        sample_output = (
            "- POCO X7 PRO: a6a213e4b476e33e (paired and reachable)\n"
            "- iPad Air: b782a1c2d3e4 (paired)\n"
            "- Pixel 8: c992a1c2d3e5 (unpaired)\n"
        )
        devs = KdeConnectService.parse_device_output(sample_output)
        self.assertEqual(len(devs), 3)
        self.assertEqual(devs[0]["name"], "POCO X7 PRO")
        self.assertTrue(devs[0]["isReachable"])
        self.assertEqual(devs[1]["name"], "iPad Air")
        self.assertFalse(devs[1]["isReachable"])

    def test_extract_avail_ids(self):
        sample_avail = (
            "- POCO X7 PRO: a6a213e4b476e33e\n"
            "1 device found\n"
        )
        avail = KdeConnectService._extract_avail_ids(sample_avail)
        self.assertIn("a6a213e4b476e33e", avail)
        self.assertEqual(len(avail), 1)

    def test_empty_cli_output(self):
        devs = KdeConnectService.parse_device_output("")
        self.assertEqual(devs, [])


if __name__ == "__main__":
    unittest.main()

