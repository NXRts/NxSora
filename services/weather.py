"""
Live Weather & Day Progress Service for NxSora
Fetches real-time weather forecasts via Open-Meteo (zero API keys, 100% free)
and tracks live Day Progress percentage across the 24-hour cycle.
"""

import json
import os
import threading
import urllib.request
import urllib.error
from datetime import datetime
from pathlib import Path

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer
import config


# Major city coordinates fallback by Timezone
TIMEZONE_COORDS = {
    "Asia/Jakarta": (-6.2146, 106.8451, "Jakarta"),
    "Asia/Pontianak": (-0.0263, 109.3425, "Pontianak"),
    "Asia/Makassar": (-5.1477, 119.4327, "Makassar"),
    "Asia/Jayapura": (-2.5337, 140.7181, "Jayapura"),
    "Asia/Singapore": (1.3521, 103.8198, "Singapore"),
    "Asia/Kuala_Lumpur": (3.1390, 101.6869, "Kuala Lumpur"),
    "Asia/Tokyo": (35.6762, 139.6503, "Tokyo"),
    "Europe/London": (51.5074, -0.1278, "London"),
    "America/New_York": (40.7128, -74.0060, "New York"),
}

WMO_WEATHER_CODES = {
    0: ("Cerah", "sun.svg"),
    1: ("Sebagian Cerah", "sun.svg"),
    2: ("Sebagian Berawan", "sun.svg"),
    3: ("Berawan", "cloud.svg"),
    45: ("Berkabut", "cloud.svg"),
    48: ("Kabut Tebal", "cloud.svg"),
    51: ("Gerimis Ringan", "cloud-rain.svg"),
    53: ("Gerimis Sedang", "cloud-rain.svg"),
    55: ("Gerimis Lebat", "cloud-rain.svg"),
    61: ("Hujan Ringan", "cloud-rain.svg"),
    63: ("Hujan Sedang", "cloud-rain.svg"),
    65: ("Hujan Lebat", "cloud-rain.svg"),
    71: ("Salju Ringan", "cloud.svg"),
    73: ("Salju Sedang", "cloud.svg"),
    75: ("Salju Lebat", "cloud.svg"),
    80: ("Hujan Guyur", "cloud-rain.svg"),
    81: ("Hujan Deras", "cloud-rain.svg"),
    82: ("Hujan Sangat Lebat", "cloud-rain.svg"),
    95: ("Badai Petir", "bolt.svg"),
    96: ("Badai Petir Es", "bolt.svg"),
    99: ("Badai Petir Berat", "bolt.svg"),
}


