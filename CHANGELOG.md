# 📜 Changelog — NxSora (Nx空)

Semua perubahan dan catatan rilis pada projek **NxSora** didokumentasikan di sini mengikuti format [Keep a Changelog](https://keepachangelog.com/id/1.0.0/).

---

## [0.1.0] - 2026-10-29 — *NxSora Initial Beta Release*

### 🌌 Identitas & Arsitektur
- **Branding Baru**: Transformasi projek menjadi **NxSora (Nx空) — The Living Sky-Notch for Linux Desktop (KDE Plasma 6 Wayland)**.
- **Standarisasi XDG**: Konfigurasi (`$XDG_CONFIG_HOME/nxsora`), Cache (`$XDG_CACHE_HOME/nxsora`), State (`$XDG_STATE_HOME/nxsora`), dan Runtime (`$XDG_RUNTIME_DIR/nxsora`).
- **Keamanan & Privasi**: Enforce izin POSIX `0600` untuk semua file state pribadi (`notifications.json`, `tasks.json`, dll.) dan filter otomatis anti-simpan untuk Password Manager (*KeePassXC, Bitwarden, 1Password, Proton Pass*).

### 🚀 Fitur Baru
- **Karaoke Synced Lyrics**: Integrasi LRCLIB asynchronous dengan cache lokal, split view `520px`, dan *click-to-seek* per baris lirik.
- **File Shelf Wayland**: Rak file sementara dengan dukungan drop zone dan seret keluar (*Native Wayland QDrag `text/uri-list`*).
- **Pomodoro Focus Timer**: Conic Ring Glow merah/biru dengan pergantian sesi otomatis dan *soft chime*.
- **Water Tracker & Eye Break**: Grafik histogram 8 jam dan timer istirahat mata 20-20-20.
- **Hardware Telemetry & TDP**: Pembacaan TDP Watt via `hwmon PPT`, suhu multi-sensor (CPU, GPU, NVMe), GPU load & VRAM, dan *power profile switcher*.
- **Bluetooth TWS & Charging HUD**: Animasi pop-up lepas-pasang earbud TWS `310x60px` dan cincin cas `310x60px`.
- **Pusat Notifikasi Split-View**: Riwayat 40 notifikasi dengan lencana kategori, copy 1-klik, DND, smart relative timestamp, dan auto-expire >48 jam.
- **System Tray Icon**: Integrasi tray di panel KDE Plasma untuk akses cepat dan status.
- **Fullscreen Auto-Hide**: Otomatis menyembunyikan notch saat aplikasi/game fullscreen aktif.
- **Privacy Dots**: Titik indikator oranye (mikrofon) dan hijau (kamera) saat PipeWire sedang menangkap audio/video.
- **Mascot Eye-Tracking**: Mata maskot melirik halus mengikuti arah kursor mouse.
- **Wi-Fi & Network Auto-Peek**: Kapsul pop-up dinamis `310x60px` saat tersambung atau terputus dari SSID Wi-Fi.
- **Smart Low-Battery Nudge**: Peringatan otomatis saat baterai laptop `<= 20%` dengan tombol aksi 1-klik "🍃 Hemat Daya".
- **Halaman Pengaturan Terpisah**: Menu Pengaturan independen di luar carousel geser 9 halaman dengan tombol navigasi `‹ Kembali` adaptif (76px) dan sakelar terpadu per-fitur.
- **Global D-Bus CLI**: Registrasi layanan D-Bus `org.nxsora.Island` dan CLI action flags (`--toggle`, `--settings`, dll.).

### 🛠️ Kualitas & Pemasangan
- **Paket AUR (`PKGBUILD`)**: Dukungan instalasi praktis di Arch Linux dan CachyOS via `yay -S nxsora-git`.
- **Skrip Pemasangan (`install.sh`)**: Pengecekan dependensi dan pendaftaran desktop entry / autostart.
- **Unit Tests Suite (`tests/`)**: 21 tes otomatis mencakup parser lirik, notifikasi, bluetooth, jaringan Wi-Fi, dan sistem telemetri.
- **GitHub Actions CI**: Alur otomatisasi pengujian lint (`ruff`) dan tes unit otomatis pada matriks Python 3.11, 3.12, dan 3.13.

