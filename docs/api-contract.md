# API Contract - PathFinder

Dokumen ini mendefinisikan spesifikasi kontrak REST API untuk layanan backend **PathFinder**. Semua endpoint berkomunikasi menggunakan format JSON dengan standar response seragam.

> **Sumber kebenaran:** dokumen ini diselaraskan dengan implementasi backend Go pada repositori `path-finder-backend` (Fiber v3 + GORM + PostgreSQL). Bila ada perbedaan antara dokumen ini dan kode backend, **kode backend yang menang** dan dokumen ini harus diperbarui.

---

## Informasi & Changelog

| Versi | Tanggal | Deskripsi Perubahan |
| :--- | :--- | :--- |
| **1.0.0** | **19-10-2026** | Inisialisasi kontrak endpoint health check dan fitur autentikasi. |
| **1.1.0** | **18-11-2026** | Menambahkan modul Cerita Diri (`POST /stories`). |
| **2.0.0** | **18-11-2026** | **Diselaraskan dengan backend Go yang sebenarnya.** Base URL menjadi `:3000/api`. Register tidak lagi memakai `username`/`password_confirmation` dan tidak mengembalikan token. Login memakai `email`, bukan `identifier`. Format error memakai `message` + `errors`, bukan objek `error.code`. Endpoint cerita menjadi `POST /api/stories`. |
| **2.1.0** | **18-11-2026** | Menambahkan modul Rekomendasi (`POST /recommendations`, `GET /recommendations/me/latest`). Bentuk data mengikuti kontrak ML `docs/architecture/data-contract.md` v1.2 (`RecommendationResponse`), ditambah field presentasi lowongan. Mesin skor masih berbasis aturan (fallback) sampai model terlatih tersedia. |

- **Base URL:** `http://127.0.0.1:3000/api`
- **Content-Type:** `application/json`
- **Accept:** `application/json`
- **Autentikasi:** HTTP Header `Authorization: Bearer <token>`
- **Masa berlaku token:** 86400 detik (24 jam), JWT HS256
- **Panduan Kontributor & AI Agent:** Lihat [docs/api-contract-guidelines.md](./api-contract-guidelines.md)

### Base URL per platform (Flutter)

| Target | Base URL |
| :--- | :--- |
| Android emulator | `http://10.0.2.2:3000` |
| iOS simulator / desktop | `http://127.0.0.1:3000` |
| Perangkat fisik | `--dart-define=BASE_URL=http://<IP-LAN>:3000` |

`127.0.0.1` di dalam emulator Android menunjuk ke emulator itu sendiri, bukan ke komputer host. Karena itu `10.0.2.2` dipakai sebagai default.

---

## Standar Format Response

Backend Go memakai satu struct envelope untuk semua response:

```go
type WebResponse[T any] struct {
    Success bool          `json:"success"`
    Message string        `json:"message"`
    Data    T             `json:"data"`
    Paging  *PageMetadata `json:"paging,omitempty"`
    Errors  string        `json:"errors,omitempty"`
}
```

### 1. Format Sukses
```json
{
  "success": true,
  "message": "Operasi berhasil dilakukan",
  "data": {}
}
```

### 2. Format Error
```json
{
  "success": false,
  "message": "email sudah terdaftar",
  "errors": "email sudah terdaftar"
}
```

> *Catatan:* `message` selalu berisi pesan yang bisa ditampilkan ke pengguna. `errors` berisi detail teknis (pesan validator atau pesan error yang sama) dan boleh diabaikan oleh client. **Tidak ada** objek `error.code` pada implementasi saat ini.

---

## Daftar Status Code

| Kode HTTP | Keterangan |
| :--- | :--- |
| `200` | Berhasil. |
| `201` | Resource berhasil dibuat (register, kirim cerita). |
| `400` | Payload tidak valid atau validasi input gagal. |
| `401` | Token tidak ada/tidak valid, atau kredensial salah. |
| `403` | Role tidak memiliki akses ke resource. |
| `404` | Resource tidak ditemukan. |
| `409` | Konflik data (mis. email sudah terdaftar, NIM duplikat). |
| `500` | Kesalahan internal server. |

---

## 1. System / Core Endpoints

