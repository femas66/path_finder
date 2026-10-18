# Panduan Pengelolaan API Contract (AI Agent & Developer Guide)

Dokumen ini merupakan instruksi operasional standar bagi **AI Agent** dan **Developer** untuk menulis, memperbaiki, dan memperluas spesifikasi API pada [`docs/api-contract.md`](./api-contract.md). 

Instruksi ini wajib dipatuhi saat proyek berkembang dan fitur-fitur baru mulai ditambahkan (misal: modul *Story*, *Recommendation*, *Assessment*, *User Profile*, dan lainnya).

---

## 1. Prinsip Utama (Core Principles)

1. **Single Source of Truth**
   - [`docs/api-contract.md`](./api-contract.md) adalah acuan tunggal bagi tim frontend (Flutter) dan tim backend.
   - Jangan pernah mengimplementasikan endpoint baru di frontend atau backend sebelum spesifikasinya disepakati dan ditulis pada API contract.

2. **Konsistensi Envelope JSON**
   Semua endpoint **tanpa pengecualian** wajib menggunakan format envelope standar yang seragam:

   - **Format Sukses:**
     ```json
     {
       "success": true,
       "message": "Pesan deskriptif singkat",
       "data": {} // Objek, array data, atau null jika tidak ada return data
     }
     ```

   - **Format Error:**
     ```json
     {
       "success": false,
       "error": {
         "code": "MACHINE_READABLE_ERROR_CODE",
         "message": "Pesan deskriptif yang ramah pengguna",
         "details": null // null atau array objek spesifik error validasi
       }
     }
     ```

3. **Konvensi Penamaan (Naming Conventions)**
   - **URL Endpoints:** Gunakan kata benda jamak (*plural nouns*), huruf kecil (*lowercase*), dan pemisah strip (*kebab-case*).
     - *Benar:* `/api/v1/stories`, `/api/v1/auth/forgot-password`, `/api/v1/recommendation-results`
     - *Salah:* `/api/v1/getStory`, `/api/v1/user_profile`, `/api/v1/createRecommendation`
   - **JSON Field Keys:** Gunakan `snake_case` untuk seluruh request body dan response data (contoh: `access_token`, `user_id`, `created_at`, `is_completed`).
   - **Error Codes:** Gunakan `SCREAMING_SNAKE_CASE` (contoh: `VALIDATION_ERROR`, `USER_NOT_FOUND`, `UNAUTHORIZED`).

4. **Kaidah Penambahan (Prefer Addition Over Modification)**
   - Jangan pernah menghapus field yang sudah aktif digunakan oleh frontend tanpa masa transisi (*backward compatibility*).
   - Jika ada kebutuhan data baru, tambahkan sebagai field opsional baru.

---

## 2. Prosedur Menambahkan Fitur / Endpoint Baru

Ketika ada instruksi untuk menambahkan fitur baru ke API contract, ikuti 5 langkah berurutan berikut:

### Langkah 1: Tentukan Kategori Modul
Periksa apakah endpoint baru termasuk ke dalam modul yang sudah ada atau membutuhkan modul baru (misal: `## 3. Modul Rekomendasi (Recommendation)`).

### Langkah 2: Siapkan Metadata Endpoint
Tentukan:
- **Judul Sub-fitur & Deskripsi Singkat:** Apa tujuan endpoint ini.
- **Method HTTP:** `GET` (ambil data), `POST` (buat data / aksi proses), `PUT` / `PATCH` (pembaruan data), `DELETE` (hapus data).
- **URL Path:** Relative terhadap base URL `/api/v1`.
- **Autentikasi:** Jelaskan apakah membutuhkan header `Authorization: Bearer <access_token>` atau `Tidak ada`.
- **Query Parameters / Headers (Jika ada):** Terutama jika endpoint mendukung *pagination*, *filter*, atau *search*.

### Langkah 3: Rinci Request & Response
Tuliskan:
- **Request Body:** Lengkapi dengan contoh payload JSON valid.
- **Response Kasus Sukses:**
  - `200 OK` (operasi sukses atau pengambilan data).
  - `201 Created` (data baru berhasil disimpan di database).
- **Response Kasus Gagal (Wajib Lengkap):**
  - `400 Bad Request` (payload rusak / malformed JSON).
  - `401 Unauthorized` (sesi habis / token tidak valid, jika endpoint butuh auth).
  - `403 Forbidden` (tidak memiliki hak akses ke data ini).
  - `404 Not Found` (resource yang dicari berdasarkan ID tidak ditemukan).
  - `409 Conflict` (duplikasi data unik).
  - `422 Unprocessable Entity` (gagal validasi input, berikan struktur `details`).
  - `500 Internal Server Error` (kesalahan server).

