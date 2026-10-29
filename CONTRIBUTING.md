# 🤝 Panduan Berkontribusi — NxSora (Nx空)

Terima kasih atas ketertarikan Anda untuk berkontribusi pada **NxSora**! Dokumen ini membantu Anda memulai berkontribusi dengan rapi dan terarah.

---

## 🛠️ 1. Persiapan Lingkungan Pengembangan

Pastikan sistem Anda menggunakan **KDE Plasma 6 (Wayland)** pada distro berbasis Arch/CachyOS atau Fedora.

1. **Clone repository**:
   ```bash
   git clone https://github.com/NXRts/NxSora.git
   cd NxSora
   ```

2. **Periksa dependensi**:
   ```bash
   ./run.sh --check
   ```

3. **Jalankan aplikasi dalam mode pengembangan**:
   ```bash
   ./run.sh
   ```

---

## 🧪 2. Menjalankan Unit Tests

Setiap fitur atau perbaikan bug pada `services/` wajib disertai dengan tes di direktori `tests/`:

```bash
# Menggunakan modul unittest bawaan Python
python3 -m unittest discover -s tests -p "test_*.py" -v

# Atau menggunakan pytest (jika terpasang)
pytest -v tests/
```

Sebelum membuat pull request, jalankan linter untuk menjaga kerapian kode:
```bash
ruff check .
```

---

## 🌿 3. Alur Branch & Commit

- Buat branch baru dari `main`:
  - `feat/nama-fitur` untuk penambahan fitur baru
  - `fix/nama-bug` untuk perbaikan masalah
  - `docs/nama-dokumen` untuk perbaikan dokumentasi
- Gunakan pesan commit konvensional (*Conventional Commits*), contoh:
  - `feat: add camera mirror peek`
  - `fix: resolve bluetooth battery parsing`
  - `docs: update troubleshooting guide`

---

## 💬 4. Pertanyaan & Diskusi

Jika Anda memiliki ide atau ingin berdiskusi mengenai desain fitur baru, silakan buka diskusi atau issue baru di [GitHub Issues](https://github.com/NXRts/NxSora/issues).

