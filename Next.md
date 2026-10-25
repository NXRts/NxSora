# 🗺️ Roadmap & Analisis Fitur: Projek Dynamic Island
**Platform:** CachyOS Linux | KDE Plasma 6 (Wayland) | Python 3 + PyQt6 + QML (Layer-Shell)

Dokumen ini memuat rangkuman analisis mendalam dari dua referensi *notch app* terkemuka:
1. **[Poni (poni.web.id)](https://poni.web.id/)**
2. **[Nusa (rama2555.github.io/nusa)](https://rama2555.github.io/nusa/)**

Serta rencana strategis (*implementation plan*) untuk mengadaptasi dan merealisasikan fitur-fitur terbaiknya ke dalam **Projek Dynamic Island** di CachyOS KDE Wayland.

---

## 🔬 1. Hasil Analisis Fitur Referensi

### A. Poni (`poni.web.id`)
* **Music Player & Adaptive Glow**: Cover album musik dengan efek pendaran cahaya (*glow*) adaptif yang mengikuti warna dominan album, live audio wave visualizer, seekbar dan media control.
* **AI Chat & Quick Translate**: Kolom input AI mengambang di dalam notch (mendukung Gemini API, Claude, OpenAI, atau Ollama lokal) untuk tanya-jawab kilat dan terjemahan instan.
* **Health & Wellness Tracker**:
  * *Water Intake*: Pencatat minum air (target 8 gelas/hari) dengan tombol tambah minum.
  * *20-20-20 Eye Break*: Pengingat istirahat mata setiap 20 menit menatap sejauh 20 kaki selama 20 detik.
  * *Stretch & Breathing*: Panduan peregangan postur dan latihan pernapasan melingkar (*inhale-hold-exhale*).
* **Calendar & Meeting Alerts**: Sinkronisasi agenda Google Calendar/Outlook/iCal dengan countdown pill sebelum meeting.
* **Weather & Forecast**: Cuaca live, suhu, kelembaban, dan prakiraan per jam serta 7 hari (Open-Meteo).
* **File Shelf**: Menaruh file sementara (*drag & drop stash*), quick zip, dan converter.
* **System Stats & Day Progress**: Monitoring CPU, RAM, Disk, Speedometer Jaringan, dan persentase hari yang telah lewat.
* **Desktop Pet**: Maskot kucing 3D yang melirik dan merespons kursor mouse.

---

### B. Nusa (`rama2555.github.io/nusa`)
* **Resting Mode (Mascot Eyes)**: Saat tidak ada notifikasi atau musik, jam memudar dan berganti sepasang mata digital bersinar yang berkedip lembut (*blinking eyes*).
* **Closed Idle Pill**: Kapsul minimalis berisikan jam digital, ring persentase baterai melingkar, dan visualizer audio mini bar saat lagu menyala.
* **Expanded Music Hub (420x140px)**: Desain pemutar musik presisi dengan artwork, judul, artis, scrubber timeline progres + sisa waktu, serta tombol kendali.
* **Synced Lyrics Mode (520x140px)**: Tampilan lirik karaoke terbelah dua (kiri: info lagu, kanan: baris lirik lagu yang otomatis scroll dan menyala terang baris demi baris mengikuti tempo vokal).
* **Focus Timer (Pomodoro)**: Ring api melingkar, hitung mundur 25:00, tombol pill *Short Break* & *Focus Time*, serta lonceng pergantian waktu.
* **Water Reminder & History Chart**: Pencatatan air dengan kuota harian (misal: 1.5/1.5 L, 100% Goal reached), tombol *Drink*, tombol *Settings*, serta grafik histogram konsumsi per jam (09, 12, 15).
* **File Shelf (Droppable Wayland Stash)**: Drop zone berpola garis putus-putus (*Drop files here*), menampilkan kartu file miniatur dengan ikon (gambar, folder, dokumen) dan ukuran file, tombol *Clear*, dan kemampuan drag-out kapan saja.
* **To-do List**: Rekap *4/5 Task Done Today*, daftar checklist tugas harian interaktif dengan coretan teks selesai, pill *Add Task* dan *Edit Task*.
* **Bluetooth & Charging Peek**:
  * *Headphones Peek (310x60px)*: Kapsul otomatis mengembang sesaat saat earbud/headphone tersambung ("AirBuds Pro Connected · 70%") dengan cincin baterai.
  * *Charging Peek (310x60px)*: Kapsul hijau bernyawa saat kabel charger dicolok dengan petir dan persentase baterai ("Charging · 70%").
* **Arsitektur Ultra-Ringan**: Menggunakan resource CPU 0% saat idle dan konsumsi memori <30 MB.

---

## ⚖️ 2. Komparasi dengan Projek Dynamic Island Saat Ini

| Fitur | Status Saat Ini | Rencana Adopsi dari Poni / Nusa |
| :--- | :---: | :--- |
| **Navigasi Multi-Halaman** | ✅ Selesai (`< >` & Dots) | Pertahankan dan perluas ke halaman baru (Lirik, Water, Todo, Shelf). |
| **Media Player MPRIS** | ✅ Selesai (Spotify/Firefox) | Tambahkan **Synced Lyrics** (Nusa) & **Adaptive Color Glow** (Poni/Nusa). |
| **Pomodoro Focus Timer** | ✅ Selesai (Dasar) | Percantik dengan **Ring Glow Lingkaran** dan preset *Short Break* (Nusa). |
| **System & Network Stats** | ✅ Selesai (CPU/RAM/Net) | Tambahkan indikator Day Progress & Cuaca Lokal (Poni). |
| **Water & Health Tracker** | ❌ Belum Ada | **Buat modul baru**: Water intake counter, 20-20-20 eye break prompt. |
| **File Shelf (Drop Zone)** | ❌ Belum Ada | **Buat modul baru**: Drop file Wayland ke Dynamic Island untuk stash sementara. |
| **To-Do List Harian** | ❌ Belum Ada | **Buat modul baru**: Checklist mini todo list di salah satu halaman hub. |
| **Resting Mascot Eyes** | ❌ Belum Ada | Tambahkan animasi mata maskot berkedip saat mode idle santai. |
| **Bluetooth / Charger Peek** | ⚠️ Sebagian (Baterai HUD) | Integrasi BlueZ DBus untuk auto-peek saat headphone tersambung. |
| **Quick AI Assistant** | ❌ Belum Ada | Prompt tanya-jawab / terjemahan cepat inline dengan Gemini API. |

---

## 🚀 3. Rencana Bertahap Implementasi (Execution Plan)

### 🟢 Fase 1: Visual Glow & Audio Enhancements (High Impact, Cepat Terasa)
1. **Adaptive Album Art Color Glow**:
   - Ekstrak warna dominan dari file cover album lagu aktif via Python (`PIL/Pillow` atau algoritma color extraction sederhana).
   - Kirim warna aksen via signal QML untuk memancarkan *glow/shadow* gradasi lembut di sekeliling Dynamic Island.
2. **Resting Mascot Eyes (Mode Santai)**:
   - Tambahkan opsi animasi sepasang mata digital berkedip lembut di kapsul tertutup saat desktop idle dan tidak ada media yang berputar.
3. **Headphones / Bluetooth Auto-Peek**:
   - Deteksi koneksi audio Bluetooth via D-Bus BlueZ, munculkan pill pop-up "AirPods/WH-1000XM5 Connected · Battery %" selama 3 detik.

### 🟡 Fase 2: Synced Lyrics & Health Tracker (Fitur Paling Diminati)
1. **Synced Lyrics Hub (Nusa-Style Split View)**:
   - Saat di halaman musik, sediakan tombol lirik yang memperluas hub dan menampilkan lirik berjalan sinkron (mengambil data dari API LRCLIB gratis berdasarkan artis & judul).
2. **Water Tracker & Health Reminder**:
   - Buat halaman widget Water Tracker: visual gelas air dengan tombol "+250ml", indikator target harian, dan grafik ringkas.
   - Pengingat pop-up halus berkala: minum air dan istirahat mata (20-20-20 Rule).

### 🟠 Fase 3: Shelf File Stash & To-Do List (Produktivitas)
1. **Wayland File Shelf (Drop Zone)**:
   - Implementasikan area `DropArea` di QML agar file dari Dolphin/Desktop bisa di-drop ke Dynamic Island.
   - Menampilkan thumbnail file yang tersimpan sementara di "Shelf", dan bisa di-drag keluar sewaktu-waktu.
2. **Mini To-Do Checklist**:
   - Halaman daftar tugas ringkas harian di Control Hub dengan checklist selesai, tombol tambah tugas, dan pencatat progres ("3/5 Selesai").

### 🟣 Fase 4: Live Weather, Day Progress & Quick AI Assistant
1. **Live Weather & Day Progress Bar**:
   - Prakiraan cuaca live tanpa API key menggunakan Open-Meteo (suhu, cuaca, kota).
   - Bar persentase hari yang berjalan dari jam 00:00 hingga 23:59.
2. **Quick Ask AI Pill (Poni-Style)**:
   - Input bar ringkas di island untuk menanyakan hal cepat ke Google Gemini API atau model LLM lokal Ollama, memberikan jawaban ringkas langsung di dalam island.