### Langkah 4: Daftarkan Error Code Baru
Jika endpoint baru memperkenalkan kode error baru yang belum terdaftar:
- Buka tabel **Daftar Kode Error (Standard Error Codes)** di bagian atas dokumen.
- Tambahkan baris baru dengan format:
  ```markdown
  | `KODE_HTTP` | `NAMA_ERROR_CODE` | Keterangan deskriptif |
  ```

### Langkah 5: Update Versi & Tabel Changelog
- Naikkan versi dokumen:
  - **Patch (`1.0.x`):** Untuk koreksi typo, penambahan contoh response, atau perbaikan deskripsi.
  - **Minor (`1.x.0`):** Untuk penambahan endpoint baru atau modul baru yang kompatibel.
  - **Major (`x.0.0`):** Untuk perubahan besar yang mematahkan skema lama (*breaking changes*).
- Tambahkan baris di tabel **Informasi & Changelog** dengan tanggal saat ini dan ringkasan fitur yang ditambahkan.

---

## 3. Template Standar Markdown untuk Endpoint Baru

Salin dan gunakan template di bawah ini setiap kali menambahkan endpoint baru ke dalam [`docs/api-contract.md`](./api-contract.md):

```markdown
### X.Y. Nama Endpoint / Fitur
Penjelasan singkat fungsi dan tujuan endpoint ini.

- **URL:** `/path-endpoint`
- **Method:** `POST`
- **Auth:** Wajib (`Authorization: Bearer <access_token>`) / Tidak ada

#### Query Parameters (Opsional, jika ada):
| Parameter | Tipe | Wajib | Keterangan |
| :--- | :--- | :--- | :--- |
| `page` | `integer` | Tidak | Nomor halaman (default: `1`) |
| `limit` | `integer` | Tidak | Jumlah item per halaman (default: `10`) |

#### Request Header (Jika butuh autentikasi):
```http
Authorization: Bearer <access_token>
```

#### Request Body (Jika method POST/PUT/PATCH):
```json
{
  "field_name": "example_value"
}
```

#### Response:
- **`200 OK` (Operasi Berhasil)**
```json
{
  "success": true,
  "message": "Data berhasil diproses",
  "data": {
    "id": "item_123",
    "field_name": "example_value"
  }
}
```

- **`401 Unauthorized` (Token Tidak Valid / Kedaluwarsa)**
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Sesi tidak valid atau telah berakhir",
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
    "message": "Validasi input gagal",
    "details": [
      {
        "field": "field_name",
        "issue": "Field tidak boleh kosong"
      }
    ]
  }
}
```
```

---

## 4. Prosedur Memperbaiki / Merevisi Kontrak (Fixes & Updates)

Jika diminta memperbaiki endpoint yang sudah ada:
1. **Analisis Dampak ke Frontend:**
   - Cek implementasi model di Flutter (`lib/features/.../data/models/`).
   - Jangan mengubah nama field kunci tanpa mendiskusikan atau memperbarui model data client.
2. **Validitas Sintaksis JSON:**
   - Pastikan contoh JSON tidak memiliki *trailing comma* `,` di item terakhir.
   - Pastikan seluruh string diapit tanda kutip ganda `""`.
3. **Penyelarasan Status Code:**
   - Gunakan `422` untuk kegagalan validasi form/input bisnis.
   - Gunakan `400` untuk request yang tidak dapat di-parse atau salah format dasar.
   - Gunakan `401` untuk token/autentikasi dan `403` untuk otorisasi hak peran (*roles/permissions*).
   - Gunakan `404` untuk entitas tidak ditemukan.

---

## 5. Checklist Verifikasi AI Agent (Pre-flight Checklist)

Sebelum AI Agent menyatakan tugas modifikasi atau penambahan API contract selesai, wajib memvalidasi checklist berikut:

- [ ] **Struktur URL:** Apakah endpoint menggunakan kaidah RESTful (kata benda jamak, kebab-case)?
- [ ] **Format Envelope:** Apakah semua contoh response menggunakan wrapper `{ success, message, data }` atau `{ success, error: { code, message, details } }`?
- [ ] **Variasi Response:** Apakah skenario error (minimal validasi `422` dan auth `401` jika berautentikasi) sudah disertakan?
- [ ] **Tabel Error Code:** Apakah ada error code baru yang perlu dicatat di tabel atas?
- [ ] **Changelog:** Apakah versi dokumen dan riwayat perubahan sudah di-update pada tabel header?
- [ ] **Kerapian Markdown:** Apakah heading, tabel, dan blok kode tertutup rapat dan mudah dibaca?
