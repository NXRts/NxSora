# 🗺️ Roadmap Fitur Masa Depan: Projek Dynamic Island
**Platform:** CachyOS Linux | KDE Plasma 6 (Wayland) | Python 3 + PyQt6 + QML (Layer-Shell)

Dokumen ini memuat rencana pengembangan fitur baru, inovasi pengalaman pengguna (*UX*), serta rekomendasi fitur prioritas untuk menjadikan **Projek Dynamic Island** solusi Dynamic Island paling canggih, fungsional, dan estetik di ekosistem Linux desktop.

---

## 🌟 Daftar Fitur yang Direncanakan & Direkomendasikan

### 1. 🎵 Multimedia & Audio Superpowers *(Rekomendasi Utama)*
* [ ] **Live CAVA / PipeWire FFT Visualizer**:
  * Mengganti animasi bar prosedural saat ini dengan gelombang spektrum audio *real-time* asli dari PipeWire (menggunakan `cava` atau modul visualizer PipeWire). Bar audio akan melompat sesuai dentuman *bass* & ritme musik yang sedang diputar.
* [ ] **Multi-Player Source Switcher**:
  * Jika pengguna memutar Spotify sekaligus video YouTube di Firefox/Chrome, kapsul menyediakan *badge* kecil untuk berpindah kendali antar media player dengan satu klik.
* [ ] **Synced Lyrics (Mode Karaoke Minimalis)**:
  * Mengambil lirik lagu yang sinkron secara *real-time* (via LRCLIB API / Spotify DBus) dan menampilkannya baris demi baris di dalam kapsul atau *expanded card*.
* [ ] **Quick Audio Device Switcher**:
  * Tombol cepat di Expanded Hub untuk mengganti output audio secara instan (Speaker Laptop ↔ Headphone Bluetooth / USB DAC) tanpa harus membuka System Settings KDE.

---

### 2. 🛡️ Indikator Privasi & Status Sistem (Apple-Style Indicators)
* [ ] **Microphone & Camera Privacy Dots**:
  * Menampilkan titik oranye (*microphone aktif*) dan titik hijau (*webcam/kamera aktif*) di sudut kapsul saat ada aplikasi (Discord, Zoom, Browser) yang mengakses audio/video.
  * Klik titik tersebut untuk melihat aplikasi mana yang sedang menggunakan mikrofon/kamera dan tombol pintas *Mute Microphone*.
* [ ] **Screen Recording / Streaming HUD**:
  * Saat OBS Studio atau KDE Spectacle sedang merekam layar, Dynamic Island menampilkan durasi rekaman dengan titik merah berkedip (*pulsing red dot*) dan tombol *Stop Recording*.

---

### 3. 🔍 Integrasi Cepat KDE Plasma & Wayland
* [ ] **Spotlight / Quick Search Runner Morphing**:
  * Menekan pintasan keyboard (misalnya `Super + Space` atau `Alt + Space`) akan mengubah Dynamic Island menjadi bilah pencarian cerdas mengambang (seperti macOS Spotlight / KRunner) untuk membuka aplikasi, mencari file, atau menghitung kalkulator matematika secara instan.
* [ ] **Brightness & Night Light OSD**:
  * Menangkap tombol kecerahan layar (*brightness keys*) dan menampilkan bar persentase kecerahan di Dynamic Island.
  * Tombol *toggle* Night Color (filter cahaya biru untuk malam hari) langsung di Control Hub.
* [ ] **Multi-Monitor Awareness**:
  * Pilihan konfigurasi di `config.py` untuk menentukan apakah Dynamic Island tampil di *Primary Monitor*, mengikuti kursor aktif (*follow focus*), atau muncul di semua layar.

---

### 4. 📱 Integrasi Ekosistem KDE Connect
* [ ] **Panggilan Masuk & SMS Smartphone**:
  * Saat smartphone Android yang terhubung via KDE Connect menerima panggilan, Dynamic Island membesar menampilkan kontak pemanggil beserta tombol *Terima / Tolak*.
