# 🌌 NxSora (Nx空) — The Living Sky-Notch for Linux Desktop

<p align="center">
  <img src="assets/logo.svg" width="100" height="100" alt="NxSora Logo" />
</p>

<p align="center">
  <strong>Mahkota cerdas di cakrawala desktop Linux Anda, perpaduan presisi komputasi NXRts dan estetika angkasa Jepang.</strong>
</p>

<p align="center">
  <a href="https://kde.org/"><img src="https://img.shields.io/badge/KDE_Plasma-6.0+-blue?logo=kde&logoColor=white" alt="KDE Plasma 6" /></a>
  <a href="https://wayland.freedesktop.org/"><img src="https://img.shields.io/badge/Display-Wayland-green?logo=wayland&logoColor=white" alt="Wayland" /></a>
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/Python-3.11+-yellow?logo=python&logoColor=white" alt="Python 3.11+" /></a>
  <a href="https://riverbankcomputing.com/software/pyqt/"><img src="https://img.shields.io/badge/GUI-PyQt6_&_QML-success?logo=qt&logoColor=white" alt="PyQt6 & QML" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-GPL--3.0-orange" alt="License: GPL-3.0" /></a>
  <a href="https://github.com/NXRts/NxSora/actions"><img src="https://img.shields.io/badge/CI-Passing-brightgreen?logo=githubactions&logoColor=white" alt="CI Status" /></a>
  <a href="https://aur.archlinux.org/packages/nxsora-git"><img src="https://img.shields.io/badge/AUR-nxsora--git-blueviolet?logo=archlinux&logoColor=white" alt="AUR Package" /></a>
</p>

---

## 🧭 Navigasi Cepat Dokumen
- 🌌 **Filosofi & Identitas**: [`NXSORA.md`](NXSORA.md) — Asal-usul nama, 4 pilar filosofis, dan palet warna *Neo-Sora*.
- 🗺️ **Roadmap Publik**: [`ROADMAP.md`](ROADMAP.md) — Rencana pengembangan bertahap dan status fitur.
- 🔬 **Master Plan Detail**: [`Next.md`](Next.md) — Analisis arsitektur 10 modul dan perbandingan ekosistem notch.
- 📖 **Panduan Penggunaan**: [`Tutorial.md`](Tutorial.md) — Tips gestur navigasi dan pintasan keyboard.
- 📜 **Catatan Rilis**: [`CHANGELOG.md`](CHANGELOG.md) — Riwayat versi dan perubahan.
- 🤝 **Panduan Kontribusi**: [`CONTRIBUTING.md`](CONTRIBUTING.md) — Tata cara pengembangan dan pull request.

---

## ⚡ Bukti Kinerja & Pemakaian Sumber Daya
NxSora dirancang dengan filosofi **Zen (Kū / 空)**:
- **CPU Idle**: **0.0%** (berkat arsitektur event-driven D-Bus dan sysfs polling ber-overhead rendah).
- **Pemakaian RAM**: **~85 MB** (ringan dan hemat memori).
- **Click-Through**: **100% tembus klik** pada seluruh area layar di luar notch; tidak pernah menghalangi tab browser ataupun editor teks Anda.

---

## ✨ 10 Modul Terpadu NxSora

1. **Resting Mascot Eyes & Closed Capsule (`150x28px`)**:
   - Mata maskot hidup dengan **Cursor Eye-Tracking** (melirik halus mengikuti kursor mouse) dan kedipan acak.
   - Mode jam digital dengan **Cincin Baterai Melingkar (`#33e07a`)** dan **Privacy Dots** (titik hijau kamera & oranye mic saat PipeWire aktif).
2. **Pemutar Musik & Karaoke Lirik LRCLIB (`420px → 520px` Split View)**:
   - Sampul album, *seekbar* interaktif (`MM:SS` & sisa waktu `-MM:SS`), dan integrasi lirik tersinkronisasi otomatis dari **LRCLIB**.
   - **Click-to-Seek**: klik baris lirik mana saja untuk langsung melompat ke detik tersebut dalam lagu!
3. **Pintasan Cepat (Quick Controls)**:
   - Pengatur volume, slider kecerahan layar, tombol Night Light, tombol mute mikrofon, dan pintasan tool desktop.
4. **Hardware, Suhu & Processor TDP Monitor**:
   - Pembacaan **Processor TDP (PPT dalam Watt)** langsung dari sensor kernel `/sys/class/hwmon`.
   - Suhu multi-sensor **CPU (`k10temp`), GPU (`amdgpu/nvidia`), dan SSD NVMe**, frekuensi clock GHz, GPU load & VRAM, proses terberat (*Top CPU*), dan peringatan overheat (`≥85°C`).
   - **Power Profile Switcher** 1-klik: 🍃 Hemat, ⚖️ Seimbang, 🚀 Performa (`powerprofilesctl`).
