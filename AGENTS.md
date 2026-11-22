# AGENTS.md — PathFinder (Aplikasi Mobile Flutter)

Panduan pemahaman proyek, arsitektur sistem, peran pengguna, alur kerja, dan konvensi pengembangan untuk AI coding agent serta pengembang perangkat lunak pada repositori PathFinder Frontend (Flutter).

---

## 1. Tentang Proyek PathFinder

### Apa itu PathFinder?
PathFinder adalah aplikasi mobile cerdas yang dirancang untuk membantu mahasiswa menemukan dan melamar program magang industri yang paling relevan dengan minat, keahlian nyata, dan rekam jejak mereka. 

Berbeda dari portal lowongan konvensional yang hanya mencocokkan kata kunci CV statis, PathFinder memanfaatkan analisis cerita diri naratif reflektif (Self-Narrative Story) yang ditulis langsung oleh mahasiswa. Cerita narasi ini mencakup:
- Pengalaman di dalam perkuliahan: mata kuliah favorit, proyek tim/tugas besar, eksperimen praktikum, dan penguasaan teori akademik.
- Eksplorasi di luar perkuliahan: proyek mandiri, hobi pemrograman, kursus daring, keaktifan organisasi/komunitas teknologi, serta pemecahan masalah teknis riil.

Narasi tersebut dianalisis menggunakan teknologi Natural Language Processing (NLP) oleh service Machine Learning untuk mengekstrak entitas keahlian (hard skills dan soft skills), lalu dicocokkan dengan kualifikasi lowongan magang yang dipasang oleh mitra industri terpercaya.

### Konteks Proyek dan Tim
- Konteks: Project-Based Learning (PBL) — Tugas Akhir Semester 5
- Pengembang: Tim Mahasiswa (5 Anggota)
- Repositori Ini: path_finder (Aplikasi Frontend Mobile untuk sistem operasi Android dan iOS berbasis Flutter)
- Status Proyek: ON PROGRESS (Masih dalam tahap pengembangan). Sebagian integrasi lintas repositori (terutama integrasi langsung Machine Learning ke Backend Go) masih berlangsung. Agen diharapkan tidak berasumsi bahwa seluruh integrasi sudah rampung.

---

## 2. Ekosistem Multi-Repository dan Batasan Lingkup (Scope Boundary)

Proyek PathFinder dibangun secara modular dan terbagi dalam 3 repositori mandiri pada lingkungan kerja:

```
+------------------------------------------------------------------------+
|                        PathFinder Ecosystem                            |
+-----------------------+-----------------------+------------------------+
| 1. Frontend (Repo Ini)| 2. Backend API        | 3. Machine Learning    |
|    [path_finder]      |    [path-finder-backend|    [pathfinder-ml]     |
+-----------------------+-----------------------+------------------------+
| - Flutter 3.x (Dart)  | - Golang (Go 1.27+)   | - Python 3.12+         |
| - Riverpod 3 + Gen    | - Fiber Framework v3  | - IndoBERT (NER)       |
| - go_router           | - GORM + PostgreSQL   | - multilingual-e5-small|
| - Dio HTTP Client     | - JWT Authentication  | - Cosine Matching &    |
| - Firebase Cloud Msg  | - FCM Push Service    |   Rule Readiness Score |
+-----------------------+-----------------------+------------------------+
```

> **Batasan Tanggung Jawab Agen (Scope Boundary):**
> - Agen yang bekerja di repositori ini hanya berfokus pada pengembangan aplikasi Flutter di folder `path_finder`.
> - Logika database, skema PostgreSQL, validasi backend, dan model NLP berada di repositori masing-masing.
> - Hindari mengubah file di repositori backend atau ML kecuali jika secara eksplisit diminta oleh pengguna.

---

## 3. Alur Kerja Inti dan Peran Pengguna (Core Workflow & Roles)

Sistem PathFinder mendukung 3 peran pengguna (roles) dengan alur interaksi sebagai berikut:

### 1. Mahasiswa (mahasiswa)
1. Registrasi dan Login: Mendaftar akun baru dan masuk ke aplikasi untuk memperoleh token sesi JWT.
2. Pengisian Cerita Diri (Wajib): Menuliskan narasi reflektif pengalaman kuliah dan eksplorasi mandiri (50-2000 karakter) di halaman StoryPage.
3. Kelengkapan Profil: Mengisi foto profil, tautan berkas CV, dan tautan portofolio (wajib dilengkapi sebelum dapat melamar lowongan magang).
4. Eksplorasi Katalog Lowongan: Menjelajahi lowongan magang aktif di DashboardPage berdasarkan kategori posisi, pencarian kata kunci, serta detail persyaratan teknis.
5. Pendaftaran Magang (Applications): Mengajukan lamaran ke lowongan mitra. Berlaku aturan: mahasiswa hanya boleh memiliki 1 lamaran aktif berstatus pending.
6. Pemantauan Seleksi dan Notifikasi: Menerima notifikasi status lamaran (accepted atau rejected) dari pihak mitra.

### 2. Mitra Industri / Perusahaan (mitra)
1. Pendaftaran dan Kelola Profil Perusahaan: Mengelola identitas perusahaan, deskripsi, lokasi, dan logo.
2. Pemasangan Lowongan Magang: Menambah lowongan baru dengan menentukan 8 kategori posisi resmi, kualifikasi required skills, tipe kerja (Remote/Onsite/Hybrid), dan deskripsi pekerjaan.
3. Manajemen Lowongan: Mengubah atau menutup lowongan yang sudah terisi.
4. Seleksi Kandidat Pelamar: Melihat daftar mahasiswa yang melamar lowongan, meninjau profil CV/portofolio, dan menentukan status kelulusan (accept atau reject).