* [ ] **Indikator Baterai Ponsel**:
  * Menampilkan persentase daya baterai smartphone di Control Hub dan memunculkan peringatan kapsul ketika baterai ponsel lemah (< 15%).

---

### 5. ⚡ Smart Productivity & Live Widgets
* [ ] **Live Weather Pill (Widget Cuaca)**:
  * Menampilkan kondisi cuaca dan suhu lokal secara diskrit di mode standby (misal: `🌦️ 28°C Jakarta`).
  * Klik untuk melihat ramalan cuaca 3 hari ke depan, kelembaban, dan kecepatan angin (menggunakan API Open-Meteo gratis tanpa kunci API).
* [ ] **Real-time Network Speedometer**:
  * Menampilkan kecepatan unduh dan unggah jaringan internet *real-time* (misal: `↓ 5.4 MB/s ↑ 820 KB/s`) di dalam Control Hub.
* [ ] **Quick Clipboard History (Klipper Integration)**:
  * Menu drop-down 3-5 teks/warna yang terakhir disalin ke *clipboard* dengan satu klik untuk menggunakan kembali (*copy-paste* cepat).

---

### 6. 🎨 Dynamic Theming & Engine Kustomisasi
* [ ] **Adaptive Dynamic Island Glow (Color Extraction)**:
  * Mengambil warna dominan dari *cover album* lagu yang sedang diputar (atau wallpaper desktop) dan menerapkannya sebagai warna glow / gradien aksen di sekeliling Dynamic Island.
* [ ] **True KWin Wayland Blur (Glassmorphism)**:
  * Mengintegrasikan protokol blur KWin (`org.kde.kwin.blur`) agar bagian belakang kapsul memiliki efek blur kaca buram (*frosted glass*) yang menyatu dengan jendela di bawahnya.
* [ ] **GUI Settings App (`island-settings`)**:
  * Jendela pengaturan visual (UI grafis) agar pengguna dapat mengatur posisi margin, mengaktifkan/menonaktifkan modul, mengubah kecepatan animasi, dan mengatur shortcut tanpa perlu menyentuh file kode `config.py`.
* [ ] **Notch-Mode vs Floating-Pill**:
  * Mode khusus untuk laptop yang memiliki *notch* fisik di layar (Dynamic Island menempel pas di sekitar lekukan kamera layar) vs mode melayang (*floating pill*).

---

## 🎯 Rencana Urutan Prioritas Implementasi

| Fase | Fokus Fitur | Estimasi Kompleksitas | Dampak Visual & UX |
| :--- | :--- | :---: | :---: |
| **Fase 1 (Segera)** | **Adaptive Glow**, **Brightness HUD**, dan **GUI Settings Window** | Sedang | ⭐⭐⭐⭐⭐ (Sangat Tinggi) |
| **Fase 2 (Menengah)** | **PipeWire Live Audio Spectrum (CAVA)** & **Privacy Dots (Mic/Cam)** | Sedang | ⭐⭐⭐⭐⭐ (Sangat Tinggi) |
| **Fase 3 (Lanjutan)** | **Live Weather Widget**, **Network Monitor**, & **Synced Lyrics** | Sedang | ⭐⭐⭐⭐ (Tinggi) |
| **Fase 4 (Ekosistem)**| **KDE Connect Phone Alerts** & **Spotlight App Search Bar** | Tinggi | ⭐⭐⭐⭐⭐ (Sangat Tinggi) |

---

## 💡 Rekomendasi Fitur Terdekat untuk Dikerjakan Selanjutnya:
1. **Adaptive Glow Theming**: Membuat pencahayaan tepi kapsul berubah warna secara dinamis mengikuti warna album musik (misalnya Spotify hijau, lagu bernuansa ungu glow ungu).
2. **Brightness HUD**: Menyatukan kontrol volume dan kecerahan ke dalam Dynamic Island.
3. **Mic & Camera Privacy Indicator**: Menambah nuansa elegan ala perangkat premium terkini.