### 1.1. Health Check
Memeriksa apakah server berjalan.

- **URL:** `/` (root, bukan di bawah `/api`)
- **Method:** `GET`
- **Auth:** Tidak ada

#### Response `200 OK`:
```json
{
  "success": true,
  "message": "juragansengon88",
  "data": "HALO JURAGAN"
}
```

---

## 2. Modul Autentikasi (Authentication)

### 2.1. Register (Daftar Akun Baru)
Mendaftarkan akun baru. Endpoint tersedia di dua path yang identik: `/auth/register` dan `/users/register`.

- **URL:** `/auth/register`
- **Method:** `POST`
- **Auth:** Tidak ada

#### Request Body:
```json
{
  "name": "Budi Santoso",
  "email": "budi.santoso@example.com",
  "password": "password123",
  "confirm_password": "password123",
  "role": "mahasiswa"
}
```

| Field | Tipe | Wajib | Aturan validasi |
| :--- | :--- | :--- | :--- |
| `name` | string | Ya | 3–100 karakter |
| `email` | string | Ya | Format email valid, maks 100 karakter, unik |
| `password` | string | Ya | 6–100 karakter |
| `confirm_password` | string | Ya | Harus sama dengan `password` |
| `role` | string | Tidak | Salah satu dari `admin`, `mitra`, `perusahaan`, `mahasiswa`. Default `mahasiswa` |

> **Tidak ada field `username`.** Tabel `users` tidak memiliki kolom username.

#### Response:
- **`201 Created` (Pendaftaran Berhasil)**
```json
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "id": "6d0f0c8e-1f2a-4c3b-9d10-2b8a7c6d5e4f",
    "name": "Budi Santoso",
    "email": "budi.santoso@example.com",
    "role": "mahasiswa",
    "created_at": "2026-11-18T10:00:00+07:00",
    "updated_at": "2026-11-18T10:00:00+07:00"
  }
}
```

> **Penting:** response register **tidak berisi token**. Untuk memperoleh sesi, client harus memanggil `POST /auth/login` memakai email dan password yang sama. Implementasi Flutter melakukan langkah ini otomatis di `AuthRepositoryImpl.register`.

- **`409 Conflict` (Email Sudah Terdaftar)**
```json
{
  "success": false,
  "message": "email sudah terdaftar",
  "errors": "email sudah terdaftar"
}
```

- **`400 Bad Request` (Validasi Gagal / Konfirmasi Tidak Cocok)**
```json
{
  "success": false,
  "message": "konfirmasi password tidak cocok",
  "errors": "konfirmasi password tidak cocok"
}
```
Bila gagal pada tag validator, `message` berisi pesan bawaan `go-playground/validator`, misalnya:
`Key: 'RegisterUserRequest.Password' Error:Field validation for 'Password' failed on the 'min' tag`.

---

### 2.2. Login (Masuk Akun)
Menukar email dan password dengan JWT. Tersedia di `/auth/login` dan `/users/login`.

- **URL:** `/auth/login`
- **Method:** `POST`
- **Auth:** Tidak ada

#### Request Body:
```json
{
  "email": "budi.santoso@example.com",
  "password": "password123"
}
```

| Field | Tipe | Wajib | Aturan validasi |
| :--- | :--- | :--- | :--- |
| `email` | string | Ya | Format email valid, maks 100 karakter |
| `password` | string | Ya | 6–100 karakter |

> Login **hanya** memakai email. Tidak ada field `identifier`, `username`, atau `remember_me`.

