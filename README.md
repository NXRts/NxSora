# 🏝️ Dynamic Island untuk CachyOS (KDE Plasma 6 Wayland)

Aplikasi **Dynamic Island** native, modern, dan berkinerja tinggi untuk **KDE Plasma 6 pada Wayland**, dibangun menggunakan **Python 3**, **PyQt6**, **QML (QtQuick)**, dan protokol **Wayland Layer-Shell** (`layer-shell-qt`). Desain terinspirasi dari [Nusa](https://rama2555.github.io/nusa/) dan Dynamic Island iOS/macOS.

> 📌 Roadmap lengkap fitur (yang sudah & belum diimplementasikan) ada di [`Next.md`](Next.md). Panduan penggunaan ada di [`Tutorial.md`](Tutorial.md).

---

## ✨ Fitur-Fitur Utama

### 🪟 1. Notch Native Wayland Overlay
- Menempel rapat (*flush*) tepat di bawah panel atas KDE Plasma dengan lekukan telinga halus (*concave ears*) yang menyatu dengan panel.
- Profil ultra-ramping (*idle* `150x28px`) sehingga tab browser/editor di bawahnya tidak tertutup.
- Menggunakan ukuran dinamis (`hitbox`), sehingga area layar lainnya tetap **100% tembus klik (click-through)**.
- Animasi elastis (*spring physics*) halus 60–144 FPS, efek **"Island Gulp"** saat file di-*drop*, dan *ambient glow* adaptif mengikuti warna sampul album / status HUD.
- **Smart Auto-Collapse**: otomatis menutup saat kursor keluar, tombol **Pin 📌** untuk menahan terbuka, dan `Esc` untuk menutup.

### 🎵 2. Media Player & Lirik Karaoke Tersinkronisasi (MPRIS)
- Terhubung otomatis dengan Spotify, Firefox, Chrome, VLC, dsb. Menampilkan sampul album, *seekbar* interaktif (`MM:SS` dan sisa waktu `-MM:SS`), serta kontrol *Prev / Play / Next* dan volume.
- **Mode Lirik Karaoke (`520px` Split View)**: lirik tersinkronisasi dari **LRCLIB** (`lrclib.net`) dengan cache lokal, baris aktif menyala, *auto-scroll*, dan **klik baris lirik untuk *seek***.
- Kapsul tertutup menampilkan **mini equalizer** saat musik diputar.

### 🔊 3. HUD Dinamis (Volume, Kecerahan, Mic, Caps Lock)
- **Volume**: via PipeWire/WirePlumber (`wpctl`); *scroll* mouse di atas kapsul tertutup untuk mengatur volume.
- **Kecerahan Layar, Caps Lock & Mic Mute** (`250x36px`): terdeteksi langsung dari sysfs (`/sys/class/backlight`, `/sys/class/leds`) dan PipeWire, plus slider kecerahan & tombol Mic di halaman *Pintasan Cepat*.

### ⚡ 4. Charging Peek & Closed Battery Ring
- Kapsul pop-up `310x60px` bergaya Nusa saat charger dicolok/dicabut: **cincin konik hijau neon**, ikon petir, dan persentase besar.
- Kapsul tertutup menampilkan **cincin baterai melingkar**, jam digital, dan indikator suhu CPU tinggi.

### 🎧 5. Bluetooth Peek & Halaman Bluetooth
- Memantau **BlueZ D-Bus** (`org.bluez`): saat TWS/headphone tersambung atau terputus, muncul kapsul `310x60px` dengan **animasi lepas-pasang TWS** (*charging case* membuka/menutup, earbud `L`/`R` keluar/masuk) dan cincin baterai biru.
- **Halaman Bluetooth & Perangkat**: status adapter, daftar perangkat terhubung/tersimpan beserta persentase baterai, tombol **Sambung/Putuskan** 1-klik, dan pintasan ke Setelan Bluetooth KDE.

### 🔔 6. Pusat Notifikasi
- Mencegat notifikasi sistem via DBus (`org.freedesktop.Notifications`) dan menyimpan **40 riwayat terakhir** (`~/.config/dynamic-island/notifications.json`).
- **Split View**: daftar kotak masuk berkategori (💬 Chat, 🎵 Media, ⚡ Sistem, 🎯 Fokus, 🌐 Browser) + **pembaca pesan penuh** yang dapat di-*scroll*.
- Tombol **📋 Salin** (cocok untuk OTP), **🔕 Do Not Disturb**, lencana *unread* di header & kapsul tertutup, dan klik pop-up (`Baca ▸`) untuk langsung membuka pesan lengkap.

### 🖥️ 7. Hardware, Suhu & TDP Monitor
- **Processor TDP** (`W` via `hwmon PPT`), suhu **CPU / GPU / NVMe**, clock CPU, GPU load & VRAM, deteksi proses terberat, dan **peringatan overheat** (`≥85°C`).
- **Power Profile Switcher** 1-klik: 🍃 Hemat, ⚖️ Seimbang, 🚀 Performa (`powerprofilesctl`).

### 📂 8. File Shelf (Drag & Drop)
- Seret file ke kapsul atas untuk menyimpannya sementara di **Rak File**; tampil dengan *thumbnail* gambar, ikon folder, dan badge ekstensi.
- Klik untuk membuka (`xdg-open`) dan **seret keluar** ke aplikasi lain (native Wayland `QDrag`).

### ⏱️ 9. Pomodoro, Kesehatan & To-Do
- **Pomodoro Focus Timer** dengan cincin konik bercahaya (*Focus 25m* / *Short Break 5m*), pergantian sesi otomatis, notifikasi, dan *soft chime*.
- **Water Tracker** dengan **histogram per jam**, kustomisasi ukuran gelas & target harian, serta pengingat **Eye Break 20-20-20**.
- **To-Do List** harian dengan penyimpanan JSON.

### 🧭 10. Navigasi 9 Halaman
- Karusel halaman: **Sistem & Pomodoro → Musik → Pintasan Cepat → Hardware → Bluetooth → Notifikasi → Kesehatan → To-Do → Shelf**.
- Perpindahan dengan **swap/drag**, *touchpad 2-finger swipe*, tombol `< >`, titik indikator, atau tombol panah keyboard.

---

## 🚀 Cara Menjalankan

Masuk ke folder project:
```bash
cd "/home/nxrts/Projek Dynamic Island"
```

| Perintah | Fungsi |
| :--- | :--- |
| `./run.sh --daemon` | Menjalankan di background (rekomendasi) |
| `./run.sh` | Menjalankan di terminal (foreground / debugging) |
| `./run.sh --stop` | Menghentikan aplikasi |
| `./run.sh --restart` | Restart aplikasi |
| `./run.sh --test-notif` | Uji coba notifikasi |

Log tersimpan di `/tmp/dynamic_island_kde.log`.

### 📦 Dependensi Utama
- Python 3, **PyQt6** (+ `PyQt6.QtDBus`), `psutil`
- `layer-shell-qt` (Wayland Layer-Shell untuk KDE Plasma 6)
- `wpctl` (PipeWire/WirePlumber), `bluetoothctl` (BlueZ), `powerprofilesctl`, `dbus-monitor`, `wl-copy` (opsional, untuk fitur Salin)

---

## 🔄 Mengaktifkan Autostart (Otomatis Aktif Saat Login)

```bash
./autostart.sh --enable    # Mengaktifkan
./autostart.sh --status    # Memeriksa status
./autostart.sh --disable   # Menonaktifkan
```

---

## 🎮 Navigasi & Kontrol

| Aksi | Efek |
| :--- | :--- |
| **Klik Kiri Kapsul** | Membuka / menutup tampilan Hub penuh |
| **Klik Kanan Kapsul** | Toggle cepat buka / tutup |
| **Scroll Mouse di atas Kapsul Tertutup** | Mengatur volume sistem |
| **Swap / Drag Mouse** atau **Touchpad 2-Finger Swipe** | Berpindah antar halaman |
| **Tombol `<` `>` / Panah Keyboard / Titik Indikator** | Berpindah halaman |
| **Tombol 🔔** (header) | Langsung ke Pusat Notifikasi |
| **Tombol 📌** | Menahan Hub tetap terbuka (nonaktifkan auto-collapse) |
| **Klik Bar Musik / Baris Lirik** | *Seek* ke posisi lagu yang dipilih |
| **Seret file ke Kapsul** | Membuka Rak File dan menyimpan file |
| **`Esc` / Tombol ✕** | Menutup kembali ke kapsul |

> ℹ️ *Scroll* mouse di dalam Hub tidak lagi berpindah halaman, sehingga daftar (Notifikasi, Bluetooth, Lirik, To-Do, Shelf) dapat di-*scroll* dengan nyaman.

---

## 🗺️ Roadmap

Fase yang sudah selesai: **Fase 1** (Lirik, Shelf, Pomodoro, Water), **Fase 2** (Bluetooth/Charging/Hardware HUD, Pusat Notifikasi), serta Hardware & TDP Monitor.

Rencana berikutnya (detail di [`Next.md`](Next.md)):
- **Fase 3**: Smart Mascot 2.0, Privacy Dots, System Tray & Fullscreen Auto-Hide, Wi-Fi Peek, Low-Battery Nudge.
- **Fase 4**: Jadwal Sholat & Pengingat Azan (lokasi *real-time*), Clipboard History, Audio Switcher, Cuaca, Camera Mirror, KDE Connect, Voice Note, Color Picker.
- **Fase 5**: Halaman Pengaturan Terpadu & kustomisasi.
- **Fase 6**: Dukungan Windows & installer `.exe`.

---

## ⚙️ Kustomisasi (`config.py`)

Anda dapat menyesuaikan ukuran, jarak dari tepi atas layar (*top margin*), durasi auto-collapse, durasi HUD, dan warna tema dengan mengedit file [`config.py`](config.py).
