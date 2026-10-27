# 🗺️ Master Roadmap & Analisis Fitur: Projek Dynamic Island
**Platform Target:** CachyOS Linux | KDE Plasma 6 (Wayland) | Python 3 + PyQt6 + QML (`Layer-Shell`)

Dokumen ini berisi hasil bedah lengkap terhadap:
1. **10 Fitur Utama di Preview Interaktif & Halaman Web [Nusa (`rama2555.github.io/nusa`)](https://rama2555.github.io/nusa/)** (sesuai gambar tab *Resting, Closed, Music, Lyrics, Focus timer, Water, Shelf, To-do, Headphones, Charging* beserta fitur sistem tersembunyinya).
2. **Ekosistem Aplikasi Notch & Dynamic Island Lintas Platform Lainnya**:
   - **Windows / Web**: **Poni (`poni.web.id`)**
   - **macOS**: **Boring.Notch**, **NotchNook**, **Alcove**, **MediaMate**, **DynamicLake**
   - **Linux Wayland**: **Tide Island**, **AX-Shell**, **Golden Gate Shell (KDE)**, **OpenAgentIsland**
3. **Rekomendasi & Masukan Eksklusif untuk KDE Plasma 6 Wayland (CachyOS)**.
4. **Master Plan Implementasi Bertahap (Actionable Roadmap)** untuk diterapkan ke kode kita.

---

## 🔍 1. Analisis Mendalam 10 Tab Fitur Nusa (Berdasarkan Gambar & Bedah Kode Web)

Berdasarkan gambar navigasi preview di web [Nusa](https://rama2555.github.io/nusa/) (`Resting | Closed | Music | Lyrics | Focus timer | Water | Shelf | To-do | Headphones | Charging`), berikut adalah spesifikasi desain, ukuran, dan perilaku asli dari masing-masing mode di Nusa:

### 1. `Resting` (Mode Maskot Santai — `150x30px`)
* **Cara Kerja di Nusa**: Saat tidak ada aktivitas atau musik berhenti, jam digital memudar dan berganti menjadi sepasang mata putih bersinar (`8.4x12.4px`) dengan pendaran *ambient glow* biru-ungu di belakangnya.
* **Detail Unik yang Belum Kita Miliki**:
  * **Doze Off (Mengantuk/Tidur)**: Setelah PC diam beberapa saat (*idle*), mata maskot perlahan menutup/mengantuk.
  * **Wave Hello (Menyapa Saat Kembali)**: Saat pengguna kembali menggerakkan mouse/keyboard, maskot bangun dan melakukan animasi menyapa (*wave/happy eyes*).
  * **Eye Tracking**: Mata melirik halus mengikuti arah kursor mouse di sekitar layar.

### 2. `Closed` (Kapsul Tertutup Aktif — `150x30px`)
* **Cara Kerja di Nusa**: Tampilan kapsul ringkas dengan 3 elemen presisi:
  * **Kiri**: **Circular Battery Ring** (`conic-gradient` hijau `#33e07a`) tanpa angka yang memakan tempat.
  * **Tengah**: **Jam Digital** (`18:55`) dengan font tegas.
  * **Kanan**: **Live Sound Wave (5-Bar Equalizer)** yang langsung bergoyang di samping jam ketika ada musik diputar di latar belakang.
* **Catatan untuk Projek Kita**: Saat ini `CompactIdle.qml` kita menampilkan titik status + jam + teks `%` baterai, dan langsung berubah ke `CompactMusic.qml` (tanpa jam) saat musik menyala. Kita bisa mengadopsi gaya **Ring Baterai Melingkar** dan opsi **Hybrid Idle-Music** (jam tetap terlihat bersama mini visualizer).

### 3. `Music` (Pemutar Musik — `420x140px`)
* **Cara Kerja di Nusa**:
  * **Header Mini Terpadu**: Menampilkan cincin baterai, Tanggal lengkap + Jam (`Thu 15 Oct 2026 18:55`), serta equalizer mini di pojok kanan atas.
  * **Body**: Cover album `62x62px` di kiri, judul lagu & nama artis-album, tombol panah navigasi halaman `< >` mengambang di tepi kiri/kanan.
  * **Timeline**: Waktu berjalan di kiri (`03:13`), progress bar di tengah, dan **waktu tersisa negatif** di kanan (`-01:03`).
  * **Tombol Lirik Inline**: Di kiri bawah sejajar dengan tombol *Prev / Play-Pause / Next*, terdapat **ikon balon lirik (`bub`)** untuk membuka mode karaoke.

### 4. `Lyrics` (Mode Lirik Tersinkronisasi / Karaoke — Melebar ke `520x140px`)
* **Cara Kerja di Nusa**:
  * Saat tombol lirik ditekan, Dynamic Island **melebar secara dinamis dari `420px` menjadi `520px`** dan terbelah dua (*Split View*) oleh garis vertikal tipis:
  * **Sisi Kiri (`252px`)**: Menyimpan cover album, judul lagu, seekbar ringkas, dan tombol kontrol media.
  * **Sisi Kanan (`234px`)**: Menampilkan daftar lirik lagu *real-time* yang diambil otomatis dari API gratis **LRCLIB (`lrclib.net`)** berdasarkan *title*, *artist*, dan *duration*.
  * **Efek Karaoke & Klik-untuk-Seek**: Baris lirik yang sedang dinyanyikan menyala putih terang (`scale(1.0)`), sedangkan baris sebelum/sesudahnya redup (`opacity 0.3`, `scale(0.93)`) dengan efek *gradient mask* di batas atas dan bawah. **Mengklik salah satu baris lirik akan langsung melompatkan posisi lagu (*seek*) ke detik lirik tersebut!**

### 5. `Focus timer` (Pomodoro Fokus — `420x140px`)
* **Cara Kerja di Nusa**:
  * **Kiri**: **Glowing Conic Ring** berwarna merah-koral (`#ff5a6e` -> `#ff3a3a`) berdiameter `64px` dengan pendaran cahaya (`pglow`) dan ikon stopwatch di tengahnya.
  * **Kanan Atas**: Angka waktu besar (`25:00`), tombol bundar *Reset* di sebelahnya, dan label status (`Focus time` / `Short break`).
  * **Kanan Bawah**: 3 tombol kapsul (*pill*): tombol mode `Short Break` (ikon cangkir kopi), tombol utama `Play/Pause` merah menyala, dan tombol mode `Focus Time` (ikon target), ditambah **bunyi lonceng lembut (*soft chime*)** saat sesi selesai.
* **Catatan untuk Projek Kita**: Saat ini timer kita masih berupa kartu kecil di halaman Sistem (`Page 0`). Membuatkannya **tampilan khusus ber-Ring Glow** dengan mode *Focus (25m)* vs *Short Break (5m)* + efek suara akan jauh lebih elegan.

### 6. `Water` (Pengingat Minum & Grafik Jam-jaman — `420x140px`)
* **Cara Kerja di Nusa**:
  * Tampilan terbelah dua (*Split View*):
  * **Sisi Kiri**: Angka besar `1.5 / 1.5 L`, sakelar toggle lonceng pengingat aktif, status `Today · 100% · Goal reached`, bar progres gradasi biru, tombol `Drink` dan tombol `Settings` (untuk mengatur ukuran gelas/botol & target harian).
  * **Sisi Kanan**: **Grafik Histogram Per Jam (Hourly Bar Chart)** dari pukul `09`, `12`, `15`, dst. dengan sumbu Y (`0 ml`, `200`, `400`) dan animasi batang tumbuh (*spring bar growth*).
* **Catatan untuk Projek Kita**: `PageHealth.qml` & `services/health.py` kita sudah punya `_hourly_history` di backend Python, namun **belum divisualisasikan menjadi grafik batang per jam di UI QML**, serta belum ada pengaturan kustomisasi ukuran botol/target langsung dari UI.

### 7. `Shelf` (Rak Penyimpanan File Sementara Drag & Drop — `420x140px`)
* **Cara Kerja di Nusa**:
  * Area garis putus-putus (`Drop files here` / `Release to add` / `Drag out anytime · click to open`).
  * **"Island Gulp" Animation**: Ketika pengguna menyeret (*drag*) file dari File Manager mendekati notch, island memancarkan cahaya gradasi biru-ungu dan sedikit "menelan/mengembang" (*swell/gulp*) saat file dilepas.
  * **Kartu File & Drag-Out**: Menampilkan kartu file beserta thumbnail (preview gambar atau ikon folder/dokumen), nama file, ukuran (`2.4 MB`), tombol `Clear`, klik untuk membuka, dan bisa **di-drag keluar lagi** ke aplikasi lain (chat, browser, email, folder) tanpa menyalin isi file ke RAM (hanya menyimpan referensi path).

### 8. `To-do` (Daftar Tugas dengan Pengingat Waktu — `420x140px`)
* **Cara Kerja di Nusa**:
  * **Layout Split**: Sisi kiri menampilkan angka progres raksasa (`4/5 Task Done Today`) beserta tombol `Add Task` dan `Edit Task`. Sisi kanan menampilkan daftar tugas scrollable dengan checkbox hijau bundar dan teks dicoret (*strikethrough*).
  * **Fitur Kunci**: Tugas dapat diberi **jam tenggat waktu (*due time reminder*)**, sehingga Dynamic Island otomatis mencolek/memunculkan pop-up saat tugas jatuh tempo.

### 9. `Headphones` (Pop-up Earbuds / Bluetooth — `310x60px`)
* **Cara Kerja di Nusa**:
  * Kapsul berukuran menengah (`310x60px`, lebih besar dari HUD biasa tetapi lebih ringkas dari Hub penuh).
  * **Kiri**: Cincin progres biru muda (`#5ec2ff`) dengan ikon Bluetooth di tengahnya.
  * **Tengah**: Nama perangkat (`AirBuds Pro`) dan status (`Connected · 70%`).
  * **Kanan**: Ikon headphone di dalam lingkaran bercahaya.

### 10. `Charging` (Pop-up Pengisian Daya — `310x60px`)
* **Cara Kerja di Nusa**:
  * Kapsul `310x60px` yang muncul saat kabel charger dicolokkan.
  * **Kiri**: Cincin progres melingkar hijau neon (`#33e07a`) dengan ikon petir putih di dalamnya.
  * **Tengah**: Teks tebal `Charging` dan subteks `Charger connected`.
  * **Kanan**: Angka persentase besar `70%` (`24px`).

---

## 🌐 2. Fitur Tambahan dari Web Nusa & Projek Notch Lainnya

Selain 10 tab di atas, hasil analisis menyeluruh terhadap dokumentasi Nusa dan aplikasi sejenis menghasilkan daftar fitur unggulan berikut:

### A. Fitur Sistem Tambahan dari Web Nusa (`rama2555.github.io/nusa`)
1. **Screen Brightness HUD Overlay**: Pop-up mulus saat mengatur kecerahan layar laptop.
2. **Caps Lock & Keyboard Layout Nudge**: Pop-up kapsul singkat saat tombol `Caps Lock` ditekan (On/Off) atau saat layout keyboard berganti.
3. **Wi-Fi Connect / Disconnect Peek**: Pop-up otomatis saat Wi-Fi terputus atau tersambung ke jaringan baru.
4. **System Tray Icon & Quick Menu**: Ikon di System Tray KDE untuk mengaktifkan/mematikan *Start on Login*, *Mascot Mode*, *Minimal Notch Mode*, dan *Exit*.
5. **Minimal Notch Mode (Thin Line)**: Opsi mengubah kapsul tertutup menjadi garis hitam tipis di tepi atas layar bagi pengguna yang menginginkan tampilan ekstra minimalis, namun tetap otomatis membuka penuh saat di-hover atau ada notifikasi.
6. **Fullscreen App Auto-Hide**: Otomatis bersembunyi (*step aside*) ketika pengguna sedang menjalankan game atau video dalam mode layar penuh (*fullscreen*).

### B. Fitur Terbaik dari Projek Notch macOS & Windows Lainnya
1. **Boring.Notch & NotchNook (macOS)**:
   - **Camera Mirror (Cermin Kamera Cepat)**: Widget kamera langsung (*live webcam preview*) di dalam island untuk mengecek wajah/rambut sebelum masuk rapat Zoom/Google Meet.
   - **Quick Share / KDE Connect Drop**: Di macOS ada AirDrop di dalam Shelf; di KDE Plasma kita bisa mengintegrasikan **KDE Connect** agar file yang di-drop ke Island bisa langsung dikirim ke HP Android/iPhone dengan 1 klik!
   - **Calendar & Next Meeting Countdown**: Menampilkan jadwal agenda berikutnya dan hitung mundur menuju rapat (`Meeting in 12m` + tombol `Join`).
   - **Clipboard History Manager**: Menyimpan 10–15 teks/gambar terakhir yang disalin (`Ctrl+C`) agar bisa ditempel ulang dengan sekali klik dari Island.
2. **Alcove & MediaMate (macOS)**:
   - **Audio Output / Input Switcher**: Mengganti perangkat output suara (Speaker Laptop ↔ Headset Bluetooth ↔ HDMI) dan mute mikrofon langsung dari halaman musik/sistem tanpa membuka pengaturan sistem.
   - **Live Spectrum / Real Audio Visualizer (`cava` / PipeWire)**: Bar gelombang suara yang benar-benar bergerak mengikuti frekuensi bass/treble audio asli dari sistem (bukan sekadar animasi loop statis).
3. **Poni (`poni.web.id`) & OpenAgentIsland (Linux)**:
   - **Quick AI Chat & Instant Translate**: Input teks cepat di dalam Island untuk bertanya ke AI (Google Gemini API / Ollama lokal) atau menerjemahkan teks clipboard secara instan.
   - **Live Weather & Day Progress Bar**: Info cuaca lokal *real-time* (via Open-Meteo tanpa API key) serta persentase waktu hari yang telah berlalu (`Day Progress: 68%`).
   - **Guided Breathing (Pernapasan Melingkar)**: Lingkaran animasi *Inhale (4s) — Hold (4s) — Exhale (4s)* di halaman Kesehatan untuk relaksasi singkat saat coding.
4. **Tide Island, AX-Shell & Golden Gate Shell (Linux Wayland)**:
   - **KDE Virtual Desktop / Workspace Indicator**: Menampilkan indikator workspace/desktop virtual KDE Plasma yang aktif dan berpindah desktop dengan scroll atau klik.
   - **Privacy Indicator Dots (Mic & Camera Active)**: Titik hijau/oranye kecil di sudut kapsul tertutup saat ada aplikasi yang sedang mengakses Mikrofon atau Kamera via PipeWire (seperti indikator privasi iOS/macOS).

---

## 📊 3. Status Implementasi Projek Kita Saat Ini vs Target Baru

| Kategori Fitur | Status di Projek Kita Saat Ini | Target Upgrade Selanjutnya |
| :--- | :---: | :--- |
| **Bentuk Notch & Concave Ears** | ✅ Selesai (`Island.qml`) | Tambah opsi **Minimal Line Mode** & animasi **"Island Gulp"** saat drop file. |
| **Navigasi Multi-Halaman** | ✅ Selesai (7 Halaman + Pin 📌) | Mendukung halaman Sistem & Pomodoro, Musik & Lirik, Tools, Net, Health, To-Do, & Shelf. |
| **Media Player & Adaptive Glow** | ✅ Selesai (`mpris.py` + `lyrics.py`) | Sudah dilengkapi **Synced Lyrics (`520px` Split View)**, sisa waktu `-MM:SS`, & Adaptive Glow. |
| **Resting Mascot Eyes** | ✅ Selesai Dasar (`MascotEyes.qml`) | Upgrade dengan **Cursor Eye-Tracking**, animasi **Mengantuk (Sleep)** & **Wave Hello**. |
| **Water & Eye Break (20-20-20)** | ✅ Selesai (`PageHealth.qml`) | Sudah dilengkapi **Grafik Histogram Per Jam (`09..16`)**, **Pengaturan Gelas/Target**, & Jeda 20-20-20. |
| **To-Do List Harian** | ✅ Selesai Dasar (`PageTodo.qml`) | Tambah fitur **Edit Task** & **Pengingat Jam Jatuh Tempo (Due Time Reminder)**. |
| **Pomodoro Focus Timer** | ✅ Selesai (`ExpandedHub.qml` + `timer.py`) | Sudah menggunakan **Conic Ring Glow**, preset *Focus (25m) / Short Break (5m)*, & *Soft Chime*. |
| **File Shelf (Drop & Drag-Out)** | ✅ Selesai (`PageShelf.qml` + `shelf.py`) | Sudah dilengkapi Wayland Drag-and-Drop, efek **"Island Gulp"**, & Drag-Out (`QDrag`). |
| **Headphones / Bluetooth Peek** | ❌ Belum Ada | **Prioritas Tinggi**: Buat HUD `310x60px` via **BlueZ / UPower D-Bus** saat TWS/Headphone tersambung. |
| **Charging Peek (Nusa Ring)** | ⚠️ Baru HUD bar (`230x32px`) | Upgrade ke **Nusa Charging Peek (`310x60px`)** dengan **Circular Conic Ring** hijau & teks `24px`. |
| **Brightness, CapsLock & Mic HUD** | ❌ Belum Ada | Integrasi D-Bus PowerDevil (Brightness), Mic Mute HUD, dan Caps Lock indicator. |
| **Privacy Dots (Cam / Mic In-Use)** | ❌ Belum Ada | Deteksi node PipeWire aktif untuk menampilkan titik hijau/oranye ala iOS/macOS di kapsul idle. |
| **System Tray & Fullscreen Hide** | ❌ Belum Ada | Tambah `QSystemTrayIcon` (menu konfigurasi cepat) & deteksi jendela Fullscreen KWin. |
| **Clipboard History / Quick AI** | ❌ Belum Ada | Tambah pengelola riwayat Clipboard & cuaca lokal (Open-Meteo). |

---

## 🚀 4. Rencana Implementasi Bertahap (Step-by-Step Implementation Plan)

Berikut adalah urutan pengerjaan yang paling terstruktur agar setiap fase memberikan peningkatan visual dan fungsional yang langsung terasa tanpa merusak kestabilan sistem yang sudah ada:

### ✅ Fase 1: Paritas Penuh Fitur Utama Nusa (Lyrics, File Shelf, & Pomodoro Ring) — [SELESAI]
1. **Synced Lyrics Mode (`520x140px` Split Karaoke View)**
   - **Backend (`services/lyrics.py`)**: Buat layanan pencari lirik asinkron ke API `https://lrclib.net/api/get` menggunakan `title`, `artist`, dan `duration` dari `MprisService`, lengkap dengan cache lokal (`~/.cache/dynamic_island/lyrics/`) dan parser format `.lrc` (`[mm:ss.xx]`).
   - **UI (`qml/ExpandedHub.qml` & `qml/Island.qml`)**: Tambahkan tombol balon lirik di halaman Musik. Saat aktif, lebarkan `Island` menjadi `520px`, bagi tampilan menjadi dua (info musik di kiri, daftar lirik auto-scroll dengan *fade mask* di kanan), dan dukung klik baris lirik untuk *seek* posisi lagu.
2. **Wayland File Shelf (Drop Zone & Drag-Out Stash)**
   - **Backend (`services/shelf.py`)**: Simpan daftar path file sementara di `~/.config/dynamic_island/shelf.json`, baca metadata (nama, ukuran file, tipe gambar/folder/dokumen), serta sediakan aksi *Open*, *Remove*, *Clear All*, dan *Start Drag Out* (`QDrag` + `QMimeData` dengan `text/uri-list`).
   - **UI (`qml/PageShelf.qml`)**: Buat halaman **Shelf** dengan `DropArea` bergaris putus-putus, efek pendaran cahaya **"Island Gulp"** saat file melayang di atas island, serta kartu thumbnail file yang bisa di-drag keluar kapan saja.
3. **Nusa-Style Pomodoro Focus Timer & Hourly Water Histogram**
   - Percantik timer dengan **Circular Conic Progress Ring** bercahaya, mode *Focus (25m)* / *Short Break (5m)* / *Long Break (15m)*, serta efek suara notifikasi lembut (`canberra-gtk-play` / `paplay`).
   - Visualisasikan data `_hourly_history` di `PageHealth.qml` menjadi **Grafik Batang Per Jam (09..18)** persis seperti di Nusa, lengkap dengan tombol pengatur ukuran gelas (`150ml / 250ml / 500ml`) dan target harian.

### ⚡ Fase 2: Smart Peek Overlays (`310x60px`) & Indikator Hardware KDE
1. **Headphones / Bluetooth Auto-Peek (`qml/HudBluetooth.qml` + `services/bluetooth.py`)**
   - Pantau koneksi perangkat audio Bluetooth melalui D-Bus `org.bluez` dan `org.freedesktop.UPower`.
   - Saat TWS/Headphone tersambung atau terputus, munculkan kapsul `310x60px` berisi cincin baterai biru, nama perangkat, persentase baterai, dan ikon headphone bercahaya selama 3,5 detik.
2. **Upgraded Charging Peek (`qml/HudBattery.qml` — `310x60px`) & Closed Battery Ring**
   - Perbarui `HudBattery.qml` menjadi gaya Nusa (`310x60px`) dengan cincin progres melingkar hijau neon (`#33e07a`), ikon petir di tengah cincin, dan persentase baterai besar di sisi kanan.
   - Tambahkan cincin baterai melingkar dan indikator gelombang suara mini pada mode kapsul tertutup (`CompactIdle.qml`).
3. **Screen Brightness, Mic Mute & Caps Lock HUD**
   - Integrasikan sinyal D-Bus KDE `org.kde.Solid.PowerManagement.Actions.BrightnessControl` untuk menampilkan HUD Kecerahan Layar saat tombol Fn+Brightness ditekan.
   - Tambahkan HUD singkat saat tombol *Microphone Mute* atau *Caps Lock* ditekan.

### 🌟 Fase 3: Interaktivitas Maskot Pintar, Privasi & Integrasi Desktop KDE
1. **Smart Mascot 2.0 (`MascotEyes.qml`)**
   - Tambahkan pelacakan kursor halus (*eye gaze mengikuti posisi mouse*), mode mengantuk (*sleeping eyes* saat idle > 5 menit), dan animasi menyapa (*happy blink / wave*) saat pengguna kembali aktif.
2. **Privacy Indicator Dots (Kamera & Mikrofon Aktif)**
   - Deteksi penggunaan kamera (`/dev/video*` / PipeWire) dan mikrofon aktif via `pw-dump` / Pactl, lalu tampilkan titik indikator hijau (kamera) dan oranye (mikrofon) di sudut Dynamic Island seperti di iOS/macOS.
3. **System Tray Menu & Fullscreen Auto-Hide**
   - Tambahkan ikon System Tray (`QSystemTrayIcon`) dengan menu cepat: *Pin/Unpin Hub*, *Mode Maskot*, *Minimal Line Mode*, *Sembunyikan Saat Fullscreen*, dan *Keluar*.
   - Deteksi saat jendela aktif di KDE Wayland berada dalam mode *Fullscreen* agar Dynamic Island otomatis menyembunyikan diri dan tidak menghalangi game/video.

### 🧠 Fase 4: Fitur Produktivitas Ekstra (Dari Boring.Notch, NotchNook & Poni)
1. **Clipboard History & Quick Paste**: Halaman/tab cepat untuk melihat 10 teks terakhir yang disalin dan menempelkannya kembali.
2. **Audio Output Device Switcher**: Pilih output audio aktif (Speaker vs Headphone Bluetooth) langsung dari halaman Musik.
3. **Live Weather & Day Progress Bar**: Widget cuaca lokal ringan (`Open-Meteo`) dan bar progres hari di halaman Jaringan/Info.
4. **Camera Mirror & KDE Connect Quick Share**: Pratinjau cermin webcam cepat dan tombol kirim file dari *Shelf* langsung ke smartphone via KDE Connect.
5. **To-Do Due Time Reminder**: Tambahkan opsi jam pengingat (`HH:MM`) pada setiap tugas di halaman To-Do yang otomatis memicu HUD Notifikasi saat waktunya tiba.

### 🧠 Fase 4: Fitur Produktivitas Ekstra (Dari Boring.Notch, NotchNook & Poni)
1. **Clipboard History & Quick Paste**: Halaman/tab cepat untuk melihat 10 teks terakhir yang disalin dan menempelkannya kembali.
2. **Audio Output Device Switcher**: Pilih output audio aktif (Speaker vs Headphone Bluetooth) langsung dari halaman Musik.
3. **Live Weather & Day Progress Bar**: Widget cuaca lokal ringan (`Open-Meteo`) dan bar progres hari di halaman Jaringan/Info.
4. **Camera Mirror & KDE Connect Quick Share**: Pratinjau cermin webcam cepat dan tombol kirim file dari *Shelf* langsung ke smartphone via KDE Connect.
5. **To-Do Due Time Reminder**: Tambahkan opsi jam pengingat (`HH:MM`) pada setiap tugas di halaman To-Do yang otomatis memicu HUD Notifikasi saat waktunya tiba.

