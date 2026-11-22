# Spesifikasi Endpoint API Riil — PathFinder Backend

Dokumen ini mendefinisikan spesifikasi teknis seluruh endpoint REST API riil backend Go (path-finder-backend) yang aktif dan terverifikasi untuk digunakan oleh aplikasi mobile Flutter (path_finder).

> **Catatan Sumber Kebenaran:**
> - Dokumen ini diselaraskan langsung dengan implementasi kode backend Go (`internal/delivery/http/route/route.go`) dan kontrak OpenAPI (`internal/apidocs/openapi.json`).
> - Jika ada perbedaan antara file dokumentasi draf lama dan dokumen ini, dokumen inilah yang mencerminkan kode backend Go riil.

---

## 1. Standar Jaringan dan Format Respons

### Base URL
- Android Emulator: `http://10.0.2.2:3000`
- iOS Simulator / Desktop: `http://127.0.0.1:3000`
- Perangkat Fisik (Physical Device): `http://<IP-LAN-KOMPUTER>:3000` (dikonfigurasi via `--dart-define=BASE_URL=...` pada `lib/core/config/env.dart`)

### Header Wajib
- `Content-Type: application/json`
- `Accept: application/json`
- `Authorization: Bearer <token_jwt>` (wajib untuk seluruh endpoint terproteksi)

### Format Envelope Sukses (WebResponse[T])
```json
{
  "success": true,
  "message": "Operasi berhasil dilakukan",
  "data": {},
  "paging": {
    "page": 1,
    "size": 10,
    "total_item": 25,
    "total_page": 3
  }
}
```
Catatan: Metadata `paging` hanya muncul pada response daftar yang memiliki paginasi.

### Format Envelope Error
```json
{
  "success": false,
  "message": "Pesan deskriptif yang aman ditampilkan ke pengguna",
  "errors": "Detail pesan error teknis validator atau database"
}
```
Catatan: Backend Go tidak menggunakan objek bersarang `error.code`. Untuk keperluan antarmuka (UI/Dialog/SnackBar), selalu gunakan field `message`.

---

## 2. Status Modul dan Integrasi

| Modul | Status di Backend Go | Status di Mobile Flutter | Keterangan |
| :--- | :--- | :--- | :--- |
| Autentikasi (Auth) | Aktif | Terhubung | Register, Login, Forgot Password, Me. |
| Profil Pengguna | Aktif | Parsial | Endpoint Mahasiswa dan Mitra siap diintegrasikan. |
| Cerita Diri (Story) | Aktif | Terhubung | Simpan dan edit cerita reflektif (status: pending). |
| Katalog Lowongan (Jobs) | Aktif | Mock Data | UI siap dialihkan dari mock data ke API riil. |
| Manajemen Lowongan Mitra | Aktif | Mock Data | UI siap dialihkan dari mock data ke API riil. |
| Lamaran Magang (Applications) | Aktif | Dalam Proses | Backend siap menangani flow lamaran dan seleksi. |
| Notifikasi FCM | Aktif | Tersedia | Endpoint update FCM token siap dipanggil. |
| Rekomendasi Cerdas (ML) | Belum Ada | Placeholder UI | Pipeline ML masih offline; endpoint backend belum dibuat. |

---

## 3. Detail Endpoint API Riil

### A. Core / Health Check
#### GET /
- Auth: Publik
- Deskripsi: Memeriksa status kesehatan server backend.
- Respons 200 OK:
  ```json
  {
    "success": true,
    "message": "juragansengon88",
    "data": "HALO JURAGAN"
  }
  ```

---

### B. Modul Autentikasi (Auth)

Backend mendukung prefiks `/api/auth/*` serta alias `/api/users/*`.

