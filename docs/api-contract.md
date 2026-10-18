# API Contract - PathFinder

Dokumen ini mendefinisikan spesifikasi kontrak REST API untuk layanan backend **PathFinder**. Semua endpoint berkomunikasi menggunakan format JSON dengan standar response seragam.

---

## Informasi & Changelog

| Versi | Tanggal | Deskripsi Perubahan |
| :--- | :--- | :--- |
| **1.0.0** | **19-10-2026** | Inisialisasi kontrak endpoint health check dan fitur autentikasi (`register`, `login`, `forgot-password`, `me`, `logout`). |

- **Base URL:** `http://127.0.0.1:8000/api/v1`
- **Content-Type:** `application/json`
- **Accept:** `application/json`
- **Autentikasi:** HTTP Header `Authorization: Bearer <access_token>`
- **Panduan Kontributor & AI Agent:** Lihat [docs/api-contract-guidelines.md](./api-contract-guidelines.md)

---

## Standar Format Response

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
  "error": {
    "code": "ERROR_CODE_NAME",
    "message": "Pesan deskriptif kesalahan yang dapat dibaca manusia",
    "details": [
      {
        "field": "email",
        "issue": "Format email tidak valid"
      }
    ]
  }
}
```

---

## Daftar Kode Error (Standard Error Codes)

| Kode HTTP | Error Code | Keterangan |
| :--- | :--- | :--- |
| `400` | `BAD_REQUEST` | Format request atau payload JSON tidak valid. |
| `401` | `UNAUTHORIZED` | Token autentikasi tidak disertakan atau tidak valid. |
| `401` | `TOKEN_EXPIRED` | Sesi token telah kedaluwarsa. |
| `401` | `INVALID_CREDENTIALS` | Identitas pengguna atau kata sandi salah. |
| `403` | `FORBIDDEN` | Akun tidak memiliki hak akses ke resource ini. |
| `404` | `NOT_FOUND` | Resource atau data yang diminta tidak ditemukan. |
| `404` | `USER_NOT_FOUND` | Pengguna dengan identifier terkait tidak ditemukan. |
| `409` | `EMAIL_ALREADY_EXISTS` | Email sudah terdaftar pada sistem. |
| `409` | `USERNAME_ALREADY_EXISTS` | Username sudah digunakan oleh pengguna lain. |
| `422` | `VALIDATION_ERROR` | Validasi input gagal (data wajib kosong, format salah, dsb). |
| `500` | `INTERNAL_SERVER_ERROR` | Kesalahan internal server yang tidak terduga. |
| `503` | `SERVICE_UNAVAILABLE` | Layanan sedang dalam pemeliharaan atau tidak siap menerima request. |

---

## 1. System / Core Endpoints

### 1.1. Health Check
Memeriksa status operasional server backend.

- **URL:** `/health`
- **Method:** `GET`
- **Auth:** Tidak ada

#### Response:
- **`200 OK` (Layanan Sehat)**
```json
{
  "success": true,
  "message": "Server dan service berjalan dengan normal",
  "data": {
    "status": "healthy",
    "version": "1.0.0",
    "timestamp": "2026-10-19T01:12:00Z"
  }
}
```

- **`503 Service Unavailable` (Layanan Mengalami Gangguan)**
```json
{
  "success": false,
  "error": {
    "code": "SERVICE_UNAVAILABLE",
    "message": "Service sedang tidak siap menerima request",
    "details": null
  }
}
```

---

## 2. Modul Autentikasi (Authentication)

### 2.1. Register (Daftar Akun Baru)
Mendaftarkan akun baru bagi pengguna aplikasi.

- **URL:** `/auth/register`
- **Method:** `POST`
- **Auth:** Tidak ada

#### Request Body:
```json
{
  "name": "Budi Santoso",
  "username": "budisantoso",
  "email": "budi.santoso@example.com",
  "password": "PasswordAman123!",
  "password_confirmation": "PasswordAman123!"
}
```

#### Response:
- **`201 Created` (Pendaftaran Berhasil)**
```json
{
  "success": true,
  "message": "Pendaftaran akun berhasil",
  "data": {
    "user": {
      "id": "usr_9f4c3a21",
      "name": "Budi Santoso",
      "username": "budisantoso",
      "email": "budi.santoso@example.com",
      "created_at": "2026-10-19T01:12:00Z"
    }
  }
}
```

- **`409 Conflict` (Email atau Username Sudah Digunakan)**
```json
{
  "success": false,
  "error": {
    "code": "EMAIL_ALREADY_EXISTS",
    "message": "Email sudah terdaftar. Silakan gunakan email lain atau login.",
    "details": [
      {
        "field": "email",
        "issue": "Email sudah digunakan"
      }
    ]
  }
}
```

- **`422 Unprocessable Entity` (Validasi Input Gagal)**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validasi form registrasi gagal",
    "details": [
      {
        "field": "password",
        "issue": "Password minimal 8 karakter dan mengandung kombinasi huruf serta angka"
      },
      {
        "field": "password_confirmation",
        "issue": "Konfirmasi password tidak cocok"
      }
    ]
  }
}
```

