"""
Prayer Times & Sun Arc Trajectory Service for NxSora (Fase 5)
100% Offline mathematical calculation using solar astronomical algorithm (Kemenag RI standard).
Tracks live Sun Arc Day Trajectory, next prayer countdown, 5-prayer checklist tracker,
and emits heads-up (10m before) and adzan triggers.
"""

import json
import math
import os
from datetime import datetime, date, timedelta
from pathlib import Path

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer
import config

# Major Indonesian & international city coordinates fallback
PRAYER_CITIES = {
    "Jakarta": (-6.2146, 106.8451, 7.0),
    "Bandung": (-6.9175, 107.6191, 7.0),
    "Surabaya": (-7.2575, 112.7521, 7.0),
    "Yogyakarta": (-7.7956, 110.3695, 7.0),
    "Semarang": (-6.9667, 110.4167, 7.0),
    "Medan": (3.5952, 98.6722, 7.0),
    "Palembang": (-2.9909, 104.7565, 7.0),
    "Pontianak": (-0.0263, 109.3425, 7.0),
    "Banjarmasin": (-3.3194, 114.5908, 8.0),
    "Makassar": (-5.1477, 119.4327, 8.0),
    "Denpasar": (-8.6705, 115.2126, 8.0),
    "Jayapura": (-2.5337, 140.7181, 9.0),
    "Kuala Lumpur": (3.1390, 101.6869, 8.0),
    "Singapore": (1.3521, 103.8198, 8.0),
}


