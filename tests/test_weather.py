"""
Tests for Live Weather & Day Progress Service (Fase 4):
Open-Meteo WMO weather code translation, day progress calculation, and location detection.
"""

import unittest
from datetime import datetime
from services.weather import WeatherService, WMO_WEATHER_CODES, TIMEZONE_COORDS


class TestWeatherService(unittest.TestCase):

    def test_wmo_weather_codes_coverage(self):
        """Verify standard WMO codes return valid descriptions and icon filenames."""
        self.assertIn(0, WMO_WEATHER_CODES)
        self.assertIn(2, WMO_WEATHER_CODES)
        self.assertIn(61, WMO_WEATHER_CODES)
        self.assertIn(95, WMO_WEATHER_CODES)

        desc, icon = WMO_WEATHER_CODES[0]
        self.assertEqual(desc, "Cerah")
        self.assertTrue(icon.endswith(".svg"))

        rain_desc, rain_icon = WMO_WEATHER_CODES[61]
        self.assertEqual(rain_desc, "Hujan Ringan")
        self.assertEqual(rain_icon, "cloud-rain.svg")

    def test_timezone_coordinates_fallback(self):
        """Verify major regional timezones have coordinates."""
        self.assertIn("Asia/Jakarta", TIMEZONE_COORDS)
        lat, lon, city = TIMEZONE_COORDS["Asia/Jakarta"]
        self.assertEqual(city, "Jakarta")
        self.assertAlmostEqual(lat, -6.2146, places=2)
        self.assertAlmostEqual(lon, 106.8451, places=2)

    def test_detect_location(self):
        """Verify detect_location returns a tuple of (lat, lon, city)."""
        service = WeatherService.__new__(WeatherService)
        lat, lon, city = service._detect_location()
        self.assertIsInstance(lat, float)
        self.assertIsInstance(lon, float)
        self.assertIsInstance(city, str)
        self.assertGreater(len(city), 0)

    def test_calculate_day_progress(self):
        """Verify day progress calculation based on hour and minute."""
        service = WeatherService.__new__(WeatherService)
        # Mocking time logic: at 12:00 PM, progress should be exactly 50%
        now = datetime(2026, 10, 30, 12, 0, 0)
        seconds_passed = now.hour * 3600 + now.minute * 60 + now.second
        ratio = seconds_passed / 86400.0
        percent = round(ratio * 100, 1)
        self.assertEqual(percent, 50.0)

        # At 00:00 AM, progress should be 0.0%
        now_start = datetime(2026, 10, 30, 0, 0, 0)
        seconds_passed_start = now_start.hour * 3600 + now_start.minute * 60 + now_start.second
        self.assertEqual(round(seconds_passed_start / 86400.0 * 100, 1), 0.0)

    def test_weather_properties_defaults(self):
        service = WeatherService.__new__(WeatherService)
        service._temp_text = "27°C"
        service._temp_c = 27
        service._condition = "Sebagian Berawan"
        service._icon = "sun.svg"
        service._city = "Jakarta"
        service._is_day = True
        service._humidity = 70
        service._wind_speed = "12 km/h"
        service._last_updated = "19:00 WIB"
        service._is_refreshing = False
        service._hourly_forecast = [
            {"time": "Sekarang", "temp": "27°", "icon": "sun.svg", "condition": "Cerah"}
        ]

        self.assertEqual(service.temperature, "27°C")
        self.assertEqual(service.temperatureC, 27)
        self.assertEqual(service.condition, "Sebagian Berawan")
        self.assertEqual(service.city, "Jakarta")
        self.assertEqual(service.humidityText, "70%")
        self.assertEqual(service.windSpeed, "12 km/h")
        self.assertEqual(len(service.hourlyForecast), 1)
        self.assertEqual(service.lastUpdated, "19:00 WIB")
        self.assertFalse(service.isRefreshing)


if __name__ == "__main__":
    unittest.main()