---

### 2.2. Login (Masuk Akun)
Autentikasi pengguna menggunakan email/username dan kata sandi untuk mendapatkan token sesi JWT.

- **URL:** `/auth/login`
- **Method:** `POST`
- **Auth:** Tidak ada

#### Request Body:
```json
{
  "identifier": "budi.santoso@example.com",
  "password": "PasswordAman123!",
  "remember_me": true
}
```
> *Catatan:* `identifier` dapat berupa alamat email atau username.

#### Response:
- **`200 OK` (Login Berhasil)**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 604800,
    "user": {
      "id": "usr_9f4c3a21",
      "name": "Budi Santoso",
      "username": "budisantoso",
      "email": "budi.santoso@example.com"
    }
  }
}
```

- **`401 Unauthorized` (Kredensial Tidak Cocok)**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Username/email atau kata sandi salah",
    "details": null
  }
}
```

- **`422 Unprocessable Entity` (Validasi Gagal)**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Input tidak valid",
    "details": [
      {
        "field": "identifier",
        "issue": "Identifier tidak boleh kosong"
      },
      {
        "field": "password",
        "issue": "Kata sandi tidak boleh kosong"
      }
    ]
  }
}
```

---

### 2.3. Lupa Password (Request Reset Password)
Mengirimkan tautan atau token pemulihan kata sandi ke email pengguna.

- **URL:** `/auth/forgot-password`
- **Method:** `POST`
- **Auth:** Tidak ada

#### Request Body:
```json
{
  "email": "budi.santoso@example.com"
}
```

#### Response:
- **`200 OK` (Instruksi Terkirim)**
```json
{
  "success": true,
  "message": "Jika email terdaftar, tautan reset password telah dikirim ke email Anda",
  "data": {
    "email": "budi.santoso@example.com",
    "retry_after_seconds": 60
  }
}
```

- **`404 Not Found` (Pengguna Tidak Ditemukan - Opsional jika sistem menerapkan verifikasi eksplisit)**
```json
{
  "success": false,
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "Akun dengan email tersebut tidak ditemukan",
    "details": null
  }
}
```

- **`422 Unprocessable Entity` (Format Email Salah)**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Format alamat email tidak valid",
    "details": [
      {
        "field": "email",
        "issue": "Masukkan alamat email yang valid"
      }
    ]
  }
}
```

---

### 2.4. Cari User Berdasarkan Sesi Login (Get Current User)
Mengambil detail profil akun yang sedang login berdasarkan token sesi yang valid.

- **URL:** `/auth/me`
- **Method:** `GET`
- **Auth:** Wajib (`Authorization: Bearer <access_token>`)

#### Request Header:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Response:
- **`200 OK` (Data User Ditemukan)**
```json
{
  "success": true,
  "message": "Data profil pengguna berhasil diambil",
  "data": {
    "id": "usr_9f4c3a21",
    "name": "Budi Santoso",
    "username": "budisantoso",
    "email": "budi.santoso@example.com",
    "avatar_url": null,
    "created_at": "2026-10-19T01:12:00Z",
    "updated_at": "2026-10-19T01:12:00Z"
  }
}
```

- **`401 Unauthorized` (Token Tidak Ada / Tidak Valid / Kedaluwarsa)**
```json
{
  "success": false,
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Sesi autentikasi telah kedaluwarsa. Silakan masuk kembali.",
    "details": null
  }
}
```

- **`404 Not Found` (Akun Sudah Terhapus)**
```json
{
  "success": false,
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "Data pengguna pemilik sesi tidak ditemukan",
    "details": null
  }
}
```

---

### 2.5. Logout (Keluar Akun)
Mengakhiri sesi aktif pengguna dan mencabut (revoke/blacklist) token akses yang sedang digunakan.

- **URL:** `/auth/logout`
- **Method:** `POST`
- **Auth:** Wajib (`Authorization: Bearer <access_token>`)

#### Request Header:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Request Body:
Kosong (`{}`)

#### Response:
- **`200 OK` (Logout Berhasil)**
```json
{
  "success": true,
  "message": "Berhasil keluar dan sesi telah diakhiri",
  "data": null
}
```

- **`401 Unauthorized` (Token Tidak Valid)**
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Sesi tidak valid atau telah berakhir sebelumnya",
    "details": null
  }
}
```
