# Design Document: Halaman Khusus Role Perusahaan (Portal Lowongan & Daftar Kandidat)

- **Tanggal**: 2026-10-26
- **Branch**: `feature/company-portal`
- **Status**: Approved by User

---

## 1. Ringkasan & Tujuan Fitur

Fitur ini menyediakan antarmuka khusus untuk pengguna dengan role **Perusahaan** pada aplikasi PathFinder. Perusahaan dapat mempublikasikan lowongan magang/pekerjaan dengan form terstruktur dan meninjau daftar kandidat/pelamar yang melamar pada lowongan tersebut.

Sesuai permintaan:
- **Style Kode**: Terstruktur dan modular seperti [`login_page.dart`](file:///Users/femasakbarfathurohim/Coolyeah/PBL/path_finder/lib/features/auth/presentation/pages/login_page.dart) & [`login_form.dart`](file:///Users/femasakbarfathurohim/Coolyeah/PBL/path_finder/lib/features/auth/presentation/widgets/login_form.dart) (pemisahan form ke widget mandiri, validasi ketat, controller management).
- **UI/UX**: Selaras dengan [`dashboard_page.dart`](file:///Users/femasakbarfathurohim/Coolyeah/PBL/path_finder/lib/features/dashboard/presentation/pages/dashboard_page.dart) (latar `#F8FAFC`, aksen `#2373F4`, font `GoogleFonts.sen`, card border `#E2E8F0`, filter chips, status badge).
- **Integritas Aplikasi**: Halaman lain tidak dimodifikasi. Halaman diakses melalui rute `/company-dashboard` di mana tester/pengembang dapat menguji dengan mengubah `initialLocation` di `lib/app/router.dart` secara mandiri.
- **Git Branch**: Seluruh pekerjaan dikembangkan dan di-commit pada branch khusus `feature/company-portal`.

---

## 2. Struktur Modul & Berkas

Seluruh implementasi ditempatkan dalam direktori fitur baru `lib/features/company/`:

```
lib/features/company/
├── domain/
│   └── models/
│       ├── job_posting.dart
│       └── candidate_application.dart
├── data/
│   └── company_mock_data.dart
└── presentation/
    ├── pages/
    │   └── company_dashboard_page.dart
    └── widgets/
        ├── company_app_bar.dart
        ├── company_bottom_navbar.dart
        ├── cards/
        │   ├── company_job_card.dart
        │   └── candidate_card.dart
        ├── forms/
        │   └── post_job_form.dart
        └── tabs/
            ├── company_home_tab.dart
            ├── post_job_tab.dart
            ├── candidates_tab.dart
            └── company_profile_tab.dart
```

---

## 3. Spesifikasi Data Model

### A. `JobPosting` (`job_posting.dart`)
- `String id`: ID unik lowongan
- `String title`: Judul posisi (misal: *Mobile Developer Intern*)
- `String field`: Bidang / departemen (misal: *Software Engineering / IT*)
- `int quota`: Kuota anak magang (misal: *3 orang*)
- `String executionPeriod`: Periode tanggal pelaksanaan (misal: *1 Januari 2027 s.d. 31 Juli 2027*)
- `String description`: Deskripsi lowongan & lingkup pekerjaan
- `String facilities`: Fasilitas yang disediakan (misal: *Uang saku bulanan, sertifikat resmi, mentor 1-on-1, akses fasilitas lab*)
- `String requiredSkills`: Keahlian yang dibutuhkan (misal: *Flutter, Dart, REST API, Git*)
- `String companyName`: Nama perusahaan (default: *PT Inovasi Teknologi Nusantara*)
- `String location`: Lokasi kerja (misal: *Bandung / Hybrid*)
- `int applicantsCount`: Jumlah pelamar saat ini
- `bool isActive`: Status lowongan aktif / ditutup
- `DateTime createdAt`: Waktu lowongan dibuat

### B. `CandidateApplication` (`candidate_application.dart`)
- `String id`: ID lamaran
- `String candidateName`: Nama pelamar (misal: *Aditya Pratama*)
- `String university`: Asal perguruan tinggi
- `String major`: Program studi & semester
- `String jobTitle`: Posisi yang dilamar
- `String appliedDate`: Tanggal melamar
- `int matchScore`: AI Match score persentase (misal: *94%*)
- `String status`: Status tahapan (`Menunggu Review`, `Seleksi Berkas`, `Wawancara`, `Diterima`, `Ditolak`)
- `String note`: Catatan evaluasi tim HR

---

## 4. Rincian Antarmuka & Interaksi Tiap Tab

### Tab 1: Ringkasan / Lowongan Saya (`CompanyHomeTab`)
- **Header**: Nama PT, ucapan selamat datang, tombol notifikasi.
- **Kartu Statistik Ringkas**:
  - Total Lowongan Aktif
  - Total Kandidat Masuk
  - Kandidat Tahap Wawancara
- **Quick Action**: Tombol cepat untuk langsung beralih ke form posting lowongan.
- **Daftar Lowongan Aktif**: Menggunakan `CompanyJobCard` yang menampilkan judul, bidang, kuota, periode pelaksanaan, dan jumlah pelamar.

### Tab 2: Formulir Posting Lowongan (`PostJobTab` & `PostJobForm`)
- Mengikuti arsitektur [`login_form.dart`](file:///Users/femasakbarfathurohim/Coolyeah/PBL/path_finder/lib/features/auth/presentation/widgets/login_form.dart):
  - Field label dengan font `GoogleFonts.sen` ukuran 13 dan warna `#32343E`.
  - Input field dengan background `#F0F5FA`, border halus, dan padding 14-16px.
  - Validasi form mencegah input kosong/tidak valid.
- **Rincian Field**:
  1. *Judul Posisi* (`TextFormField`)
  2. *Bidang / Bidang Kerja* (`TextFormField`)
  3. *Kuota Anak Magang* (`TextFormField` dengan `TextInputType.number`)
  4. *Tanggal Pelaksanaan* (`TextFormField` atau Date Range helper, default format contoh: *1 Januari 2027 s.d. 31 Juli 2027*)
  5. *Deskripsi Pekerjaan* (`TextFormField` multiline, min 3 baris)
  6. *Fasilitas yang Disediakan* (`TextFormField` multiline, contoh: laptop, uang saku, sertifikat)
  7. *Keahlian yang Dibutuhkan* (`TextFormField` multiline, contoh: Flutter, State Management, API)
- **Tombol Submit**:
  - Tombol primer biru (`#2373F4`) berukuran penuh dengan efek loading.
  - Feedback `SnackBar` sukses berwarna hijau/biru.
  - Data langsung ditambahkan ke state aktif dan form di-reset.

### Tab 3: Daftar Kandidat (`CandidatesTab`)
- **Filter Chips Horizontal**:
  - `Semua`, `Menunggu Review`, `Seleksi Berkas`, `Wawancara`, `Diterima`, `Ditolak`.
- **Kartu Kandidat (`CandidateCard`)**:
  - Nama pelamar, kampus, jurusan.
  - Badge AI Matching Score (`94% Match`).
  - Badge status saat ini dengan warna semantik:
    - Menunggu Review: Abu-abu / Slate
    - Seleksi Berkas: Biru `#2373F4`
    - Wawancara: Oranye `#F59E0B`
    - Diterima: Hijau `#10B981`
    - Ditolak: Merah `#EF4444`
  - Tombol aksi *"Ubah Status"* yang membuka bottom sheet pilihan status baru. Saat dipilih, status kandidat langsung terupdate.

### Tab 4: Profil Perusahaan (`CompanyProfileTab`)
- Header profil perusahaan: Avatar/Logo PT, nama industri, alamat kantor.
- Menu informasi perusahaan: Deskripsi PT, Kontak HR, Dokumen Legalitas / Kerjasama Magang, Pengaturan Akun.
- Tombol *"Keluar dari Akun"* (merah lembut ala profile dashboard mahasiswa).

---

## 5. Rute Navigasi (`lib/app/router.dart`)

- Menambahkan konstanta:
  ```dart
  static const String companyDashboard = '/company-dashboard';
  ```
- Menambahkan route handler:
  ```dart
  GoRoute(
    path: AppRoutePaths.companyDashboard,
    builder: (context, state) => const CompanyDashboardPage(),
  ),
  ```
- **Catatan Penting**: `initialLocation` tetap dipertahankan pada nilai aslinya (`AppRoutePaths.splash`) dan tidak ada route lain yang diubah, sehingga pengguna/tester dapat menguji secara manual dengan mengubah `initialLocation` menjadi `AppRoutePaths.companyDashboard`.

---

## 6. Rencana Pengujian (Testing Strategy)

1. **Unit/Widget Test**:
   - `test/features/company/post_job_form_test.dart`:
     - Verifikasi validasi input kosong pada form.
     - Verifikasi pengisian seluruh field (judul, bidang, kuota, tanggal, deskripsi, fasilitas, keahlian) dan pemanggilan callback onSaved.
   - `test/features/company/company_dashboard_page_test.dart`:
     - Verifikasi navigasi 4 tab berfungsi dengan benar.
     - Verifikasi pemfilteran kandidat berdasarkan status chip.
2. **Static Analysis**:
   - `flutter analyze` memastikan 0 issue dan 0 warning.