#### 1. Register Akun Baru
- Method dan Path: `POST /api/auth/register` (alias `/api/users/register`)
- Auth: Publik
- Request Body:
  ```json
  {
    "name": "Budi Santoso",
    "email": "budi@example.com",
    "password": "password123",
    "confirm_password": "password123",
    "role": "mahasiswa"
  }
  ```
  - `role`: opsional, salah satu dari `"mahasiswa"` (default) atau `"mitra"`.
- Respons 201 Created: Mengembalikan data user yang dibuat.
  > **Catatan Alur Autentikasi:** Backend tidak mengembalikan token JWT pada response register. Client aplikasi Flutter wajib otomatis memanggil endpoint login segera setelah registrasi berhasil untuk memperoleh token sesi.

#### 2. Login Akun
- Method dan Path: `POST /api/auth/login` (alias `/api/users/login`)
- Auth: Publik
- Request Body:
  ```json
  {
    "email": "budi@example.com",
    "password": "password123"
  }
  ```
- Respons 200 OK:
  ```json
  {
    "success": true,
    "message": "Login berhasil",
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsIn...",
      "user": {
        "id": "6d0f0c8e-1f2a-4c3b-9d10-2b8a7c6d5e4f",
        "name": "Budi Santoso",
        "email": "budi@example.com",
        "role": "mahasiswa",
        "created_at": "2026-11-18T10:00:00Z",
        "updated_at": "2026-11-18T10:00:00Z"
      }
    }
  }
  ```

#### 3. Lupa Password
- Method dan Path: `POST /api/auth/forgot-password` (alias `/api/users/forgot-password`)
- Auth: Publik
- Request Body: `{ "email": "budi@example.com" }`
- Respons 200 OK: Kode verifikasi dikirimkan (pada tahap development dicetak di log terminal backend).

#### 4. Sesi Pengguna Aktif (Get Current User)
- Method dan Path: `GET /api/auth/me` (alias `/api/users/current`, `/api/users/profile`)
- Auth: Bearer Token
- Respons 200 OK: Mengembalikan data profil lengkap user pemilik token.

#### 5. Update Token FCM (Push Notification)
- Method dan Path: `PATCH /api/users/fcm-token`
- Auth: Bearer Token
- Request Body: `{ "fcm_token": "token_fcm_dari_perangkat..." }`
- Respons 200 OK: Token perangkat berhasil disimpan untuk menerima notifikasi status lamaran.

---

### C. Modul Profil Pengguna dan Dashboard

#### 1. Profil Mahasiswa
- `GET /api/mahasiswa/profile` (Auth: Role `mahasiswa`)
  - Mengambil data profil mahasiswa yang login.
- `PUT /api/mahasiswa/profile` / `PATCH /api/mahasiswa/profile` (Auth: Role `mahasiswa`)
  - Request Body:
    ```json
    {
      "location": "Malang",
      "profile_picture": "https://example.com/foto.jpg",
      "cv": "https://example.com/cv.pdf",
      "portfolio_url": "https://github.com/budi"
    }
    ```
    Dukungan alias field: Backend juga menerima nama field bahasa Indonesia (`lokasi`, `foto_profile`, `link_portofolio`). Nilai URL harus valid HTTP/HTTPS.
- `GET /api/mahasiswa/dashboard` (Auth: Role `mahasiswa`)
  - Mengembalikan ringkasan data user dashboard mahasiswa.

#### 2. Profil Mitra (Perusahaan)
- `GET /api/mitra/profile` (alias `/api/perusahaan/profile`) (Auth: Role `mitra`)
  - Mengambil profil perusahaan mitra.
- `PUT /api/mitra/profile` / `PATCH /api/mitra/profile` (alias `/api/perusahaan/profile`) (Auth: Role `mitra`)
  - Request Body:
    ```json
    {
      "name": "PT Mitra Jaya Abadi",
      "location": "Jakarta Selatan",
      "profile_picture": "https://example.com/logo.png"
    }
    ```
    Dukungan alias field: `nama_mitra`, `nama_perusahaan`, `lokasi`, `foto_profile`.
