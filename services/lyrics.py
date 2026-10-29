"""
Synced Lyrics Service (LRCLIB Integration)
Fetches real-time synchronized karaoke lyrics (.lrc) from lrclib.net,
caches them locally in ~/.cache/dynamic_island/lyrics/, and tracks the active line.
"""

import hashlib
import json
import os
import re
import threading
import urllib.parse
import urllib.request
from PyQt6.QtCore import QObject, pyqtSignal
import config


class LyricsService(QObject):
    lyricsUpdated = pyqtSignal()
    currentIndexChanged = pyqtSignal(int)
    lyricsModeChanged = pyqtSignal(bool)

    # Internal thread-safe signal from worker thread -> main thread
    _fetchCompleted = pyqtSignal(str, list, str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._cache_dir = str(config.CACHE_DIR / "lyrics")
        os.makedirs(self._cache_dir, exist_ok=True)

        self._lyrics_mode = False
        self._status = "idle"  # "idle", "loading", "synced", "plain", "not_found"
        self._lines = []       # list of {"time": float, "text": str}
        self._current_index = -1
        self._current_key = ""

        self._fetchCompleted.connect(self._on_fetch_completed)

    @property
    def lyricsMode(self):
        return self._lyrics_mode

    def setLyricsMode(self, active: bool):
        active = bool(active)
        if self._lyrics_mode != active:
            self._lyrics_mode = active
            self.lyricsModeChanged.emit(self._lyrics_mode)

    def toggleLyricsMode(self):
        self.setLyricsMode(not self._lyrics_mode)

    @property
    def status(self):
        return self._status

    @property
    def lines(self):
        return self._lines

    @property
    def currentIndex(self):
        return self._current_index

    @property
    def currentLineText(self):
        if 0 <= self._current_index < len(self._lines):
            return self._lines[self._current_index].get("text", "")
        return ""

    @staticmethod
    def _clean_metadata(title: str, artist: str):
        """Clean noisy YouTube/Spotify suffixes from title and artist."""
        clean_t = title or ""
        clean_a = artist or ""

        # Strip common video/audio tags in brackets/parentheses
        patterns = [
            r"\(\s*(?:official\s*)?(?:music\s*)?(?:video|audio|lyric\s*video|lyrics|visualizer|mv|hd|4k|hq|live|(?:[0-9]{4}\s+)?remaster(?:ed)?[^)]*)\s*\)",
            r"\[\s*(?:official\s*)?(?:music\s*)?(?:video|audio|lyric\s*video|lyrics|visualizer|mv|hd|4k|hq|live|(?:[0-9]{4}\s+)?remaster(?:ed)?[^\]]*)\s*\]",
            r"\b(?:official\s+music\s+video|official\s+video|official\s+audio|lyric\s+video)\b",
        ]
        for pat in patterns:
            clean_t = re.sub(pat, "", clean_t, flags=re.IGNORECASE)

        # Strip "- Topic" from YouTube Music channel names
        clean_a = re.sub(r"\s*-\s*Topic$", "", clean_a, flags=re.IGNORECASE).strip()
        clean_t = clean_t.strip(" -|")

        # If title contains "Artist - Song" (typical on YouTube/Firefox), extract both
        alt_artist, alt_title = "", ""
        if " - " in clean_t:
            parts = clean_t.split(" - ", 1)
            alt_artist = parts[0].strip()
            alt_title = parts[1].strip()

        return clean_t, clean_a, alt_title, alt_artist

    @staticmethod
    def _parse_lrc(lrc_text: str):
        """Parse standard [mm:ss.xx] LRC format into sorted list of {'time', 'text'}."""
        if not lrc_text:
            return []

        time_tag_re = re.compile(r"\[(\d{1,3}):(\d{2})(?:[.:](\d{1,3}))?\]")
        parsed = []

        raw_entries = []
        for raw_line in lrc_text.splitlines():
            matches = list(time_tag_re.finditer(raw_line))
            if not matches:
                continue
            lyric_text = time_tag_re.sub("", raw_line).strip()

            for m in matches:
                mins = int(m.group(1))
                secs = int(m.group(2))
                frac_str = m.group(3) or "0"
                frac = float("0." + frac_str)
                total_sec = mins * 60.0 + secs + frac
                raw_entries.append({"time": round(total_sec, 2), "text": lyric_text})

        raw_entries.sort(key=lambda item: item["time"])

        # Filter out short empty end-of-line markers so the sung lyric stays lit;
        # only keep an instrumental marker if the gap to the next vocal line is >= 12s.
        parsed = []
        for i, entry in enumerate(raw_entries):
            if entry["text"]:
                parsed.append(entry)
            else:
                next_time = raw_entries[i + 1]["time"] if (i + 1) < len(raw_entries) else (entry["time"] + 15.0)
                if (next_time - entry["time"]) >= 12.0 and (not parsed or parsed[-1]["text"] != "♪ Instrumental ♪"):
                    parsed.append({"time": entry["time"], "text": "♪ Instrumental ♪"})

        return parsed

    @staticmethod
    def _parse_plain(plain_text: str, duration: float):
        """Convert plain unsynced lyrics into estimated time-spaced lines."""
        raw_lines = [ln.strip() for ln in (plain_text or "").splitlines() if ln.strip()]
        if not raw_lines:
            return []
        effective_dur = max(60.0, float(duration or 180.0) * 0.9)
        step = effective_dur / max(1, len(raw_lines))
        return [
            {"time": round(i * step, 2), "text": text}
            for i, text in enumerate(raw_lines)
        ]

    def update_track(self, title: str, artist: str, album: str = "", duration: float = 0.0):
        """Trigger lyrics lookup when the playing song changes."""
        title = (title or "").strip()
        artist = (artist or "").strip()

        if not title:
            self._current_key = ""
            self._status = "idle"
            self._lines = []
            self._current_index = -1
            self.lyricsUpdated.emit()
            return

        track_key = f"{artist.lower()}::{title.lower()}"
        if track_key == self._current_key and self._lines:
            return

        self._current_key = track_key
        self._status = "loading"
        self._lines = [
            {"time": 0.0, "text": "Mencari lirik lagu..."},
            {"time": 1.0, "text": f"{title} — {artist or 'Unknown'}"},
        ]
        self._current_index = 0
        self.lyricsUpdated.emit()
        self.currentIndexChanged.emit(0)

        # Spawn background fetch thread
        worker = threading.Thread(
            target=self._fetch_worker,
            args=(track_key, title, artist, album or "", float(duration or 0.0)),
            daemon=True,
        )
        worker.start()

    def _cache_path(self, track_key: str) -> str:
        digest = hashlib.sha256(track_key.encode("utf-8")).hexdigest()[:24]
        return os.path.join(self._cache_dir, f"{digest}.json")

    def _fetch_worker(self, track_key: str, title: str, artist: str, album: str, duration: float):
        cache_file = self._cache_path(track_key)

        # 1. Check local cache first
        if os.path.exists(cache_file):
            try:
                with open(cache_file, "r", encoding="utf-8") as f:
                    cached = json.load(f)
                lines = cached.get("lines", [])
                status = cached.get("status", "synced")
                if lines:
                    self._fetchCompleted.emit(track_key, lines, status)
                    return
            except Exception:
                pass

        clean_t, clean_a, alt_t, alt_a = self._clean_metadata(title, artist)

        headers = {
            "User-Agent": "KDE-Dynamic-Island/2.0 (https://github.com/NXRts/Projek-Dynamic-Island)"
        }

        def query_json(url: str):
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=5.0) as resp:
                return json.loads(resp.read().decode("utf-8"))

        best_synced = None
        best_plain = None

        # 2. Try exact /api/get if both title and artist are present
        if clean_t and clean_a:
            try:
                params = {"track_name": clean_t, "artist_name": clean_a}
                if duration > 5:
                    params["duration"] = int(round(duration))
                url = "https://lrclib.net/api/get?" + urllib.parse.urlencode(params)
                data = query_json(url)
                if isinstance(data, dict):
                    best_synced = data.get("syncedLyrics")
                    best_plain = data.get("plainLyrics")
            except Exception:
                pass

        # 3. Fallback to /api/search with multiple smart query candidates
        if not best_synced:
            search_queries = []
            if clean_t and clean_a:
                search_queries.append({"track_name": clean_t, "artist_name": clean_a})
                search_queries.append({"q": f"{clean_a} {clean_t}"})
            if alt_t and alt_a:
                search_queries.append({"track_name": alt_t, "artist_name": alt_a})
                search_queries.append({"q": f"{alt_a} {alt_t}"})
            if clean_t:
                search_queries.append({"q": clean_t})

            for q_params in search_queries:
                try:
                    url = "https://lrclib.net/api/search?" + urllib.parse.urlencode(q_params)
                    results = query_json(url)
                    if isinstance(results, list) and results:
                        # Prefer results that have syncedLyrics and closest duration
                        with_synced = [r for r in results if r.get("syncedLyrics")]
                        if with_synced:
                            if duration > 5:
                                with_synced.sort(
                                    key=lambda r: abs(float(r.get("duration") or 0) - duration)
                                )
                            best_synced = with_synced[0].get("syncedLyrics")
                            break
                        elif not best_plain:
                            with_plain = [r for r in results if r.get("plainLyrics")]
                            if with_plain:
                                best_plain = with_plain[0].get("plainLyrics")
                except Exception:
                    continue

        # 4. Parse result
        lines = []
        status = "not_found"
        if best_synced:
            lines = self._parse_lrc(best_synced)
            if lines:
                status = "synced"

        if not lines and best_plain:
            lines = self._parse_plain(best_plain, duration)
            if lines:
                status = "plain"

        if lines:
            try:
                with open(cache_file, "w", encoding="utf-8") as f:
                    json.dump({"status": status, "lines": lines}, f, ensure_ascii=False)
            except Exception:
                pass
        else:
            lines = [
                {"time": 0.0, "text": "♪ Lirik belum tersedia di LRCLIB"},
                {"time": 5.0, "text": clean_t or title},
                {"time": 10.0, "text": clean_a or artist or "Nikmati alunan musik ♪"},
            ]
            status = "not_found"

        self._fetchCompleted.emit(track_key, lines, status)

    def _on_fetch_completed(self, track_key: str, lines: list, status: str):
        if track_key != self._current_key:
            return
        self._lines = lines
        self._status = status
        self._current_index = 0 if lines else -1
        self.lyricsUpdated.emit()
        self.currentIndexChanged.emit(self._current_index)

    def update_position(self, position_sec: float):
        """Update active lyric line index based on current song playback position."""
        if not self._lines:
            return

        # Slight look-ahead (0.20s) makes karaoke highlighting feel snappy
        pos = float(position_sec) + 0.20
        idx = 0
        for i, item in enumerate(self._lines):
            if item["time"] <= pos:
                idx = i
            else:
                break

        if idx != self._current_index:
            self._current_index = idx
            self.currentIndexChanged.emit(self._current_index)

