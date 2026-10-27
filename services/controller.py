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

    # Mascot & Pin mode
    mascotModeChanged = pyqtSignal(bool)
    isPinnedChanged = pyqtSignal(bool)

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

        # Mascot mode toggle (Resting Eyes vs Digital Clock)
        self._mascot_mode = False
        self._is_pinned = False

        # Island UI State:
        # "idle", "music", "hud-volume", "hud-battery", "hud-notification", "expanded-hub"
        self._state = "idle"
        self._is_expanded = False
        self._previous_compact_state = "idle"
        self._active_hub_page = 0

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

        self.timer_service.timerTick.connect(self._on_timer_tick)
        self.timer_service.timerFinished.connect(self._on_timer_finished)
        self.timer_service.timerStateChanged.connect(lambda _: self.timerChanged.emit())

        self.system.networkUpdated.connect(lambda d, u: self.networkChanged.emit())
        self.system.nightLightChanged.connect(lambda a: self.nightLightChanged.emit())
        self.health.waterChanged.connect(lambda: self.waterChanged.emit())
        self.health.eyeBreakChanged.connect(lambda: self.eyeBreakChanged.emit())
        self.health.eyeBreakAlert.connect(self._on_eye_break_alert)
        self.todo.tasksChanged.connect(lambda: self.tasksChanged.emit())

        self.shelf.shelfChanged.connect(lambda: self.shelfChanged.emit())
        self.shelf.shelfGulpTriggered.connect(lambda: self.shelfGulpTriggered.emit())

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
        if not self._is_expanded:
            self._set_state("hud-volume")
            self._hud_timer.start(config.CONFIG.get("hud_volume_timeout", 2200))

    def _on_stats_updated(self, cpu, ram, text):
        self.statsChanged.emit()

    def _on_battery_updated(self, pct, plugged):
        self.batteryChanged.emit()

    def _on_power_plugged_event(self, plugged, pct):
        self.batteryChanged.emit()
        if not self._is_expanded:
            self._set_state("hud-battery")
            self._hud_timer.start(config.CONFIG.get("hud_battery_timeout", 3000))

    def _on_notification_received(self, app_name, summary, body):
        self._notif_app = app_name
        self._notif_title = summary
        self._notif_body = body
        self.notificationChanged.emit()
        if not self._is_expanded:
            self._set_state("hud-notification")
            self._hud_timer.start(config.CONFIG.get("hud_notification_timeout", 5000))

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

    # System Stats
    @pyqtProperty(int, notify=statsChanged)
    def cpuPercent(self):
        return int(round(self.system.cpu_percent))

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
        clamped = max(0, min(int(page_index), 6))
        if self._active_hub_page != clamped:
            self._active_hub_page = clamped
            self.activeHubPageChanged.emit(self._active_hub_page)

    @pyqtSlot()
    def toggleExpand(self):
        """Toggle between compact pill and expanded view"""
        if self._is_expanded:
            self.collapse()
        else:
            if self.mediaHasTrack:
                self._active_hub_page = 1  # Music page
            else:
                self._active_hub_page = 0  # System page
            self.activeHubPageChanged.emit(self._active_hub_page)
            self._set_state("expanded-hub")

    @pyqtSlot()
    def collapse(self):
        self._hud_timer.stop()
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
    def expandToShelf(self):
        """Automatically expand to Page 6 (File Shelf) when a file is dragged over the notch."""
        self._active_hub_page = 6
        self.activeHubPageChanged.emit(6)
        self._set_state("expanded-hub")

    @pyqtSlot(int)
    def openHubPage(self, page_index):
        self._active_hub_page = max(0, min(page_index, 6))
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
        self.notifications.trigger_test(
            "Dynamic Island Aktif!",
            "Semua sistem KDE Plasma 6 Wayland berfungsi normal."
        )

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

    @pyqtSlot()
    def toggleNightLight(self):
        self.system.toggle_night_light()

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