- `GET /api/mitra/dashboard` (Auth: Role `mitra`)
  - Mengembalikan data user dashboard mitra.

---

### D. Modul Cerita Diri (Story)

#### 1. Kirim Cerita Diri Baru
- Method dan Path: `POST /api/stories`
- Auth: Role `mahasiswa`
- Request Body:
  ```json
  {
    "content": "Saya adalah mahasiswa yang senang mendalami Flutter dan pengembangan aplikasi mobile..."
  }
  ```
  - Validasi: Panjang `content` minimal 50 karakter dan maksimal 2000 karakter setelah di-trim.
- Respons 201 Created:
  ```json
  {
    "success": true,
    "message": "Cerita berhasil disimpan",
    "data": {
      "id": "uuid-cerita",
      "user_id": "uuid-user",
      "content": "...",
      "word_count": 42,
      "analysis_status": "pending",
      "created_at": "2026-11-20T10:00:00Z",
      "updated_at": "2026-11-20T10:00:00Z"
    }
  }
  ```

#### 2. Ambil Cerita Terakhir
- Method dan Path: `GET /api/stories/me`
- Auth: Role `mahasiswa`
- Respons 200 OK: Mengembalikan data cerita aktif terakhir milik mahasiswa.

#### 3. Perbarui Cerita Diri
- Method dan Path: `PUT /api/stories/:id` atau `PATCH /api/stories/:id`
- Auth: Role `mahasiswa`
- Path Parameter: `:id` dapat berupa UUID cerita atau keyword `"me"` untuk langsung memperbarui cerita terakhir.
- Request Body: `{ "content": "Konten baru minimal 50 karakter..." }`
- Catatan: Status `analysis_status` otomatis direset ke `"pending"` dan `word_count` dihitung ulang.

---

### E. Modul Lowongan Magang (Jobs)

#### 8 Kategori Lowongan Resmi (Enum Case-Sensitive)
1. `Software Engineer Intern`
2. `Backend Developer Intern`
3. `Mobile Developer Intern`
4. `Frontend Developer Intern`
5. `Data Analyst Intern`
6. `UI/UX Designer Intern`
7. `QA Engineer Intern`
8. `Network & IT Support Intern`

#### 1. Katalog Lowongan (Untuk Semua Role Terautentikasi)
- `GET /api/jobs`
  - Auth: Semua role login (`mahasiswa`, `mitra`, `admin`).
  - Query Parameters:
    - `page`: nomor halaman (default `1`, integer positif).
    - `size`: jumlah item per halaman (default `10`, min `1`, max `100`).
    - `search`: pencarian teks pada judul lowongan (`title`) atau nama perusahaan (`company`).
    - `category`: salah satu dari 8 kategori resmi di atas.
  - Respons 200 OK: Mengembalikan `data: []` beserta objek `paging`.
- `GET /api/jobs/:id`
  - Auth: Semua role login.
  - Respons 200 OK: Mengembalikan detail lowongan lengkap (kualifikasi, deskripsi, skill yang dibutuhkan).

#### 2. CRUD Lowongan Milik Mitra (Role `mitra`)
- `GET /api/mitra/jobs`: Menampilkan daftar lowongan milik mitra yang sedang login (mendukung filter `page`, `size`, `search`, `category`).
- `POST /api/mitra/jobs`: Menambah lowongan baru.
  - Request Body:
    ```json
    {
      "title": "Flutter Developer Intern",
      "category": "Mobile Developer Intern",
      "description": "Mengembangkan aplikasi mobile Android dan iOS bersama tim produk...",
      "location": "Bandung / Hybrid",
      "work_type": "Hybrid",
      "required_skills": ["Flutter", "Dart", "REST API"],
      "optional_skills": ["Riverpod", "Git"],
      "source_url": "https://mitra.example.com/careers/flutter-intern"
    }
    ```
