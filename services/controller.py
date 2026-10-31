"""
Island Controller
Central QObject bridge linking all backend services directly to QML.
"""

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer
from services.mpris import MprisService
from services.volume import VolumeService
from services.system import SystemService
from services.notifications import NotificationService
from services.timer import TimerService
from services.health import HealthService
from services.todo import TodoService
from services.lyrics import LyricsService
from services.shelf import ShelfService
from services.bluetooth import BluetoothService
from services.hardware_hud import HardwareHudService
from services.privacy import PrivacyService
from services.network import NetworkService
from services.workspace import WorkspaceService
from services.weather import WeatherService
from services.kdeconnect import KdeConnectService
from services.prayer import PrayerService
from services.visualizer import AudioVisualizerService
from services.clipboard import ClipboardService
from services.audio_devices import AudioDeviceService
from services.voicenote import VoiceNoteService
from services.colorpicker import ColorPickerService
from services.location import LocationService
from PyQt6.QtCore import QVariant
import config


class IslandController(QObject):
    # Core state change signal
    stateChanged = pyqtSignal(str)
    isExpandedChanged = pyqtSignal(bool)

    # Media & Lyrics signals
    mediaChanged = pyqtSignal()
    mediaProgressChanged = pyqtSignal()
    lyricsChanged = pyqtSignal()
    currentLyricIndexChanged = pyqtSignal(int)
    lyricsModeChanged = pyqtSignal(bool)

    # Volume signals
    volumeChanged = pyqtSignal()

    # System signals
    statsChanged = pyqtSignal()
    batteryChanged = pyqtSignal()
    powerProfileChanged = pyqtSignal()

    # Notification signal
    notificationChanged = pyqtSignal()

    # Timer signal
    timerChanged = pyqtSignal()

    # Network & Utility signals
    networkChanged = pyqtSignal()
    nightLightChanged = pyqtSignal()
    activeHubPageChanged = pyqtSignal(int)

    # Health & Wellness signals
    waterChanged = pyqtSignal()
    eyeBreakChanged = pyqtSignal()

    # To-Do Task signals
    tasksChanged = pyqtSignal()

    # Shelf (File Stash) signals
    shelfChanged = pyqtSignal()
    shelfGulpTriggered = pyqtSignal()

    # Bluetooth & Hardware HUD signals (Fase 2)
    bluetoothChanged = pyqtSignal()
    hardwareHudChanged = pyqtSignal()

    # Privacy & Fullscreen signals (Fase 3)
    privacyChanged = pyqtSignal()
    fullscreenChanged = pyqtSignal(bool)
    settingsChanged = pyqtSignal()
    isSettingsViewOpenChanged = pyqtSignal(bool)

    # Mascot & Pin mode
    mascotModeChanged = pyqtSignal(bool)
    isPinnedChanged = pyqtSignal(bool)
    mascotSleepTriggered = pyqtSignal()
    mascotWakeTriggered = pyqtSignal()

    # Fase 4 signals: Workspace, Weather & Camera Mirror
    workspaceChanged = pyqtSignal()
    weatherChanged = pyqtSignal()
    dayProgressChanged = pyqtSignal()
    kdeConnectChanged = pyqtSignal()
    cameraMirrorStateChanged = pyqtSignal(bool)

    # Fase 5 signals: Prayer, Visualizer, Clipboard, Audio Devices, Voice Note, Color Picker
    prayerChanged = pyqtSignal()
    prayerChecklistChanged = pyqtSignal()
    prayerAlertSignal = pyqtSignal(str, str, str)  # alert_type ("headsup"|"adzan"), title, time_or_sub
    audioSpectrumChanged = pyqtSignal()
    clipboardChanged = pyqtSignal()
    audioDevicesChanged = pyqtSignal()
    voiceNoteChanged = pyqtSignal()
    colorPickerChanged = pyqtSignal()

    # Unified Location Manager signals
    locationChanged = pyqtSignal()
    locationSearchResultsChanged = pyqtSignal()
    locationSearchingChanged = pyqtSignal()
    locationDetectingChanged = pyqtSignal()
    locationStatusMessageChanged = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)

        # Sub-services
        self.mpris = MprisService(self)
        self.lyrics = LyricsService(self)
        self.volume_service = VolumeService(self)
        self.system = SystemService(self)
        self.notifications = NotificationService(self)
        self.timer_service = TimerService(self)
        self.health = HealthService(self)
        self.todo = TodoService(self)
        self.shelf = ShelfService(self)
        self.bluetooth = BluetoothService(self)
        self.hw_hud = HardwareHudService(self)
        self.privacy = PrivacyService(self)
        self.network = NetworkService(self)
        self.workspace = WorkspaceService(self)
        self.weather = WeatherService(self)
        self.kdeconnect = KdeConnectService(self)
        self.prayer = PrayerService(self)
        self.visualizer = AudioVisualizerService(self)
        self.clipboard = ClipboardService(self)
        self.audio_devices = AudioDeviceService(self)
        self.voicenote = VoiceNoteService(self.shelf, self)
        self.colorpicker = ColorPickerService(self.clipboard, self)
        self.location = LocationService(self.weather, self.prayer, self)

        # Fase 5 state
        self._prayer_alert_type = ""
        self._prayer_alert_name = ""
        self._prayer_alert_extra = ""
        self._show_prayer_page = config.CONFIG.get("show_prayer_page", True)
        self._prayer_auto_pause = config.CONFIG.get("prayer_auto_pause", True)
        self._prayer_reminder_headsup = config.CONFIG.get("prayer_reminder_headsup", True)
        self._prayer_reminder_adzan = config.CONFIG.get("prayer_reminder_adzan", True)

        # Mascot mode toggle (Resting Eyes vs Digital Clock)
        self._mascot_mode = False
        self._is_pinned = False
        self._is_settings_view_open = False
        self._settings_scroll_y = 0
        self._low_battery_nudged = False

        # Island UI State:
        # "idle", "music", "hud-volume", "hud-battery", "hud-bluetooth", "hud-hardware", "hud-notification", "expanded-hub"
        self._state = "idle"
        self._is_expanded = False
        self._previous_compact_state = "idle"
        self._active_hub_page = 0
        self._test_notif_counter = 0

        # Notification data
        self._notif_app = ""
        self._notif_title = ""
        self._notif_body = ""

        # HUD Revert Timer
        self._hud_timer = QTimer(self)
        self._hud_timer.setSingleShot(True)
        self._hud_timer.timeout.connect(self._revert_hud)

        # Wire up sub-services
        self.mpris.mediaChanged.connect(self._on_media_changed)
        self.mpris.positionChanged.connect(self._on_media_progress)
        self.lyrics.lyricsUpdated.connect(lambda: self.lyricsChanged.emit())
        self.lyrics.currentIndexChanged.connect(self._on_lyric_index_changed)
        self.lyrics.lyricsModeChanged.connect(lambda m: self.lyricsModeChanged.emit(m))

        self.volume_service.volumeChanged.connect(self._on_volume_changed)
        self.system.statsUpdated.connect(self._on_stats_updated)
        self.system.batteryChanged.connect(self._on_battery_updated)
        self.system.powerPluggedEvent.connect(self._on_power_plugged_event)
        self.notifications.notificationReceived.connect(self._on_notification_received)
        self.notifications.historyChanged.connect(lambda: self.notificationChanged.emit())

        self.timer_service.timerTick.connect(self._on_timer_tick)
        self.timer_service.timerFinished.connect(self._on_timer_finished)
        self.timer_service.timerStateChanged.connect(lambda _: self.timerChanged.emit())

        self.system.networkUpdated.connect(lambda d, u: self.networkChanged.emit())
        self.system.nightLightChanged.connect(lambda a: self.nightLightChanged.emit())
        self.system.powerProfileChanged.connect(lambda _: self.powerProfileChanged.emit())
        self.system.overheatAlert.connect(self._on_overheat_alert)
        self.health.waterChanged.connect(lambda: self.waterChanged.emit())
        self.health.eyeBreakChanged.connect(lambda: self.eyeBreakChanged.emit())
        self.health.eyeBreakAlert.connect(self._on_eye_break_alert)
        self.todo.tasksChanged.connect(lambda: self.tasksChanged.emit())

        self.shelf.shelfChanged.connect(lambda: self.shelfChanged.emit())
        self.shelf.shelfGulpTriggered.connect(lambda: self.shelfGulpTriggered.emit())

        self.bluetooth.bluetoothChanged.connect(lambda: self.bluetoothChanged.emit())
        self.bluetooth.bluetoothPeekTriggered.connect(self._on_bluetooth_peek)

        self.hw_hud.brightnessChanged.connect(lambda _: self.hardwareHudChanged.emit())
        self.hw_hud.capsLockChanged.connect(lambda _: self.hardwareHudChanged.emit())
        self.hw_hud.micMuteChanged.connect(lambda m, v: self.hardwareHudChanged.emit())
        self.hw_hud.hardwareHudTriggered.connect(self._on_hardware_hud_triggered)

        self.privacy.micInUseChanged.connect(lambda _: self.privacyChanged.emit())
        self.privacy.camInUseChanged.connect(lambda _: self.privacyChanged.emit())
        self.privacy.fullscreenActiveChanged.connect(self._on_fullscreen_changed)

        self.network.networkChanged.connect(lambda: self.networkChanged.emit())
        self.network.networkPeekTriggered.connect(self._on_network_peek)

        self.workspace.workspaceChanged.connect(lambda: self.workspaceChanged.emit())
        self.weather.weatherChanged.connect(lambda: self.weatherChanged.emit())
        self.weather.dayProgressChanged.connect(lambda: self.dayProgressChanged.emit())
        self.kdeconnect.devicesChanged.connect(lambda: self.kdeConnectChanged.emit())
        self.kdeconnect.shareStatusChanged.connect(lambda s, m: self.kdeConnectChanged.emit())

        # Fase 5 signal connects
        self.prayer.prayerChanged.connect(lambda: self.prayerChanged.emit())
        self.prayer.checklistChanged.connect(lambda: self.prayerChecklistChanged.emit())
        self.prayer.prayerHeadsUpTriggered.connect(self._on_prayer_headsup)
        self.prayer.prayerAdzanTriggered.connect(self._on_prayer_adzan)
        self.visualizer.spectrumChanged.connect(lambda: self.audioSpectrumChanged.emit())
        self.clipboard.clipboardChanged.connect(lambda: self.clipboardChanged.emit())
        self.audio_devices.devicesChanged.connect(lambda: self.audioDevicesChanged.emit())
        self.audio_devices.deviceSwitched.connect(lambda _: self.audioDevicesChanged.emit())
        self.voicenote.recordingStateChanged.connect(lambda: self.voiceNoteChanged.emit())
        self.colorpicker.pickerChanged.connect(lambda: self.colorPickerChanged.emit())
        self.colorpicker.colorPicked.connect(self._on_color_picked)
        self.todo.taskDueReminder.connect(self._on_task_due_reminder)
        self.location.locationChanged.connect(lambda: self.locationChanged.emit())
        self.location.searchResultsChanged.connect(lambda: self.locationSearchResultsChanged.emit())
        self.location.isSearchingChanged.connect(lambda: self.locationSearchingChanged.emit())
        self.location.isDetectingChanged.connect(lambda: self.locationDetectingChanged.emit())
        self.location.statusMessageChanged.connect(self.locationStatusMessageChanged.emit)

        # Initial state setup
        if self.mpris.status in ("Playing", "Paused") and self.mpris.title:
            self._state = "music"
            self.lyrics.update_track(
                self.mpris.title, self.mpris.artist, self.mpris.album, self.mpris.duration
            )
        else:
            self._state = "idle"

    # --- State Management ---

    def _set_state(self, new_state):
        if self._state != new_state:
            self._state = new_state
            self.stateChanged.emit(self._state)

            expanded = new_state.startswith("expanded-")
            if self._is_expanded != expanded:
                self._is_expanded = expanded
                self.isExpandedChanged.emit(self._is_expanded)

    def _revert_hud(self):
        if self._is_expanded:
            return
        if self.mpris.status == "Playing" or (self.mpris.title and self.mpris.status == "Paused"):
            self._set_state("music")
        else:
            self._set_state("idle")

    # --- Sub-service event handlers ---

    def _on_media_changed(self):
        self.mediaChanged.emit()
        self.lyrics.update_track(
            self.mpris.title, self.mpris.artist, self.mpris.album, self.mpris.duration
        )
        if self.mpris.status == "Playing":
            self.visualizer.setEnabled(True)
        else:
            self.visualizer.setEnabled(False)

        if not self._is_expanded and not self._state.startswith("hud-"):
            if self.mpris.status == "Playing" or (self.mpris.title and self.mpris.status == "Paused"):
                self._set_state("music")
            else:
                self._set_state("idle")

    def _on_media_progress(self, pos, dur):
        self.mediaProgressChanged.emit()
        self.lyrics.update_position(pos)

    def _on_lyric_index_changed(self, idx):
        self.currentLyricIndexChanged.emit(idx)

    def _on_volume_changed(self, vol, is_muted):
        self.volumeChanged.emit()
        if not self._is_expanded and config.CONFIG.get("hud_volume_enabled", True):
            self._set_state("hud-volume")
            self._hud_timer.start(config.CONFIG.get("hud_volume_timeout", 2200))

    def _on_stats_updated(self, cpu, ram, text):
        self.statsChanged.emit()

    def _on_battery_updated(self, pct, plugged):
        self.batteryChanged.emit()
        if not plugged and pct <= 20 and not self._low_battery_nudged:
            self._low_battery_nudged = True
            self.notifications.trigger_test(
                f"Baterai Lemah ({int(round(pct))}%)",
                "Daya baterai laptop hampir habis. Segera sambungkan charger atau aktifkan Mode Hemat Daya."
            )
            if not self._is_expanded and config.CONFIG.get("hud_battery_enabled", True):
                self._set_state("hud-battery")
                self._hud_timer.start(5000)
        elif plugged or pct > 25:
            self._low_battery_nudged = False

    def _on_network_peek(self, ssid, connected, signal_pct, net_type):
        self.networkChanged.emit()
        if not self._is_expanded and config.CONFIG.get("hud_network_enabled", True):
            self._set_state("hud-network")
            self._hud_timer.start(3500)

    def _on_power_plugged_event(self, plugged, pct):
        self.batteryChanged.emit()
        if not self._is_expanded and config.CONFIG.get("hud_battery_enabled", True):
            self._set_state("hud-battery")
            self._hud_timer.start(config.CONFIG.get("hud_battery_timeout", 3500))

    def _on_bluetooth_peek(self, name, connected, battery):
        self.bluetoothChanged.emit()
        if not self._is_expanded and config.CONFIG.get("hud_bluetooth_enabled", True):
            self._set_state("hud-bluetooth")
            self._hud_timer.start(4200)

    def _on_hardware_hud_triggered(self, hud_type, label, val, active):
        self.hardwareHudChanged.emit()
        if not self._is_expanded and config.CONFIG.get("hud_hardware_enabled", True):
            self._set_state("hud-hardware")
            timeout = 1800 if hud_type == "capslock" else 2200
            self._hud_timer.start(timeout)

    def _on_prayer_headsup(self, prayer_name: str, mins_left: int):
        if not self._prayer_reminder_headsup:
            return
        self._prayer_alert_type = "headsup"
        self._prayer_alert_name = prayer_name
        self._prayer_alert_extra = f"{mins_left} min"
        self.prayerAlertSignal.emit("headsup", prayer_name, f"{mins_left} min")
        if not self._is_expanded:
            self._set_state("hud-prayer")
            self._hud_timer.start(5000)

    def _on_prayer_adzan(self, prayer_name: str, time_str: str):
        if self._prayer_auto_pause:
            try:
                self.mpris.pause()
            except Exception:
                pass
        if not self._prayer_reminder_adzan:
            return
        self._prayer_alert_type = "adzan"
        self._prayer_alert_name = prayer_name
        self._prayer_alert_extra = time_str
        self.prayerAlertSignal.emit("adzan", prayer_name, time_str)
        if not self._is_expanded:
            self._set_state("hud-prayer")
            self._hud_timer.start(7000)

    def _on_task_due_reminder(self, task_text: str, due_time: str):
        self.notifications.trigger_test(
            f"Tenggat Tugas: {task_text} ⏰",
            f"Waktu jatuh tempo tugas adalah {due_time} WIB."
        )

    def _on_color_picked(self, hex_val: str, rgb_val: str):
        self.notifications.trigger_test(
            f"Warna Disalin: {hex_val} 🎨",
            f"Format Hex {hex_val} dan {rgb_val} siap ditempel dari Clipboard."
        )

    def _on_notification_received(self, app_name, summary, body):
        self._notif_app = app_name
        self._notif_title = summary
        self._notif_body = body
        self.notificationChanged.emit()
        if not self._is_expanded and config.CONFIG.get("hud_notification_enabled", True):
            self._set_state("hud-notification")
            self._hud_timer.start(config.CONFIG.get("hud_notification_timeout", 5000))

    def _on_fullscreen_changed(self, is_fs):
        self.fullscreenChanged.emit(is_fs)
        if is_fs and config.CONFIG.get("fullscreen_autohide_enabled", True):
            if self._is_expanded:
                self.collapse()

    def _on_timer_tick(self, rem, text):
        self.timerChanged.emit()

    def _on_timer_finished(self, completed_mode="focus"):
        self.timerChanged.emit()
        if completed_mode == "focus":
            self.notifications.trigger_test(
                "Sesi Fokus 25m Selesai! 🎯",
                "Kerja bagus! Saatnya mengambil Short Break (5 menit)."
            )
        else:
            self.notifications.trigger_test(
                "Waktu Istirahat Selesai! ☕",
                "Siap kembali memulai sesi Focus Time berikutnya."
            )

    # --- PyQT Properties for QML ---

    @pyqtProperty(str, notify=stateChanged)
    def state(self):
        return self._state

    @pyqtProperty(bool, notify=isExpandedChanged)
    def isExpanded(self):
        return self._is_expanded

    # Media Properties
    @pyqtProperty(str, notify=mediaChanged)
    def mediaTitle(self):
        return self.mpris.title or "Tidak ada media"

    @pyqtProperty(str, notify=mediaChanged)
    def mediaArtist(self):
        return self.mpris.artist or "Tidak ada artis"

    @pyqtProperty(str, notify=mediaChanged)
    def mediaAlbum(self):
        return self.mpris.album or ""

    @pyqtProperty(str, notify=mediaChanged)
    def mediaArtUrl(self):
        return self.mpris.art_url

    @pyqtProperty(str, notify=mediaChanged)
    def mediaAccentColor(self):
        return getattr(self.mpris, "accent_color", "#38bdf8")

    @pyqtProperty(str, notify=mediaChanged)
    def mediaStatus(self):
        return self.mpris.status

    @pyqtProperty(bool, notify=mediaChanged)
    def mediaIsPlaying(self):
        return self.mpris.status == "Playing"

    @pyqtProperty(bool, notify=mediaChanged)
    def mediaHasTrack(self):
        return bool(self.mpris.title)

    @pyqtProperty(float, notify=mediaProgressChanged)
    def mediaPosition(self):
        return self.mpris.position

    @pyqtProperty(float, notify=mediaProgressChanged)
    def mediaDuration(self):
        return self.mpris.duration

    @pyqtProperty(float, notify=mediaProgressChanged)
    def mediaPositionRatio(self):
        if self.mpris.duration > 0:
            return min(1.0, max(0.0, self.mpris.position / self.mpris.duration))
        return 0.0

    @pyqtProperty(str, notify=mediaProgressChanged)
    def mediaPositionFormatted(self):
        mins = int(self.mpris.position) // 60
        secs = int(self.mpris.position) % 60
        return f"{mins:02d}:{secs:02d}"

    @pyqtProperty(str, notify=mediaProgressChanged)
    def mediaDurationFormatted(self):
        mins = int(self.mpris.duration) // 60
        secs = int(self.mpris.duration) % 60
        return f"{mins:02d}:{secs:02d}"

    @pyqtProperty(str, notify=mediaProgressChanged)
    def mediaRemainingFormatted(self):
        rem = max(0, int(self.mpris.duration - self.mpris.position))
        mins = rem // 60
        secs = rem % 60
        return f"-{mins:02d}:{secs:02d}"

    # --- Synced Lyrics Properties ---
    @pyqtProperty(bool, notify=lyricsModeChanged)
    def lyricsModeActive(self):
        return self.lyrics.lyricsMode

    @pyqtProperty(str, notify=lyricsChanged)
    def lyricsStatus(self):
        return self.lyrics.status

    @pyqtProperty(list, notify=lyricsChanged)
    def lyricsLines(self):
        return self.lyrics.lines

    @pyqtProperty(int, notify=currentLyricIndexChanged)
    def currentLyricIndex(self):
        return self.lyrics.currentIndex

    @pyqtProperty(str, notify=currentLyricIndexChanged)
    def currentLyricText(self):
        return self.lyrics.currentLineText

    @pyqtSlot()
    def toggleLyricsMode(self):
        self.lyrics.toggleLyricsMode()

    @pyqtSlot(bool)
    def setLyricsMode(self, active):
        self.lyrics.setLyricsMode(active)

    @pyqtSlot(float)
    def seekToLyricTime(self, seconds):
        if self.mpris.duration > 0:
            ratio = max(0.0, min(1.0, float(seconds) / self.mpris.duration))
            self.mediaSeek(ratio)
            self.lyrics.update_position(float(seconds))

    # Volume Properties
    @pyqtProperty(float, notify=volumeChanged)
    def volume(self):
        return self.volume_service.volume

    @pyqtProperty(int, notify=volumeChanged)
    def volumePercent(self):
        return int(round(self.volume_service.volume * 100))

    @pyqtProperty(bool, notify=volumeChanged)
    def isMuted(self):
        return self.volume_service.is_muted

    # Battery Properties
    @pyqtProperty(int, notify=batteryChanged)
    def batteryPercent(self):
        return int(round(self.system.battery_percent))

    @pyqtProperty(bool, notify=batteryChanged)
    def isCharging(self):
        return self.system.power_plugged

    @pyqtProperty(bool, notify=batteryChanged)
    def hasBattery(self):
        return self.system.has_battery

    @pyqtProperty(str, notify=batteryChanged)
    def batteryStatusText(self):
        if self.system.power_plugged:
            return f"Mengisi Daya {self.batteryPercent}%"
        return f"Baterai {self.batteryPercent}%"

    # System, Thermal & TDP Stats
    @pyqtProperty(int, notify=statsChanged)
    def cpuPercent(self):
        return int(round(self.system.cpu_percent))

    @pyqtProperty(int, notify=statsChanged)
    def cpuTemp(self):
        return int(round(self.system.cpu_temp))

    @pyqtProperty(str, notify=statsChanged)
    def cpuFreqText(self):
        return self.system.cpu_freq_text

    @pyqtProperty(str, constant=True)
    def cpuModel(self):
        return self.system.cpu_model

    @pyqtProperty(float, notify=statsChanged)
    def cpuTdpWatts(self):
        return float(self.system.cpu_tdp_watts)

    @pyqtProperty(float, notify=statsChanged)
    def cpuTdpMaxWatts(self):
        return float(self.system.cpu_tdp_max_watts)

    @pyqtProperty(float, notify=statsChanged)
    def cpuTdpRatio(self):
        mx = max(1.0, float(self.system.cpu_tdp_max_watts))
        return max(0.0, min(1.0, float(self.system.cpu_tdp_watts) / mx))

    @pyqtProperty(str, notify=statsChanged)
    def cpuTdpText(self):
        prefix = "~" if getattr(self.system, "cpu_tdp_is_estimated", False) else ""
        return f"{prefix}{self.system.cpu_tdp_watts:.1f} W"

    @pyqtProperty(bool, notify=statsChanged)
    def cpuTdpIsEstimated(self):
        return bool(getattr(self.system, "cpu_tdp_is_estimated", False))

    @pyqtProperty(int, notify=statsChanged)
    def gpuPercent(self):
        return int(self.system.gpu_percent)

    @pyqtProperty(int, notify=statsChanged)
    def gpuTemp(self):
        return int(round(self.system.gpu_temp))

    @pyqtProperty(int, notify=statsChanged)
    def gpuFreqMhz(self):
        return int(self.system.gpu_freq_mhz)

    @pyqtProperty(int, notify=statsChanged)
    def vramPercent(self):
        return int(self.system.vram_percent)

    @pyqtProperty(str, notify=statsChanged)
    def vramText(self):
        return self.system.vram_text

    @pyqtProperty(int, notify=statsChanged)
    def nvmeTemp(self):
        return int(round(self.system.nvme_temp))

    @pyqtProperty(int, notify=statsChanged)
    def diskPercent(self):
        return int(self.system.disk_percent)

    @pyqtProperty(str, notify=statsChanged)
    def diskText(self):
        return self.system.disk_text

    @pyqtProperty(str, notify=statsChanged)
    def topProcess(self):
        return self.system.top_process

    @pyqtProperty(str, notify=powerProfileChanged)
    def powerProfile(self):
        return self.system.power_profile

    @pyqtProperty(int, notify=statsChanged)
    def ramPercent(self):
        return int(round(self.system.ram_percent))

    @pyqtProperty(str, notify=statsChanged)
    def ramText(self):
        return self.system.ram_text

    # Notification Properties
    @pyqtProperty(str, notify=notificationChanged)
    def notifApp(self):
        return self._notif_app

    @pyqtProperty(str, notify=notificationChanged)
    def notifTitle(self):
        return self._notif_title

    @pyqtProperty(str, notify=notificationChanged)
    def notifBody(self):
        return self._notif_body

    @pyqtProperty(list, notify=notificationChanged)
    def notifHistory(self):
        return list(self.notifications.history)

    @pyqtProperty(int, notify=notificationChanged)
    def notifUnreadCount(self):
        return int(self.notifications.unread_count)

    @pyqtProperty(int, notify=notificationChanged)
    def notifTotalCount(self):
        return len(self.notifications.history)

    @pyqtProperty(bool, notify=notificationChanged)
    def notifDndEnabled(self):
        return bool(self.notifications.dnd_enabled)

    @pyqtProperty(int, notify=notificationChanged)
    def notifSelectedIndex(self):
        return int(self.notifications.selected_index)

    @pyqtProperty("QVariantMap", notify=notificationChanged)
    def selectedNotif(self):
        return dict(self.notifications.selected_item)

    # Timer / Pomodoro Properties
    @pyqtProperty(int, notify=timerChanged)
    def timerRemaining(self):
        return self.timer_service.remaining_seconds

    @pyqtProperty(str, notify=timerChanged)
    def timerFormatted(self):
        mins = self.timer_service.remaining_seconds // 60
        secs = self.timer_service.remaining_seconds % 60
        return f"{mins:02d}:{secs:02d}"

    @pyqtProperty(bool, notify=timerChanged)
    def timerRunning(self):
        return self.timer_service.is_running

    @pyqtProperty(str, notify=timerChanged)
    def timerMode(self):
        return self.timer_service.mode

    @pyqtProperty(str, notify=timerChanged)
    def timerModeLabel(self):
        return self.timer_service.mode_label

    @pyqtProperty(float, notify=timerChanged)
    def timerProgressRatio(self):
        return self.timer_service.progress_ratio

    # Network & System Info Properties
    @pyqtProperty(str, notify=networkChanged)
    def netDownSpeed(self):
        return self.system.net_down_str

    @pyqtProperty(str, notify=networkChanged)
    def netUpSpeed(self):
        return self.system.net_up_str

    @pyqtProperty(str, constant=True)
    def kernelInfo(self):
        return self.system.kernel_info

    @pyqtProperty(str, constant=True)
    def osInfo(self):
        return self.system.os_info

    @pyqtProperty(bool, notify=nightLightChanged)
    def nightLightActive(self):
        return self.system.night_light_active

    @pyqtProperty(int, notify=activeHubPageChanged)
    def activeHubPage(self):
        return self._active_hub_page

    @pyqtProperty(bool, notify=isPinnedChanged)
    def isPinned(self):
        return self._is_pinned

    @pyqtSlot()
    def togglePin(self):
        self._is_pinned = not self._is_pinned
        self.isPinnedChanged.emit(self._is_pinned)

    # --- Slots / Invocable Actions for QML ---

    @pyqtSlot(int)
    def setActiveHubPage(self, page_index):
        clamped = max(0, min(int(page_index), 11))
        if self._active_hub_page != clamped:
            self._active_hub_page = clamped
            if clamped == 8:
                self.notifications.select_notification(self.notifications.selected_index)
            self.activeHubPageChanged.emit(self._active_hub_page)

    @pyqtSlot()
    def toggleExpand(self):
        """Toggle between compact pill and expanded view"""
        if self._is_expanded:
            self.collapse()
        else:
            if self._state == "hud-bluetooth":
                self._active_hub_page = 4  # Bluetooth & Perangkat page
            elif self._state == "hud-notification":
                self._active_hub_page = 5  # Pusat Notifikasi page
                self.notifications.select_notification(0)
            elif self.mediaHasTrack:
                self._active_hub_page = 1  # Music page
            else:
                self._active_hub_page = 0  # System page
            self.activeHubPageChanged.emit(self._active_hub_page)
            self._set_state("expanded-hub")

    @pyqtSlot()
    def collapse(self):
        self._hud_timer.stop()
        if self._is_settings_view_open:
            self._is_settings_view_open = False
            self.isSettingsViewOpenChanged.emit(False)
        if self.mpris.status == "Playing" or (self.mpris.title and self.mpris.status == "Paused"):
            self._set_state("music")
        else:
            self._set_state("idle")

    @pyqtSlot()
    def expandMusic(self):
        self._active_hub_page = 1
        self.activeHubPageChanged.emit(1)
        self._set_state("expanded-hub")

    @pyqtSlot()
    def expandHub(self):
        self._active_hub_page = 0
        self.activeHubPageChanged.emit(0)
        self._set_state("expanded-hub")

    @pyqtSlot()
    def expandToWeather(self):
        """Open Page 3 (Cuaca & Waktu)."""
        self._active_hub_page = 3
        self.activeHubPageChanged.emit(3)
        self._set_state("expanded-hub")

    @pyqtSlot()
    def expandToPrayer(self):
        """Open Page 4 (Jadwal Sholat & Sun Arc)."""
        self._active_hub_page = 4
        self.activeHubPageChanged.emit(4)
        self._set_state("expanded-hub")

    @pyqtSlot()
    def expandToClipboard(self):
        """Open Page 5 (Riwayat Clipboard)."""
        self._active_hub_page = 5
        self.activeHubPageChanged.emit(5)
        self._set_state("expanded-hub")

    @pyqtSlot()
    def expandToBluetooth(self):
        """Open Page 7 (Bluetooth & Perangkat)."""
        self._active_hub_page = 7
        self.activeHubPageChanged.emit(7)
        self._set_state("expanded-hub")

    @pyqtSlot()
    def expandToNotifications(self):
        """Open Page 8 (Pusat Notifikasi) and select the latest notification."""
        self.notifications.refresh_relative_times()
        self.notifications.select_notification(0)
        self._active_hub_page = 8
        self.activeHubPageChanged.emit(8)
        self._set_state("expanded-hub")

    @pyqtSlot()
    def expandToShelf(self):
        """Automatically expand to Page 11 (File Shelf) when a file is dragged over the notch."""
        self._active_hub_page = 11
        self.activeHubPageChanged.emit(11)
        self._set_state("expanded-hub")

    @pyqtSlot(int)
    def openHubPage(self, page_index):
        self._active_hub_page = max(0, min(page_index, 11))
        if self._active_hub_page == 8:
            self.notifications.refresh_relative_times()
            self.notifications.select_notification(self.notifications.selected_index)
        self.activeHubPageChanged.emit(self._active_hub_page)
        self._set_state("expanded-hub")

    # Media controls
    @pyqtSlot()
    def mediaPlayPause(self):
        self.mpris.play_pause()

    @pyqtSlot()
    def mediaNext(self):
        self.mpris.next()

    @pyqtSlot()
    def mediaPrevious(self):
        self.mpris.previous()

    @pyqtSlot(float)
    def mediaSeek(self, ratio):
        try:
            self.mpris.seek_ratio(ratio)
        except Exception as e:
            print(f"[Controller] Warning in mediaSeek: {e}")

    # Volume controls
    @pyqtSlot(float)
    def setVolume(self, val):
        self.volume_service.set_volume(val)

    @pyqtSlot(float)
    def changeVolume(self, delta):
        self.volume_service.change_volume(delta)

    @pyqtSlot()
    def toggleMute(self):
        self.volume_service.toggle_mute()

    # Timer / Pomodoro controls
    @pyqtSlot(int)
    def startTimer(self, seconds):
        self.timer_service.start_timer(seconds)

    @pyqtSlot(str)
    def setTimerMode(self, mode):
        self.timer_service.set_mode(mode, auto_start=False)

    @pyqtSlot(str, bool)
    def setTimerModeAndStart(self, mode, auto_start):
        self.timer_service.set_mode(mode, auto_start=bool(auto_start))

    @pyqtSlot()
    def toggleTimer(self):
        self.timer_service.toggle()

    @pyqtSlot()
    def resetTimer(self):
        self.timer_service.reset()

    # Test helpers
    @pyqtSlot()
    def triggerTestNotification(self):
        samples = [
            (
                "WhatsApp",
                "Budi Santoso",
                "Halo bro! Dokumen laporan dan draft desain sudah saya kirim ya.\nTolong dicek dan kabari kalau ada revisi 🙏",
            ),
            (
                "WhatsApp",
                "Kode Keamanan",
                "Kode verifikasi WhatsApp Anda: 492-817. Jangan bagikan kode ini kepada siapa pun demi keamanan akun.",
            ),
            (
                "Telegram",
                "Linux Dev Community",
                "Rilis kernel 6.13 kini telah tersedia dengan optimasi scheduler BORE dan gaming latency ultra-rendah.",
            ),
            (
                "NxSora",
                "Sistem Siap 🚀",
                "Pusat Notifikasi Cerdas aktif. Semua modul KDE Plasma 6 Wayland berfungsi normal.",
            ),
        ]
        app_name, title, body = samples[self._test_notif_counter % len(samples)]
        self._test_notif_counter += 1
        self.notifications.trigger_test(title=title, body=body, app_name=app_name)

    # Quick System Utilities
    @pyqtSlot()
    def takeScreenshot(self):
        self.system.take_screenshot()

    @pyqtSlot()
    def lockScreen(self):
        self.system.lock_screen()

    @pyqtSlot()
    def openTerminal(self):
        self.system.open_terminal()

    @pyqtSlot()
    def openSettings(self):
        self.system.open_settings()

    # --- Dedicated Separate In-App Settings View ---
    @pyqtProperty(bool, notify=isSettingsViewOpenChanged)
    def isSettingsViewOpen(self):
        return self._is_settings_view_open

    @pyqtSlot()
    def openSettingsView(self):
        self._is_settings_view_open = True
        self.isSettingsViewOpenChanged.emit(True)
        self.expandHub()

    @pyqtSlot()
    def closeSettingsView(self):
        if self._is_settings_view_open:
            self._is_settings_view_open = False
            self.isSettingsViewOpenChanged.emit(False)

    @pyqtSlot()
    def toggleSettingsView(self):
        self._is_settings_view_open = not self._is_settings_view_open
        self.isSettingsViewOpenChanged.emit(self._is_settings_view_open)
        if self._is_settings_view_open and not self._is_expanded:
            self.expandHub()

    @pyqtProperty(int, notify=settingsChanged)
    def settingsScrollY(self) -> int:
        return self._settings_scroll_y

    @pyqtSlot(int)
    def scrollSettings(self, pos: int):
        self._settings_scroll_y = int(pos)
        self.settingsChanged.emit()

    # --- Network / Wi-Fi Peek Properties & Slots ---
    @pyqtProperty(str, notify=networkChanged)
    def networkSsid(self):
        return self.network.ssid

    @pyqtProperty(bool, notify=networkChanged)
    def networkConnected(self):
        return self.network.connected

    @pyqtProperty(int, notify=networkChanged)
    def networkSignal(self):
        return self.network.signalPercent

    @pyqtProperty(str, notify=networkChanged)
    def networkType(self):
        return self.network.netType

    @pyqtSlot()
    def triggerWifiPeekDemo(self):
        self.network.trigger_demo()

    @pyqtSlot()
    def triggerLowBatteryDemo(self):
        if not self._is_expanded:
            self._set_state("hud-battery")
            self._hud_timer.start(5000)

    @pyqtSlot()
    def toggleNightLight(self):
        self.system.toggle_night_light()

    @pyqtSlot(str)
    def setPowerProfile(self, profile):
        self.system.set_power_profile(profile)

    @pyqtSlot()
    def cyclePowerProfile(self):
        self.system.cycle_power_profile()

    def _on_overheat_alert(self, temp_c, top_proc):
        self.notifications.trigger_test(
            f"⚠️ Suhu Tinggi ({temp_c}°C)!",
            f"Proses terberat: {top_proc} · TDP: {self.cpuTdpText}. Pertimbangkan mode Balanced/Power Saver."
        )

    def _on_eye_break_alert(self):
        self.notifications.trigger_test(
            "Istirahat Mata (20-20-20)",
            "Pandang objek sejauh 20 kaki (6 meter) selama 20 detik untuk mengistirahatkan mata."
        )

    # --- Mascot Mode Properties ---
    @pyqtProperty(bool, notify=mascotModeChanged)
    def mascotMode(self):
        return self._mascot_mode

    @pyqtSlot()
    def toggleMascotMode(self):
        self._mascot_mode = not self._mascot_mode
        self.mascotModeChanged.emit(self._mascot_mode)

    # --- Health & Water Properties ---
    @pyqtProperty(int, notify=waterChanged)
    def waterIntake(self):
        return self.health.waterIntake

    @pyqtProperty(int, notify=waterChanged)
    def waterGoal(self):
        return self.health.waterGoal

    @pyqtProperty(int, notify=waterChanged)
    def waterCupSize(self):
        return self.health.waterCupSize

    @pyqtProperty(float, notify=waterChanged)
    def waterProgressRatio(self):
        return self.health.waterProgressRatio

    @pyqtProperty(int, notify=waterChanged)
    def waterPercent(self):
        return self.health.waterPercent

    @pyqtProperty(str, notify=waterChanged)
    def waterFormatted(self):
        return self.health.waterFormatted

    @pyqtProperty(list, notify=waterChanged)
    def waterHourlyBars(self):
        return self.health.waterHourlyBars

    @pyqtProperty(int, notify=eyeBreakChanged)
    def eyeBreakRemaining(self):
        return self.health.eyeBreakRemaining

    @pyqtProperty(str, notify=eyeBreakChanged)
    def eyeBreakFormatted(self):
        return self.health.eyeBreakFormatted

    @pyqtSlot()
    @pyqtSlot(int)
    def drinkWater(self, amount=0):
        self.health.drinkWater(amount)

    @pyqtSlot()
    def cycleWaterCupSize(self):
        self.health.cycleWaterCupSize()

    @pyqtSlot()
    def cycleWaterGoal(self):
        self.health.cycleWaterGoal()

    @pyqtSlot()
    def resetWater(self):
        self.health.resetWater()

    @pyqtSlot()
    def resetEyeBreak(self):
        self.health.resetEyeBreak()

    # --- To-Do Task Properties ---
    @pyqtProperty(list, notify=tasksChanged)
    def tasks(self):
        return self.todo.tasks

    @pyqtProperty(int, notify=tasksChanged)
    def tasksTotalCount(self):
        return self.todo.totalCount

    @pyqtProperty(int, notify=tasksChanged)
    def tasksDoneCount(self):
        return self.todo.doneCount

    @pyqtProperty(str, notify=tasksChanged)
    def tasksSummaryText(self):
        return self.todo.summaryText

    @pyqtSlot(str)
    def addTask(self, text):
        self.todo.addTask(text)

    @pyqtSlot(int)
    def toggleTask(self, index):
        self.todo.toggleTask(index)

    @pyqtSlot(int)
    def removeTask(self, index):
        self.todo.removeTask(index)

    @pyqtSlot()
    def clearCompletedTasks(self):
        self.todo.clearCompleted()

    # --- Wayland File Shelf Properties & Slots ---
    @pyqtProperty(list, notify=shelfChanged)
    def shelfItems(self):
        return self.shelf.items

    @pyqtProperty(int, notify=shelfChanged)
    def shelfCount(self):
        return self.shelf.count

    @pyqtSlot("QVariant")
    def addShelfFiles(self, urls):
        self.shelf.addDroppedUrls(urls)

    @pyqtSlot(int)
    def removeShelfFile(self, index):
        self.shelf.removeItem(index)

    @pyqtSlot()
    def clearShelf(self):
        self.shelf.clearShelf()

    @pyqtSlot(int)
    def openShelfFile(self, index):
        self.shelf.openItem(index)

    @pyqtSlot(int)
    def startShelfDrag(self, index):
        self.shelf.startDragOut(index)

    @pyqtSlot()
    def startShelfDragAll(self):
        self.shelf.startDragAll()

    # --- Fase 2: Bluetooth Headphones Peek & Hardware HUD Properties / Slots ---
    @pyqtProperty(bool, notify=bluetoothChanged)
    def btAdapterPowered(self):
        return bool(getattr(self.bluetooth, "adapter_powered", True))

    @pyqtProperty(list, notify=bluetoothChanged)
    def btDevicesList(self):
        return list(getattr(self.bluetooth, "devices_list", []))

    @pyqtProperty(int, notify=bluetoothChanged)
    def btConnectedCount(self):
        return int(getattr(self.bluetooth, "connected_count", 0))

    @pyqtProperty(str, notify=bluetoothChanged)
    def btDeviceName(self):
        return self.bluetooth.device_name

    @pyqtProperty(bool, notify=bluetoothChanged)
    def btDeviceConnected(self):
        return bool(self.bluetooth.device_connected)

    @pyqtProperty(int, notify=bluetoothChanged)
    def btDeviceBattery(self):
        return max(0, min(100, int(self.bluetooth.device_battery))) if self.bluetooth.device_battery >= 0 else 100

    @pyqtProperty(str, notify=bluetoothChanged)
    def btDeviceType(self):
        return getattr(self.bluetooth, "device_type", "tws")

    @pyqtProperty(int, notify=bluetoothChanged)
    def btAnimSerial(self):
        return int(getattr(self.bluetooth, "anim_serial", 0))

    @pyqtSlot(str)
    def toggleBluetoothDevice(self, address):
        self.bluetooth.toggle_device_connection(address)

    @pyqtSlot()
    def toggleBluetoothAdapter(self):
        self.bluetooth.toggle_adapter_power()

    @pyqtSlot()
    def openBluetoothSettings(self):
        self.collapse()
        self.bluetooth.open_bluetooth_settings()

    @pyqtProperty(int, notify=hardwareHudChanged)
    def brightnessPercent(self):
        return int(self.hw_hud.brightness_percent)

    @pyqtProperty(bool, notify=hardwareHudChanged)
    def capsLockOn(self):
        return bool(self.hw_hud.caps_lock_on)

    @pyqtProperty(bool, notify=hardwareHudChanged)
    def micMuted(self):
        return bool(self.hw_hud.mic_muted)

    @pyqtProperty(int, notify=hardwareHudChanged)
    def micPercent(self):
        return int(self.hw_hud.mic_percent)

    @pyqtProperty(str, notify=hardwareHudChanged)
    def hwHudType(self):
        return self.hw_hud.hud_type

    @pyqtProperty(str, notify=hardwareHudChanged)
    def hwHudLabel(self):
        return self.hw_hud.hud_label

    @pyqtProperty(int, notify=hardwareHudChanged)
    def hwHudValue(self):
        return int(self.hw_hud.hud_value)

    @pyqtProperty(bool, notify=hardwareHudChanged)
    def hwHudActive(self):
        return bool(self.hw_hud.hud_active)

    @pyqtSlot(float)
    def setBrightness(self, ratio):
        self.hw_hud.set_brightness(ratio)

    @pyqtSlot()
    def toggleMicMute(self):
        self.hw_hud.toggle_mic_mute()

    @pyqtSlot()
    def triggerTestBluetoothPeek(self):
        self.collapse()
        self.bluetooth.trigger_demo_peek()

    @pyqtSlot()
    def toggleBluetoothPeekState(self):
        self.bluetooth.trigger_demo_peek()

    @pyqtSlot()
    def triggerTestChargingPeek(self):
        self.collapse()
        self._set_state("hud-battery")
        self._hud_timer.start(3800)

    # --- Notification Center Slots ---
    @pyqtSlot(int)
    def selectNotification(self, index):
        self.notifications.select_notification(int(index))

    @pyqtSlot(int)
    def removeNotification(self, index):
        self.notifications.remove_notification(int(index))

    @pyqtSlot()
    def clearNotifications(self):
        self.notifications.clear_all()

    @pyqtSlot()
    def markAllNotificationsRead(self):
        self.notifications.mark_all_read()

    @pyqtSlot()
    def toggleNotifDnd(self):
        self.notifications.toggle_dnd()

    @pyqtSlot(result=bool)
    def copySelectedNotification(self):
        return self.notifications.copy_selected()

    # --- Privacy & Fullscreen Properties (Fase 3) ---
    @pyqtProperty(bool, notify=privacyChanged)
    def micInUse(self):
        return bool(self.privacy.micInUse)

    @pyqtProperty(bool, notify=privacyChanged)
    def camInUse(self):
        return bool(self.privacy.camInUse)

    @pyqtProperty(bool, notify=fullscreenChanged)
    def fullscreenActive(self):
        return bool(self.privacy.fullscreenActive)

    # --- Settings Slots (Fase 3) ---
    @pyqtSlot(str, result="QVariant")
    def getSetting(self, key: str):
        return config.CONFIG.get(key, None)

    @pyqtSlot(str, "QVariant")
    def setSetting(self, key: str, value):
        config.CONFIG[key] = value
        config.save_user_config(config.CONFIG)
        self.settingsChanged.emit()

    @pyqtSlot()
    def resetSettings(self):
        config.CONFIG = config.DEFAULT_CONFIG.copy()
        config.save_user_config(config.CONFIG)
        self.settingsChanged.emit()

    @pyqtSlot()
    def openConfigFile(self):
        try:
            import subprocess
            subprocess.Popen(["xdg-open", str(config.USER_CONFIG_FILE)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass

    # =========================================================================
    # FASE 4: WORKSPACE, WEATHER, CAMERA MIRROR, MASCOT 2.0 & KDE CONNECT
    # =========================================================================

    # --- Mascot 2.0 Actions ---
    @pyqtSlot()
    def triggerMascotSleep(self):
        self.mascotSleepTriggered.emit()

    @pyqtSlot()
    def triggerMascotWake(self):
        self.mascotWakeTriggered.emit()

    # --- Camera Mirror Slots ---
    @pyqtSlot()
    def openCameraMirror(self):
        if self._state != "hud-camera":
            self._previous_compact_state = self._state if self._state != "hud-camera" else "idle"
            self._set_state("hud-camera")
            self.cameraMirrorStateChanged.emit(True)

    @pyqtSlot()
    def closeCameraMirror(self):
        if self._state == "hud-camera":
            prev = self._previous_compact_state if self._previous_compact_state not in ("hud-camera",) else "idle"
            self._set_state(prev)
            self.cameraMirrorStateChanged.emit(False)

    @pyqtSlot()
    def toggleCameraMirror(self):
        if self._state == "hud-camera":
            self.closeCameraMirror()
        else:
            self.openCameraMirror()

    # --- KDE Virtual Desktop / Workspace Slots & Properties ---
    @pyqtSlot(int)
    def switchToWorkspace(self, idx: int):
        self.workspace.switchToIndex(idx)

    @pyqtSlot()
    def nextWorkspace(self):
        self.workspace.nextDesktop()

    @pyqtSlot()
    def previousWorkspace(self):
        self.workspace.previousDesktop()

    @pyqtProperty(int, notify=workspaceChanged)
    def workspaceCount(self) -> int:
        return self.workspace.count

    @pyqtProperty(int, notify=workspaceChanged)
    def currentWorkspaceIndex(self) -> int:
        return self.workspace.currentIndex

    @pyqtProperty(str, notify=workspaceChanged)
    def currentWorkspaceName(self) -> str:
        return self.workspace.currentName

    @pyqtProperty("QVariantList", notify=workspaceChanged)
    def workspacesList(self):
        return self.workspace.desktops

    # --- Live Weather & Day Progress Properties ---
    @pyqtProperty(str, notify=weatherChanged)
    def weatherTemp(self) -> str:
        return self.weather.temperature

    @pyqtProperty(int, notify=weatherChanged)
    def weatherTemperature(self) -> int:
        return self.weather.temperatureC

    @pyqtProperty(str, notify=weatherChanged)
    def weatherCondition(self) -> str:
        return self.weather.condition

    @pyqtProperty(str, notify=weatherChanged)
    def weatherIcon(self) -> str:
        return self.weather.icon

    @pyqtProperty(str, notify=weatherChanged)
    def weatherCity(self) -> str:
        return self.weather.city

    @pyqtProperty(int, notify=weatherChanged)
    def weatherHumidity(self) -> int:
        return self.weather.humidity

    @pyqtProperty(str, notify=weatherChanged)
    def weatherHumidityText(self) -> str:
        return self.weather.humidityText

    @pyqtProperty(str, notify=weatherChanged)
    def weatherWind(self) -> str:
        return self.weather.windSpeed

    @pyqtProperty(bool, notify=weatherChanged)
    def weatherIsDay(self) -> bool:
        return self.weather.isDay

    @pyqtProperty("QVariantList", notify=weatherChanged)
    def weatherHourlyForecast(self):
        return self.weather.hourlyForecast

    @pyqtProperty(str, notify=weatherChanged)
    def weatherLastUpdated(self) -> str:
        return self.weather.lastUpdated

    @pyqtProperty(bool, notify=weatherChanged)
    def weatherIsRefreshing(self) -> bool:
        return self.weather.isRefreshing

    @pyqtProperty(float, notify=dayProgressChanged)
    def dayProgressPercent(self) -> float:
        return self.weather.dayProgressPercent

    @pyqtProperty(str, notify=dayProgressChanged)
    def dayProgressText(self) -> str:
        return self.weather.dayProgressText

    @pyqtSlot()
    def refreshWeather(self):
        self.weather.refresh_weather_async()

    # --- Quick Share KDE Connect Slots & Properties ---
    @pyqtProperty(bool, notify=kdeConnectChanged)
    def kdeConnectAvailable(self) -> bool:
        return self.kdeconnect.available

    @pyqtProperty(bool, notify=kdeConnectChanged)
    def kdeConnectHasDevices(self) -> bool:
        return self.kdeconnect.hasDevices

    @pyqtProperty(str, notify=kdeConnectChanged)
    def kdeConnectDeviceName(self) -> str:
        return self.kdeconnect.defaultDeviceName

    @pyqtProperty(str, notify=kdeConnectChanged)
    def kdeConnectStatus(self) -> str:
        return self.kdeconnect.lastStatus

    @pyqtProperty(bool, notify=kdeConnectChanged)
    def kdeConnectIsSharing(self) -> bool:
        return self.kdeconnect.isSharing

    @pyqtProperty("QVariantList", notify=kdeConnectChanged)
    def kdeConnectDevices(self):
        return self.kdeconnect.devices

    @pyqtSlot(str)
    @pyqtSlot(str, str)
    def shareFileToPhone(self, file_path: str, device_id: str = ""):
        self.kdeconnect.shareFile(file_path, device_id)

    # =========================================================================
    # FASE 5: JADWAL SHOLAT & SUN ARC TRAJECTORY
    # =========================================================================

    @pyqtProperty(str, notify=prayerChanged)
    def prayerCity(self) -> str:
        return self.prayer.city

    @pyqtProperty(str, notify=prayerChanged)
    def prayerSubuh(self) -> str:
        return self.prayer.subuh

    @pyqtProperty(str, notify=prayerChanged)
    def prayerTerbit(self) -> str:
        return self.prayer.terbit

    @pyqtProperty(str, notify=prayerChanged)
    def prayerDzuhur(self) -> str:
        return self.prayer.dzuhur

    @pyqtProperty(str, notify=prayerChanged)
    def prayerAshar(self) -> str:
        return self.prayer.ashar

    @pyqtProperty(str, notify=prayerChanged)
    def prayerMaghrib(self) -> str:
        return self.prayer.maghrib

    @pyqtProperty(str, notify=prayerChanged)
    def prayerIsya(self) -> str:
        return self.prayer.isya

    @pyqtProperty(str, notify=prayerChanged)
    def prayerImsak(self) -> str:
        return self.prayer.imsak

    @pyqtProperty(str, notify=prayerChanged)
    def prayerNextName(self) -> str:
        return self.prayer.nextPrayerName

    @pyqtProperty(str, notify=prayerChanged)
    def prayerNextTime(self) -> str:
        return self.prayer.nextPrayerTime

    @pyqtProperty(str, notify=prayerChanged)
    def prayerCountdown(self) -> str:
        return self.prayer.countdownText

    @pyqtProperty(int, notify=prayerChanged)
    def prayerMinutesToNext(self) -> int:
        return self.prayer.minutesToNext

    @pyqtProperty(float, notify=prayerChanged)
    def prayerSunPosition(self) -> float:
        return self.prayer.sunPosition

    @pyqtProperty(bool, notify=prayerChanged)
    def prayerIsDaytime(self) -> bool:
        return self.prayer.isDaytime

    @pyqtProperty(int, notify=prayerChanged)
    def prayerActiveIndex(self) -> int:
        return self.prayer.activePrayerIndex

    @pyqtProperty("QVariantMap", notify=prayerChecklistChanged)
    def prayerChecklist(self) -> dict:
        return self.prayer.checklist

    @pyqtProperty(str, notify=prayerChanged)
    def prayerAlertType(self) -> str:
        return self._prayer_alert_type

    @pyqtProperty(str, notify=prayerChanged)
    def prayerAlertName(self) -> str:
        return self._prayer_alert_name

    @pyqtProperty(str, notify=prayerChanged)
    def prayerAlertExtra(self) -> str:
        return self._prayer_alert_extra

    @pyqtProperty(bool, notify=settingsChanged)
    def showPrayerPage(self) -> bool:
        return self._show_prayer_page

    @pyqtProperty(bool, notify=settingsChanged)
    def prayerAutoPause(self) -> bool:
        return self._prayer_auto_pause

    @pyqtProperty(bool, notify=settingsChanged)
    def prayerReminderHeadsup(self) -> bool:
        return self._prayer_reminder_headsup

    @pyqtProperty(bool, notify=settingsChanged)
    def prayerReminderAdzan(self) -> bool:
        return self._prayer_reminder_adzan

    @pyqtSlot(str, bool)
    def setPrayerChecked(self, prayer_name: str, checked: bool):
        self.prayer.setPrayerChecked(prayer_name, checked)

    @pyqtSlot(str)
    def setPrayerCity(self, city_name: str):
        self.prayer.setCity(city_name)

    @pyqtSlot(bool)
    def setShowPrayerPage(self, enabled: bool):
        self._show_prayer_page = bool(enabled)
        config.CONFIG["show_prayer_page"] = self._show_prayer_page
        config.save_user_config(config.CONFIG)
        self.settingsChanged.emit()

    @pyqtSlot(bool)
    def setPrayerAutoPause(self, enabled: bool):
        self._prayer_auto_pause = bool(enabled)
        config.CONFIG["prayer_auto_pause"] = self._prayer_auto_pause
        config.save_user_config(config.CONFIG)
        self.settingsChanged.emit()

    @pyqtSlot(bool)
    def setPrayerReminderHeadsup(self, enabled: bool):
        self._prayer_reminder_headsup = bool(enabled)
        config.CONFIG["prayer_reminder_headsup"] = self._prayer_reminder_headsup
        config.save_user_config(config.CONFIG)
        self.settingsChanged.emit()

    @pyqtSlot(bool)
    def setPrayerReminderAdzan(self, enabled: bool):
        self._prayer_reminder_adzan = bool(enabled)
        config.CONFIG["prayer_reminder_adzan"] = self._prayer_reminder_adzan
        config.save_user_config(config.CONFIG)
        self.settingsChanged.emit()

    # =========================================================================
    # FASE 5: REAL PIPEWIRE AUDIO SPECTRUM VISUALIZER
    # =========================================================================

    @pyqtProperty(list, notify=audioSpectrumChanged)
    def audioSpectrum(self) -> list:
        return self.visualizer.bands

    @pyqtProperty(bool, notify=audioSpectrumChanged)
    def isVisualizerActive(self) -> bool:
        return self.visualizer.isEnabled

    @pyqtSlot(bool)
    def setVisualizerEnabled(self, enabled: bool):
        self.visualizer.setEnabled(enabled)

    # =========================================================================
    # FASE 5: CLIPBOARD HISTORY & QUICK PASTE
    # =========================================================================

    @pyqtProperty(list, notify=clipboardChanged)
    def clipboardHistory(self) -> list:
        return self.clipboard.history

    @pyqtProperty(int, notify=clipboardChanged)
    def clipboardCount(self) -> int:
        return self.clipboard.count

    @pyqtProperty(int, notify=clipboardChanged)
    def clipboardPinnedCount(self) -> int:
        return self.clipboard.pinnedCount

    @pyqtSlot(str)
    def copyClipboardItem(self, item_id: str):
        self.clipboard.copyItem(item_id)

    @pyqtSlot(str)
    def toggleClipboardPin(self, item_id: str):
        self.clipboard.togglePin(item_id)

    @pyqtSlot(str)
    def deleteClipboardItem(self, item_id: str):
        self.clipboard.deleteItem(item_id)

    @pyqtSlot()
    def clearClipboardUnpinned(self):
        self.clipboard.clearUnpinned()

    @pyqtSlot(str)
    def setClipboardSearch(self, query: str):
        self.clipboard.setSearchQuery(query)

    # =========================================================================
    # FASE 5: AUDIO OUTPUT & INPUT DEVICE SWITCHER
    # =========================================================================

    @pyqtProperty(list, notify=audioDevicesChanged)
    def audioSinks(self) -> list:
        return self.audio_devices.sinks

    @pyqtProperty(list, notify=audioDevicesChanged)
    def audioSources(self) -> list:
        return self.audio_devices.sources

    @pyqtProperty(str, notify=audioDevicesChanged)
    def currentSinkName(self) -> str:
        return self.audio_devices.currentSinkName

    @pyqtProperty(str, notify=audioDevicesChanged)
    def currentSourceName(self) -> str:
        return self.audio_devices.currentSourceName

    @pyqtSlot(int)
    def setDefaultAudioSink(self, dev_id: int):
        self.audio_devices.setDefaultSink(dev_id)

    @pyqtSlot(int)
    def setDefaultAudioSource(self, dev_id: int):
        self.audio_devices.setDefaultSource(dev_id)

    # =========================================================================
    # FASE 5: QUICK VOICE NOTE RECORDER
    # =========================================================================

    @pyqtProperty(bool, notify=voiceNoteChanged)
    def isRecordingVoiceNote(self) -> bool:
        return self.voicenote.isRecording

    @pyqtProperty(str, notify=voiceNoteChanged)
    def voiceNoteDurationFormatted(self) -> str:
        return self.voicenote.durationFormatted

    @pyqtProperty(int, notify=voiceNoteChanged)
    def voiceNoteDurationSeconds(self) -> int:
        return self.voicenote.durationSeconds

    @pyqtProperty(str, notify=voiceNoteChanged)
    def voiceNoteLastPath(self) -> str:
        return self.voicenote.lastSavedPath

    @pyqtSlot()
    def toggleVoiceNoteRecording(self):
        self.voicenote.toggleRecording()

    @pyqtSlot()
    def startVoiceNoteRecording(self):
        self.voicenote.startRecording()

    @pyqtSlot()
    def stopVoiceNoteRecording(self):
        self.voicenote.stopRecording()

    @pyqtSlot()
    def cancelVoiceNoteRecording(self):
        self.voicenote.cancelRecording()

    # =========================================================================
    # FASE 5: SCREEN COLOR PICKER (EYEDROPPER)
    # =========================================================================

    @pyqtProperty(str, notify=colorPickerChanged)
    def lastPickedHex(self) -> str:
        return self.colorpicker.lastHex

    @pyqtProperty(str, notify=colorPickerChanged)
    def lastPickedRgb(self) -> str:
        return self.colorpicker.lastRgb

    @pyqtProperty(bool, notify=colorPickerChanged)
    def isColorPickerActive(self) -> bool:
        return self.colorpicker.isActive

    @pyqtSlot()
    def pickScreenColor(self):
        self.colorpicker.pickColor()

    # =========================================================================
    # FASE 5: TO-DO EDIT & DUE TIME
    # =========================================================================

    @pyqtSlot(int, str)
    def editTodoTask(self, index: int, new_text: str):
        self.todo.editTask(index, new_text)

    @pyqtSlot(int, str)
    def setTodoDueTime(self, index: int, due_time: str):
        self.todo.setDueTime(index, due_time)

    # =========================================================================
    # FASE 5: UNIFIED LOCATION MANAGER (WEATHER & PRAYER)
    # =========================================================================

    @pyqtProperty(str, notify=locationChanged)
    def locationCity(self) -> str:
        return self.location.city

    @pyqtProperty(str, notify=locationChanged)
    def locationRegion(self) -> str:
        return self.location.region

    @pyqtProperty(float, notify=locationChanged)
    def locationLatitude(self) -> float:
        return self.location.latitude

    @pyqtProperty(float, notify=locationChanged)
    def locationLongitude(self) -> float:
        return self.location.longitude

    @pyqtProperty(float, notify=locationChanged)
    def locationTimezoneOffset(self) -> float:
        return self.location.timezoneOffset

    @pyqtProperty(int, notify=locationChanged)
    def locationIhtiathMinutes(self) -> int:
        return self.location.ihtiathMinutes

    @pyqtProperty(bool, notify=locationSearchingChanged)
    def locationIsSearching(self) -> bool:
        return self.location.isSearching

    @pyqtProperty(bool, notify=locationDetectingChanged)
    def locationIsDetecting(self) -> bool:
        return self.location.isDetecting

    @pyqtProperty(list, notify=locationSearchResultsChanged)
    def locationSearchResults(self) -> list:
        return self.location.searchResults

    @pyqtProperty(str, notify=locationStatusMessageChanged)
    def locationStatusMessage(self) -> str:
        return self.location.statusMessage

    @pyqtSlot(str)
    def searchLocation(self, query: str):
        self.location.searchLocation(query)

    @pyqtSlot()
    def detectLocationAuto(self):
        self.location.detectLocationAuto()

    @pyqtSlot(int)
    def selectLocationResult(self, index: int):
        self.location.selectSearchResult(index)

    @pyqtSlot(int)
    def setLocationIhtiath(self, minutes: int):
        self.location.setIhtiathMinutes(minutes)


