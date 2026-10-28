# 🗺️ Master Roadmap & Analisis Fitur: Projek Dynamic Island

**Platform Target:** CachyOS Linux | KDE Plasma 6 (Wayland) | Python 3 + PyQt6 + QML (`Layer-Shell`)

Dokumen ini berisi hasil bedah lengkap terhadap:

1. **10 Fitur Utama di Preview Interaktif & Halaman Web [Nusa (`rama2555.github.io/nusa`)](https://rama2555.github.io/nusa/)** (sesuai gambar tab _Resting, Closed, Music, Lyrics, Focus timer, Water, Shelf, To-do, Headphones, Charging_ beserta fitur sistem tersembunyinya).
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

- **Cara Kerja di Nusa**: Saat tidak ada aktivitas atau musik berhenti, jam digital memudar dan berganti menjadi sepasang mata putih bersinar (`8.4x12.4px`) dengan pendaran _ambient glow_ biru-ungu di belakangnya.
- **Detail Unik yang Belum Kita Miliki**:
  - **Doze Off (Mengantuk/Tidur)**: Setelah PC diam beberapa saat (_idle_), mata maskot perlahan menutup/mengantuk.
  - **Wave Hello (Menyapa Saat Kembali)**: Saat pengguna kembali menggerakkan mouse/keyboard, maskot bangun dan melakukan animasi menyapa (_wave/happy eyes_).
  - **Eye Tracking**: Mata melirik halus mengikuti arah kursor mouse di sekitar layar.

### 2. `Closed` (Kapsul Tertutup Aktif — `150x30px`)

- **Cara Kerja di Nusa**: Tampilan kapsul ringkas dengan 3 elemen presisi:
  - **Kiri**: **Circular Battery Ring** (`conic-gradient` hijau `#33e07a`) tanpa angka yang memakan tempat.
  - **Tengah**: **Jam Digital** (`18:55`) dengan font tegas.
  - **Kanan**: **Live Sound Wave (5-Bar Equalizer)** yang langsung bergoyang di samping jam ketika ada musik diputar di latar belakang.
- **Catatan untuk Projek Kita**: Saat ini `CompactIdle.qml` kita menampilkan titik status + jam + teks `%` baterai, dan langsung berubah ke `CompactMusic.qml` (tanpa jam) saat musik menyala. Kita bisa mengadopsi gaya **Ring Baterai Melingkar** dan opsi **Hybrid Idle-Music** (jam tetap terlihat bersama mini visualizer).

### 3. `Music` (Pemutar Musik — `420x140px`)

- **Cara Kerja di Nusa**:
  - **Header Mini Terpadu**: Menampilkan cincin baterai, Tanggal lengkap + Jam (`Thu 15 Oct 2026 18:55`), serta equalizer mini di pojok kanan atas.
  - **Body**: Cover album `62x62px` di kiri, judul lagu & nama artis-album, tombol panah navigasi halaman `< >` mengambang di tepi kiri/kanan.
  - **Timeline**: Waktu berjalan di kiri (`03:13`), progress bar di tengah, dan **waktu tersisa negatif** di kanan (`-01:03`).
  - **Tombol Lirik Inline**: Di kiri bawah sejajar dengan tombol _Prev / Play-Pause / Next_, terdapat **ikon balon lirik (`bub`)** untuk membuka mode karaoke.

### 4. `Lyrics` (Mode Lirik Tersinkronisasi / Karaoke — Melebar ke `520x140px`)

- **Cara Kerja di Nusa**:
  - Saat tombol lirik ditekan, Dynamic Island **melebar secara dinamis dari `420px` menjadi `520px`** dan terbelah dua (_Split View_) oleh garis vertikal tipis:
  - **Sisi Kiri (`252px`)**: Menyimpan cover album, judul lagu, seekbar ringkas, dan tombol kontrol media.
  - **Sisi Kanan (`234px`)**: Menampilkan daftar lirik lagu _real-time_ yang diambil otomatis dari API gratis **LRCLIB (`lrclib.net`)** berdasarkan _title_, _artist_, dan _duration_.
  - **Efek Karaoke & Klik-untuk-Seek**: Baris lirik yang sedang dinyanyikan menyala putih terang (`scale(1.0)`), sedangkan baris sebelum/sesudahnya redup (`opacity 0.3`, `scale(0.93)`) dengan efek _gradient mask_ di batas atas dan bawah. **Mengklik salah satu baris lirik akan langsung melompatkan posisi lagu (_seek_) ke detik lirik tersebut!**

### 5. `Focus timer` (Pomodoro Fokus — `420x140px`)

- **Cara Kerja di Nusa**:
  - **Kiri**: **Glowing Conic Ring** berwarna merah-koral (`#ff5a6e` -> `#ff3a3a`) berdiameter `64px` dengan pendaran cahaya (`pglow`) dan ikon stopwatch di tengahnya.
  - **Kanan Atas**: Angka waktu besar (`25:00`), tombol bundar _Reset_ di sebelahnya, dan label status (`Focus time` / `Short break`).
  - **Kanan Bawah**: 3 tombol kapsul (_pill_): tombol mode `Short Break` (ikon cangkir kopi), tombol utama `Play/Pause` merah menyala, dan tombol mode `Focus Time` (ikon target), ditambah **bunyi lonceng lembut (_soft chime_)** saat sesi selesai.
- **Catatan untuk Projek Kita**: Saat ini timer kita masih berupa kartu kecil di halaman Sistem (`Page 0`). Membuatkannya **tampilan khusus ber-Ring Glow** dengan mode _Focus (25m)_ vs _Short Break (5m)_ + efek suara akan jauh lebih elegan.

### 6. `Water` (Pengingat Minum & Grafik Jam-jaman — `420x140px`)

- **Cara Kerja di Nusa**:
  - Tampilan terbelah dua (_Split View_):
  - **Sisi Kiri**: Angka besar `1.5 / 1.5 L`, sakelar toggle lonceng pengingat aktif, status `Today · 100% · Goal reached`, bar progres gradasi biru, tombol `Drink` dan tombol `Settings` (untuk mengatur ukuran gelas/botol & target harian).
  - **Sisi Kanan**: **Grafik Histogram Per Jam (Hourly Bar Chart)** dari pukul `09`, `12`, `15`, dst. dengan sumbu Y (`0 ml`, `200`, `400`) dan animasi batang tumbuh (_spring bar growth_).
- **Catatan untuk Projek Kita**: `PageHealth.qml` & `services/health.py` kita sudah punya `_hourly_history` di backend Python, namun **belum divisualisasikan menjadi grafik batang per jam di UI QML**, serta belum ada pengaturan kustomisasi ukuran botol/target langsung dari UI.

### 7. `Shelf` (Rak Penyimpanan File Sementara Drag & Drop — `420x140px`)

- **Cara Kerja di Nusa**:
  - Area garis putus-putus (`Drop files here` / `Release to add` / `Drag out anytime · click to open`).
  - **"Island Gulp" Animation**: Ketika pengguna menyeret (_drag_) file dari File Manager mendekati notch, island memancarkan cahaya gradasi biru-ungu dan sedikit "menelan/mengembang" (_swell/gulp_) saat file dilepas.
  - **Kartu File & Drag-Out**: Menampilkan kartu file beserta thumbnail (preview gambar atau ikon folder/dokumen), nama file, ukuran (`2.4 MB`), tombol `Clear`, klik untuk membuka, dan bisa **di-drag keluar lagi** ke aplikasi lain (chat, browser, email, folder) tanpa menyalin isi file ke RAM (hanya menyimpan referensi path).

### 8. `To-do` (Daftar Tugas dengan Pengingat Waktu — `420x140px`)

- **Cara Kerja di Nusa**:
  - **Layout Split**: Sisi kiri menampilkan angka progres raksasa (`4/5 Task Done Today`) beserta tombol `Add Task` dan `Edit Task`. Sisi kanan menampilkan daftar tugas scrollable dengan checkbox hijau bundar dan teks dicoret (_strikethrough_).
  - **Fitur Kunci**: Tugas dapat diberi **jam tenggat waktu (_due time reminder_)**, sehingga Dynamic Island otomatis mencolek/memunculkan pop-up saat tugas jatuh tempo.

### 9. `Headphones` (Pop-up Earbuds / Bluetooth — `310x60px`)

- **Cara Kerja di Nusa**:
  - Kapsul berukuran menengah (`310x60px`, lebih besar dari HUD biasa tetapi lebih ringkas dari Hub penuh).
  - **Kiri**: Cincin progres biru muda (`#5ec2ff`) dengan ikon Bluetooth di tengahnya.
  - **Tengah**: Nama perangkat (`AirBuds Pro`) dan status (`Connected · 70%`).
  - **Kanan**: Ikon headphone di dalam lingkaran bercahaya.

### 10. `Charging` (Pop-up Pengisian Daya — `310x60px`)

- **Cara Kerja di Nusa**:
  - Kapsul `310x60px` yang muncul saat kabel charger dicolokkan.
  - **Kiri**: Cincin progres melingkar hijau neon (`#33e07a`) dengan ikon petir putih di dalamnya.
  - **Tengah**: Teks tebal `Charging` dan subteks `Charger connected`.
  - **Kanan**: Angka persentase besar `70%` (`24px`).

---

## 🌐 2. Fitur Tambahan dari Web Nusa & Projek Notch Lainnya

Selain 10 tab di atas, hasil analisis menyeluruh terhadap dokumentasi Nusa dan aplikasi sejenis menghasilkan daftar fitur unggulan berikut:

### A. Fitur Sistem Tambahan dari Web Nusa (`rama2555.github.io/nusa`)

1. **Screen Brightness HUD Overlay**: Pop-up mulus saat mengatur kecerahan layar laptop.
2. **Caps Lock & Keyboard Layout Nudge**: Pop-up kapsul singkat saat tombol `Caps Lock` ditekan (On/Off) atau saat layout keyboard berganti.
3. **Wi-Fi Connect / Disconnect Peek**: Pop-up otomatis saat Wi-Fi terputus atau tersambung ke jaringan baru.
4. **System Tray Icon & Quick Menu**: Ikon di System Tray KDE untuk mengaktifkan/mematikan _Start on Login_, _Mascot Mode_, _Minimal Notch Mode_, dan _Exit_.
5. **Minimal Notch Mode (Thin Line)**: Opsi mengubah kapsul tertutup menjadi garis hitam tipis di tepi atas layar bagi pengguna yang menginginkan tampilan ekstra minimalis, namun tetap otomatis membuka penuh saat di-hover atau ada notifikasi.
6. **Fullscreen App Auto-Hide**: Otomatis bersembunyi (_step aside_) ketika pengguna sedang menjalankan game atau video dalam mode layar penuh (_fullscreen_).

### B. Fitur Terbaik dari Projek Notch macOS & Windows Lainnya

1. **Boring.Notch & NotchNook (macOS)**:
   - **Camera Mirror (Cermin Kamera Cepat)**: Widget kamera langsung (_live webcam preview_) di dalam island untuk mengecek wajah/rambut sebelum masuk rapat Zoom/Google Meet.
   - **Quick Share / KDE Connect Drop**: Di macOS ada AirDrop di dalam Shelf; di KDE Plasma kita bisa mengintegrasikan **KDE Connect** agar file yang di-drop ke Island bisa langsung dikirim ke HP Android/iPhone dengan 1 klik!
   - **Calendar & Next Meeting Countdown**: Menampilkan jadwal agenda berikutnya dan hitung mundur menuju rapat (`Meeting in 12m` + tombol `Join`).
   - **Clipboard History Manager**: Menyimpan 10–15 teks/gambar terakhir yang disalin (`Ctrl+C`) agar bisa ditempel ulang dengan sekali klik dari Island.
2. **Alcove & MediaMate (macOS)**:
   - **Audio Output / Input Switcher**: Mengganti perangkat output suara (Speaker Laptop ↔ Headset Bluetooth ↔ HDMI) dan mute mikrofon langsung dari halaman musik/sistem tanpa membuka pengaturan sistem.
   - **Live Spectrum / Real Audio Visualizer (`cava` / PipeWire)**: Bar gelombang suara yang benar-benar bergerak mengikuti frekuensi bass/treble audio asli dari sistem (bukan sekadar animasi loop statis).
3. **Poni (`poni.web.id`) & OpenAgentIsland (Linux)**:
   - **Quick AI Chat & Instant Translate**: Input teks cepat di dalam Island untuk bertanya ke AI (Google Gemini API / Ollama lokal) atau menerjemahkan teks clipboard secara instan.
   - **Live Weather & Day Progress Bar**: Info cuaca lokal _real-time_ (via Open-Meteo tanpa API key) serta persentase waktu hari yang telah berlalu (`Day Progress: 68%`).
   - **Guided Breathing (Pernapasan Melingkar)**: Lingkaran animasi _Inhale (4s) — Hold (4s) — Exhale (4s)_ di halaman Kesehatan untuk relaksasi singkat saat coding.
4. **Tide Island, AX-Shell & Golden Gate Shell (Linux Wayland)**:
   - **KDE Virtual Desktop / Workspace Indicator**: Menampilkan indikator workspace/desktop virtual KDE Plasma yang aktif dan berpindah desktop dengan scroll atau klik.
   - **Privacy Indicator Dots (Mic & Camera Active)**: Titik hijau/oranye kecil di sudut kapsul tertutup saat ada aplikasi yang sedang mengakses Mikrofon atau Kamera via PipeWire (seperti indikator privasi iOS/macOS).

---

## 📊 3. Tabel Ringkasan Status Implementasi (Sudah vs Belum)

| Kategori Fitur | Status Saat Ini | Detail yang Sudah Diimplementasikan | Target yang Belum Diimplementasikan |
| :--- | :---: | :--- | :--- |
| **Bentuk Notch & Concave Ears** | ✅ Selesai | Bentuk notch lengkung *concave ears* (`Island.qml`), *Adaptive Music Glow*, & animasi **"Island Gulp"** saat drop file ke *Shelf*. | Opsi **Minimal Line Mode** (garis tipis saat *idle*). |
| **Navigasi Multi-Halaman & Swipe** | ✅ Selesai | **7 Halaman** dengan *Continuous Wrap-Around*, tombol `< \| >`, **Interactive Drag/Swipe Gesture**, **Scroll Wheel Mouse di seluruh halaman**, *Touchpad 2-Finger Swipe*, tombol **Pin 📌**, & **Smart Auto-Collapse**. | — |
| **Media Player & Adaptive Glow** | ✅ Selesai | Sampul album, *seekbar* interaktif (`MM:SS` & sisa waktu `-MM:SS`), kontrol simetris `[💬] [⏮][⏸][⏭] [🔊]`, & *Adaptive Color Extraction*. | **Audio Output Switcher** (pindah Speaker ↔ Headset langsung dari UI) & **Real PipeWire Audio Visualizer**. |
| **Mode Lirik Karaoke (`520px` Split)** | ✅ Selesai | **Synced Lyrics (`services/lyrics.py`)** via API **LRCLIB** + cache lokal, ekspansi dinamis `420px → 520px`, *highlight* baris aktif kontras tinggi, *click-to-seek* per baris lirik, ikon vektor `assets/lyrics.svg`, & **Full-Width Volume Pill Bar** saat lirik dibuka. | — |
| **File Shelf (Drop & Drag-Out)** | ✅ Selesai | Halaman ke-7 (`qml/PageShelf.qml` + `services/shelf.py`), auto-expand saat file di-drag ke kapsul atas, *thumbnail* gambar / ikon folder emas / badge ekstensi, klik untuk buka (`xdg-open`), & **Native Wayland Drag-Out (`QDrag`)**. | Integrasi **KDE Connect Quick Share** (kirim file dari *Shelf* ke HP dengan 1 klik). |
| **Pomodoro Focus Timer** | ✅ Selesai | **Conic Ring Glow (`qml/ExpandedHub.qml` + `services/timer.py`)**, mode **Focus Time (25m)** & **Short Break (5m)**, auto-switch sesi, notifikasi desktop, & *Soft Chime* (`paplay`). | Statistik riwayat jumlah sesi fokus harian. |
| **Water Tracker & Eye Break** | ✅ Selesai | **Split View (`qml/PageHealth.qml` + `services/health.py`)**, **Grafik Histogram Per Jam (`09..16`)**, tombol kustomisasi ukuran gelas (`150–500ml`) & target harian (`1.5–3.0L`), serta pengingat **Eye Break 20-20-20**. | Animasi **Guided Breathing (Pernapasan 4-4-4)** di halaman Kesehatan. |
| **Resting Mascot Eyes** | ⏳ Sebagian | Mata maskot berkedip (`MascotEyes.qml`) & toggle mode maskot di halaman Sistem. | **Cursor Eye-Tracking** (melirik kursor), animasi **Doze Off (Mengantuk/Tidur)**, & **Wave Hello**. |
| **To-Do List Harian** | ⏳ Sebagian | Tambah tugas, centang selesai (*strikethrough*), hapus tugas, & penyimpanan JSON (`PageTodo.qml` + `services/todo.py`). | **Edit Task** inline & **Pengingat Jam Jatuh Tempo (Due Time Reminder)**. |
| **Headphones / Bluetooth Peek** | ✅ Selesai | Kapsul pop-up `310x60px` (`HudBluetooth.qml` + `services/bluetooth.py`) via **BlueZ D-Bus (`org.bluez`)** dengan cincin baterai biru `#5ec2ff`, nama perangkat, persentase baterai, & lencana headphone bercahaya selama 3,5 detik. | — |
| **Charging Peek (`310x60px`)** | ✅ Selesai | **Nusa Charging Peek (`310x60px` di `HudBattery.qml`)** dengan **Circular Conic Ring** hijau `#33e07a`, ikon petir, & teks `22px`, serta **Closed Battery Ring + Mini Sound Wave** di `CompactIdle.qml` (`150x28px`). | — |
| **Brightness, CapsLock & Mic HUD** | ✅ Selesai | **HUD Hardware (`250x36px` di `HudHardware.qml` + `services/hardware_hud.py`)** untuk **Screen Brightness** (`amdgpu_bl1` + KDE PowerManagement D-Bus), **Caps Lock Nudge** (`/sys/class/leds/input*::capslock`), & **Mic Mute HUD** (`wpctl`), plus slider kecerahan & tombol Mic di *Pintasan Cepat*. | — |
| **Privacy Dots (Cam / Mic In-Use)** | ❌ Belum | — | Deteksi node PipeWire aktif untuk menampilkan titik hijau (kamera) & oranye (mikrofon) ala iOS/macOS. |
| **System Tray & Fullscreen Hide** | ❌ Belum | Daemon systemd / background via `run.sh`. | **`QSystemTrayIcon`** (menu konfigurasi cepat) & **Fullscreen App Auto-Hide** (sembunyi saat main game/video fullscreen). |
| **Hardware, Suhu & TDP Monitor** | ✅ Selesai | **Processor TDP (`W` via `hwmon PPT`)**, **Suhu CPU (`k10temp`), GPU (`amdgpu`), & NVMe (`°C`)**, **Clock CPU (`GHz`)**, **GPU Load & VRAM**, **Top Process**, **Overheat HUD Alert (`≥85°C`)**, & **1-Click Power Profile Switcher** (`PageHardware.qml` + `services/system.py`). | Statistik riwayat suhu & kecepatan kipas (`RPM` jika tersedia). |
| **Clipboard, Cuaca & Kamera** | ❌ Belum | — | **Clipboard History Manager**, **Live Weather & Day Progress Bar**, serta **Camera Mirror**. |

---

## 🚀 4. Rencana Implementasi Bertahap (Checklist Fitur Sudah vs Belum)

### ✅ Fase 1: Fitur Core Visual & Produktivitas Utama Nusa (SUDAH DIIMPLEMENTASIKAN)

  - [x] **1. Mode Lirik Tersinkronisasi / Karaoke (`services/lyrics.py` + `qml/ExpandedHub.qml` + `qml/Island.qml`)**
  - [x] Integrasi API **LRCLIB (`lrclib.net`)** asynchronous + pembersih judul YouTube/Spotify otomatis & cache lokal `~/.cache/dynamic_island/lyrics/`.
  - [x] Ekspansi lebar dinamis dari `420px` ke `520px` (*Split View*) dengan pembagi vertikal saat tombol lirik aktif.
  - [x] *Highlight* baris lirik aktif kontras tinggi (`#ffffff` + aksen bar kiri), auto-scroll mulus, & fitur **Klik Baris Lirik untuk Seek Lagu**.
  - [x] Ikon vektor khusus (`assets/lyrics.svg`), tata letak tombol kontrol musik simetris (`[💬] [⏮][⏸][⏭] [🔊]`), dan **Full-Width Interactive Volume Bar** saat lirik dibuka.
  - [x] **2. Wayland File Shelf — Rak File Drag & Drop (`services/shelf.py` + `qml/PageShelf.qml`)**
  - [x] Halaman ke-7 (`Rak File / Shelf`) dengan area garis putus-putus (*dashed drop zone*), *thumbnail* gambar asli, ikon folder emas, & badge ekstensi berwarna.
  - [x] Auto-expand ke halaman *Shelf* saat file diseret mendekati kapsul Dynamic Island tertutup, disertai efek pendaran **"Island Gulp"**.
  - [x] Klik kartu untuk membuka file (`xdg-open`) dan seret keluar (**Native Wayland `QDrag` `text/uri-list`**) untuk memindahkan/menyalin file ke aplikasi lain.
  - [x] **3. Upgraded Pomodoro Focus Timer (`services/timer.py` + `qml/ExpandedHub.qml`)**
  - [x] Tampilan **Circular Conic Progress Ring** bercahaya (`#ff5a6e` untuk *Focus Time 25:00* dan `#38bdf8` untuk *Short Break 05:00*).
  - [x] Tombol kapsul *Short Break*, *Play/Pause*, *Focus Time*, tombol *Reset*, pergantian sesi otomatis, dan efek suara lonceng lembut (*soft chime*).
  - [x] **4. Water Tracker Histogram Per Jam & Kustomisasi (`services/health.py` + `qml/PageHealth.qml`)**
  - [x] Tampilan *Split View* dengan **Grafik Histogram 8 Batang Per Jam (`09..15`)** di sisi kanan.
  - [x] Tombol pengaturan ukuran gelas (`150ml / 200ml / 250ml / 300ml / 500ml`) dan target harian (`1500ml – 3000ml`) langsung dari UI.
- [x] **5. Navigasi Swipe / Swap Interaktif & Perbaikan Input (`qml/ExpandedHub.qml` + `qml/Island.qml`)**
  - [x] *Interactive Mouse/Touchpad Drag-to-Swipe* (`DragHandler`) dengan *live preview* halaman tetangga & *continuous wrap-around*.
  - [x] Perpindahan halaman dengan *Mouse Scroll Wheel* & *Touchpad 2-Finger Swipe* (`WheelHandler` di layer `z: 50`) yang bebas macet di seluruh 7 halaman (termasuk melewati *To-Do List* dan *Shelf*).
  - [x] Perbaikan bug perubahan volume tidak sengaja saat memutar *scroll wheel* ketika Dynamic Island sedang terbuka.
- [x] **6. Hardware, Suhu & Processor TDP Telemetry Suite (`services/system.py` + `qml/PageHardware.qml` + `qml/ExpandedHub.qml`)**
  - [x] **Processor TDP / Package Power (`PPT` dalam Watt)**: Pembacaan daya prosesor *real-time* dari sensor kernel `/sys/class/hwmon/hwmon*/power1_input` (`15.0–30.0 W`) lengkap dengan bar progres TDP.
  - [x] **Multi-Sensor Temperature (`°C`)**: Suhu *real-time* **CPU (`k10temp`)**, **GPU (`amdgpu`)**, dan **SSD NVMe (`nvme`)** dengan badge warna adaptif (🟢 `<62°C`, 🟡 `62–79°C`, 🔴 `≥80°C`).
  - [x] **CPU Clock (`GHz`), GPU Load (`%`), GPU Clock (`MHz`) & VRAM (`MB`)**: Telemetri lengkap kartu grafis Radeon & frekuensi prosesor.
  - [x] **Top CPU Process Detector & Thermal Overheat Alert (`≥85°C`)**: Deteksi aplikasi paling berat (`🔥 Top: ...`) dan peringatan notifikasi otomatis saat suhu melewati `85°C`.
  - [x] **1-Click Power Profile & TDP Mode Switcher**: Tombol interaktif **🍃 Hemat (`power-saver`)**, **⚖️ Seimbang (`balanced`)**, dan **🚀 Performa (`performance`)** via `powerprofilesctl`.

---

### ✅ Fase 2: Smart Peek Overlays (`310x60px`) & Indikator Hardware KDE (SUDAH DIIMPLEMENTASIKAN)

- [x] **1. Headphones / Bluetooth Auto-Peek (`qml/HudBluetooth.qml` + `services/bluetooth.py`)**
  - [x] Pantau koneksi perangkat audio Bluetooth secara *real-time* melalui sistem D-Bus `org.bluez` (`GetManagedObjects` + `org.bluez.Battery1`).
  - [x] Saat TWS/Headphone (`soundcore R50i`, `thinkplus-TH30`, dll.) tersambung atau terputus, munculkan kapsul `310x60px` berisi cincin baterai biru (`#5ec2ff`), nama perangkat, persentase baterai, dan lencana headphone bercahaya selama 3,5 detik.
- [x] **2. Upgraded Charging Peek (`qml/HudBattery.qml` — `310x60px`) & Closed Battery Ring (`qml/CompactIdle.qml`)**
  - [x] Perbarui `HudBattery.qml` menjadi gaya Nusa (`310x60px`) dengan cincin progres melingkar hijau neon (`#33e07a`), ikon petir di tengah cincin, label `Charging / Charger connected`, dan persentase baterai besar (`22px`) di sisi kanan.
  - [x] Tambahkan **Circular Battery Conic Ring (`#33e07a`)** di sisi kiri dan **4-Bar Animated Mini Sound Wave** di sisi kanan pada mode kapsul tertutup (`CompactIdle.qml` — `150x28px`).
- [x] **3. Screen Brightness, Mic Mute & Caps Lock HUD (`qml/HudHardware.qml` + `services/hardware_hud.py`)**
  - [x] Integrasikan pemantauan kecerahan layar (`/sys/class/backlight/amdgpu_bl1` + KDE PowerManagement D-Bus `BrightnessControl`) untuk menampilkan HUD Kecerahan Layar (`250x36px`) saat tombol `Fn + Brightness` ditekan atau diatur dari slider *Pintasan Cepat*.
  - [x] Tambahkan HUD kapsul otomatis (`250x36px`) saat tombol **Caps Lock** (`/sys/class/leds/input*::capslock/brightness`) atau **Microphone Mute** (`wpctl`) ditekan, lengkap dengan tombol *toggle* Mikrofon dan tombol uji *Peek TWS/Cas* di halaman *Pintasan Cepat*.

---

### ⏳ Fase 3: Interaktivitas Maskot Pintar, Privasi & Integrasi Desktop KDE (BELUM DIIMPLEMENTASIKAN)

- [ ] **1. Smart Mascot 2.0 (`qml/MascotEyes.qml`)**
  - Tambahkan pelacakan kursor halus (*eye gaze* mengikuti posisi mouse), mode mengantuk (*sleeping eyes* saat idle > 5 menit), dan animasi menyapa (*happy blink / wave*) saat pengguna kembali aktif.
- [ ] **2. Privacy Indicator Dots (Kamera & Mikrofon Aktif)**
  - Deteksi penggunaan kamera (`/dev/video*` / PipeWire) dan mikrofon aktif via `pw-dump` / `pactl`, lalu tampilkan titik indikator hijau (kamera) dan oranye (mikrofon) di sudut Dynamic Island seperti di iOS/macOS.
- [ ] **3. System Tray Menu & Fullscreen Auto-Hide**
  - Tambahkan ikon System Tray (`QSystemTrayIcon`) dengan menu cepat: *Pin/Unpin Hub*, *Mode Maskot*, *Minimal Line Mode*, *Sembunyikan Saat Fullscreen*, dan *Keluar*.
  - Deteksi saat jendela aktif di KDE Wayland berada dalam mode *Fullscreen* agar Dynamic Island otomatis menyembunyikan diri dan tidak menghalangi game/video.

---

### ⏳ Fase 4: Fitur Produktivitas Ekstra — Boring.Notch, NotchNook & Poni (BELUM DIIMPLEMENTASIKAN)

- [ ] **1. Clipboard History & Quick Paste**: Halaman/tab cepat untuk melihat 10 teks terakhir yang disalin (`Ctrl+C`) dan menempelkannya kembali dengan sekali klik.
- [ ] **2. Audio Output Device Switcher**: Pilih perangkat output audio aktif (Speaker Laptop ↔ Headphone Bluetooth ↔ HDMI) langsung dari halaman Musik/Sistem.
- [ ] **3. Live Weather & Day Progress Bar**: Widget cuaca lokal ringan (`Open-Meteo` tanpa API key) dan bar progres waktu hari di halaman Jaringan/Info.
- [ ] **4. Camera Mirror & KDE Connect Quick Share**: Pratinjau cermin webcam cepat sebelum rapat online dan tombol kirim file dari *Shelf* langsung ke smartphone via KDE Connect.
- [ ] **5. To-Do Edit & Due Time Reminder**: Tambahkan fitur edit teks tugas dan opsi jam pengingat (`HH:MM`) pada setiap tugas di halaman To-Do yang otomatis memicu HUD Notifikasi saat jatuh tempo.
- [ ] **6. Guided Breathing (Relaksasi Pernapasan)**: Animasi lingkaran pernapasan *Inhale (4s) — Hold (4s) — Exhale (4s)* di halaman Kesehatan.
