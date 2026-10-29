import unittest
from PyQt6.QtCore import QCoreApplication
from services.network import NetworkService


class TestNetworkService(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = QCoreApplication.instance() or QCoreApplication([])

    def setUp(self):
        self.net = NetworkService()

    def test_initial_state_types(self):
        self.assertIsInstance(self.net.ssid, str)
        self.assertIsInstance(self.net.connected, bool)
        self.assertIsInstance(self.net.signalPercent, int)
        self.assertIn(self.net.netType, ("wifi", "ethernet"))

    def test_trigger_demo(self):
        emitted = []
        self.net.networkPeekTriggered.connect(lambda n, c, s, t: emitted.append((n, c, s, t)))
        self.net.trigger_demo()

        self.assertTrue(self.net.connected)
        self.assertEqual(self.net.ssid, "Starlink Ultra 5G")
        self.assertEqual(self.net.signalPercent, 92)
        self.assertEqual(self.net.netType, "wifi")
        self.assertTrue(len(emitted) > 0)
        self.assertEqual(emitted[0][0], "Starlink Ultra 5G")
        self.assertTrue(emitted[0][1])

    def test_trigger_disconnect_demo(self):
        emitted = []
        self.net.networkPeekTriggered.connect(lambda n, c, s, t: emitted.append((n, c, s, t)))
        self.net.trigger_disconnect_demo()

        self.assertFalse(self.net.connected)
        self.assertEqual(self.net.ssid, "Wi-Fi Terputus")
        self.assertEqual(self.net.signalPercent, 0)
        self.assertTrue(len(emitted) > 0)
        self.assertEqual(emitted[0][0], "Wi-Fi Terputus")
        self.assertFalse(emitted[0][1])


if __name__ == "__main__":
    unittest.main()
