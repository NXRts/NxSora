"""
KDE Connect Quick Share Service for NxSora
Enables 1-click sharing of files from the Wayland File Shelf directly to paired
smartphones (Android / iOS) via kdeconnect-cli.
"""

import os
import re
import shutil
import subprocess
import threading
from pathlib import Path

from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QTimer


class KdeConnectService(QObject):
    devicesChanged = pyqtSignal()
    shareStatusChanged = pyqtSignal(bool, str)

    def __init__(self, parent=None):
        super().__init__(parent)

        self._cli_path = shutil.which("kdeconnect-cli")
        self._is_available = bool(self._cli_path)
        self._devices = []
        self._default_device_name = ""
        self._default_device_id = ""
        self._last_status = "Siap berbagi ke HP"
        self._is_sharing = False

        if self._is_available:
            self.refresh_devices()
            # Periodic scan every 60 seconds
            self._timer = QTimer(self)
            self._timer.setInterval(60000)
            self._timer.timeout.connect(self.refresh_devices_async)
            self._timer.start()

    @pyqtSlot()
    def refresh_devices_async(self):
        """Asynchronously refreshes available and paired devices."""
        if not self._is_available:
            return
        thread = threading.Thread(target=self.refresh_devices, daemon=True)
        thread.start()

    @pyqtSlot()
    def refresh_devices(self):
        """Scans for paired and available KDE Connect devices."""
        if not self._is_available:
            return

        try:
            # Query all paired devices
            res = subprocess.run(
                ["kdeconnect-cli", "-l"],
                capture_output=True, text=True, timeout=3.0
            )
            # Query reachable devices
            res_avail = subprocess.run(
                ["kdeconnect-cli", "-a"],
                capture_output=True, text=True, timeout=3.0
            )
            avail_ids = set()
            if res_avail.returncode == 0:
                avail_ids = self._extract_avail_ids(res_avail.stdout)

            devs = self.parse_device_output(res.stdout, avail_ids) if res.returncode == 0 else []

            self._devices = devs
            if devs:
                # Prefer first reachable device, else first paired
                chosen = next((d for d in devs if d["isReachable"]), devs[0])
                self._default_device_name = chosen["name"]
                self._default_device_id = chosen["id"]
            else:
                self._default_device_name = ""
                self._default_device_id = ""

            self.devicesChanged.emit()
        except Exception:
            pass

    @staticmethod
    def _extract_avail_ids(stdout_avail: str) -> set:
        avail = set()
        for line in stdout_avail.splitlines():
            m = re.search(r':\s*([a-zA-Z0-9_-]+)', line)
            if m:
                avail.add(m.group(1).strip())
        return avail

    @staticmethod
    def parse_device_output(stdout_paired: str, avail_ids: set = None) -> list:
        if avail_ids is None:
            avail_ids = set()
        devs = []
        for line in stdout_paired.splitlines():
            m = re.match(r'-\s*(.+?):\s*([a-zA-Z0-9_-]+)\s*\((.*?)\)', line)
            if m:
                d_name = m.group(1).strip()
                d_id = m.group(2).strip()
                d_status = m.group(3).strip()
                is_reachable = (d_id in avail_ids) or ("reachable" in d_status.lower())
                devs.append({
                    "name": d_name,
                    "id": d_id,
                    "isReachable": is_reachable,
                    "isPaired": True,
                })
        return devs

    @pyqtSlot(str)
    @pyqtSlot(str, str)
    def shareFile(self, file_path: str, device_id: str = ""):
        """Sends a file or directory to a KDE Connect smartphone asynchronously."""
        if not self._is_available:
            self._last_status = "KDE Connect tidak terpasang"
            self.shareStatusChanged.emit(False, self._last_status)
            return

        p = Path(file_path)
        if not p.exists():
            self._last_status = f"Berkas tidak ditemukan: {p.name}"
            self.shareStatusChanged.emit(False, self._last_status)
            return

        target_id = device_id or self._default_device_id
        target_name = self._default_device_name or "HP"

        # Find friendly name if specific device_id given
        if device_id:
            for d in self._devices:
                if d["id"] == device_id:
                    target_name = d["name"]
                    break

        self._is_sharing = True
        self._last_status = f"Mengirim {p.name} ke {target_name}..."
        self.shareStatusChanged.emit(True, self._last_status)

        thread = threading.Thread(
            target=self._share_worker,
            args=(str(p.resolve()), target_id, target_name, p.name),
            daemon=True
        )
        thread.start()

    def _share_worker(self, full_path: str, target_id: str, target_name: str, file_name: str):
        """Worker thread to run kdeconnect-cli --share without blocking UI."""
        try:
            cmd = ["kdeconnect-cli", "--share", full_path]
            if target_id:
                cmd.extend(["-d", target_id])

            proc = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
            self._is_sharing = False

            if proc.returncode == 0:
                self._last_status = f"✓ {file_name} berhasil dikirim ke {target_name}!"
                self.shareStatusChanged.emit(True, self._last_status)
            else:
                err_msg = proc.stderr.strip() or proc.stdout.strip() or "Koneksi terputus"
                self._last_status = f"Gagal kirim: {err_msg}"
                self.shareStatusChanged.emit(False, self._last_status)
        except Exception as e:
            self._is_sharing = False
            self._last_status = f"Gagal: {str(e)}"
            self.shareStatusChanged.emit(False, self._last_status)

    # --- Properties ---

    @pyqtProperty(bool, notify=devicesChanged)
    def available(self) -> bool:
        return self._is_available

    @pyqtProperty(bool, notify=devicesChanged)
    def hasDevices(self) -> bool:
        return len(self._devices) > 0

    @pyqtProperty(str, notify=devicesChanged)
    def defaultDeviceName(self) -> str:
        return self._default_device_name

    @pyqtProperty(str, notify=devicesChanged)
    def defaultDeviceId(self) -> str:
        return self._default_device_id

    @pyqtProperty("QVariantList", notify=devicesChanged)
    def devices(self):
        return self._devices

    @pyqtProperty(str, notify=shareStatusChanged)
    def lastStatus(self) -> str:
        return self._last_status

    @pyqtProperty(bool, notify=shareStatusChanged)
    def isSharing(self) -> bool:
        return self._is_sharing
