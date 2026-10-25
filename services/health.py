"""
Health & Wellness Service
Tracks daily water intake, hydration progress, and 20-20-20 eye rest intervals.
Data is stored persistently in ~/.config/dynamic_island/health.json
"""

import json
import os
from datetime import date
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer


class HealthService(QObject):
    waterChanged = pyqtSignal()
    eyeBreakChanged = pyqtSignal()
    eyeBreakAlert = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._config_dir = os.path.expanduser("~/.config/dynamic_island")
        self._config_file = os.path.join(self._config_dir, "health.json")
        os.makedirs(self._config_dir, exist_ok=True)

        self._water_intake = 1250  # default starter (ml)
        self._water_goal = 2000    # default goal (ml)
        self._today_str = str(date.today())
        self._hourly_history = [250, 500, 250, 250]  # sample morning/afternoon distribution

        # 20-20-20 Eye break timer: 20 minutes = 1200 seconds
        self._eye_break_total = 1200
        self._eye_break_remaining = 1200

        self._load_data()

        # Eye break countdown ticker (every 1 second)
        self._ticker = QTimer(self)
        self._ticker.setInterval(1000)
        self._ticker.timeout.connect(self._on_tick)
        self._ticker.start()

    def _load_data(self):
        if os.path.exists(self._config_file):
            try:
                with open(self._config_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    saved_date = data.get("date", "")
                    if saved_date == str(date.today()):
                        self._water_intake = int(data.get("water_intake", 1250))
                        self._water_goal = int(data.get("water_goal", 2000))
                        self._hourly_history = data.get("hourly_history", [250, 500, 250, 250])
                    else:
                        # New day: start fresh
                        self._water_intake = 0
                        self._hourly_history = [0, 0, 0, 0]
                        self._today_str = str(date.today())
                        self._save_data()
            except Exception as e:
                print(f"[HealthService] Error loading health.json: {e}")

    def _save_data(self):
        try:
            payload = {
                "date": str(date.today()),
                "water_intake": self._water_intake,
                "water_goal": self._water_goal,
                "hourly_history": self._hourly_history,
            }
            with open(self._config_file, "w", encoding="utf-8") as f:
                json.dump(payload, f, indent=2)
        except Exception as e:
            print(f"[HealthService] Error saving health.json: {e}")

    def _on_tick(self):
        # Check day rollover
        if str(date.today()) != self._today_str:
            self._today_str = str(date.today())
            self._water_intake = 0
            self._hourly_history = [0, 0, 0, 0]
            self._save_data()
            self.waterChanged.emit()

        if self._eye_break_remaining > 0:
            self._eye_break_remaining -= 1
            self.eyeBreakChanged.emit()
            if self._eye_break_remaining == 0:
                self.eyeBreakAlert.emit()
                # Auto restart for next 20 mins
                self._eye_break_remaining = self._eye_break_total

    # --- Water Intake Properties ---

    @pyqtProperty(int, notify=waterChanged)
    def waterIntake(self):
        return self._water_intake

    @pyqtProperty(int, notify=waterChanged)
    def waterGoal(self):
        return self._water_goal

    @pyqtProperty(float, notify=waterChanged)
    def waterProgressRatio(self):
        if self._water_goal <= 0:
            return 0.0
        return min(1.0, max(0.0, self._water_intake / float(self._water_goal)))

    @pyqtProperty(int, notify=waterChanged)
    def waterPercent(self):
        return int(round(self.waterProgressRatio * 100))

    @pyqtProperty(str, notify=waterChanged)
    def waterFormatted(self):
        intake_l = self._water_intake / 1000.0
        goal_l = self._water_goal / 1000.0
        return f"{intake_l:.1f} / {goal_l:.1f} L"

    # --- Eye Break Properties ---

    @pyqtProperty(int, notify=eyeBreakChanged)
    def eyeBreakRemaining(self):
        return self._eye_break_remaining

    @pyqtProperty(str, notify=eyeBreakChanged)
    def eyeBreakFormatted(self):
        mins = self._eye_break_remaining // 60
        secs = self._eye_break_remaining % 60
        return f"{mins:02d}:{secs:02d}"

    # --- Slots ---

    @pyqtSlot()
    @pyqtSlot(int)
    def drinkWater(self, amount=250):
        self._water_intake += amount
        # Update hourly distribution
        if self._hourly_history:
            self._hourly_history[-1] += amount
        self._save_data()
        self.waterChanged.emit()

    @pyqtSlot()
    def resetWater(self):
        self._water_intake = 0
        self._hourly_history = [0, 0, 0, 0]
        self._save_data()
        self.waterChanged.emit()

    @pyqtSlot()
    def resetEyeBreak(self):
        self._eye_break_remaining = self._eye_break_total
        self.eyeBreakChanged.emit()
