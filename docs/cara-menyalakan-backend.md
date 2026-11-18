# Cara Menyalakan Backend Path Finder

Backend = **PostgreSQL** (lewat Docker) + **server Go**. Keduanya harus hidup sebelum aplikasi Flutter bisa register/login.

---

## Cara tercepat (satu perintah)

Buka PowerShell di folder `path-finder-backend`, lalu:

```powershell
.\start-backend.ps1
```

Skrip ini otomatis:
1. Menyalakan Docker Desktop kalau daemon-nya belum jalan (menunggu sampai siap)
2. Menyalakan container PostgreSQL
3. Menunggu PostgreSQL benar-benar `healthy`
4. Memeriksa port 3000 tidak dipakai proses lain
5. Menjalankan `go run ./cmd/web`

Output yang benar terlihat seperti ini:

```
==> Memeriksa Docker
    OK  Docker siap

==> Menyalakan PostgreSQL
    OK  PostgreSQL healthy di port 5432

==> Memeriksa port 3000
    OK  Port 3000 bebas

==> Menjalankan server Go di http://localhost:3000
INFO Server started on:  http://127.0.0.1:3000 (bound on host 0.0.0.0 and port 3000)
```

**Biarkan terminal itu terbuka.** Kalau ditutup atau ditekan Ctrl+C, backend mati dan aplikasi akan timeout.

> Kalau muncul `running scripts is disabled on this system`, jalankan sekali:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

---

## Cara manual (kalau ingin tahu langkahnya)

### Terminal 1 — PostgreSQL

```powershell
cd C:\Users\HP\Documents\GitHub\path-finder-backend
docker compose up -d postgres
docker compose ps          # tunggu sampai statusnya "running (healthy)"
```

### Terminal 2 — server Go

```powershell
cd C:\Users\HP\Documents\GitHub\path-finder-backend
go run ./cmd/web
```

### Terminal 3 — aplikasi Flutter

```powershell
cd C:\Users\HP\Documents\GitHub\path_finder
flutter run
```

---

## Cara memastikan backend benar-benar hidup

Dari PowerShell di komputer:

```powershell
curl http://localhost:3000/
```

Harus menjawab:

```json
{"success":true,"message":"juragansengon88","data":"HALO JURAGAN"}
```

Kalau **tidak** menjawab apa pun, backend mati — bukan masalah jaringan aplikasi.

---

## Cara menghentikan backend

| Yang dihentikan | Perintah |
| :--- | :--- |
| Server Go | Tekan `Ctrl+C` di terminal tempat ia berjalan |
| Server Go (kalau terminalnya hilang) | `Get-Process web \| Stop-Process -Force` |
| PostgreSQL (data tetap tersimpan) | `docker compose stop postgres` |
| Docker Desktop | Klik kanan ikon Docker di system tray → *Quit Docker Desktop* |

Data user **tidak hilang** saat Postgres di-`stop`, karena disimpan di volume `postgres_data`.

---

## Kalau backend tidak mau start

| Pesan error | Arti | Solusi |
| :--- | :--- | :--- |
| `failed to connect ... 5432: actively refused it` | PostgreSQL belum jalan | `docker compose up -d postgres`, tunggu sampai healthy |
| `failed to connect to the docker API ... dockerDesktopLinuxEngine` | Docker Desktop belum jalan | Buka Docker Desktop, tunggu ikon di tray berhenti beranimasi |
| `bind: address already in use` | Port 3000 dipakai proses lain | `Get-NetTCPConnection -LocalPort 3000 -State Listen` lalu hentikan PID-nya |
| `running scripts is disabled on this system` | Execution policy Windows | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| `go: command not found` | Go belum terpasang / tidak di PATH | Pasang Go 1.27+ |

---

## Catatan penting

1. **Docker Desktop tidak auto-start di komputer ini.** Setiap kali Windows baru dinyalakan, Docker harus dibuka dulu. `start-backend.ps1` sudah menangani ini otomatis.
2. **PostgreSQL harus healthy sebelum server Go dijalankan.** Backend memanggil `log.Fatal` kalau database gagal terhubung, sehingga prosesnya langsung mati tanpa pesan yang jelas di aplikasi.
3. **Jangan tutup terminal backend.** Ini penyebab paling umum aplikasi menampilkan pesan timeout.
4. **Android emulator memakai `10.0.2.2`, bukan `127.0.0.1`.** Sudah diatur otomatis di `lib/core/config/env.dart`.
