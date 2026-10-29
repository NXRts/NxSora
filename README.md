# 🌌 NxSora (Nx空) — The Living Sky-Notch for Linux Desktop

<p align="center">
  <img src="assets/logo.svg" width="96" height="96" alt="NxSora Logo" />
</p>

<p align="center">
  <strong>Mahkota cerdas di cakrawala desktop Linux Anda, memadukan utilitas produktivitas modern dengan estetika Wayland yang luwes.</strong>
</p>

<p align="center">
  <a href="https://kde.org/"><img src="https://img.shields.io/badge/KDE_Plasma-6.0+-blue?logo=kde&logoColor=white" alt="KDE Plasma 6" /></a>
  <a href="https://wayland.freedesktop.org/"><img src="https://img.shields.io/badge/Display-Wayland-green?logo=wayland&logoColor=white" alt="Wayland" /></a>
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/Python-3.11_|_3.12_|_3.13-yellow?logo=python&logoColor=white" alt="Python 3.11+" /></a>
  <a href="https://riverbankcomputing.com/software/pyqt/"><img src="https://img.shields.io/badge/GUI-PyQt6_&_QML-success?logo=qt&logoColor=white" alt="PyQt6 & QML" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-GPL--3.0-orange" alt="License: GPL-3.0" /></a>
  <a href="https://github.com/NXRts/NxSora/actions/workflows/ci.yml"><img src="https://github.com/NXRts/NxSora/actions/workflows/ci.yml/badge.svg" alt="NxSora CI" /></a>
  <a href="packaging/aur/PKGBUILD"><img src="https://img.shields.io/badge/AUR-PKGBUILD_Ready-blueviolet?logo=archlinux&logoColor=white" alt="AUR PKGBUILD" /></a>
</p>

<p align="center">
  <a href="README.md"><strong>Bahasa Indonesia</strong></a> | <a href="README.en.md"><strong>English</strong></a>
</p>

---

## 🧭 Navigasi Cepat Dokumen
- 🗺️ **Roadmap Publik**: [`ROADMAP.md`](ROADMAP.md) — Rencana pengembangan bertahap dan status fitur.
- 📜 **Catatan Rilis**: [`CHANGELOG.md`](CHANGELOG.md) — Riwayat versi dan perubahan rilis `v0.1.0`.
- 🤝 **Panduan Kontribusi**: [`CONTRIBUTING.md`](CONTRIBUTING.md) — Standar kontribusi, testing, dan pull request.
- 🌌 **Spesifikasi & Filosofi**: [`docs/NXSORA.md`](docs/NXSORA.md) — Asal-usul nama, bahasa desain Neo-Sora, dan palet warna.
- 🔬 **Master Plan Detail**: [`docs/NEXT.md`](docs/NEXT.md) — Analisis arsitektur dan komparasi ekosistem dynamic island.
- 📖 **Panduan Penggunaan**: [`docs/TUTORIAL.md`](docs/TUTORIAL.md) — Navigasi gestur, klik, dan pintasan keyboard.

---

## ⚡ Karakteristik & Efisiensi Sistem
NxSora dirancang untuk efisiensi tinggi pada lingkungan desktop modern:
- **Penggunaan CPU Ringan**: **< 0.5% CPU** saat idle (rata-rata terukur selama 60 detik pada CachyOS Linux, prosesor AMD Ryzen / Intel Core i5 saat kapsul resting).
- **Konsumsi Memori Hemat**: **~85 MB RAM** (arsitektur QML QtQuick 2 + daemon Python terpadu).
- **100% Click-Through**: Area layar di luar bentuk fisik notch sepenuhnya tembus klik dan tidak menghalangi jendela aplikasi lain.
- **Wayland Native**: Terintegrasi menggunakan protokol `layer-shell-qt` di lapisan `LayerOverlay`.

---

## ✨ 10 Halaman Terpadu NxSora

1. **Resting Mascot Eyes & Closed Capsule (`150x28px`)**:
   - Mata maskot hidup dengan **Cursor Eye-Tracking** (melirik halus mengikuti kursor mouse saat mendekati area notch) dan kedipan acak.
   - Mode jam digital dengan **Cincin Baterai Melingkar (`#33e07a`)** dan **Privacy Dots** (titik hijau kamera & oranye mikrofon via PipeWire).
