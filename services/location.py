"""
Unified Location Manager Service for NxSora (Fase 5)
Handles accurate city search (Open-Meteo Geocoding API), 1-click auto-detection (IP Geolocation),
and synchronizes location data across Weather, Prayer, Sun Arc, and Day Progress services.
"""

import json
import os
import threading
import urllib.parse
import urllib.request
import urllib.error
from pathlib import Path

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer
import config


# Fallback coordinates by timezone
TIMEZONE_COORDS = {
    "Asia/Jakarta": (-6.2146, 106.8451, "Jakarta", "DKI Jakarta, Indonesia", 7.0),
    "Asia/Pontianak": (-0.0263, 109.3425, "Pontianak", "Kalimantan Barat, Indonesia", 7.0),
    "Asia/Makassar": (-5.1477, 119.4327, "Makassar", "Sulawesi Selatan, Indonesia", 8.0),
    "Asia/Jayapura": (-2.5337, 140.7181, "Jayapura", "Papua, Indonesia", 9.0),
    "Asia/Singapore": (1.3521, 103.8198, "Singapore", "Singapore", 8.0),
    "Asia/Kuala_Lumpur": (3.1390, 101.6869, "Kuala Lumpur", "Malaysia", 8.0),
    "Asia/Tokyo": (35.6762, 139.6503, "Tokyo", "Japan", 9.0),
    "Europe/London": (51.5074, -0.1278, "London", "United Kingdom", 0.0),
    "America/New_York": (40.7128, -74.0060, "New York", "United States", -5.0),
}