class WeatherService(QObject):
    weatherChanged = pyqtSignal()
    dayProgressChanged = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)

        self._cache_file = config.CACHE_DIR / "weather_cache.json"
        self._temp_c = 27
        self._temp_text = "27°C"
        self._condition = "Sebagian Berawan"
        self._icon = "sun.svg"
        self._city = "Jakarta"
        self._is_day = True
        self._humidity = 70
        self._wind_speed = "12 km/h"
        self._weather_code = 2
        self._is_refreshing = False
        self._last_updated = "Hari ini"

        self._day_progress_percent = 50.0
        self._day_progress_text = "Hari Ini 50%"

        # Default fallback hourly forecast
        self._hourly_forecast = [
            {"time": "Sekarang", "temp": "27°", "icon": "sun.svg", "condition": "Cerah"},
            {"time": "+1 jam", "temp": "27°", "icon": "sun.svg", "condition": "Cerah"},
            {"time": "+2 jam", "temp": "26°", "icon": "cloud.svg", "condition": "Berawan"},
            {"time": "+3 jam", "temp": "26°", "icon": "cloud.svg", "condition": "Berawan"},
            {"time": "+4 jam", "temp": "25°", "icon": "cloud.svg", "condition": "Berawan"},
            {"time": "+5 jam", "temp": "25°", "icon": "cloud.svg", "condition": "Berawan"},
        ]

        # Initialize location
        self._lat, self._lon, self._city = self._detect_location()

        # Load cache if available
        self._load_cache()

        # Update day progress timer (every 10 seconds)
        self._progress_timer = QTimer(self)
        self._progress_timer.setInterval(10000)
        self._progress_timer.timeout.connect(self._update_day_progress)
        self._progress_timer.start()
        self._update_day_progress()

        # Weather refresh timer (every 30 minutes)
        self._refresh_timer = QTimer(self)
        self._refresh_timer.setInterval(30 * 60 * 1000)
        self._refresh_timer.timeout.connect(self.refresh_weather_async)
        self._refresh_timer.start()

        # Initial asynchronous fetch
        QTimer.singleShot(1200, self.refresh_weather_async)

    def _detect_location(self):
        """Detects city and coordinates from configuration, system timezone, or default."""
        cfg = config.CONFIG
        if cfg.get("location_city") and cfg.get("location_lat") and cfg.get("location_lon"):
            return (float(cfg["location_lat"]), float(cfg["location_lon"]), cfg["location_city"])

        tz_name = "Asia/Jakarta"
        try:
            # Check /etc/timezone or readlink /etc/localtime
            if os.path.exists("/etc/localtime"):
                real = os.path.realpath("/etc/localtime")
                parts = real.split("zoneinfo/")
                if len(parts) > 1:
                    tz_name = parts[1]
        except Exception:
            pass

        if tz_name in TIMEZONE_COORDS:
            return TIMEZONE_COORDS[tz_name]
        return (-6.2146, 106.8451, "Jakarta")

    def set_location(self, city: str, lat: float, lon: float):
        """Updates weather location coordinates and triggers instant refresh."""
        self._city = city
        self._lat = float(lat)
        self._lon = float(lon)
        self.refresh_weather_async()
        self.weatherChanged.emit()

    def _load_cache(self):
        """Loads cached weather data to display instantly on startup."""
        try:
            if self._cache_file.exists():
                with open(self._cache_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    self._temp_c = data.get("temp", self._temp_c)
                    self._temp_text = f"{self._temp_c}°C"
                    self._condition = data.get("condition", self._condition)
                    self._icon = data.get("icon", self._icon)
                    self._city = data.get("city", self._city)
                    self._is_day = data.get("is_day", self._is_day)
                    self._humidity = data.get("humidity", self._humidity)
                    self._wind_speed = data.get("wind", self._wind_speed)
                    self._weather_code = data.get("code", self._weather_code)
                    self._last_updated = data.get("last_updated", self._last_updated)
                    cached_hourly = data.get("hourly", [])
                    if cached_hourly and len(cached_hourly) >= 3:
                        self._hourly_forecast = cached_hourly
        except Exception:
            pass

    def _save_cache(self):
        """Saves current weather data to cache."""
        try:
            self._cache_file.parent.mkdir(parents=True, exist_ok=True)
            with open(self._cache_file, "w", encoding="utf-8") as f:
                json.dump({
                    "temp": self._temp_c,
                    "condition": self._condition,
                    "icon": self._icon,
                    "city": self._city,
                    "is_day": self._is_day,
                    "humidity": self._humidity,
                    "wind": self._wind_speed,
                    "code": self._weather_code,
                    "hourly": self._hourly_forecast,
                    "last_updated": self._last_updated,
                    "updated_at": datetime.now().isoformat(),
                }, f)
        except Exception:
            pass

    def _update_day_progress(self):
        """Calculates percentage of time elapsed in the current day."""
        now = datetime.now()
        seconds_passed = now.hour * 3600 + now.minute * 60 + now.second
        pct = (seconds_passed / 86400.0) * 100.0
        self._day_progress_percent = round(pct, 1)

        # Day/Night phase label
        if 5 <= now.hour < 11:
            phase = "Pagi"
        elif 11 <= now.hour < 15:
            phase = "Siang"
        elif 15 <= now.hour < 18:
            phase = "Sore"
        else:
            phase = "Malam"

        self._day_progress_text = f"{phase} · {self._day_progress_percent:.0f}%"
        self.dayProgressChanged.emit()

    @pyqtSlot()
    def refresh_weather_async(self):
        """Triggers a non-blocking background fetch from Open-Meteo."""
        if self._is_refreshing:
            return
        self._is_refreshing = True
        self.weatherChanged.emit()
        thread = threading.Thread(target=self._fetch_weather_worker, daemon=True)
        thread.start()

    def _fetch_weather_worker(self):
        """Background worker fetching weather without blocking main Qt thread."""
        try:
            url = (
                f"https://api.open-meteo.com/v1/forecast"
                f"?latitude={self._lat:.4f}&longitude={self._lon:.4f}"
                f"&current=temperature_2m,relative_humidity_2m,is_day,weather_code,wind_speed_10m"
                f"&hourly=temperature_2m,weather_code,is_day"
                f"&forecast_days=2"
                f"&timezone=auto"
            )

            req = urllib.request.Request(
                url,
                headers={"User-Agent": "NxSora-DynamicIsland/0.1"}
            )
            # Timeout 4s to ensure zero hang
            with urllib.request.urlopen(req, timeout=4) as response:
                payload = json.loads(response.read().decode("utf-8"))
                current = payload.get("current", {})

                raw_temp = current.get("temperature_2m", self._temp_c)
                self._temp_c = round(float(raw_temp))
                self._temp_text = f"{self._temp_c}°C"
                self._weather_code = int(current.get("weather_code", 0))
                self._is_day = bool(current.get("is_day", 1))
                self._humidity = int(current.get("relative_humidity_2m", 70))
                raw_wind = current.get("wind_speed_10m", 10.0)
                self._wind_speed = f"{round(float(raw_wind))} km/h"

                # Condition & Icon
                cond_info = WMO_WEATHER_CODES.get(self._weather_code, ("Cerah", "sun.svg"))
                self._condition = cond_info[0]
                if not self._is_day and cond_info[1] == "sun.svg":
                    self._icon = "moon.svg"
                else:
                    self._icon = cond_info[1]

                # Hourly Forecast parsing (next 6 hours)
                hourly = payload.get("hourly", {})
                times = hourly.get("time", [])
                temps = hourly.get("temperature_2m", [])
                codes = hourly.get("weather_code", [])
                is_days = hourly.get("is_day", [])

                if times and temps:
                    now_iso_hour = datetime.now().strftime("%Y-%m-%dT%H:00")
                    current_idx = 0
                    for i, t in enumerate(times):
                        if t >= now_iso_hour:
                            current_idx = i
                            break

                    new_hourly = []
                    for idx in range(current_idx, min(current_idx + 6, len(times))):
                        t_str = times[idx]
                        hour_label = "Sekarang" if idx == current_idx else t_str.split("T")[-1][:5]
                        code = int(codes[idx]) if idx < len(codes) else 0
                        t_val = round(float(temps[idx])) if idx < len(temps) else self._temp_c
                        is_d = bool(is_days[idx]) if idx < len(is_days) else True

                        h_cond, h_icon = WMO_WEATHER_CODES.get(code, ("Cerah", "sun.svg"))
                        if not is_d and h_icon == "sun.svg":
                            h_icon = "moon.svg"

                        new_hourly.append({
                            "time": hour_label,
                            "temp": f"{t_val}°",
                            "icon": h_icon,
                            "condition": h_cond,
                        })

                    if new_hourly:
                        self._hourly_forecast = new_hourly

                self._last_updated = datetime.now().strftime("%H:%M") + " WIB"
                self._save_cache()
        except Exception:
            # Silently retain cached/fallback state on network error
            pass
        finally:
            self._is_refreshing = False
            self.weatherChanged.emit()

    # --- Properties ---

    @pyqtProperty(str, notify=weatherChanged)
    def temperature(self) -> str:
        return self._temp_text

    @pyqtProperty(int, notify=weatherChanged)
    def temperatureC(self) -> int:
        return self._temp_c

    @pyqtProperty(str, notify=weatherChanged)
    def condition(self) -> str:
        return self._condition

    @pyqtProperty(str, notify=weatherChanged)
    def icon(self) -> str:
        return self._icon

    @pyqtProperty(str, notify=weatherChanged)
    def city(self) -> str:
        return self._city

    @pyqtProperty(bool, notify=weatherChanged)
    def isDay(self) -> bool:
        return self._is_day

    @pyqtProperty(int, notify=weatherChanged)
    def humidity(self) -> int:
        return self._humidity

    @pyqtProperty(str, notify=weatherChanged)
    def humidityText(self) -> str:
        return f"{self._humidity}%"

    @pyqtProperty(str, notify=weatherChanged)
    def windSpeed(self) -> str:
        return self._wind_speed

    @pyqtProperty("QVariantList", notify=weatherChanged)
    def hourlyForecast(self) -> list:
        return self._hourly_forecast

    @pyqtProperty(str, notify=weatherChanged)
    def lastUpdated(self) -> str:
        return self._last_updated

    @pyqtProperty(bool, notify=weatherChanged)
    def isRefreshing(self) -> bool:
        return self._is_refreshing

    @pyqtProperty(float, notify=dayProgressChanged)
    def dayProgressPercent(self) -> float:
        return self._day_progress_percent

    @pyqtProperty(str, notify=dayProgressChanged)
    def dayProgressText(self) -> str:
        return self._day_progress_text