#### Response:
- **`200 OK` (Login Berhasil)**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "6d0f0c8e-1f2a-4c3b-9d10-2b8a7c6d5e4f",
      "name": "Budi Santoso",
      "email": "budi.santoso@example.com",
      "role": "mahasiswa",
      "created_at": "2026-11-18T10:00:00+07:00",
      "updated_at": "2026-11-18T10:00:00+07:00"
    }
  }
}
```
> Token berada di `data.token`, bukan `data.access_token`.

- **`401 Unauthorized` (Kredensial Tidak Cocok)**
```json
{
  "success": false,
  "message": "email atau password salah",
  "errors": "email atau password salah"
}
```

---

### 2.3. Lupa Password (Request Reset Password)
Membuat kode OTP 6 digit dan mengirimkannya ke email pengguna.

- **URL:** `/auth/forgot-password` (alias `/users/forgot-password`)
- **Method:** `POST`
- **Auth:** Tidak ada

#### Request Body:
```json
{
  "email": "budi.santoso@example.com"
}
```

#### Response:
- **`200 OK`**
```json
{
  "success": true,
  "message": "Kode verifikasi telah dikirim ke email",
  "data": {
    "email": "budi.santoso@example.com"
  }
}
```

- **`404 Not Found` (Email Tidak Terdaftar)**
```json
{
  "success": false,
  "message": "email tidak ditemukan",
  "errors": "email tidak ditemukan"
}
```

---

### 2.4. Cari User Berdasarkan Sesi Login (Get Current User)
Mengambil data pengguna pemilik token.

- **URL:** `/auth/me` (alias `/users/current`, `/users/profile`)
- **Method:** `GET`
- **Auth:** Wajib (`Authorization: Bearer <token>`)

#### Response `200 OK`:
```json
{
  "success": true,
  "message": "Berhasil mengambil data pengguna",
  "data": {
    "id": "6d0f0c8e-1f2a-4c3b-9d10-2b8a7c6d5e4f",
    "name": "Budi Santoso",
    "email": "budi.santoso@example.com",
    "role": "mahasiswa",
    "created_at": "2026-11-18T10:00:00+07:00",
    "updated_at": "2026-11-18T10:00:00+07:00"
  }
}
```

#### Response `401 Unauthorized`:
```json
{
  "success": false,
  "message": "Unauthorized: token tidak ditemukan",
  "errors": "unauthorized"
}
```
Bila token ada tetapi tidak valid/kedaluwarsa:
`"message": "Unauthorized: token tidak valid atau kedaluwarsa"`.

---

### 2.5. Logout
**Belum tersedia di backend.** Tidak ada endpoint logout. Karena JWT bersifat stateless, client cukup menghapus token dari penyimpanan lokal (`AuthRepository.clearSession`). Penambahan token blacklist dapat dilakukan di iterasi berikutnya.

---

## 3. Modul Cerita Diri (Story)

Setiap pengguna hanya boleh membaca ceritanya sendiri. Semua endpoint pada modul ini wajib menyertakan token.

### 3.1. Kirim Cerita Diri
Menyimpan cerita diri milik pengguna yang sedang login.

- **URL:** `/stories`
- **Method:** `POST`
- **Auth:** Wajib (`Authorization: Bearer <token>`)

#### Request Body:
```json
{
  "content": "Saya adalah mahasiswa yang senang membangun aplikasi mobile. Saya pernah mengerjakan proyek katalog produk dan aplikasi pencatatan keuangan sederhana menggunakan Flutter."
}
```

| Field | Tipe | Wajib | Aturan validasi |
| :--- | :--- | :--- | :--- |
| `content` | string | Ya | 50–2000 karakter setelah `trim` |

`word_count` dan `analysis_status` dihitung oleh server, tidak dikirim client.

#### Response:
- **`201 Created` (Cerita Berhasil Disimpan)**
```json
{
  "success": true,
  "message": "Cerita berhasil disimpan",
  "data": {
    "id": "b1f2c3d4-5e6f-4a7b-8c9d-0e1f2a3b4c5d",
    "user_id": "6d0f0c8e-1f2a-4c3b-9d10-2b8a7c6d5e4f",
    "content": "Saya adalah mahasiswa yang senang membangun aplikasi mobile...",
    "word_count": 24,
    "analysis_status": "pending",
    "created_at": "2026-11-18T10:05:00+07:00",
    "updated_at": "2026-11-18T10:05:00+07:00"
  }
}
```

Nilai `analysis_status` saat ini selalu `pending`. Nilai lain (mis. `processing`, `done`) disiapkan untuk integrasi model ML.

- **`400 Bad Request` (Cerita Terlalu Pendek / Terlalu Panjang)**
```json
{
  "success": false,
  "message": "cerita minimal 50 karakter dan maksimal 2000 karakter",
  "errors": "cerita minimal 50 karakter dan maksimal 2000 karakter"
}
```

- **`401 Unauthorized` (Token Tidak Ada / Tidak Valid)**
```json
{
  "success": false,
  "message": "Unauthorized: token tidak ditemukan",
  "errors": "unauthorized"
}
```

---

### 3.2. Ambil Cerita Terakhir Milik Sendiri
- **URL:** `/stories/me`
- **Method:** `GET`
- **Auth:** Wajib (`Authorization: Bearer <token>`)

#### Response `200 OK`:
```json
{
  "success": true,
  "message": "Cerita berhasil diambil",
  "data": {
    "id": "b1f2c3d4-5e6f-4a7b-8c9d-0e1f2a3b4c5d",
    "user_id": "6d0f0c8e-1f2a-4c3b-9d10-2b8a7c6d5e4f",
    "content": "Saya adalah mahasiswa yang senang membangun aplikasi mobile...",
    "word_count": 24,
    "analysis_status": "pending",
    "created_at": "2026-11-18T10:05:00+07:00",
    "updated_at": "2026-11-18T10:05:00+07:00"
  }
}
```

#### Response `404 Not Found`:
```json
{
  "success": false,
  "message": "cerita belum pernah dikirim",
  "errors": "cerita belum pernah dikirim"
}
```

---

## 4. Modul Rekomendasi (Recommendation)

Modul ini mengubah **cerita diri** menjadi daftar lowongan magang yang paling cocok.

### Sumber data dan mesin skor

- **Katalog lowongan** disimpan di tabel `jobs` dan di-seed otomatis saat server start dari `internal/dataset/jobs.csv`. Setiap lowongan wajib memiliki `category` yang merupakan salah satu dari delapan posisi resmi.
- **Ekstraksi keahlian** memakai leksikon `internal/dataset/skills.csv` (111 keahlian kanonik beserta aliasnya). Pencocokan dilakukan per kata pada narasi, sehingga "golang" dan "go lang" sama-sama menjadi `Go`.
- **Mesin skor saat ini berbasis aturan (fallback).** Pipeline `pathfinder-ml` belum memiliki model terlatih maupun HTTP API, sehingga backend Go menghitung skor sendiri. Bentuk response sudah mengikuti kontrak ML, jadi saat model asli tersedia cukup mengganti isi perhitungan tanpa mengubah kontrak ini.

Nilai `model_version` memakai format kontrak ML `ner:<versi>;encoder:<nama>;ranker:<versi>`. Selama masih fallback, isinya `ner:lexicon-rule-1.0.0;encoder:none;ranker:rule-1.0.0`.

### Delapan posisi resmi (`category`)

1. `Software Engineer Intern`
2. `Backend Developer Intern`
3. `Mobile Developer Intern`
4. `Frontend Developer Intern`
5. `Data Analyst Intern`
6. `UI/UX Designer Intern`
7. `QA Engineer Intern`
8. `Network & IT Support Intern`

### Arti `status` dan `score_status`

| Field | Nilai | Arti |
| :--- | :--- | :--- |
| `status` | `ok` | Semua item punya skor lengkap |
| `status` | `parsial` | Sebagian item belum bisa diberi skor |
| `status` | `profil_tidak_lengkap` | Tidak ada keahlian yang terdeteksi; `items` kosong |
| `score_status` | `ok` | `matching_score` terisi |
| `score_status` | `skor_belum_tersedia` | Profil punya keahlian, tetapi skor belum bisa dihitung |
| `score_status` | `persyaratan_belum_tersedia` | Lowongan tidak punya `required_skills`; `matching_score` null |
| `score_status` | `profil_tanpa_keterampilan` | Profil tidak punya keahlian; `matching_score` null |

### Rumus skor (fallback berbasis aturan)

```
hard_skill_match  = jumlah skill wajib yang cocok / jumlah skill wajib
optional_match    = jumlah skill opsional yang cocok / jumlah skill opsional