2. **Pemutar Musik & Karaoke Lirik LRCLIB (`420px → 520px` Split View)**:
   - Sampul album, *seekbar* interaktif (`MM:SS` & sisa waktu `-MM:SS`), dan integrasi lirik tersinkronisasi otomatis dari **LRCLIB**.
   - **Click-to-Seek**: klik baris lirik mana saja untuk langsung melompat ke detik lagu yang dipilih.
3. **Pintasan Cepat (Quick Controls)**:
   - Pengatur volume PipeWire, slider kecerahan monitor laptop, sakelar bisu mikrofon, dan tombol tes animasi.
4. **Hardware, Suhu & Processor TDP Monitor**:
   - Pembacaan **Processor Package Power / TDP (Watt)** langsung dari kernel `/sys/class/hwmon` (atau estimasi bertanda `~` jika sensor absen).
   - Suhu multi-sensor **CPU (`k10temp`), GPU (`amdgpu/nvidia`), dan SSD NVMe**, frekuensi clock GHz, beban GPU, proses terberat (*Top CPU*), dan peringatan suhu tinggi (`≥85°C`).
   - **Power Profile Switcher** 1-klik: 🍃 Hemat, ⚖️ Seimbang, 🚀 Performa (`powerprofilesctl`).
5. **Bluetooth & Perangkat TWS**:
   - Terhubung via **BlueZ D-Bus (`org.bluez`)** dengan **animasi pop-up TWS (`310x60px`)** saat earbud tersambung/terputus.
   - Halaman daftar perangkat Bluetooth terpasang, level baterai per perangkat, dan tombol sambung/putus 1-klik.
6. **Pusat Notifikasi Split-View**:
   - Riwayat 40 notifikasi terakhir dengan kategori otomatis (💬 Chat, 🎵 Media, ⚡ Sistem, 🎯 Fokus, 🌐 Browser).
   - Tombol **📋 Salin** (untuk kode OTP), **🔕 Do Not Disturb**, lencana *unread*, **Smart Relative Timestamp** (Hari ini / Kemarin), dan pembersihan otomatis sampah kedaluwarsa (>48 jam).
   - **Privasi Terjamin**: File tersimpan dengan izin `0600` dan otomatis menolak penyimpanan kata sandi dari Password Manager (*KeePassXC, Bitwarden, 1Password, Proton Pass, Enpass*).
7. **Kesehatan & Pengingat Minum Air**:
   - **Histogram 8 Jam** konsumsi air harian, kustomisasi ukuran gelas (`150–500ml`), target harian (`1.5–3.0L`), dan pengingat **Eye Break 20-20-20**.
8. **Daftar Tugas Harian (To-Do)**:
   - Pengelola checklist tugas harian dengan penyimpanan lokal persisten.
9. **Wayland File Shelf (Rak File Drag & Drop)**:
   - Seret file dari Dolphin/file manager ke notch atas untuk menyimpannya sementara (*Island Gulp effect*).
   - Pratinjau thumbnail gambar dan kemampuan seret keluar (**Native Wayland `QDrag` `text/uri-list`**) ke chat, browser, atau aplikasi lain.
10. **Pengaturan & Personalisasi (Settings)**:
    - Sakelar per-HUD (Volume, Baterai, Bluetooth, Caps Lock, Notifikasi).
    - **Fullscreen Auto-Hide**: otomatis menyembunyikan notch saat game atau video layar penuh berjalan.
    - **System Tray Icon**: menu status di panel KDE Plasma untuk membuka Hub, toggle mode maskot, atau keluar.

---

## 📦 Pemasangan (Installation)

### Opsi A: Melalui PKGBUILD Lokal (Arch Linux / CachyOS)
```bash
# 1. Clone repositori
git clone https://github.com/NXRts/NxSora.git
cd NxSora/packaging/aur

# 2. Build dan pasang paket lokal
makepkg -si
```
*(Catatan: Paket `nxsora-git` siap diajukan ke upstream AUR).*

### Opsi B: Pemasangan Manual & Skrip Otomatis
```bash
# 1. Clone repositori
git clone https://github.com/NXRts/NxSora.git
cd NxSora

# 2. Pastikan ~/.local/bin terdaftar di PATH Anda
export PATH="$HOME/.local/bin:$PATH"

# 3. Periksa dependensi sistem
./run.sh --check

# 4. Pasang desktop launcher & autostart
./install.sh
```

---

## 🚀 Penggunaan & Perintah CLI