class PrayerService(QObject):
    prayerChanged = pyqtSignal()
    checklistChanged = pyqtSignal()
    prayerHeadsUpTriggered = pyqtSignal(str, int)  # prayer_name, minutes_left
    prayerAdzanTriggered = pyqtSignal(str, str)     # prayer_name, time_str

    def __init__(self, parent=None):
        super().__init__(parent)

        self._tracker_file = config.CACHE_DIR / "prayer_tracker.json"
        self._city = "Jakarta"
        self._lat = -6.2146
        self._lon = 106.8451
        self._tz = 7.0
        self._fine_tune_minutes = 0  # User ihtiath offset

        # Daily schedule times
        self._times = {
            "imsak": "04:00",
            "subuh": "04:10",
            "terbit": "05:28",
            "dzuhur": "11:40",
            "ashar": "14:56",
            "maghrib": "17:48",
            "isya": "19:02",
        }

        # Dynamic Sun Arc state
        self._next_prayer_name = "Maghrib"
        self._next_prayer_time = "17:48"
        self._countdown_text = "dalam 2 jam"
        self._minutes_to_next = 120
        self._sun_position = 0.5  # 0.0 (sunrise) to 1.0 (sunset)
        self._is_daytime = True
        self._active_prayer_index = 3  # 0: Subuh, 1: Dzuhur, 2: Ashar, 3: Maghrib, 4: Isya

        # Daily prayer checklist (Subuh, Dzuhur, Ashar, Maghrib, Isya)
        self._checklist = {
            "subuh": False,
            "dzuhur": False,
            "ashar": False,
            "maghrib": False,
            "isya": False,
        }
        self._last_alerted_prayer = ""
        self._last_headsup_prayer = ""

        # Initialize location from config / timezone
        self._detect_location()
        self._load_checklist()
        self.recalculate()

        # Minute timer to update trajectory & countdown
        self._timer = QTimer(self)
        self._timer.setInterval(10000)  # Check every 10 seconds
        self._timer.timeout.connect(self._on_tick)
        self._timer.start()

    def _detect_location(self):
        saved_city = config.CONFIG.get("prayer_city", "Jakarta")
        if saved_city in PRAYER_CITIES:
            self._city = saved_city
            self._lat, self._lon, self._tz = PRAYER_CITIES[saved_city]
        else:
            self._city = "Jakarta"
            self._lat, self._lon, self._tz = PRAYER_CITIES["Jakarta"]

    @staticmethod
    def calculate_times_for_date(d: date, lat: float, lon: float, tz: float = 7.0, offset_min: int = 0) -> dict:
        """Computes astronomical prayer times with Kemenag RI parameters."""
        year, month, day = d.year, d.month, d.day
        if month <= 2:
            year -= 1
            month += 12
        a = math.floor(year / 100)
        b = 2 - a + math.floor(a / 4)
        jd = math.floor(365.25 * (year + 4716)) + math.floor(30.6001 * (month + 1)) + day + b - 1524.5

        d_num = jd - 2451545.0
        g = math.radians((357.529 + 0.98560028 * d_num) % 360)
        q = (280.459 + 0.98564736 * d_num) % 360
        L = math.radians((q + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g)) % 360)
        e = math.radians(23.439 - 0.00000036 * d_num)

        ra = math.atan2(math.cos(e) * math.sin(L), math.cos(L))
        ra_deg = (math.degrees(ra) / 15.0) % 24
        dec = math.asin(math.sin(e) * math.sin(L))

        eq_t = (q / 15.0) - ra_deg
        if eq_t > 12:
            eq_t -= 24
        elif eq_t < -12:
            eq_t += 24

        noon = 12.0 + tz - (lon / 15.0) - eq_t
        dhuhr = noon + (2.0 / 60.0) + (offset_min / 60.0)

        rad_lat = math.radians(lat)

        def hour_angle(alt_deg):
            alt_rad = math.radians(alt_deg)
            cos_ha = (math.sin(alt_rad) - math.sin(rad_lat) * math.sin(dec)) / (math.cos(rad_lat) * math.cos(dec))
            if cos_ha > 1.0 or cos_ha < -1.0:
                return None
            return math.degrees(math.acos(cos_ha)) / 15.0

        ha_subuh = hour_angle(-20.0)
        subuh = dhuhr - ha_subuh if ha_subuh else dhuhr - 1.5

        ha_terbit = hour_angle(-0.833)
        terbit = noon - ha_terbit if ha_terbit else noon - 1.0

        alt_asr = math.degrees(math.atan(1.0 / (1.0 + math.tan(abs(rad_lat - dec)))))
        ha_asr = hour_angle(alt_asr)
        ashar = dhuhr + ha_asr + (2.0 / 60.0) + (offset_min / 60.0) if ha_asr else dhuhr + 3.0

        ha_sunset = hour_angle(-0.833)
        maghrib = noon + ha_sunset + (2.0 / 60.0) + (offset_min / 60.0) if ha_sunset else noon + 1.0

        ha_isya = hour_angle(-18.0)
        isya = dhuhr + ha_isya + (2.0 / 60.0) + (offset_min / 60.0) if ha_isya else dhuhr + 1.2

        def fmt(h):
            h = h % 24
            hh = int(h)
            mm = int(round((h - hh) * 60))
            if mm >= 60:
                hh = (hh + 1) % 24
                mm = 0
            return f"{hh:02d}:{mm:02d}"

        return {
            "imsak": fmt(subuh - (10.0 / 60.0)),
            "subuh": fmt(subuh),
            "terbit": fmt(terbit),
            "dzuhur": fmt(dhuhr),
            "ashar": fmt(ashar),
            "maghrib": fmt(maghrib),
            "isya": fmt(isya),
        }

    def recalculate(self):
        """Recalculates today's prayer times and updates Sun Arc state."""
        now = datetime.now()
        self._times = self.calculate_times_for_date(
            now.date(), self._lat, self._lon, self._tz, self._fine_tune_minutes
        )
        self._update_trajectory(now)
        self.prayerChanged.emit()

    def _parse_time(self, time_str: str, base_date: date) -> datetime:
        hh, mm = map(int, time_str.split(":"))
        return datetime(base_date.year, base_date.month, base_date.day, hh, mm, 0)

    def _update_trajectory(self, now: datetime):
        today = now.date()
        dt_subuh = self._parse_time(self._times["subuh"], today)
        dt_terbit = self._parse_time(self._times["terbit"], today)
        dt_dzuhur = self._parse_time(self._times["dzuhur"], today)
        dt_ashar = self._parse_time(self._times["ashar"], today)
        dt_maghrib = self._parse_time(self._times["maghrib"], today)
        dt_isya = self._parse_time(self._times["isya"], today)

        # 1. Daytime vs Nighttime & Sun position along the Arc [0.0 .. 1.0]
        if dt_terbit <= now <= dt_maghrib:
            self._is_daytime = True
            total_sec = (dt_maghrib - dt_terbit).total_seconds()
            passed_sec = (now - dt_terbit).total_seconds()
            self._sun_position = max(0.0, min(1.0, passed_sec / max(1.0, total_sec)))
        else:
            self._is_daytime = False
            # Night arc from Maghrib to tomorrow's Sunrise
            if now > dt_maghrib:
                tomorrow_terbit = dt_terbit + timedelta(days=1)
                total_sec = (tomorrow_terbit - dt_maghrib).total_seconds()
                passed_sec = (now - dt_maghrib).total_seconds()
            else:
                yesterday_maghrib = dt_maghrib - timedelta(days=1)
                total_sec = (dt_terbit - yesterday_maghrib).total_seconds()
                passed_sec = (now - yesterday_maghrib).total_seconds()
            self._sun_position = max(0.0, min(1.0, passed_sec / max(1.0, total_sec)))

        # 2. Determine Next Prayer & Active Index
        prayer_list = [
            ("Subuh", dt_subuh, 0),
            ("Dzuhur", dt_dzuhur, 1),
            ("Ashar", dt_ashar, 2),
            ("Maghrib", dt_maghrib, 3),
            ("Isya", dt_isya, 4),
        ]

        next_p = None
        for name, p_dt, idx in prayer_list:
            if now < p_dt:
                next_p = (name, p_dt, idx)
                break

        if next_p:
            self._next_prayer_name = next_p[0]
            self._next_prayer_time = self._times[next_p[0].lower()]
            self._active_prayer_index = next_p[2]
            diff_sec = int((next_p[1] - now).total_seconds())
        else:
            # Tomorrow Subuh
            tomorrow_subuh = dt_subuh + timedelta(days=1)
            self._next_prayer_name = "Subuh"
            self._next_prayer_time = self._times["subuh"]
            self._active_prayer_index = 0
            diff_sec = int((tomorrow_subuh - now).total_seconds())

        self._minutes_to_next = max(0, diff_sec // 60)

        # Formatted countdown
        hours = self._minutes_to_next // 60
        mins = self._minutes_to_next % 60
        if hours > 0:
            self._countdown_text = f"dalam {hours} jam {mins} mnt"
        elif mins > 0:
            self._countdown_text = f"dalam {mins} mnt"
        else:
            self._countdown_text = "saat ini"

        # 3. Heads-up (10 minutes before) & Adzan Alerts
        if 9 <= self._minutes_to_next <= 10 and self._last_headsup_prayer != self._next_prayer_name:
            self._last_headsup_prayer = self._next_prayer_name
            self.prayerHeadsUpTriggered.emit(self._next_prayer_name, self._minutes_to_next)

        if self._minutes_to_next == 0 and self._last_alerted_prayer != self._next_prayer_name:
            self._last_alerted_prayer = self._next_prayer_name
            self.prayerAdzanTriggered.emit(self._next_prayer_name, self._next_prayer_time)

    def _on_tick(self):
        now = datetime.now()
        # Reset checklist if date changed
        saved_date = getattr(self, "_today_str", "")
        cur_date_str = now.strftime("%Y-%m-%d")
        if saved_date != cur_date_str:
            self._today_str = cur_date_str
            self._checklist = {k: False for k in self._checklist}
            self._save_checklist()
            self.checklistChanged.emit()

        self._update_trajectory(now)
        self.prayerChanged.emit()

    def _load_checklist(self):
        try:
            self._today_str = date.today().strftime("%Y-%m-%d")
            if self._tracker_file.exists():
                with open(self._tracker_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    if data.get("date") == self._today_str:
                        self._checklist = data.get("checklist", self._checklist)
        except Exception:
            pass

    def _save_checklist(self):
        try:
            self._tracker_file.parent.mkdir(parents=True, exist_ok=True)
            with open(self._tracker_file, "w", encoding="utf-8") as f:
                json.dump({
                    "date": self._today_str,
                    "checklist": self._checklist,
                }, f)
        except Exception:
            pass

    @pyqtSlot(str, bool)
    def setPrayerChecked(self, prayer_name: str, checked: bool):
        key = prayer_name.lower().strip()
        if key in self._checklist:
            self._checklist[key] = bool(checked)
            self._save_checklist()
            self.checklistChanged.emit()

    @pyqtSlot(str)
    def setCity(self, city_name: str):
        if city_name in PRAYER_CITIES:
            self._city = city_name
            self._lat, self._lon, self._tz = PRAYER_CITIES[city_name]
            config.CONFIG["prayer_city"] = city_name
            config.save_user_config(config.CONFIG)
            self.recalculate()

    # --- Properties ---

    @pyqtProperty(str, notify=prayerChanged)
    def city(self) -> str:
        return self._city

    @pyqtProperty(str, notify=prayerChanged)
    def subuh(self) -> str:
        return self._times.get("subuh", "04:10")

    @pyqtProperty(str, notify=prayerChanged)
    def terbit(self) -> str:
        return self._times.get("terbit", "05:28")

    @pyqtProperty(str, notify=prayerChanged)
    def dzuhur(self) -> str:
        return self._times.get("dzuhur", "11:40")

    @pyqtProperty(str, notify=prayerChanged)
    def ashar(self) -> str:
        return self._times.get("ashar", "14:56")

    @pyqtProperty(str, notify=prayerChanged)
    def maghrib(self) -> str:
        return self._times.get("maghrib", "17:48")

    @pyqtProperty(str, notify=prayerChanged)
    def isya(self) -> str:
        return self._times.get("isya", "19:02")

    @pyqtProperty(str, notify=prayerChanged)
    def imsak(self) -> str:
        return self._times.get("imsak", "04:00")

    @pyqtProperty(str, notify=prayerChanged)
    def nextPrayerName(self) -> str:
        return self._next_prayer_name

    @pyqtProperty(str, notify=prayerChanged)
    def nextPrayerTime(self) -> str:
        return self._next_prayer_time

    @pyqtProperty(str, notify=prayerChanged)
    def countdownText(self) -> str:
        return self._countdown_text

    @pyqtProperty(int, notify=prayerChanged)
    def minutesToNext(self) -> int:
        return self._minutes_to_next

    @pyqtProperty(float, notify=prayerChanged)
    def sunPosition(self) -> float:
        return self._sun_position

    @pyqtProperty(bool, notify=prayerChanged)
    def isDaytime(self) -> bool:
        return self._is_daytime

    @pyqtProperty(int, notify=prayerChanged)
    def activePrayerIndex(self) -> int:
        return self._active_prayer_index

    @pyqtProperty("QVariantMap", notify=checklistChanged)
    def checklist(self) -> dict:
        return self._checklist