matching_score    = round(100 × (0.8 × hard_skill_match + 0.2 × optional_match))
                    bila lowongan tidak punya skill opsional:
                    matching_score = round(100 × hard_skill_match)

readiness_score   = round(100 × (0.7 × hard_skill_match + 0.1 × profile_completeness) / 0.8)
                    profile_completeness = kelompok profil terisi / 4
                    (hard_skills, soft_skills, interests, experience)
```

`cosine_similarity` selalu `null` selama encoder belum tersedia. `rank` diberikan setelah pengurutan `matching_score` menurun, lalu `readiness_score` menurun, lalu `job_id`.

---

### 4.1. Buat Rekomendasi

Menjalankan analisis terhadap cerita diri dan mengembalikan lowongan teratas.

- **URL:** `/recommendations`
- **Method:** `POST`
- **Auth:** Wajib (`Authorization: Bearer <token>`)

#### Request Body (opsional):

```json
{
  "story_id": "b1f2c3d4-5e6f-4a7b-8c9d-0e1f2a3b4c5d",
  "top_k": 3
}
```

| Field | Tipe | Wajib | Aturan |
| :--- | :--- | :--- | :--- |
| `story_id` | string | Tidak | Bila kosong, dipakai cerita terakhir milik pengguna |
| `top_k` | integer | Tidak | 1–8, default `3` |

Body boleh kosong sama sekali (`{}` atau tanpa body).

#### Response `200 OK`:

```json
{
  "success": true,
  "message": "Rekomendasi berhasil dibuat",
  "data": {
    "id": "9c1d2e3f-4a5b-6c7d-8e9f-0a1b2c3d4e5f",
    "student_id": "6d0f0c8e-1f2a-4c3b-9d10-2b8a7c6d5e4f",
    "story_id": "b1f2c3d4-5e6f-4a7b-8c9d-0e1f2a3b4c5d",
    "generated_at": "2026-11-18T07:31:58Z",
    "schema_version": "1.0",
    "model_version": "ner:lexicon-rule-1.0.0;encoder:none;ranker:rule-1.0.0",
    "top_k": 3,
    "status": "ok",
    "profile": {
      "hard_skills": ["Go", "PostgreSQL", "Git"],
      "soft_skills": ["Teamwork"],
      "interests": [],
      "profile_status": "lengkap"
    },
    "items": [
      {
        "job_id": "JOB-009",
        "title": "Backend Developer Intern",
        "category": "Backend Developer Intern",
        "company": "PT Qtera Mandiri",
        "location": "Jakarta Utara",
        "work_type": "WFO",
        "source": "Glints",
        "source_url": "https://glints.com/id/opportunities/jobs/backend-developer-intern/17325250",
        "matching_score": 84,
        "cosine_similarity": null,
        "readiness_score": 66,
        "matched_skills": ["Go", "PostgreSQL", "Git"],
        "missing_skills": ["Docker", "REST API"],
        "score_status": "ok",
        "rank": 1
      }
    ]
  }
}
```

#### Response `200 OK` — keahlian tidak terdeteksi:

```json
{
  "success": true,
  "message": "Rekomendasi berhasil dibuat",
  "data": {
    "id": "9c1d2e3f-4a5b-6c7d-8e9f-0a1b2c3d4e5f",
    "student_id": "6d0f0c8e-1f2a-4c3b-9d10-2b8a7c6d5e4f",
    "story_id": "b1f2c3d4-5e6f-4a7b-8c9d-0e1f2a3b4c5d",
    "generated_at": "2026-11-18T07:31:58Z",
    "schema_version": "1.0",
    "model_version": "ner:lexicon-rule-1.0.0;encoder:none;ranker:rule-1.0.0",
    "top_k": 3,
    "status": "profil_tidak_lengkap",
    "profile": {
      "hard_skills": [],
      "soft_skills": [],
      "interests": [],
      "profile_status": "tanpa_skill"
    },
    "items": []
  }
}
```

Aplikasi harus menampilkan ajakan memperbaiki cerita (sebutkan alat, bahasa, atau bidang yang dikuasai), bukan halaman kosong.

#### Response `400 Bad Request` (`top_k` tidak valid):

```json
{
  "success": false,
  "message": "top_k harus bernilai 1 sampai 8",
  "errors": "top_k harus bernilai 1 sampai 8"
}
```

#### Response `404 Not Found` (belum pernah mengirim cerita):

```json
{
  "success": false,
  "message": "cerita belum pernah dikirim, kirim cerita dulu",
  "errors": "cerita belum pernah dikirim"
}
```

#### Response `401 Unauthorized`:

```json
{
  "success": false,
  "message": "Unauthorized: token tidak ditemukan",
  "errors": "unauthorized"
}
```

Setelah analisis berhasil, `analysis_status` pada cerita yang dipakai berubah dari `pending` menjadi `done`.

---

### 4.2. Ambil Rekomendasi Terakhir Milik Sendiri

Berguna saat aplikasi dibuka ulang tanpa perlu menghitung ulang.

- **URL:** `/recommendations/me/latest`
- **Method:** `GET`
- **Auth:** Wajib (`Authorization: Bearer <token>`)

#### Response `200 OK`:

Bentuk `data` identik dengan response `POST /recommendations`.

#### Response `404 Not Found`:

```json
{
  "success": false,
  "message": "rekomendasi belum pernah dibuat",
  "errors": "rekomendasi belum pernah dibuat"
}
```

---

## 5. Endpoint Lain yang Tersedia di Backend

Endpoint berikut sudah ada di `route.go` tetapi belum dipakai oleh aplikasi Flutter, sehingga belum didokumentasikan detail. Rujuk langsung ke kode backend bila akan diintegrasikan.

| Method | URL | Role | Keterangan |
| :--- | :--- | :--- | :--- |
| `GET` | `/admin/dashboard` | admin | Dashboard admin |
| `POST` | `/admin/mahasiswa` | admin | Buat akun mahasiswa |
| `GET` | `/admin/mahasiswa` | admin | List + paging + search |
| `GET` | `/admin/mahasiswa/:id` | admin | Detail mahasiswa |
| `PUT`/`PATCH` | `/admin/mahasiswa/:id` | admin | Ubah data mahasiswa |
| `DELETE` | `/admin/mahasiswa/:id` | admin | Hapus mahasiswa |
| `GET` | `/mitra/dashboard` | mitra, perusahaan | Dashboard mitra |
| `GET` | `/mitra/profile`, `/perusahaan/profile` | mitra, perusahaan | Profil mitra/perusahaan |
| `PUT`/`PATCH` | `/mitra/profile`, `/perusahaan/profile` | mitra, perusahaan | Ubah profil mitra/perusahaan |
| `GET` | `/mahasiswa/dashboard` | mahasiswa | Dashboard mahasiswa |
| `GET` | `/mahasiswa/profile` | mahasiswa | Profil mahasiswa |
| `PUT`/`PATCH` | `/mahasiswa/profile` | mahasiswa | Ubah profil mahasiswa |

---

## 6. Catatan Integrasi Flutter

1. **Prefix path.** Client menyusun path sebagai `<baseUrl>/api/...`. Bila `BASE_URL` sudah berakhir dengan `/api`, client tidak menambahkan prefix lagi.
2. **Token.** Disimpan di `SharedPreferences` lewat `AuthLocalSource` dan dipasang sebagai header `Authorization: Bearer <token>` oleh interceptor Dio.
3. **Register.** Karena register tidak mengembalikan token, `AuthRepositoryImpl.register` memanggil login otomatis. Bila login otomatis gagal, akun tetap dibuat dan UI mengarahkan pengguna ke halaman login.
4. **Error.** `ErrorMapper` membaca `message` lebih dulu, lalu `errors`. Status `400` dan `422` dipetakan ke `ValidationException`, `401`/`403` ke `UnauthorizedException`, `404` ke `NotFoundException`, `409` ke `ServerException`.
5. **Cleartext HTTP.** Backend lokal memakai HTTP, sehingga build debug/profile Android mengaktifkan `usesCleartextTraffic` dan iOS memakai `NSAllowsLocalNetworking`.
6. **Rekomendasi.** Layar pemrosesan tidak lagi memakai progres palsu. `RecommendationController` memanggil `POST /recommendations`; `isCompleted` pada `MlProcessingView` baru bernilai `true` setelah response diterima. Bila gagal, tampilkan pesan error dan tombol coba lagi — jangan biarkan pengguna menunggu tanpa batas.