### 3. Admin Program Studi (admin)
- Memantau rekapitulasi data mahasiswa dan analitik keterserapan magang prodi melalui dashboard admin.

---

## 4. Status Integrasi dan Penunjuk Dokumentasi Teknis (docs/)

Agar implementasi kode tetap terarah, akurat, dan selaras dengan backend yang sedang berjalan, seluruh dokumentasi teknis telah ditata secara modular di dalam folder `docs/`:

### Lokasi Spesifikasi Endpoint API
Seluruh detail teknis endpoint API backend Go riil (path URL, method, payload JSON request, format respons, query parameters, dan aturan validasi) terdokumentasi di:
- **docs/api/endpoints.md**

> **Catatan Sinkronisasi Endpoint:**
> - Dokumen `docs/api/endpoints.md` adalah rangkuman resmi yang diselaraskan dengan backend Go (`path-finder-backend`).
> - Fitur Rekomendasi ML (`/api/recommendations`): Saat ini belum disediakan oleh backend Go. Backend Go saat ini baru menyimpan cerita dengan status pending. Di aplikasi Flutter, jangan membuat ketergantungan keras yang menyebabkan aplikasi crash ketika endpoint rekomendasi belum aktif.

### Indeks Dokumentasi di Folder docs/
```
docs/
|-- api/
|   +-- endpoints.md        # Daftar endpoint riil, auth, contoh request/response
|-- guides/
|   |-- add-page.md         # Cara membuat halaman baru (lokasi file, router, pola UI)
|   |-- add-endpoint.md     # Cara menambah endpoint baru (DTO, remote source, repository, provider)
|   +-- running-backend.md  # Cara menjalankan backend Go dan PostgreSQL lokal
|-- architecture.md         # Alur data, struktur folder, Clean Architecture & Riverpod
+-- superpowers/            # Dokumentasi rencana dan spesifikasi superpowers (jangan diubah)
```

---

## 5. Struktur Arsitektur Frontend (lib/)

Aplikasi Flutter ini menerapkan arsitektur Feature-First + Clean Architecture:

```
lib/
|-- app/                  # Inisialisasi global aplikasi, rute, tema
|   |-- app.dart          # Konfigurasi MaterialApp.router
|   |-- router.dart       # Konfigurasi rute navigasi (go_router)
|   +-- theme.dart        # Theme Material 3, skema warna, dan tipografi
|-- core/                 # Modul bersama (independen, DILARANG mengimpor dari features/)
|   |-- config/           # Konfigurasi environment (Env.baseUrl, timeout)
|   |-- errors/           # AppException dan pemetaan kegagalan (ErrorMapper)
|   |-- network/          # Dio client setup, interceptor token auth dan logger
|   |-- notifications/    # Integrasi Firebase Cloud Messaging (FCM)
|   +-- widgets/          # Shared reusable widgets (loading, error, button, dialog)
+-- features/             # Modul fungsional berbasis fitur
    |-- auth/             # Login, register, forgot password, token session
    |-- splash/           # Layar pembuka aplikasi dan inisialisasi sesi
    |-- onboarding/       # Pengenalan fitur aplikasi awal
    |-- story/            # Form pengisian narasi cerita diri mahasiswa
    |-- recommendation/   # Tampilan hasil analisis dan status kalkulasi ML
    |-- dashboard/        # Katalog dan eksplorasi lowongan magang mahasiswa
    +-- company/          # Dashboard mitra, pasang lowongan, dan seleksi pelamar
```

Tiap folder fitur di dalam `features/` dipecah menjadi 3 lapisan independen:
- `domain/`: Entity murni dan interface abstract repository (bebas dependensi framework/UI/Dio).
- `data/`: Remote data source, implementasi repository, dan model DTO JSON.
- `presentation/`: Tampilan UI (pages/, widgets/) serta state management (providers/, controllers).

---

## 6. Konvensi dan Aturan Pengembangan untuk AI Coding Agent

1. State Management dan Code Generation:
   - Gunakan Riverpod 3 dengan anotasi resmi (`@riverpod`).
   - Setiap kali mengubah atau membuat provider/controller baru, jalankan build runner:
     ```bash
     dart run build_runner build --delete-conflicting-outputs
     ```
2. Pemisahan Tanggung Jawab (Separation of Concerns):
   - Widget UI dilarang memanggil Dio secara langsung. Widget hanya boleh mengamati (watch/listen) controller atau provider Riverpod.
   - Lapisan `core/` dilarang mengimpor file dari folder `features/`.
   - Antar-fitur dilarang saling mengimpor lapisan `data/` milik fitur lain. Pertukaran data dilakukan melalui model `domain/` atau provider bersama.
3. Navigasi Terpusat:
   - Gunakan `context.go` atau `context.push` via go_router yang didefinisikan secara terpusat di `lib/app/router.dart`.
4. Penanganan Error:
   - Tangkap semua DioException pada data source/repository dan petakan ke AppException melalui ErrorMapper.
   - Tampilkan pesan yang ramah pengguna berdasarkan `message` dari response backend.
5. Verifikasi Kualitas Kode:
   - Pastikan analisis statis kode bersih sebelum menandai tugas selesai:
     ```bash
     flutter analyze
     ```
   - Jalankan pengujian unit jika relevan:
     ```bash
     flutter test
     ```