- `GET /api/mitra/jobs/:id`: Detail lowongan milik mitra login.
- `PUT /api/mitra/jobs/:id` / `PATCH /api/mitra/jobs/:id`: Partial update data lowongan milik mitra.
- `DELETE /api/mitra/jobs/:id`: Hapus permanen lowongan milik mitra.

---

### F. Modul Pendaftaran Magang (Applications)

#### Aturan Bisnis dan Validasi
1. Profil Wajib Lengkap: Mahasiswa wajib mengisi `profile_picture`, `cv`, dan `portfolio_url` sebelum melamar. Jika belum lengkap, server menolak dengan 400 Bad Request.
2. Satu Lamaran Aktif (Single Active Application):
   - Mahasiswa hanya boleh memiliki 1 lamaran aktif berstatus `pending`. Upaya melamar ke lowongan lain saat ada lamaran pending akan ditolak (400 Bad Request).
   - Jika ditolak (`rejected`), mahasiswa diperbolehkan melamar lowongan lain.
   - Jika diterima (`accepted`), mahasiswa terkunci secara permanen dan tidak dapat melamar ke lowongan mana pun lagi.
3. Lowongan Seed (Tanpa Mitra): Lowongan katalog awal yang memiliki `mitra_id == null` tidak menerima pendaftaran langsung via platform (400 Bad Request).
4. Terminal Status: Status lamaran yang sudah bernilai `accepted` atau `rejected` bersifat permanen dan tidak dapat diubah lagi.

#### 1. Mengajukan Lamaran (Mahasiswa)
- Method dan Path:
  - `POST /api/jobs/:id/apply` (ID lowongan di path URL)
  - `POST /api/mahasiswa/applications` (Request body: `{ "job_id": "UUID-LOWONGAN" }`)
- Auth: Role `mahasiswa`
- Respons 201 Created: Mengembalikan data lamaran dengan status awal `"pending"`.

#### 2. Riwayat Lamaran Mahasiswa
- Method dan Path: `GET /api/mahasiswa/applications`
- Auth: Role `mahasiswa`
- Respons 200 OK: Daftar seluruh lamaran yang diajukan mahasiswa beserta objek relasi detail lowongan.

#### 3. Daftar Pelamar Lowongan (Mitra)
- Method dan Path: `GET /api/mitra/applications`
- Auth: Role `mitra`
- Query Parameters: `job_id` (opsional), `page` (default 1), `size` (default 10, max 100).
- Respons 200 OK: Mengembalikan data kandidat pelamar (`mahasiswa`: nama, email, foto, CV, portofolio) dan objek lowongan terkait.

#### 4. Update Status Lamaran (Mitra)
- Method dan Path: `PATCH /api/mitra/applications/:id/status` atau `PUT /api/mitra/applications/:id/status`
- Auth: Role `mitra`
- Request Body:
  ```json
  {
    "status": "accepted"
  }
  ```
  - Nilai yang diizinkan hanya `"accepted"` atau `"rejected"`.

---

### G. Modul Rekomendasi Machine Learning (Status Realitas)

- Status Saat Ini: Belum diimplementasikan di Backend Go.
- Kondisi Repository `pathfinder-ml`: Repositori ML berisi modul Python untuk pipeline offline (ekstraksi NER IndoBERT, normalisasi skill, kemiripan embedding e5-small, dan rule-based readiness scorer). Namun, pipeline ini belum diekspos sebagai HTTP server dan belum dihubungkan ke backend Go.
- Kondisi di Backend Go: Tidak ada route `/api/recommendations`.
- Pedoman untuk Frontend Flutter:
  - File `recommendation_remote_source.dart` yang memanggil `/api/recommendations` akan menghasilkan error 404 Not Found pada server aktif.
  - Tangani kondisi ini dengan graceful fallback atau pesan informatif kepada pengguna bahwa analisis cerita sedang dalam antrean atau tahap pengembangan.
