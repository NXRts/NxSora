"""
Tests for Bluetooth Service: Device Classification & Audio Types
"""

import unittest
from services.bluetooth import BluetoothService


class TestBluetoothService(unittest.TestCase):

    def test_classify_tws_earbuds(self):
        self.assertEqual(BluetoothService._classify_device("soundcore R50i", "audio-headset"), "tws")
        self.assertEqual(BluetoothService._classify_device("AirPods Pro", "audio-headphones"), "tws")
        self.assertEqual(BluetoothService._classify_device("Galaxy Buds2 Pro", "audio-card"), "tws")
        self.assertEqual(BluetoothService._classify_device("Redmi Buds 4 Active", ""), "tws")

    def test_classify_over_ear_headphones(self):
        self.assertEqual(BluetoothService._classify_device("Lenovo thinkplus-TH30", "audio-headphones"), "headphones")
        self.assertEqual(BluetoothService._classify_device("Sony WH-1000XM4", "audio-headphones"), "headphones")

    def test_classify_speakers(self):
        self.assertEqual(BluetoothService._classify_device("JBL Flip 6", "audio-card"), "speaker")
        self.assertEqual(BluetoothService._classify_device("Tribit StormBox", "audio-card"), "speaker")

    def test_classify_input_peripherals(self):
        self.assertEqual(BluetoothService._classify_device("Logitech MX Master 3S", "input-mouse"), "mouse")
        self.assertEqual(BluetoothService._classify_device("Keychron K2 Keyboard", "input-keyboard"), "keyboard")


if __name__ == "__main__":
    unittest.main()

