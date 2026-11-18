# Menghubungkan Aplikasi Flutter ke Backend Go

Backend berada di repositori terpisah: `path-finder-backend` (Go + Fiber + GORM + PostgreSQL). Dokumen ini menjelaskan cara menjalankannya dan menghubungkannya ke aplikasi Flutter.

---

## 1. Prasyarat

| Kebutuhan | Cek dengan | Catatan |
| :--- | :--- | :--- |
| Go 1.27+ | `go version` | Backend memakai `go 1.27.3` |
| Docker Desktop | `docker ps` | Dipakai untuk PostgreSQL. **Docker Desktop harus benar-benar berjalan**, bukan hanya terpasang |
| Flutter SDK | `flutter --version` | |

> **Penting:** `docker --version` bisa berhasil walaupun daemon-nya mati. Kalau `docker ps` gagal dengan pesan `failed to connect to the docker API ... dockerDesktopLinuxEngine`, buka **Docker Desktop** dan tunggu sampai statusnya *running*.

---

## 2. Jalankan Database (PostgreSQL)

> Cara tercepat: jalankan `.\start-backend.ps1` dari folder `path-finder-backend`. Skrip itu menangani langkah 2–3 sekaligus. Panduan lengkap: [cara-menyalakan-backend.md](./cara-menyalakan-backend.md).

Dari folder `path-finder-backend`:

```bash
docker compose up -d postgres
```

Tunggu sampai sehat:

```bash
docker compose ps
```

Container `path_finder_postgres` harus berstatus `running (healthy)`.

Konfigurasi database ada di `config.json`:

```json
"database": {
  "username": "juragansengon88",
  "password": "juragansengon88",
  "host": "localhost",
  "port": 5432,
  "name": "path_finder_db"
}
```

> **Penyebab error di terminal Anda** — `failed to connect to user=juragansengon88 database=path_finder_db: dial error (dial tcp 127.0.0.1:5432: connectex: No connection could be made because the target machine actively refused it)` — adalah PostgreSQL belum berjalan. Backend memanggil `log.Fatal` saat `gorm.Open` gagal, sehingga proses langsung berhenti sebelum server sempat listen.

---

## 3. Jalankan Backend

```bash
cd path-finder-backend
go run ./cmd/web
```

Tabel `users`, `password_resets`, dan `stories` dibuat otomatis oleh `AutoMigrate` saat start.

Verifikasi:

```bash
curl http://localhost:3000/
```

Harus mengembalikan:

```json
{ "success": true, "message": "juragansengon88", "data": "HALO JURAGAN" }
```

Port default ada di `config.json` → `web.port` = **3000**.

### Alternatif: jalankan semuanya lewat Docker

```bash
docker compose up --build
```

Ini menjalankan Postgres + backend sekaligus di port 3000.

---

## 4. Jalankan Aplikasi Flutter

Base URL sudah otomatis menyesuaikan platform (`lib/core/config/env.dart`):

| Target | Default |
| :--- | :--- |
| Android emulator | `http://10.0.2.2:3000` |
| iOS simulator / desktop | `http://127.0.0.1:3000` |

```bash
flutter clean   # wajib setelah perubahan AndroidManifest
flutter run
```

Untuk perangkat fisik atau port berbeda, override:

```bash
flutter run --dart-define=BASE_URL=http://192.168.1.10:3000
```

> `127.0.0.1` **di dalam emulator Android** menunjuk ke emulator itu sendiri. Host komputer diakses lewat `10.0.2.2`.

---

## 5. Uji Cepat Tanpa Aplikasi

Gunakan file `path-finder-backend/api-test.http` dengan ekstensi VS Code **REST Client**, atau lewat curl:

```bash
# 1. Register (201, tanpa token)
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Budi Santoso","email":"budi@example.com","password":"password123","confirm_password":"password123","role":"mahasiswa"}'

# 2. Login (200, dapat token)
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"budi@example.com","password":"password123"}'

# 3. Kirim cerita diri (201)
curl -X POST http://localhost:3000/api/stories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN_DARI_LOGIN>" \
  -d '{"content":"Saya adalah mahasiswa yang senang membangun aplikasi mobile. Saya pernah mengerjakan proyek katalog produk dan aplikasi pencatatan keuangan sederhana menggunakan Flutter."}'

# 4. Minta rekomendasi (200). Body boleh kosong: dipakai cerita terakhir.
curl -X POST http://localhost:3000/api/recommendations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN_DARI_LOGIN>" \
  -d '{"top_k":3}'

# 5. Ambil rekomendasi terakhir (200)
curl http://localhost:3000/api/recommendations/me/latest \
  -H "Authorization: Bearer <TOKEN_DARI_LOGIN>"
```

---

## 6. Alur Cerita → Rekomendasi

