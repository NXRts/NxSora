"""
Tests for Lyrics Service: Title Cleaner, LRC Parser, and Unsynced Converter
"""

import unittest
from services.lyrics import LyricsService


class TestLyricsService(unittest.TestCase):

    def test_clean_track_info_strips_youtube_tags(self):
        title = "YOASOBI - Idol (Official Music Video) [4K]"
        artist = "Ayase / YOASOBI - Topic"
        clean_t, clean_a, alt_t, alt_a = LyricsService._clean_metadata(title, artist)

        self.assertNotIn("Official Music Video", clean_t)
        self.assertNotIn("4K", clean_t)
        self.assertNotIn("- Topic", clean_a)
        self.assertEqual(clean_a, "Ayase / YOASOBI")
        self.assertEqual(alt_a, "YOASOBI")
        self.assertEqual(alt_t, "Idol")

    def test_clean_track_info_removes_parenthesized_remaster(self):
        title = "Bohemian Rhapsody (2011 Remaster)"
        artist = "Queen"
        clean_t, clean_a, _, _ = LyricsService._clean_metadata(title, artist)
        self.assertEqual(clean_t, "Bohemian Rhapsody")
        self.assertEqual(clean_a, "Queen")

    def test_parse_lrc_standard_format(self):
        sample_lrc = """
[00:12.34]First line of the song
[00:18.50]Second line with feeling
[01:05.10]Chorus kicks in!
"""
        parsed = LyricsService._parse_lrc(sample_lrc)
        self.assertEqual(len(parsed), 3)
        self.assertEqual(parsed[0]["time"], 12.34)
        self.assertEqual(parsed[0]["text"], "First line of the song")
        self.assertEqual(parsed[1]["time"], 18.50)
        self.assertEqual(parsed[2]["time"], 65.10)

    def test_parse_lrc_empty_or_invalid(self):
        self.assertEqual(LyricsService._parse_lrc(""), [])
        self.assertEqual(LyricsService._parse_lrc(None), [])
        self.assertEqual(LyricsService._parse_lrc("Just raw text with no timestamps"), [])

    def test_parse_plain_lyrics_spreads_across_duration(self):
        plain = "Line 1\nLine 2\nLine 3\nLine 4"
        duration = 60.0  # 60 seconds
        parsed = LyricsService._parse_plain(plain, duration)
        self.assertEqual(len(parsed), 4)
        self.assertEqual(parsed[0]["text"], "Line 1")
        self.assertLess(parsed[0]["time"], parsed[1]["time"])
        self.assertLess(parsed[-1]["time"], duration)


if __name__ == "__main__":
    unittest.main()
