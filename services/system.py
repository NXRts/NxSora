"""
System & Hardware Monitoring Service
Tracks CPU, RAM, Battery, and Charging status.
"""

from PyQt6.QtCore import QObject, pyqtSignal, QTimer
import psutil


class SystemService(QObject):
    statsUpdated = pyqtSignal(float, float, str)  # cpu%, ram%, ram_text
    batteryChanged = pyqtSignal(float, bool)     # percent, power_plugged
    powerPluggedEvent = pyqtSignal(bool, float)  # plugged_in, battery_percent (event trigger)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.cpu_percent = 0.0
        self.ram_percent = 0.0
        self.ram_text = "0/0 GB"
        self.battery_percent = 100.0
        self.power_plugged = True
        self.has_battery = False

        self._last_plugged_state = None

        # Check initial battery
        batt = psutil.sensors_battery()
        if batt is not None:
            self.has_battery = True
            self.battery_percent = batt.percent
            self.power_plugged = batt.power_plugged
            self._last_plugged_state = self.power_plugged

        # Timer to poll stats
        self.timer = QTimer(self)
        self.timer.setInterval(1500)
        self.timer.timeout.connect(self._poll)
        self.timer.start()

        self._poll()

    def _poll(self):
        # CPU
        self.cpu_percent = psutil.cpu_percent(interval=None)

        # RAM
        vmem = psutil.virtual_memory()
        self.ram_percent = vmem.percent
        used_gb = vmem.used / (1024 ** 3)
        total_gb = vmem.total / (1024 ** 3)
        self.ram_text = f"{used_gb:.1f}/{total_gb:.1f} GB"

        self.statsUpdated.emit(self.cpu_percent, self.ram_percent, self.ram_text)

        # Battery
        batt = psutil.sensors_battery()
        if batt is not None:
            self.has_battery = True
            self.battery_percent = batt.percent
            current_plugged = batt.power_plugged
            
            # Check for plug/unplug transition
            if self._last_plugged_state is not None and self._last_plugged_state != current_plugged:
                self.powerPluggedEvent.emit(current_plugged, self.battery_percent)

            self._last_plugged_state = current_plugged
            self.power_plugged = current_plugged
            self.batteryChanged.emit(self.battery_percent, self.power_plugged)
