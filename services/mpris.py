"""
MPRIS Media Player Service
Integrates with Spotify, Chrome, Firefox, VLC, and other MPRIS-compliant players.
"""

from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, QTimer
from PyQt6.QtDBus import QDBusConnection, QDBusInterface, QDBusMessage
import os
import time
import subprocess
from services.color_extractor import ColorExtractor


class MprisService(QObject):
    mediaChanged = pyqtSignal()
    positionChanged = pyqtSignal(float, float)  # position_sec, duration_sec

    def __init__(self, parent=None):
        super().__init__(parent)
        self.bus = QDBusConnection.sessionBus()
        self.active_player = None
        self.title = ""
        self.artist = ""
        self.album = ""
        self.art_url = ""
        self.accent_color = "#38bdf8"
        self.status = "Stopped"  # Playing, Paused, Stopped
        self.position = 0.0
        self.duration = 0.0
        
        # Connect to DBus signals
        self.bus.connect(
            "",
            "/org/mpris/MediaPlayer2",
            "org.freedesktop.DBus.Properties",
            "PropertiesChanged",
            self._on_properties_changed
        )
        
        # Connect to service owner changes (detect player start/stop)
        self.bus.connect(
            "org.freedesktop.DBus",
            "/org/freedesktop/DBus",
            "org.freedesktop.DBus",
            "NameOwnerChanged",
            self._on_name_owner_changed
        )

        # Poll timer for smooth playback progress
        self.poll_timer = QTimer(self)
        self.poll_timer.setInterval(1000)
        self.poll_timer.timeout.connect(self._poll_position)

        # Initial detection
        self.refresh_players()

    def refresh_players(self):
        iface = QDBusInterface("org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", self.bus)
        reply = iface.call("ListNames")
        if not reply.arguments():
            return
            
        players = [str(n) for n in reply.arguments()[0] if str(n).startswith("org.mpris.MediaPlayer2")]
        
        # Prefer currently playing player, or first available
        best_player = None
        for p in players:
            p_iface = QDBusInterface(p, "/org/mpris/MediaPlayer2", "org.freedesktop.DBus.Properties", self.bus)
            res = p_iface.call("Get", "org.mpris.MediaPlayer2.Player", "PlaybackStatus")
            if res.arguments() and str(res.arguments()[0]) == "Playing":
                best_player = p
                break
        
        if not best_player and players:
            best_player = players[0]

        if best_player:
            self._set_active_player(best_player)
        else:
            self.active_player = None
            self.status = "Stopped"
            self.title = ""
            self.artist = ""
            self.album = ""
            self.art_url = ""
            self.duration = 0.0
            self.position = 0.0
            self.poll_timer.stop()
            self.mediaChanged.emit()

    def _set_active_player(self, player_service):
        self.active_player = player_service
        self._update_player_state()

    @pyqtSlot(QDBusMessage)
    def _on_name_owner_changed(self, msg):
        args = msg.arguments()
        if len(args) >= 3:
            name = str(args[0])
            old_owner = str(args[1])
            new_owner = str(args[2])
            if name.startswith("org.mpris.MediaPlayer2"):
                if not new_owner:
                    # Player closed
                    if self.active_player == name:
                        self.refresh_players()
                else:
                    # New player launched
                    self.refresh_players()

    @pyqtSlot(QDBusMessage)
    def _on_properties_changed(self, msg):
        try:
            if not self.active_player:
                self.refresh_players()
                return
            self._update_player_state()
        except Exception as e:
            print(f"[MPRIS] Warning in properties changed: {e}")

    def _update_player_state(self):
        if not self.active_player:
            return

        try:
            p_iface = QDBusInterface(self.active_player, "/org/mpris/MediaPlayer2", "org.freedesktop.DBus.Properties", self.bus)
            
            # Get PlaybackStatus
            status_reply = p_iface.call("Get", "org.mpris.MediaPlayer2.Player", "PlaybackStatus")
            if status_reply.arguments():
                self.status = str(status_reply.arguments()[0])
            else:
                self.status = "Stopped"

            # Get Metadata
            meta_reply = p_iface.call("Get", "org.mpris.MediaPlayer2.Player", "Metadata")
            meta = {}
            if meta_reply.arguments():
                raw_meta = meta_reply.arguments()[0]
                if isinstance(raw_meta, dict):
                    meta = raw_meta
                elif hasattr(raw_meta, "value") and isinstance(raw_meta.value(), dict):
                    meta = raw_meta.value()

            # Title
            self.title = str(meta.get("xesam:title", ""))
            
            # Artist (can be string or list)
            artists = meta.get("xesam:artist", "")
            if isinstance(artists, (list, tuple)):
                self.artist = ", ".join([str(a) for a in artists])
            else:
                self.artist = str(artists)

            # Album
            self.album = str(meta.get("xesam:album", ""))

            # Art URL
            raw_art = str(meta.get("mpris:artUrl", ""))
            if raw_art.startswith("file://") or raw_art.startswith("https://") or raw_art.startswith("http://"):
                self.art_url = raw_art
            else:
                self.art_url = ""

            # Extract dynamic ambient color
            self.accent_color = ColorExtractor.get_accent_color(self.art_url, "#38bdf8")

            # Duration in microseconds -> seconds
            length_us = meta.get("mpris:length", 0)
            try:
                self.duration = float(length_us) / 1_000_000.0
            except (ValueError, TypeError):
                self.duration = 0.0

            self._poll_position()
            
            if self.status == "Playing":
                if not self.poll_timer.isActive():
                    self.poll_timer.start()
            else:
                self.poll_timer.stop()

            self.mediaChanged.emit()
        except Exception as e:
            print(f"[MPRIS] Warning updating player state: {e}")

    def _poll_position(self):
        if not self.active_player:
            return
        p_iface = QDBusInterface(self.active_player, "/org/mpris/MediaPlayer2", "org.freedesktop.DBus.Properties", self.bus)
        pos_reply = p_iface.call("Get", "org.mpris.MediaPlayer2.Player", "Position")
        if pos_reply.arguments():
            try:
                self.position = float(pos_reply.arguments()[0]) / 1_000_000.0
                self.positionChanged.emit(self.position, self.duration)
            except (ValueError, TypeError):
                pass

    def play_pause(self):
        if not self.active_player:
            return
        p_iface = QDBusInterface(self.active_player, "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", self.bus)
        p_iface.call("PlayPause")
        QTimer.singleShot(150, self._update_player_state)

    def next(self):
        if not self.active_player:
            return
        p_iface = QDBusInterface(self.active_player, "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", self.bus)
        p_iface.call("Next")
        QTimer.singleShot(150, self._update_player_state)

    def previous(self):
        if not self.active_player:
            return
        p_iface = QDBusInterface(self.active_player, "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", self.bus)
        p_iface.call("Previous")
        QTimer.singleShot(150, self._update_player_state)

    def seek_ratio(self, ratio):
        if not self.active_player or self.duration <= 0:
            return
        try:
            now = time.time()
            # Update local position immediately for smooth responsive UI
            self.position = max(0.0, min(self.duration, ratio * self.duration))
            self.positionChanged.emit(self.position, self.duration)

            # Throttle D-Bus subprocess calls while dragging to max ~16 calls/sec
            if hasattr(self, "_last_seek_time") and (now - self._last_seek_time) < 0.06:
                return
            self._last_seek_time = now

            target_pos_us = int(ratio * self.duration * 1_000_000)

            # Safely fetch track_id from DBus Properties interface
            prop_iface = QDBusInterface(
                self.active_player,
                "/org/mpris/MediaPlayer2",
                "org.freedesktop.DBus.Properties",
                self.bus
            )
            track_id_str = "/org/mpris/MediaPlayer2/TrackList/NoTrack"
            meta_reply = prop_iface.call("Get", "org.mpris.MediaPlayer2.Player", "Metadata")
            if meta_reply.arguments():
                raw_meta = meta_reply.arguments()[0]
                if hasattr(raw_meta, "value"):
                    raw_meta = raw_meta.value()
                if isinstance(raw_meta, dict):
                    track_id_val = raw_meta.get("mpris:trackid")
                    if track_id_val is not None:
                        val_str = str(track_id_val)
                        if val_str.startswith("/"):
                            track_id_str = val_str

            # Execute SetPosition via gdbus (handles (ox) int64 microsecond position accurately)
            try:
                subprocess.run(
                    [
                        "gdbus", "call", "--session",
                        "--dest", self.active_player,
                        "--object-path", "/org/mpris/MediaPlayer2",
                        "--method", "org.mpris.MediaPlayer2.Player.SetPosition",
                        track_id_str, str(target_pos_us)
                    ],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=0.6
                )
            except Exception:
                try:
                    subprocess.run(
                        [
                            "dbus-send", "--session",
                            f"--dest={self.active_player}",
                            "--type=method_call",
                            "/org/mpris/MediaPlayer2",
                            "org.mpris.MediaPlayer2.Player.SetPosition",
                            f"objpath:{track_id_str}",
                            f"int64:{target_pos_us}"
                        ],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                        timeout=0.6
                    )
                except Exception:
                    pass
        except Exception as e:
            print(f"[MPRIS] Warning in seek_ratio: {e}")