```bash
# Menjalankan di latar belakang (daemon aman)
nxsora --daemon

# Memeriksa status aplikasi, PID, dan konsumsi memori
nxsora --status

# Me-restart aplikasi (memuat ulang konfigurasi & QML)
nxsora --restart

# Buka / Tutup Hub interaktif (ideal untuk pintasan keyboard global)
nxsora --toggle

# Menghentikan aplikasi
nxsora --stop

# Mengirim notifikasi uji coba ke notch
nxsora --test-notif
```

---

## ⚙️ Layanan Systemd (Opsional)

Jika Anda ingin mengelola NxSora sebagai layanan pengguna systemd:

```ini
# ~/.config/systemd/user/nxsora.service
[Unit]
Description=NxSora - The Living Sky-Notch for KDE Plasma 6 Wayland
PartOf=graphical-session.target
After=plasma-workspace.target

[Service]
Type=simple
ExecStart=%h/.local/bin/nxsora
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical-session.target
```

Aktivasi layanan:
```bash
systemctl --user daemon-reload
systemctl --user enable --now nxsora.service
```

> [!WARNING]
> **Perhatian**: Pilih salah satu antara autostart desktop (`~/.config/autostart/nxsora.desktop` dari `./install.sh`) **atau** unit systemd user service. Jangan aktifkan keduanya secara bersamaan.

---

## 🔧 Standarisasi Direktori XDG
- **Konfigurasi**: `~/.config/nxsora/config.json`
- **Cache (Lirik & Cover)**: `~/.cache/nxsora/lyrics/`
- **Berkas Log**: `~/.local/state/nxsora/nxsora.log`
- **Lock & Runtime**: `/run/user/<UID>/nxsora/nxsora.lock`

---

## ❓ Troubleshooting & Tanya Jawab (FAQ)

<details>
<summary><strong>1. Notch tidak menempel di tepi atas atau tertutup panel lain?</strong></summary>
Pastikan Anda menjalankan sesi <strong>Wayland</strong>. NxSora menggunakan pustaka <code>layer-shell-qt</code> untuk menempel presisi di layer panel atas. Anda dapat menyesuaikan margin atas di <code>~/.config/nxsora/config.json</code> (properti <code>top_margin</code>).
</details>

<details>
<summary><strong>2. Notifikasi sistem tidak masuk ke NxSora?</strong></summary>
Pastikan paket <code>dbus-monitor</code> tersedia di sistem Anda. NxSora memantau sinyal <code>org.freedesktop.Notifications</code> secara pasif tanpa mengambil alih daemon notifikasi bawaan KDE Plasma.
</details>

<details>
<summary><strong>3. Status baterai TWS Bluetooth tidak tampil?</strong></summary>
Pastikan layanan BlueZ experimental Battery1 aktif pada sistem Anda. Sebagian besar TWS modern otomatis mengirimkan status baterai via Bluetooth D-Bus.
</details>

<details>
<summary><strong>4. Nilai TDP Prosesor menampilkan tanda "~"?</strong></summary>
Tanda <code>~</code> menandakan nilai TDP merupakan estimasi berbasis beban CPU karena kernel belum menyediakan sensor <code>power1_input</code> di sysfs <code>/sys/class/hwmon</code>.
</details>

<details>
<summary><strong>5. Apakah eye-tracking melacak kursor di seluruh layar?</strong></summary>
Pada protokol Wayland, pembacaan posisi mouse global dibatasi demi keamanan sandboxing; pelacakan mata maskot bekerja secara presisi saat kursor berada di dalam batas area interaksi notch.
</details>

---

## 🙏 Penghargaan & Kredit Inspirasi (Credits)

Proyek ini terinspirasi oleh konsep antarmuka interaktif **[Nusa](https://rama2555.github.io/nusa/)** yang dirancang oleh **Rama ([@rama2555](https://github.com/rama2555))**.

NxSora mengadaptasi dan membangun ulang konsep tersebut dari nol sebagai aplikasi desktop native untuk lingkungan **Linux KDE Plasma 6 (Wayland)** menggunakan Python, PyQt6, QtQuick QML, PipeWire, BlueZ, dan Wayland Layer-Shell.

---

## 📄 Lisensi
Didistribusikan di bawah lisensi **GNU General Public License v3.0 (GPL-3.0)**. Lihat file [`LICENSE`](LICENSE) untuk informasi lebih lanjut.

Dikembangkan oleh **[NXRts](https://github.com/NXRts)** — Terinspirasi oleh konsep antarmuka **[Nusa](https://rama2555.github.io/nusa/)**.