5. **Bluetooth & Perangkat TWS**:
   - Terhubung via **BlueZ D-Bus (`org.bluez`)** dengan **animasi pop-up TWS (`310x60px`)** saat earbud tersambung/terputus.
   - Halaman daftar perangkat Bluetooth terpasang, level baterai per perangkat, dan tombol sambung/putuskan 1-klik.
6. **Pusat Notifikasi Split-View**:
   - Riwayat 40 notifikasi terakhir dengan kategori otomatis (💬 Chat, 🎵 Media, ⚡ Sistem, 🎯 Fokus, 🌐 Browser).
   - Tombol **📋 Salin** (untuk kode OTP), **🔕 Do Not Disturb**, lencana *unread*, **Smart Relative Timestamp** (Hari ini / Kemarin), dan pembersihan otomatis sampah kedaluwarsa (>48 jam).
   - **Privasi Terjamin**: File tersimpan dengan izin `0600` dan otomatis menolak penyimpanan kata sandi dari Password Manager (*KeePassXC, Bitwarden, 1Password*).
7. **Kesehatan & Pengingat Minum Air**:
   - **Histogram 8 Jam** konsumsi air harian, kustomisasi ukuran gelas (`150–500ml`), target harian (`1.5–3.0L`), dan pengingat **Eye Break 20-20-20**.
8. **Daftar Tugas Harian (To-Do)**:
   - Pengelola checklist tugas cepat dengan penyimpanan lokal persisten.
9. **Wayland File Shelf (Rak File Drag & Drop)**:
   - Seret file dari Dolphin/file manager ke notch atas untuk menyimpannya sementara (*Island Gulp effect*).
   - Pratinjau thumbnail gambar dan seret keluar (**Native Wayland `QDrag`**) ke chat, browser, atau folder lain.
10. **Pengaturan & Personalisasi (Settings)**:
    - Sakelar toggle untuk setiap Smart Peek HUD (Volume, Cas, Bluetooth, Caps Lock, Notifikasi).
    - **Fullscreen Auto-Hide**: otomatis menyembunyikan notch saat game atau video layar penuh berjalan.
    - **System Tray Icon**: menu status di panel KDE Plasma untuk membuka Hub, toggle mode maskot, atau keluar.

---

## 📦 Pemasangan (Installation)

### Opsi A: Melalui AUR (Arch Linux / CachyOS) — *Disarankan*
```bash
yay -S nxsora-git
```

### Opsi B: Pemasangan Manual via Git & Skrip Otomatis
```bash
# 1. Clone repositori
git clone https://github.com/NXRts/NxSora.git
cd NxSora

# 2. Periksa dependensi sistem
./run.sh --check

# 3. Pasang desktop launcher & autostart
./install.sh
```

---

## 🚀 Penggunaan & Perintah CLI

```bash
# Menjalankan di latar belakang (daemon aman ditutup)
nxsora --daemon

# Memeriksa status aplikasi
nxsora --status

# Me-restart aplikasi (misal setelah update konfigurasi)
nxsora --restart

# Menghentikan aplikasi
nxsora --stop

# Mengirim notifikasi uji coba ke notch
nxsora --test-notif
```

---

## 🔧 Standarisasi Direktori XDG
NxSora mematuhi standar direktori XDG Linux:
- **Konfigurasi**: `~/.config/nxsora/config.json`
- **Cache (Lirik & Cover)**: `~/.cache/nxsora/lyrics/`
- **Berkas Log**: `~/.local/state/nxsora/nxsora.log`
- **Lock & Runtime**: `/run/user/<UID>/nxsora/`

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
Pastikan layanan BlueZ experimental Battery1 aktif pada sistem Anda. Sebagian besar TWS modern (misal Soundcore, Thinkplus, Galaxy Buds) otomatis mengirimkan status baterai via Bluetooth D-Bus.
</details>

<details>
<summary><strong>4. Nilai TDP Prosesor (Watt) bernilai estimasi?</strong></summary>
Jika kernel Linux Anda tidak mengekspos sensor <code>power1_input</code> di sysfs <code>/sys/class/hwmon</code>, NxSora akan menggunakan algoritma estimasi cerdas berbasis beban CPU saat ini agar tampilan tetap informatif tanpa crash.
</details>

---

## 📄 Lisensi
Didistribusikan di bawah lisensi **GNU General Public License v3.0 (GPL-3.0)**. Lihat [`LICENSE`](LICENSE) untuk informasi lebih lanjut.

Karya orisinal oleh **[NXRts](https://github.com/NXRts)**.
