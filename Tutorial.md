# 📖 Panduan Lengkap Penggunaan Projek Dynamic Island
**Platform:** CachyOS Linux | KDE Plasma 6 (Wayland)

Panduan ini berisi petunjuk lengkap cara menggunakan, mengontrol, mengonfigurasi, dan mengoptimalkan **Dynamic Island** pada desktop CachyOS KDE Plasma 6 Anda.

---

## 📑 Daftar Isi
1. [Cara Menjalankan & Menghentikan](#1-cara-menjalankan--menghentikan)
2. [Mengaktifkan Autostart (Otomatis Saat Login)](#2-mengaktifkan-autostart-otomatis-saat-login)
3. [Panduan Interaksi Mouse & Kontrol](#3-panduan-interaksi-mouse--kontrol)
4. [Fitur-Fitur Utama & Cara Pakai](#4-fitur-fitur-utama--cara-pakai)
   - [A. Pemutar Musik (Spotify, Browser, VLC)](#a-pemutar-musik-spotify-browser-vlc)
   - [B. Pengatur Volume & Scroll Mouse](#b-pengatur-volume--scroll-mouse)
   - [C. Status Baterai & Charger](#c-status-baterai--charger)
   - [D. Notifikasi Desktop](#d-notifikasi-desktop)
   - [E. Control Hub & Monitoring Sistem](#e-control-hub--monitoring-sistem)
   - [F. Quick Timer / Pomodoro](#f-quick-timer--pomodoro)
5. [Kustomisasi Tampilan (`config.py`)](#5-kustomisasi-tampilan-configpy)
6. [Troubleshooting & FAQ](#6-troubleshooting--faq)

---

## 1. Cara Menjalankan & Menghentikan

Buka terminal dan masuk ke direktori proyek:
```bash
cd "/home/nxrts/Projek Dynamic Island"
```

Tersedia skrip pembantu `./run.sh` untuk memudahkan pengoperasian:

| Perintah | Deskripsi |
| :--- | :--- |
| `./run.sh --daemon` | **(Rekomendasi)** Menjalankan aplikasi di background. Terminal bisa langsung ditutup. |
| `./run.sh` | Menjalankan di foreground (output log tampil langsung di terminal, tekan `Ctrl + C` untuk berhenti). |
| `./run.sh --stop` | Menghentikan Dynamic Island yang sedang berjalan. |
| `./run.sh --restart` | Merestart aplikasi (berguna setelah Anda mengubah file `config.py` atau QML). |
| `./run.sh --test-notif` | Mengirimkan notifikasi uji coba untuk melihat animasi kapsul meluas. |
| `./run.sh --help` | Menampilkan ringkasan seluruh perintah bantuan. |

---

## 2. Mengaktifkan Autostart (Otomatis Saat Login)

Agar Dynamic Island otomatis aktif setiap kali Anda menyalakan PC/laptop atau login ke akun desktop Anda:

```bash
# 1. Mengaktifkan autostart
./autostart.sh --enable

# 2. Memeriksa status autostart
./autostart.sh --status

# 3. Menonaktifkan autostart jika tidak diinginkan lagi
./autostart.sh --disable
```

*File autostart tersimpan di standar XDG: `~/.config/autostart/dynamic-island.desktop`.*

---

## 3. Panduan Interaksi Mouse & Kontrol

Dynamic Island dirancang dengan prinsip **100% Click-Through**: Anda tetap bisa mengklik jendela, tombol browser, atau tab yang berada di sekitar kapsul tanpa terhalang.

| Aksi Kursor / Keyboard | Efek pada Dynamic Island |
| :--- | :--- |
| **Klik Kiri pada Kapsul** | Membuka tampilan kartu penuh (*Expanded Card*). |
| **Klik Kanan pada Kapsul** | Pintasan cepat untuk toggle buka / tutup kartu. |
| **Tombol `<` dan `>` di Header** | Berpindah halaman kartu ke samping (4 halaman menu beragam). |
| **Klik Titik Indikator (`● ○ ○ ○`)** | Langsung melompat ke halaman menu yang dipilih. |
| **Tombol Panah Keyboard (`←` / `→`)** | Berpindah halaman menu secara instan saat kartu terbuka. |
| **Geser / Drag Mouse Horisontal** | Menggeser (*swipe*) halaman menu ke samping secara mulus. |
| **Scroll Roda Mouse di atas Kapsul** | Mengatur volume suara sistem secara langsung. |
| **Klik pada Garis Durasi Musik** | Melompat (*seek*) langsung ke menit tertentu dalam lagu/video. |
| **Tombol ✕ di Sudut Kartu** | Menutup kembali tampilan kartu menjadi kapsul minimalis. |

---

## 4. Fitur-Fitur Utama & Cara Pakai

### A. Dynamic Control Hub Berhalaman (Multi-Page Hub)
Gunakan tombol navigasi **`<`** dan **`>`** (atau geser / klik titik indikator) untuk berpindah antara 6 halaman menu beragam:

1. **Halaman 1: 📊 Sistem & Monitoring**:
   * **CPU Usage**: Persentase pemakaian prosesor dan grafik bar.
   * **RAM Usage**: Persentase pemakaian RAM beserta angka memori terpakai (misal: `4.5 / 15.4 GB`).
   * **Battery Health**: Indikator baterai dan status pengisian.
   * **Pomodoro / Quick Timer**: Preset timer 1m, 5m, 25m dengan live countdown.
   * **Quick Mute**: Tombol satu klik untuk mematikan/menyalakan suara.

2. **Halaman 2: 🎵 Pemutar Musik Lengkap**:
   * **Adaptive Album Glow**: Pendaran pendar cahaya gradasi di sekeliling island yang otomatis mengekstrak warna dominan cover album aktif.
   * Menampilkan sampul lagu besar, judul lagu, dan nama artis.
   * Garis durasi interaktif (bisa diklik untuk melompat menit lagu).
   * Tombol kontrol Prev (⏮), Play/Pause (▶ / ⏸), Next (⏭), dan slider volume langsung.

3. **Halaman 3: ⚡ Pintasan Cepat (Quick Tools)**:
   * 📸 **Screenshot**: Satu klik untuk mengambil cuplikan area layar dengan Spectacle.
   * 🌙 **Night Light**: Mengaktifkan/menonaktifkan filter cahaya biru malam hari KWin.
   * 🔒 **Kunci Layar**: Mengunci sesi desktop seketika (`loginctl lock-session`).
   * 💻 **Konsole**: Membuka terminal KDE dengan cepat.
   * ⚙️ **Pengaturan**: Membuka System Settings KDE.
   * 🔔 **Uji Notifikasi**: Memunculkan pop-up notifikasi uji coba.

4. **Halaman 4: 🌐 Jaringan & Informasi Sistem**:
   * **Speedometer Internet Live**: Kecepatan unduh (`↓`) dan unggah (`↑`) *real-time*.
   * **Info Sistem**: Versi distro CachyOS, Kernel Linux, dan status Wayland Layer-Shell.

5. **Halaman 5: 💧 Kesehatan & Pelacak Air (Health Tracker)**:
   * **Pelacak Minum Air**: Tampilan target harian (misal: `1.5 / 2.0 L · 75% Target`), tombol cepat **`+250 ml`** untuk mencatat 1 gelas minum, tombol reset, dan bar progres hidrasi.
   * **Jeda Mata 20-20-20**: Timer istirahat mata setiap 20 menit untuk memandang kejauhan selama 20 detik demi kesehatan mata.
   * **Mode Maskot Santai**: Sakelar satu klik untuk mengubah tampilan kapsul idle antara jam digital standar dan sepasang mata maskot berkedip (*Mascot Eyes*).

6. **Halaman 6: ✓ Daftar Tugas (To-Do List Harian)**:
   * **Rekap Tugas**: Indikator jumlah tugas yang telah selesai hari ini.
   * **Checklist Interaktif**: Klik lingkaran centang untuk menandai tugas selesai (teks langsung dicoret).
   * **Tambah Tugas Baru**: Ketik di kolom input lalu tekan tombol Enter / Tambah.
   * **Hapus Tugas & Bersihkan**: Tombol ✕ untuk menghapus tugas tertentu dan tombol *Bersihkan Selesai*.

---

## 5. Kustomisasi Tampilan (`config.py`)

Anda dapat menyesuaikan preferensi tampilan dengan mengedit file [`config.py`](file:///home/nxrts/Projek%20Dynamic%20Island/config.py):

```python
CONFIG = {
    # Jarak dari tepi atas layar dalam pixel (default: 10)
    "top_margin": 10,
    
    # Ukuran Kapsul Standby (Lebar & Tinggi)
    "idle_width": 150,
    "idle_height": 34,
    
    # Ukuran Kapsul Musik
    "music_compact_width": 240,
    "music_compact_height": 36,
    
    # Durasi auto-collapse (dalam milidetik)
    "hud_volume_timeout": 2200,       # 2.2 detik
    "hud_battery_timeout": 3000,      # 3 detik
    "hud_notification_timeout": 5000, # 5 detik
}
```

> **Tips:** Setelah mengubah konfigurasi, jalankan `./run.sh --restart` di terminal agar perubahan langsung diterapkan.

---

## 6. Troubleshooting & FAQ

#### Q: Dynamic Island tiba-tiba tidak muncul di layar?
Jalankan perintah restart:
```bash
./run.sh --restart
```
Atau periksa log error jika ada kendala:
```bash
cat /tmp/dynamic_island_kde.log
```

#### Q: Lagu di browser tidak terdeteksi oleh Dynamic Island?
Sebagian browser memerlukan integrasi tombol media diaktifkan. Buka browser Anda (misalnya Firefox / Chrome) dan pastikan fitur integrasi MPRIS/Media Keys aktif di pengaturan browser. Di Firefox, fitur ini aktif secara bawaan melalui integrasi desktop KDE.

#### Q: Bagaimana cara menutup aplikasi secara permanen?
Cukup jalankan:
```bash
./run.sh --stop
```
Jika Anda juga ingin mematikan autostart saat login:
```bash
./autostart.sh --disable
```
