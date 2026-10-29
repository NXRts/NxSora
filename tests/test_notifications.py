"""
Tests for Notification Service: HTML Sanitization, Chat Normalization,
Relative Time Formatting, Password Manager Exclusion, and Lifecycle Auto-Expire.
"""

import time
import unittest
from datetime import datetime, timedelta
from services.notifications import NotificationService


class TestNotificationService(unittest.TestCase):

    def test_clean_text_strips_html_and_unescapes(self):
        raw = "<b>Halo</b> &amp; <i>Selamat Datang</i><br/>di NxSora!"
        cleaned = NotificationService._clean_text(raw)
        self.assertEqual(cleaned, "Halo & Selamat Datang\ndi NxSora!")

    def test_classify_app_categories(self):
        self.assertEqual(NotificationService._classify_app("WhatsApp", "Pesan dari Ibu"), "chat")
        self.assertEqual(NotificationService._classify_app("Spotify", "Playing Track"), "media")
        self.assertEqual(NotificationService._classify_app("Sistem", "Suhu CPU Tinggi"), "thermal")
        self.assertEqual(NotificationService._classify_app("Pomodoro", "Waktunya Istirahat"), "focus")
        self.assertEqual(NotificationService._classify_app("Firefox", "Download Complete"), "browser")
        self.assertEqual(NotificationService._classify_app("KDE System", "Update Available"), "system")

    def test_normalize_chat_notification_whatsapp(self):
        app, title, body = NotificationService._normalize_chat_notification(
            app_name="Google Chrome",
            summary="WhatsApp • Siti Rahma",
            body="Besok kita jadi ketemuan jam 2 siang?",
        )
        self.assertEqual(app, "WhatsApp")
        self.assertEqual(title, "Siti Rahma")
        self.assertIn("Besok kita jadi ketemuan", body)

    def test_normalize_chat_notification_whatsapp_sender_in_body(self):
        app, title, body = NotificationService._normalize_chat_notification(
            app_name="WhatsApp Web",
            summary="WhatsApp",
            body="Ahmad Dani: Siap, filenya sudah saya kirim.",
        )
        self.assertEqual(app, "WhatsApp")
        self.assertEqual(title, "Ahmad Dani")
        self.assertEqual(body, "Siap, filenya sudah saya kirim.")

    def test_format_relative_time(self):
        now = datetime.now()
        # Today
        today_ts = now.timestamp()
        self.assertEqual(NotificationService.format_relative_time(today_ts), now.strftime("%H:%M"))

        # Yesterday
        yesterday_ts = (now - timedelta(days=1)).timestamp()
        expected_yesterday = f"Kemarin, {(now - timedelta(days=1)).strftime('%H:%M')}"
        self.assertEqual(NotificationService.format_relative_time(yesterday_ts), expected_yesterday)

    def test_password_manager_blacklist(self):
        blocked_apps = ["KeePassXC", "Bitwarden", "1Password", "Proton Pass", "Enpass"]
        for app in blocked_apps:
            is_blocked = any(pm in app.lower() for pm in NotificationService.PASSWORD_MANAGER_APPS)
            self.assertTrue(is_blocked, f"Expected {app} to be blocked in password manager filter")


if __name__ == "__main__":
    unittest.main()