class LocationService(QObject):
    locationChanged = pyqtSignal()
    searchResultsChanged = pyqtSignal()
    isSearchingChanged = pyqtSignal()
    isDetectingChanged = pyqtSignal()
    statusMessageChanged = pyqtSignal(str)

    def __init__(self, weather_service=None, prayer_service=None, parent=None):
        super().__init__(parent)

        self._weather_service = weather_service
        self._prayer_service = prayer_service

        # Load persisted settings or fallback
        cfg = config.CONFIG
        self._city = cfg.get("location_city", "")
        self._region = cfg.get("location_region", "")
        self._lat = float(cfg.get("location_lat", 0.0))
        self._lon = float(cfg.get("location_lon", 0.0))
        self._tz_offset = float(cfg.get("location_tz_offset", 7.0))
        self._ihtiath_minutes = int(cfg.get("prayer_ihtiath_minutes", 2))

        self._is_searching = False
        self._is_detecting = False
        self._search_results = []
        self._status_message = ""

        # If not configured, initialize from timezone
        if not self._city or self._lat == 0.0:
            default_lat, default_lon, default_city, default_region, default_tz = self._detect_timezone_default()
            self._lat = default_lat
            self._lon = default_lon
            self._city = default_city
            self._region = default_region
            self._tz_offset = default_tz

        # Sync initial coordinates to downstream services
        self._sync_to_services()

    def _detect_timezone_default(self):
        tz_name = "Asia/Jakarta"
        try:
            if os.path.exists("/etc/localtime"):
                real = os.path.realpath("/etc/localtime")
                parts = real.split("zoneinfo/")
                if len(parts) > 1:
                    tz_name = parts[1]
        except Exception:
            pass

        if tz_name in TIMEZONE_COORDS:
            return TIMEZONE_COORDS[tz_name]
        return (-6.2146, 106.8451, "Jakarta", "DKI Jakarta, Indonesia", 7.0)

    # =========================================================================
    # Properties
    # =========================================================================
    @pyqtProperty(str, notify=locationChanged)
    def city(self) -> str:
        return self._city

    @pyqtProperty(str, notify=locationChanged)
    def region(self) -> str:
        return self._region

    @pyqtProperty(float, notify=locationChanged)
    def latitude(self) -> float:
        return round(self._lat, 4)

    @pyqtProperty(float, notify=locationChanged)
    def longitude(self) -> float:
        return round(self._lon, 4)

    @pyqtProperty(float, notify=locationChanged)
    def timezoneOffset(self) -> float:
        return self._tz_offset

    @pyqtProperty(int, notify=locationChanged)
    def ihtiathMinutes(self) -> int:
        return self._ihtiath_minutes

    @pyqtProperty(bool, notify=isSearchingChanged)
    def isSearching(self) -> bool:
        return self._is_searching

    @pyqtProperty(bool, notify=isDetectingChanged)
    def isDetecting(self) -> bool:
        return self._is_detecting

    @pyqtProperty(list, notify=searchResultsChanged)
    def searchResults(self) -> list:
        return self._search_results

    @pyqtProperty(str, notify=statusMessageChanged)
    def statusMessage(self) -> str:
        return self._status_message

    # =========================================================================
    # Location Search (Open-Meteo Geocoding)
    # =========================================================================
    @pyqtSlot(str)
    def searchLocation(self, query: str):
        query = query.strip()
        if not query or len(query) < 2:
            self._search_results = []
            self.searchResultsChanged.emit()
            return

        self._is_searching = True
        self.isSearchingChanged.emit()
        self._status_message = f"Mencari '{query}'..."
        self.statusMessageChanged.emit(self._status_message)

        thread = threading.Thread(target=self._worker_search, args=(query,), daemon=True)
        thread.start()

    def _worker_search(self, query: str):
        results = []
        try:
            encoded = urllib.parse.quote(query)
            url = f"https://geocoding-api.open-meteo.com/v1/search?name={encoded}&count=6&language=id&format=json"
            req = urllib.request.Request(url, headers={"User-Agent": "NxSora-DynamicIsland/1.0"})

            with urllib.request.urlopen(req, timeout=5) as response:
                if response.status == 200:
                    data = json.loads(response.read().decode("utf-8"))
                    raw_items = data.get("results", [])

                    for it in raw_items:
                        name = it.get("name", "")
                        admin1 = it.get("admin1", "")
                        country = it.get("country", "")
                        lat = float(it.get("latitude", 0.0))
                        lon = float(it.get("longitude", 0.0))
                        tz_str = it.get("timezone", "Asia/Jakarta")

                        # Derive tz offset from timezone name
                        tz_offset = 7.0
                        if "Makassar" in tz_str or "Denpasar" in tz_str or "Singapore" in tz_str or "Kuala_Lumpur" in tz_str:
                            tz_offset = 8.0
                        elif "Jayapura" in tz_str or "Tokyo" in tz_str:
                            tz_offset = 9.0
                        elif "London" in tz_str or "UTC" in tz_str:
                            tz_offset = 0.0

                        parts = [p for p in [admin1, country] if p]
                        sub_text = ", ".join(parts) if parts else country

                        results.append({
                            "name": name,
                            "subtitle": sub_text,
                            "lat": round(lat, 4),
                            "lon": round(lon, 4),
                            "timezone": tz_str,
                            "tzOffset": tz_offset
                        })
        except Exception as e:
            print(f"[NxSora Location] Search error: {e}")

        self._search_results = results
        self._is_searching = False
        msg = f"Ditemukan {len(results)} lokasi" if results else "Lokasi tidak ditemukan"
        self._status_message = msg

        QTimer.singleShot(0, self.searchResultsChanged.emit)
        QTimer.singleShot(0, self.isSearchingChanged.emit)
        QTimer.singleShot(0, lambda: self.statusMessageChanged.emit(msg))

    # =========================================================================
    # Auto-Detect Location (IP Geolocation)
    # =========================================================================
    @pyqtSlot()
    def detectLocationAuto(self):
        if self._is_detecting:
            return

        self._is_detecting = True
        self.isDetectingChanged.emit()
        self._status_message = "Mendeteksi lokasi jaringan..."
        self.statusMessageChanged.emit(self._status_message)

        thread = threading.Thread(target=self._worker_detect_auto, daemon=True)
        thread.start()

    def _worker_detect_auto(self):
        success = False
        detected_city = ""
        detected_region = ""
        detected_lat = 0.0
        detected_lon = 0.0
        detected_tz = 7.0

        # Method 1: ip-api.com
        try:
            url = "http://ip-api.com/json/?fields=status,message,country,regionName,city,lat,lon,timezone,offset"
            req = urllib.request.Request(url, headers={"User-Agent": "NxSora-DynamicIsland/1.0"})
            with urllib.request.urlopen(req, timeout=4) as response:
                if response.status == 200:
                    data = json.loads(response.read().decode("utf-8"))
                    if data.get("status") == "success":
                        detected_city = data.get("city", "")
                        region_name = data.get("regionName", "")
                        country = data.get("country", "")
                        detected_lat = float(data.get("lat", 0.0))
                        detected_lon = float(data.get("lon", 0.0))
                        offset_sec = float(data.get("offset", 25200))
                        detected_tz = round(offset_sec / 3600.0, 1)

                        parts = [p for p in [region_name, country] if p]
                        detected_region = ", ".join(parts)
                        success = True
        except Exception:
            pass

        # Method 2 fallback: ipapi.co
        if not success:
            try:
                url = "https://ipapi.co/json/"
                req = urllib.request.Request(url, headers={"User-Agent": "NxSora-DynamicIsland/1.0"})
                with urllib.request.urlopen(req, timeout=4) as response:
                    if response.status == 200:
                        data = json.loads(response.read().decode("utf-8"))
                        detected_city = data.get("city", "")
                        region_name = data.get("region", "")
                        country = data.get("country_name", "")
                        detected_lat = float(data.get("latitude", 0.0))
                        detected_lon = float(data.get("longitude", 0.0))
                        offset_str = data.get("utc_offset", "+0700")
                        try:
                            sign = 1 if offset_str[0] == "+" else -1
                            hours = float(offset_str[1:3])
                            detected_tz = sign * hours
                        except Exception:
                            detected_tz = 7.0

                        parts = [p for p in [region_name, country] if p]
                        detected_region = ", ".join(parts)
                        success = True
            except Exception:
                pass

        self._is_detecting = False
        QTimer.singleShot(0, self.isDetectingChanged.emit)

        if success and detected_city and detected_lat != 0.0:
            msg = f"Lokasi terdeteksi: {detected_city}, {detected_region}"
            self._status_message = msg
            QTimer.singleShot(0, lambda: self.statusMessageChanged.emit(msg))
            QTimer.singleShot(0, lambda: self.applyLocation(
                detected_city, detected_region, detected_lat, detected_lon, detected_tz
            ))
        else:
            msg = "Gagal mendeteksi lokasi otomatis. Coba gunakan kolom pencarian."
            self._status_message = msg
            QTimer.singleShot(0, lambda: self.statusMessageChanged.emit(msg))

    # =========================================================================
    # Apply & Persist Location
    # =========================================================================
    @pyqtSlot(int)
    def selectSearchResult(self, index: int):
        if 0 <= index < len(self._search_results):
            it = self._search_results[index]
            self.applyLocation(
                it.get("name", ""),
                it.get("subtitle", ""),
                float(it.get("lat", 0.0)),
                float(it.get("lon", 0.0)),
                float(it.get("tzOffset", 7.0))
            )
            # Clear search results once applied
            self._search_results = []
            self.searchResultsChanged.emit()

    @pyqtSlot(str, str, float, float, float)
    def applyLocation(self, city: str, region: str, lat: float, lon: float, tz_offset: float = 7.0):
        self._city = city
        self._region = region
        self._lat = lat
        self._lon = lon
        self._tz_offset = tz_offset

        # Persist to config
        config.CONFIG["location_city"] = self._city
        config.CONFIG["location_region"] = self._region
        config.CONFIG["location_lat"] = self._lat
        config.CONFIG["location_lon"] = self._lon
        config.CONFIG["location_tz_offset"] = self._tz_offset
        config.save_user_config(config.CONFIG)

        self._status_message = f"Lokasi aktif: {self._city} ({self._lat:.2f}, {self._lon:.2f})"
        self.statusMessageChanged.emit(self._status_message)
        self.locationChanged.emit()

        # Synchronize downstream services
        self._sync_to_services()

    @pyqtSlot(int)
    def setIhtiathMinutes(self, minutes: int):
        self._ihtiath_minutes = max(-10, min(10, int(minutes)))
        config.CONFIG["prayer_ihtiath_minutes"] = self._ihtiath_minutes
        config.save_user_config(config.CONFIG)
        self.locationChanged.emit()

        if self._prayer_service:
            self._prayer_service.setFineTuneMinutes(self._ihtiath_minutes)

    def _sync_to_services(self):
        """Pushes updated coordinates to Weather and Prayer services."""
        if self._weather_service and hasattr(self._weather_service, "set_location"):
            self._weather_service.set_location(self._city, self._lat, self._lon)

        if self._prayer_service and hasattr(self._prayer_service, "set_coordinates"):
            self._prayer_service.set_coordinates(
                self._city, self._lat, self._lon, self._tz_offset, self._ihtiath_minutes
            )