```
Story form
   └─> POST /api/stories                     (201, analysis_status = pending)
   └─> /recommendation/processing?story_id=… (layar analisis)
          └─> POST /api/recommendations      (200, status ok / parsial / profil_tidak_lengkap)
          └─> sukses  → /recommendation      (daftar lowongan + skor)
          └─> gagal   → pesan error + tombol "Coba Lagi"
```

Hal yang perlu diketahui saat mengubah bagian ini:

- **Tidak ada progres palsu.** Layar pemrosesan menunggu response nyata; `isCompleted` baru `true` setelah data diterima.
- **Batas waktu 30 detik** di `RecommendationController`. Bila terlampaui, muncul `ErrorView` dengan tombol coba lagi — pengguna tidak pernah menunggu tanpa batas.
- **`analysis_status`** pada cerita berubah `pending` → `done` setelah analisis berhasil.
- **Katalog lowongan** (`jobs`) di-seed otomatis saat server start dari `internal/dataset/jobs.csv`. Menambah lowongan cukup menambah baris di file itu lalu restart server; ID yang sudah ada tidak ditimpa.
- **Mesin skor masih berbasis aturan.** Pipeline `pathfinder-ml` belum punya model terlatih maupun HTTP API, jadi ekstraksi keahlian memakai leksikon `internal/dataset/skills.csv`. Bentuk response sudah mengikuti kontrak ML, sehingga model asli bisa menggantikan isi perhitungan tanpa mengubah kontrak.

---

## 7. Alur Autentikasi di Aplikasi

```
Register form
   └─> POST /api/auth/register      (201, data user saja, tanpa token)
   └─> POST /api/auth/login         (200, dapat token)   ← dilakukan otomatis
   └─> token disimpan di SharedPreferences
   └─> redirect ke /story
```

Bila langkah login otomatis gagal (mis. jaringan putus tepat setelah register), akun tetap sudah dibuat dan aplikasi mengarahkan pengguna ke halaman login dengan pesan *"Pendaftaran berhasil. Silakan masuk ke akunmu."*

---

## 8. Troubleshooting

| Gejala | Penyebab | Solusi |
| :--- | :--- | :--- |
| `failed to connect ... 5432: actively refused it` | PostgreSQL belum jalan | Jalankan Docker Desktop, lalu `docker compose up -d postgres` |
| `Server tidak merespons (timeout) di http://10.0.2.2:3000. Pastikan backend sudah berjalan...` | Proses backend mati/berhenti. Emulator meneruskan paket ke host, tapi tidak ada yang menjawab sehingga koneksi menggantung sampai timeout | Nyalakan backend: `cd path-finder-backend && go run ./cmd/web`. Cek dengan `curl http://localhost:3000/` |
| `Tidak bisa terhubung ke backend di <alamat>...` | Host/port salah atau tidak ada yang listen | Cek `BASE_URL` / `env.dart`; pastikan port backend 3000 |
| `email atau password salah` padahal benar | Email belum terdaftar, atau password < 6 karakter | Register dulu lewat form |
| `email sudah terdaftar` | Email dipakai akun lain | Pakai email lain atau login |
| `Unauthorized: token tidak ditemukan` saat kirim cerita | Belum login, atau token terhapus | Login dulu, lalu ulangi |
| Layar analisis berhenti dengan pesan error | Backend mati, atau `POST /api/recommendations` belum ada (server lama) | Nyalakan ulang backend agar route baru terdaftar, lalu tekan "Coba Lagi" |
| `cerita belum pernah dikirim, kirim cerita dulu` (404) | Belum ada cerita untuk akun itu | Kirim cerita diri lebih dulu |
| `katalog lowongan belum tersedia` (500) | Seeding `jobs` gagal saat start | Cek log server, pastikan `internal/dataset/jobs.csv` valid, lalu restart |
| Rekomendasi kosong / "Ceritamu belum menyebut keahlian" | Narasi tidak memuat istilah yang ada di leksikon | Sebutkan bahasa pemrograman, alat, atau bidang yang dikuasai |
| `Cannot POST /api/...` (404) | Path tidak ada di backend | Cek `path-finder-backend/internal/delivery/http/route/route.go` |
| Perubahan manifest tidak berpengaruh | Hot reload tidak memuat ulang manifest | `flutter clean` lalu `flutter run` |

> **Catatan penting:** pesan timeout **bukan** berarti jaringan bermasalah. Pada emulator Android, `10.0.2.2` meneruskan koneksi ke komputer host; kalau port 3000 kosong, paketnya di-drop diam-diam dan Dio melaporkan *timeout* (bukan *connection refused*). Ciri backend mati adalah pesan timeout, bukan pesan "tidak bisa terhubung".

---

## 9. Referensi

- Kontrak API lengkap: [api-contract.md](./api-contract.md)
- Cara menyalakan backend: [cara-menyalakan-backend.md](./cara-menyalakan-backend.md)
- Route backend: `path-finder-backend/internal/delivery/http/route/route.go`
- Konfigurasi backend: `path-finder-backend/config.json`
