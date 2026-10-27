"""
Health & Wellness Service (Nusa & Poni Style)
Tracks daily water intake, hourly hydration histogram chart (09..16),
customizable bottle/cup size & daily goal, and 20-20-20 eye rest intervals.
Data is stored persistently in ~/.config/dynamic_island/health.json
"""

import json
import os
from datetime import date, datetime
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer


CHART_HOURS = ["09", "10", "11", "12", "13", "14", "15", "16"]
CUP_PRESETS = [150, 200, 250, 350, 500]
GOAL_PRESETS = [1500, 2000, 2500, 3000]


class HealthService(QObject):
    waterChanged = pyqtSignal()
    eyeBreakChanged = pyqtSignal()
    eyeBreakAlert = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._config_dir = os.path.expanduser("~/.config/dynamic_island")
        self._config_file = os.path.join(self._config_dir, "health.json")
        os.makedirs(self._config_dir, exist_ok=True)

        self._water_intake = 1250
        self._water_goal = 2000
        self._water_cup_size = 250
        self._today_str = str(date.today())
        # 8 hourly buckets corresponding to 09:00 .. 16:00+
        self._hourly_history = [250, 250, 0, 250, 250, 0, 250, 0]

        # 20-20-20 Eye break timer: 20 minutes = 1200 seconds
        self._eye_break_total = 1200
        self._eye_break_remaining = 1200

        self._load_data()

        # Eye break countdown ticker (every 1 second)
        self._ticker = QTimer(self)
        self._ticker.setInterval(1000)
        self._ticker.timeout.connect(self._on_tick)
        self._ticker.start()

    def _normalize_hourly(self, raw_list):
        if not isinstance(raw_list, list):
            return [0] * 8
        cleaned = [int(x) for x in raw_list[:8] if isinstance(x, (int, float))]
        while len(cleaned) < 8:
            cleaned.append(0)
        return cleaned

    def _load_data(self):
        if os.path.exists(self._config_file):
            try:
                with open(self._config_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    saved_date = data.get("date", "")
                    self._water_goal = int(data.get("water_goal", 2000))
                    self._water_cup_size = int(data.get("water_cup_size", 250))
                    if saved_date == str(date.today()):
                        self._water_intake = int(data.get("water_intake", 1250))
                        self._hourly_history = self._normalize_hourly(
                            data.get("hourly_history", [250, 250, 0, 250, 250, 0, 250, 0])
                        )
                    else:
                        # New day: reset intake & hourly bars, keep user goal & cup size
                        self._water_intake = 0
                        self._hourly_history = [0] * 8
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
                "water_cup_size": self._water_cup_size,
                "hourly_history": self._hourly_history,
            }
            with open(self._config_file, "w", encoding="utf-8") as f:
                json.dump(payload, f, indent=2)
        except Exception as e:
            print(f"[HealthService] Error saving health.json: {e}")

    def _current_bucket_index(self) -> int:
        hour = datetime.now().hour
        # Map 09..16 to indices 0..7 (hours < 9 map to 0, hours > 16 map to 7)
        return max(0, min(7, hour - 9))

    def _on_tick(self):
        # Check day rollover
        if str(date.today()) != self._today_str:
            self._today_str = str(date.today())
            self._water_intake = 0
            self._hourly_history = [0] * 8
            self._save_data()
            self.waterChanged.emit()

        if self._eye_break_remaining > 0:
            self._eye_break_remaining -= 1
            self.eyeBreakChanged.emit()
            if self._eye_break_remaining == 0:
                self.eyeBreakAlert.emit()
                self._eye_break_remaining = self._eye_break_total

    # --- Water Intake Properties ---

    @pyqtProperty(int, notify=waterChanged)
    def waterIntake(self):
        return self._water_intake

    @pyqtProperty(int, notify=waterChanged)
    def waterGoal(self):
        return self._water_goal

    @pyqtProperty(int, notify=waterChanged)
    def waterCupSize(self):
        return self._water_cup_size

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
        return f"{intake_l:.2f} / {goal_l:.1f} L"

    @pyqtProperty(list, notify=waterChanged)
    def waterHourlyBars(self):
        """Return 8 hourly bars for Nusa-style histogram chart."""
        cur_idx = self._current_bucket_index()
        max_scale = 500.0
        bars = []
        for i, h_label in enumerate(CHART_HOURS):
            ml = int(self._hourly_history[i]) if i < len(self._hourly_history) else 0
            ratio = min(1.0, max(0.0, ml / max_scale))
            bars.append({
                "hour": h_label,
                "ml": ml,
                "ratio": ratio,
                "isCurrent": (i == cur_idx),
            })
        return bars

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
    def drinkWater(self, amount=0):
        add_ml = int(amount) if amount and int(amount) > 0 else self._water_cup_size
        self._water_intake += add_ml
        idx = self._current_bucket_index()
        self._hourly_history[idx] = int(self._hourly_history[idx]) + add_ml
        self._save_data()
        self.waterChanged.emit()

    @pyqtSlot()
    def cycleWaterCupSize(self):
        try:
            idx = CUP_PRESETS.index(self._water_cup_size)
            self._water_cup_size = CUP_PRESETS[(idx + 1) % len(CUP_PRESETS)]
        except ValueError:
            self._water_cup_size = 250
        self._save_data()
        self.waterChanged.emit()

    @pyqtSlot()
    def cycleWaterGoal(self):
        try:
            idx = GOAL_PRESETS.index(self._water_goal)
            self._water_goal = GOAL_PRESETS[(idx + 1) % len(GOAL_PRESETS)]
        except ValueError:
            self._water_goal = 2000
        self._save_data()
        self.waterChanged.emit()

    @pyqtSlot()
    def resetWater(self):
        self._water_intake = 0
        self._hourly_history = [0] * 8
        self._save_data()
        self.waterChanged.emit()

    @pyqtSlot()
    def resetEyeBreak(self):
        self._eye_break_remaining = self._eye_break_total
        self.eyeBreakChanged.emit()
