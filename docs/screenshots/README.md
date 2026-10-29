# 📸 Galeri Tangkapan Layar NxSora (Nx空)

Direktori ini menyimpan aset tangkapan layar (screenshot) dan GIF demo untuk halaman README dan dokumentasi.

## Struktur Aset yang Direkomendasikan
- `demo-hero.gif`: Animasi GIF demo di bagian paling atas README (Musik + Karaoke Lirik, Bluetooth TWS Peek, File Shelf Gulp).
- `01-compact-idle.png`: Tampilan kapsul tertutup (*Closed Capsule & Mascot Eyes*).
- `02-music-karaoke.png`: Tampilan Pemutar Musik & Karaoke Synced Lyrics (`520px`).
- `03-hardware-tdp.png`: Tampilan Hardware, Suhu & Processor TDP Telemetry.
- `04-bluetooth-tws.png`: Tampilan Halaman Bluetooth & Peek Animasi TWS.
- `05-notification-center.png`: Tampilan Split-View Pusat Notifikasi & Pembaca Penuh.
- `06-file-shelf.png`: Tampilan Rak File Sementara (Drop & Drag-Out).
- `07-settings-page.png`: Tampilan Halaman Pengaturan & Personalisasi.

## Cara Mengambil Screenshot Bersih di KDE Plasma Wayland
Gunakan utilitas `spectacle`:
```bash
# Ambil area jendela notch aktif
spectacle -a -b -o docs/screenshots/01-compact-idle.png
```

