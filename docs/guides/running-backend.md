# Panduan Menjalankan Backend Lokal (Running Backend)

Panduan untuk menyiapkan dan menjalankan database PostgreSQL dan server backend Go lokal agar aplikasi mobile Flutter dapat melakukan pengujian fitur dan integrasi API secara nyata.

---

## 1. Prasyarat Sistem

Pastikan perangkat telah terpasang:
1. Docker Desktop (harus dalam kondisi running untuk menjalankan container PostgreSQL).
2. Go SDK versi 1.27 atau lebih baru (`go version`).
3. Flutter SDK (`flutter --version`).

---

## 2. Menjalankan Database PostgreSQL

Buka terminal pada repositori backend (`path-finder-backend`), lalu jalankan container PostgreSQL:

```bash
docker compose up -d postgres
```

Periksa status container:
```bash
docker compose ps
```
Pastikan container `path_finder_postgres` telah berstatus `running (healthy)`.

Konfigurasi database default di `path-finder-backend/config.json`:
- Host: `localhost`
- Port: `5432`
- User: `juragansengon88`
- Password: `juragansengon88`
- Database: `path_finder_db`

---

## 3. Menjalankan Server Backend Go

Dari folder `path-finder-backend`, jalankan aplikasi web server:

```bash
go run ./cmd/web
```

Server akan otomatis melakukan migrasi skema tabel (`AutoMigrate`) dan mendengarkan request pada port `3000` (`http://localhost:3000`).

Biarkan terminal ini tetap terbuka selama melakukan pengujian aplikasi Flutter.

---

## 4. Memverifikasi Server Aktif

Uji status server melalui terminal atau curl:

```bash
curl http://localhost:3000/
```

Respons yang benar:
```json
{
  "success": true,
  "message": "juragansengon88",
  "data": "HALO JURAGAN"
}
```

---

## 5. Menjalankan Aplikasi Flutter

Aplikasi mobile Flutter telah memiliki deteksi host otomatis di `lib/core/config/env.dart`:
- Android Emulator: otomatis mengarah ke `http://10.0.2.2:3000`.
- iOS Simulator / Desktop macOS: otomatis mengarah ke `http://127.0.0.1:3000`.
- Perangkat Fisik (Physical Device): jalankan dengan menyertakan alamat IP lokal komputer host:
  ```bash
  flutter run --dart-define=BASE_URL=http://<IP_LAN_KOMPUTER>:3000
  ```
