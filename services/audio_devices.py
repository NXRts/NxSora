"""
Audio Output & Input Device Switcher Service for NxSora (Fase 5)
Detects and switches active audio sinks (Speakers, Bluetooth, HDMI) and sources (Microphones)
using PipeWire / WirePlumber (wpctl).
"""

import re
import subprocess
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer


class AudioDeviceService(QObject):
    devicesChanged = pyqtSignal()
    deviceSwitched = pyqtSignal(str)

    def __init__(self, parent=None):
        super().__init__(parent)

        self._sinks = []
        self._sources = []
        self._current_sink_name = "Speaker"
        self._current_source_name = "Microphone"

        self.refresh()

        # Refresh every 3 seconds to detect plugged/unplugged headphones/HDMI/Bluetooth
        self._timer = QTimer(self)
        self._timer.setInterval(3000)
        self._timer.timeout.connect(self.refresh)
        self._timer.start()

    def _prettify_name(self, raw_name: str, is_source: bool = False) -> tuple[str, str]:
        lower = raw_name.lower()
        if "hdmi" in lower or "dp" in lower or "displayport" in lower:
            return "Monitor / TV HDMI", "tv"
        elif "bluez" in lower or "bluetooth" in lower or "buds" in lower or "airpods" in lower or "headphone" in lower or "headset" in lower:
            return "Headphones / TWS", "headphones"
        elif "camera" in lower or "webcam" in lower:
            return "Mic Webcam", "mic"
        elif is_source:
            return "Mikrofon Laptop", "mic"
        else:
            return "Speaker Laptop", "speaker"

    @pyqtSlot()
    def refresh(self):
        try:
            res = subprocess.run(
                ["wpctl", "status"],
                capture_output=True,
                text=True,
                timeout=1.0
            )
            if res.returncode != 0:
                return

            output = res.stdout
            sinks = []
            sources = []
            current_section = None

            for line in output.splitlines():
                stripped = line.strip()
                if "Sinks:" in line:
                    current_section = "sinks"
                    continue
                elif "Sources:" in line:
                    current_section = "sources"
                    continue
                elif "Filters:" in line or "Streams:" in line or "Video" in line or "Settings" in line:
                    current_section = None
                    continue

                if current_section in ("sinks", "sources"):
                    m = re.search(r"([*]?)\s+(\d+)\.\s+(.+?)(?:\s+\[vol:\s*([\d\.]+)\])?$", stripped)
                    if m:
                        is_default = bool(m.group(1))
                        dev_id = int(m.group(2))
                        name = m.group(3).strip()
                        vol = int(float(m.group(4)) * 100) if m.group(4) else 50
                        is_src = (current_section == "sources")
                        clean_name, icon = self._prettify_name(name, is_src)

                        item = {
                            "id": dev_id,
                            "rawName": name,
                            "name": clean_name,
                            "isDefault": is_default,
                            "volume": vol,
                            "icon": icon
                        }

                        if current_section == "sinks":
                            sinks.append(item)
                            if is_default:
                                self._current_sink_name = clean_name
                        else:
                            sources.append(item)
                            if is_default:
                                self._current_source_name = clean_name

            if sinks != self._sinks or sources != self._sources:
                self._sinks = sinks
                self._sources = sources
                self.devicesChanged.emit()

        except Exception:
            pass

    @pyqtProperty(list, notify=devicesChanged)
    def sinks(self) -> list:
        return self._sinks

    @pyqtProperty(list, notify=devicesChanged)
    def sources(self) -> list:
        return self._sources

    @pyqtProperty(str, notify=devicesChanged)
    def currentSinkName(self) -> str:
        return self._current_sink_name

    @pyqtProperty(str, notify=devicesChanged)
    def currentSourceName(self) -> str:
        return self._current_source_name

    @pyqtSlot(int)
    def setDefaultSink(self, dev_id: int):
        try:
            subprocess.run(["wpctl", "set-default", str(dev_id)], check=True, timeout=1.0)
            self.refresh()
            for s in self._sinks:
                if s["id"] == dev_id:
                    self.deviceSwitched.emit(f"Audio Output: {s['name']}")
                    break
        except Exception:
            pass

    @pyqtSlot(int)
    def setDefaultSource(self, dev_id: int):
        try:
            subprocess.run(["wpctl", "set-default", str(dev_id)], check=True, timeout=1.0)
            self.refresh()
            for s in self._sources:
                if s["id"] == dev_id:
                    self.deviceSwitched.emit(f"Audio Input: {s['name']}")
                    break
        except Exception:
            pass

