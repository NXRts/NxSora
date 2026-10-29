# 📖 Panduan Lengkap Penggunaan NxSora (Nx空)
**Platform:** CachyOS / Arch Linux / openSUSE / Fedora | KDE Plasma 6 (Wayland)  
**Binary Resmi:** `nxsora`

Panduan ini berisi petunjuk lengkap cara menggunakan, mengontrol, mengonfigurasi, dan mengoptimalkan **NxSora** pada desktop Linux KDE Plasma 6 Anda.

---

## 📑 Daftar Isi
1. [Cara Menjalankan & Menghentikan (CLI `nxsora`)](#1-cara-menjalankan--menghentikan-cli-nxsora)
2. [Mengaktifkan Autostart (Otomatis Saat Login)](#2-mengaktifkan-autostart-otomatis-saat-login)
3. [Panduan Interaksi Mouse & Kontrol](#3-panduan-interaksi-mouse--kontrol)
4. [Struktur 9 Halaman Carousel & Menu Pengaturan Terpisah](#4-struktur-9-halaman-carousel--menu-pengaturan-terpisah)
5. [Konfigurasi XDG & Penyesuaian](#5-konfigurasi-xdg--penyesuaian)
6. [Troubleshooting & Tanya Jawab (FAQ)](#6-troubleshooting--tanya-jawab-faq)

---

## 1. Cara Menjalankan & Menghentikan (CLI `nxsora`)

NxSora menyediakan utilitas command line resmi `nxsora`:

| Perintah | Deskripsi |
| :--- | :--- |
| `nxsora --daemon` | **(Rekomendasi)** Menjalankan aplikasi di background. Terminal bisa langsung ditutup. |
| `nxsora` | Menjalankan di foreground (output log tampil langsung di terminal, tekan `Ctrl + C` untuk berhenti). |
| `nxsora --status` | Memeriksa status proses, PID, dan konsumsi memori aplikasi. |
| `nxsora --toggle` | Buka / Tutup Hub interaktif (ideal untuk pintasan keyboard global KDE). |
| `nxsora --settings` | Langsung membuka tampilan Menu Pengaturan terpisah. |
| `nxsora --restart` | Merestart aplikasi (berguna setelah mengubah konfigurasi atau file QML). |
| `nxsora --stop` | Menghentikan NxSora yang sedang berjalan. |
| `nxsora --test-notif` | Mengirimkan notifikasi uji coba ke notch. |
| `nxsora --help` | Menampilkan ringkasan seluruh perintah bantuan. |

---

## 2. Mengaktifkan Autostart (Otomatis Saat Login)

### Opsi A: Desktop Entry Autostart (Bawaan `install.sh`)
Skrip `./install.sh` otomatis mendaftarkan desktop entry ke `~/.config/autostart/nxsora.desktop`.

### Opsi B: Layanan Pengguna Systemd (Opsional)
Jika Anda lebih menyukai manajemen systemd user service:
```bash
systemctl --user enable --now nxsora.service
```
*(Catatan: Pilih salah satu antara autostart desktop atau systemd, jangan aktifkan keduanya sekaligus).*

---

## 3. Panduan Interaksi Mouse & Kontrol

NxSora dirancang dengan prinsip **100% Click-Through**: Anda tetap bisa mengklik jendela, tombol browser, atau tab yang berada di sekitar kapsul tanpa terhalang.

| Aksi Kursor / Keyboard | Efek pada NxSora |
| :--- | :--- |
| **Klik Kiri pada Kapsul** | Membuka tampilan Hub penuh (*Expanded Hub*). |
| **Klik Kanan pada Kapsul** | Pintasan cepat untuk toggle buka / tutup kartu. |
| **Tombol `<` dan `>` di Header** | Berpindah halaman kartu carousel ke samping (9 modul). |
| **Klik Titik Indikator (`● ○ ○ ...`)** | Langsung melompat ke halaman modul yang dipilih. |
| **Tombol Panah Keyboard (`←` / `→`)** | Berpindah halaman modul secara instan saat Hub terbuka. |
| **Geser / Drag Mouse Horisontal** | Menggeser (*swipe*) halaman modul ke samping secara mulus (*continuous wrap*). |
| **Touchpad 2-Finger Horizontal Swipe** | Berpindah halaman modul dengan gestur 2 jari di touchpad laptop. |
| **Scroll Roda Mouse di atas Kapsul** | Mengatur volume suara sistem PipeWire secara langsung. |
| **Klik pada Baris Lirik Musik** | Melompat (*seek*) lagu langsung ke detik baris lirik yang diklik (*Click-to-Seek*). |
| **Ikon Gerigi ⚙️ di Header** | Membuka Menu Pengaturan Terpisah. |
| **Tombol ‹ Kembali di Pengaturan** | Menutup pengaturan dan kembali ke halaman utama carousel. |
| **Tombol ✕ di Sudut Header** | Menutup kembali tampilan kartu menjadi kapsul minimalis. |
| **Tombol Escape (`Esc`)** | Menutup Menu Pengaturan (jika sedang terbuka) atau menutup Hub penuh. |

---

## 4. Struktur 9 Halaman Carousel & Menu Pengaturan Terpisah

### A. 9 Modul Carousel Utama (Geser `< >` atau Swipe)
1. **📊 Halaman 1: Sistem & Pomodoro Fokus**:
   - Pemantauan CPU, RAM, status baterai, dan timer Pomodoro Fokus ber-Ring Glow (25m Focus / 5m Break + *soft chime*).
2. **🎵 Halaman 2: Pemutar Musik & Lirik Karaoke LRCLIB**:
   - Sampul album, *seekbar* interaktif, kontrol media, pendaran warna adaptif (*Adaptive Glow*), dan mode lirik tersinkronisasi `520px` Split View (*Click-to-Seek*).
3. **⚡ Halaman 3: Pintasan Cepat (Quick Tools)**:
   - Slider kecerahan monitor, volume PipeWire, sakelar bisu mikrofon, kunci layar, tangkapan layar, dan tombol pengujian HUD.
4. **🌡️ Halaman 4: Hardware, Suhu & Processor TDP Monitor**:
   - Telemetri daya prosesor **TDP (Watt)** langsung dari kernel hwmon PPT, suhu multi-sensor **CPU (`k10temp`), GPU (`amdgpu/nvidia`), dan SSD NVMe**, frekuensi GHz, beban GPU, proses terberat (*Top CPU*), dan **Power Profile Switcher** (Hemat, Seimbang, Performa).
5. **🎧 Halaman 5: Bluetooth & Perangkat TWS**:
   - Terhubung via BlueZ D-Bus, daftar perangkat Bluetooth terpasang/tersimpan, persentase baterai earbud/headphone, dan tombol sambung/putus 1-klik.
6. **🔔 Halaman 6: Pusat Notifikasi Split-View**:
   - Riwayat 40 notifikasi dengan lencana kategori otomatis, tombol **📋 Salin OTP**, mode **🔕 Do Not Disturb**, lencana unread, dan pembersihan otomatis sampah kedaluwarsa (>48 jam).
7. **💧 Halaman 7: Kesehatan & Pelacak Air**:
   - **Histogram 8 Jam** konsumsi air harian, kustomisasi ukuran gelas (`150–500ml`), target harian (`1.5–3.0L`), dan pengingat **Eye Break 20-20-20**.
8. **✓ Halaman 8: Daftar Tugas (To-Do List Harian)**:
   - Pengelola checklist tugas harian dengan centang coret teks dan penyimpanan persisten aman (`0600`).
9. **📁 Halaman 9: Wayland File Shelf (Rak File Drag & Drop)**:
   - Seret file dari Dolphin/file manager ke notch untuk menyimpannya sementara (*Island Gulp effect*), pratinjau thumbnail, dan seret keluar (**Native Wayland `QDrag` `text/uri-list`**).

### B. ⚙️ Menu Pengaturan Terpisah (Dedicated Settings View)
Dapat diakses dengan mengklik ikon gerigi **`⚙️`** di header atau perintah terminal `nxsora --settings`:
- **Sakelar Smart Peek HUD**: Toggle individual untuk Volume HUD, Baterai HUD, Bluetooth HUD, Hardware HUD, Notifikasi Pop-up, dan Wi-Fi HUD.
- **Privasi & Perilaku**: Sakelar Fullscreen Auto-Hide, Privacy Dots (PipeWire kamera/mikrofon), dan Mascot Eye-Tracking.
- **Tombol Uji Cepat**: Uji Wi-Fi Peek dan Uji Baterai Lemah secara langsung.
- **Aksi Konfigurasi**: Buka `config.json` di text editor default dan Reset ke Pengaturan Awal bawaan.
- **Kembali**: Klik tombol **`[ ‹ Kembali ]`** di sudut kiri atas atau tekan tombol **`Esc`** untuk kembali ke carousel menu.

---

## 5. Konfigurasi XDG & Penyesuaian

NxSora mematuhi spesifikasi direktori XDG:
- **Konfigurasi Pengguna**: `~/.config/nxsora/config.json`
- **Cache (Lirik & Cover)**: `~/.cache/nxsora/lyrics/`
- **Berkas Riwayat Data**: `~/.config/nxsora/notifications.json` dan `tasks.json` (izin file `0600`)
- **Berkas Log**: `~/.local/state/nxsora/nxsora.log`
- **Lock & Runtime**: `/run/user/<UID>/nxsora/nxsora.lock`

> **Tips:** Setelah mengubah berkas `config.json`, jalankan `nxsora --restart` di terminal agar perubahan langsung dimuat ulang.

---

## 6. Troubleshooting & Tanya Jawab (FAQ)

#### Q: NxSora tidak muncul di layar atau tertutup panel lain?
Pastikan Anda menjalankan sesi **Wayland**. NxSora menggunakan pustaka `layer-shell-qt` untuk menempel presisi di layer panel atas. Anda dapat menyesuaikan margin atas di `~/.config/nxsora/config.json` (properti `top_margin`).

#### Q: Notifikasi sistem tidak masuk ke NxSora?
Pastikan paket `dbus-monitor` terinstal di sistem Anda. NxSora memantau sinyal `org.freedesktop.Notifications` secara pasif tanpa mengambil alih daemon notifikasi bawaan KDE Plasma.

#### Q: Bagaimana cara mengatur pintasan keyboard global (Shortcut)?
Buka **KDE System Settings ➜ Shortcuts ➜ Custom Commands / Shortcuts**, tambahkan pintasan baru:
- Perintah: `nxsora --toggle` (misal untuk `Meta + I` membuka/menutup Hub)
- Perintah: `nxsora --settings` (misal untuk `Meta + Shift + S` membuka Pengaturan)

#### Q: Bagaimana cara menghentikan aplikasi secara permanen?
Cukup jalankan:
```bash
nxsora --stop
```
Jika Anda menggunakan systemd service:
```bash
systemctl --user stop nxsora.service
```
