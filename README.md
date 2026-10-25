# 🏝️ Dynamic Island untuk CachyOS (KDE Plasma 6 Wayland)

Aplikasi **Dynamic Island** native, modern, dan berkinerja tinggi untuk **KDE Plasma 6 pada Wayland**, dibangun menggunakan **Python 3**, **PyQt6**, **QML (QtQuick)**, dan protokol **Wayland Layer-Shell** (`layer-shell-qt`).

---

## ✨ Fitur-Fitur Utama ("Full Fungsi")

1. **Sleek Flush Notch Native Wayland Overlay (Layer-Shell)**:
   - Menempel rapat (*flush margin 0*) tepat di bawah panel atas KDE Plasma tanpa celah mengambang yang menutupi tab aplikasi.
   - Dilengkapi lekukan telinga halus (*concave ear curves*) ala Nusa & MacBook yang menyatu mulus dan organik dengan panel atas.
   - Profil ultra-ramping (*idle height* hanya 28px) sehingga tab browser / text editor (VS Code) di bawahnya tidak lagi tertutupi.
   - Menggunakan ukuran dinamis (`hitbox`), sehingga seluruh area layar lainnya tetap **100% tembus klik (click-through)** ke aplikasi di bawahnya.
   - Animasi elastis (*spring & ease-in-out physics*) 60–144 FPS yang halus ala Apple Dynamic Island.

2. **🎵 Media Player Terintegrasi (MPRIS)**:
   - Terhubung otomatis dengan Spotify, Firefox, Google Chrome, VLC, dsb.
   - **Mode Kapsul (Compact)**: Menampilkan thumbnail album/ikon musik, judul lagu, dan 4 batang visualizer audio (*equalizer wave*) yang bergerak dinamis saat musik berputar.
   - **Mode Ekspansi (Expanded Card)**: Klik kapsul untuk membuka card pemutar musik lengkap dengan cover album besar, slider durasi interaktif (bisa di-klik untuk *seek*), tombol Prev/Play/Pause/Next, serta pengatur volume langsung.

3. **🔊 Volume & Brightness HUD Dinamis**:
   - Terintegrasi dengan WirePlumber / PipeWire (`wpctl`).
   - Saat volume diubah, kapsul membesar mulus menampilkan ikon speaker, indikator level, dan persentase numerik, lalu menyusut kembali otomatis setelah 2 detik.
   - **Fitur Spesial**: Anda bisa mengarahkan kursor ke atas kapsul dan melakukan **scroll mouse wheel** untuk menaikkan/menurunkan volume secara instan!

4. **⚡ Status Baterai & Pengisian Daya**:
   - Mendeteksi charger saat dicolokkan atau dicabut secara instan.
   - Memunculkan kapsul hijau cerah *"Mengisi Daya 85%"* atau indikator status baterai.

5. **🔔 Notifikasi Desktop Interaktif**:
   - Mencegat notifikasi sistem melalui DBus (`org.freedesktop.Notifications`).
   - Notifikasi masuk ditampilkan langsung dari kapsul dengan animasi meluas, nama aplikasi, judul notifikasi, dan cuplikan pesan tanpa mengganggu jendela aktif.

6. **⏱️ Quick Timer & Pomodoro**:
   - Timer countdown cepat (preset 1m, 5m, 25m Pomodoro) langsung dari hub.
   - Waktu mundur ditampilkan langsung di kapsul saat aktif.

7. **📊 System Monitoring Hub**:
   - Klik kapsul saat standby untuk membuka panel kontrol cepat.
   - Indikator penggunaan CPU (%), RAM (GB & %), status baterai, tombol Mute cepat, dan timer.

---

## 🚀 Cara Menjalankan

Masuk ke folder project:
```bash
cd "/home/nxrts/Projek Dynamic Island"
```

### 1. Menjalankan di Background (Rekomendasi)
```bash
./run.sh --daemon
```

### 2. Menjalankan di Terminal (Foreground / Debugging)
```bash
./run.sh
```

### 3. Menghentikan Aplikasi
```bash
./run.sh --stop
```

### 4. Restart Aplikasi
```bash
./run.sh --restart
```

### 5. Uji Coba Notifikasi
```bash
./run.sh --test-notif
```

---

## 🔄 Mengaktifkan Autostart (Otomatis Aktif Saat Login)

Agar Dynamic Island otomatis berjalan setiap kali Anda login ke CachyOS KDE:

```bash
# Mengaktifkan
./autostart.sh --enable

# Memeriksa status
./autostart.sh --status

# Menonaktifkan
./autostart.sh --disable
```

---

## 🎮 Navigasi & Kontrol

| Aksi | Efek |
| :--- | :--- |
| **Klik Kiri Kapsul** | Membuka / menutup tampilan kartu penuh (*Expanded Card*) |
| **Klik Kanan Kapsul** | Toggle cepat buka / tutup kartu |
| **Scroll Mouse Wheel di atas Kapsul** | Mengatur volume suara sistem (naik / turun) |
| **Klik Bar Garis Musik** | Melompat (*seek*) ke bagian menit lagu yang dipilih |
| **Tombol ✕ di Card** | Menutup kembali ke bentuk kapsul minimalis |

---

## ⚙️ Kustomisasi (`config.py`)

Anda dapat menyesuaikan ukuran, jarak dari tepi atas layar (*top margin*), durasi auto-collapse, dan warna tema dengan mengedit file [`config.py`](file:///home/nxrts/Projek%20Dynamic%20Island/config.py).
