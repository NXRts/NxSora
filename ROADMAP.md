# 🗺️ Roadmap Publik — NxSora (Nx空)

> Rencana pengembangan fitur **NxSora** untuk desktop Linux (KDE Plasma 6 Wayland).

---

## 📌 Ringkasan Status

| Fase | Fokus Utama | Status |
| :---: | :--- | :---: |
| **Fase 1** | Karaoke LRCLIB, File Shelf Drag-Out, Pomodoro Ring, Water Tracker, Navigasi Swipe, Telemetri TDP | ✅ Selesai |
| **Fase 2** | Smart Peek Overlays `310x60px` (Bluetooth TWS, Cas), Hardware HUD (Kecerahan, Caps Lock), Pusat Notifikasi Split-View | ✅ Selesai |
| **Fase 3** | Polesan Repo, Paket AUR, Kemudahan Instalasi, Standarisasi XDG, Tray Icon, Fullscreen Auto-Hide, Privacy Dots, Unit Test & CI | 🚀 Selesai |
| **Fase 4** | Indikator Workspace Virtual KDE, Live Weather (Open-Meteo), Camera Mirror, Quick Share KDE Connect | ⏳ Direncanakan |
| **Fase 5** | Jadwal Sholat Kemenag RI (Sun Arc Trajectory), Real PipeWire Audio Spectrum (`cava`), Portabilitas Windows (`.exe`) | ⏳ Direncanakan |

---

## 🧭 Detail Fase 3 (Polesan & Stabilitas)
- [x] Standarisasi Path XDG (`~/.config/nxsora`, `~/.cache/nxsora`, `~/.local/state/nxsora`)
- [x] Izin keamanan data `0600` dan proteksi data Password Manager
- [x] Paket AUR `PKGBUILD` (`nxsora-git`) & Skrip Pemasangan `install.sh`
- [x] Sistem Tray Icon (`QSystemTrayIcon`) di panel KDE Plasma
- [x] Fullscreen Auto-Hide (sembunyi saat game/video layar penuh)
- [x] Privacy Dots (titik mikrofon oranye & kamera hijau via PipeWire)
- [x] Mascot Eye-Tracking (mata melirik kursor mouse)
- [x] Unit test otomatis (`tests/`) dan GitHub Actions CI
- [x] Dokumentasi lengkap: `LICENSE`, `CHANGELOG.md`, `CONTRIBUTING.md`, issue template

---

Untuk rencana teknis mendalam dan analisis perbandingan aplikasi Dynamic Island lainnya, lihat [Next.md](Next.md).
