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

| Aksi Kursor | Efek pada Dynamic Island |
| :--- | :--- |
| **Klik Kiri pada Kapsul** | Membuka tampilan kartu penuh (*Expanded Card*) untuk melihat detail musik atau Control Hub. |
| **Klik Kanan pada Kapsul** | Pintasan cepat untuk toggle buka / tutup kartu. |
| **Scroll Roda Mouse di atas Kapsul** | Mengatur volume suara sistem (scroll ke atas untuk memperbesar, ke bawah untuk mengecilkan). |
| **Klik pada Garis Durasi Musik** | Melompat (*seek*) langsung ke menit tertentu dalam lagu/video. |
| **Tombol ✕ di Sudut Kartu** | Menutup kembali tampilan kartu menjadi kapsul minimalis. |

---

## 4. Fitur-Fitur Utama & Cara Pakai

### A. Pemutar Musik (Spotify, Browser, VLC)
* **Kapsul Otomatis Mendeteksi Media**: Saat Anda memutar lagu di Spotify atau video di YouTube (Firefox / Chrome / Brave), kapsul otomatis memanjang menampilkan ikon album, judul lagu, dan visualizer audio dinamis yang bergoyang.
* **Tampilan Kartu Penuh**: Klik kapsul untuk membuka player lengkap.
  * Tekan tombol **Play / Pause** (tengah bulat biru).
  * Tekan **Previous (⏮)** untuk lagu sebelumnya.
  * Tekan **Next (⏭)** untuk lagu berikutnya.
  * Klik garis durasi biru untuk melompat menit lagu.
  * Atur slider volume suara tepat di dalam kartu musik.

### B. Pengatur Volume & Scroll Mouse
* Setiap kali Anda menekan tombol volume fisik di keyboard, Dynamic Island memunculkan bar indikator suara dengan angka persentase.
* Anda juga bisa mengarahkan mouse ke kapsul lalu memutar roda mouse untuk mengatur volume secara instan.
* Kapsul volume akan menyusut kembali secara otomatis setelah 2 detik tidak ada aktivitas.

### C. Status Baterai & Charger
* Saat kabel pengisi daya (charger laptop) dicolokkan, Dynamic Island memunculkan kapsul hijau cerah bertuliskan *"Mengisi Daya XX%"*.
* Saat charger dilepas, status akan beralih menjadi *"Baterai XX%"*.

### D. Notifikasi Desktop
* Setiap ada pesan atau notifikasi masuk (Discord, Telegram, WhatsApp Web, email, atau sistem), Dynamic Island otomatis membesar menampilkan logo notifikasi, nama pengirim, judul, serta cuplikan pesan.
* Notifikasi akan menutup kembali secara otomatis setelah 5 detik.
* Uji fitur ini kapan saja dengan perintah: `./run.sh --test-notif`.

### E. Control Hub & Monitoring Sistem
* Saat tidak ada musik yang sedang berputar, klik kapsul jam di atas untuk membuka **Dynamic Control Hub**.
* Di dalam Control Hub Anda dapat memantau:
  * **CPU Usage**: Persentase pemakaian prosesor dan grafik bar.
  * **RAM Usage**: Persentase pemakaian RAM beserta angka memori terpakai (misal: `4.5 / 15.4 GB`).
  * **Battery Health**: Indikator baterai dan status pengisian.
  * **Quick Mute**: Tombol cepat untuk mematikan/menyalakan suara.

### F. Quick Timer / Pomodoro
* Buka **Control Hub**, lalu pilih preset timer cepat:
  * `1m` (1 menit)
  * `5m` (5 menit)
  * `25m` (25 menit / Pomodoro kerja)
* Saat timer berjalan, waktu mundur akan terus ditampilkan secara *real-time* di kapsul standby.
* Saat waktu habis, Dynamic Island akan mengirimkan notifikasi pemberitahuan.

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
