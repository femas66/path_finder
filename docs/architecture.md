# Arsitektur Aplikasi — PathFinder Mobile

Dokumen ini menjelaskan arsitektur perangkat lunak, struktur folder, pola manajemen state, serta alur data (data flow) pada aplikasi mobile PathFinder (Flutter).

---

## 1. Pola Desain: Feature-First + Clean Architecture

Proyek ini memadukan pendekatan Feature-First (pengelompokan direktori berdasarkan fitur fungsional) dengan Clean Architecture (pemisahan tanggung jawab ke dalam lapisan presentation, domain, dan data).

```
lib/
|-- app/                  # Inisialisasi aplikasi, konfigurasi rute, tema global
|-- core/                 # Komponen dan modul bersama yang dipakai lintas fitur
+-- features/             # Modul-modul fungsional independen
    |-- auth/
    |-- story/
    |-- dashboard/
    |-- company/
    |-- recommendation/
    |-- onboarding/
    +-- splash/
```

### Aturan Ketergantungan (Dependency Rule)
1. Lapisan `core/` bersifat mandiri. File di dalam `core/` dilarang mengimpor file dari `features/`.
2. Antar-fitur dilarang saling mengimpor lapisan `data/`. Jika Fitur A membutuhkan data dari Fitur B, komunikasi dilakukan lewat entitas `domain/` atau provider Riverpod yang diekspos secara publik.
3. Lapisan `domain/` murni dari dependensi UI atau framework HTTP (bebas dari import `flutter/material.dart` atau `dio`).

---

## 2. Struktur Tiga Lapisan per Fitur

Setiap folder di dalam `lib/features/<nama_fitur>/` dibagi menjadi 3 lapisan:

```
features/<nama_fitur>/
|-- domain/               # Lapisan Bisnis Murni (Inward)
|   |-- entities/         # Objek bisnis murni tanpa serialisasi JSON
|   +-- repositories/     # Interface abstract repository
|-- data/                 # Lapisan Sumber Data (Outward)
|   |-- models/           # DTO (Data Transfer Object) dengan fromJson/toJson
|   |-- *_remote_source.dart # Klien HTTP (Dio)
|   +-- *_repository_impl.dart # Implementasi interface domain repository
+-- presentation/         # Lapisan Tampilan & Interaksi Pengguna
    |-- pages/            # Layar antarmuka utama (Scaffold)
    |-- widgets/          # Komponen UI spesifik fitur
    +-- providers/        # State management (Riverpod controllers & providers)
```

---

## 3. Alur Data (Data Flow)

Alur permintaan data dari aksi pengguna di UI hingga kembali menampilkan data:

```
[User Action di UI]
        |
        v
[Presentation: Widget / Page]
        | memanggil controller via ref.read(...)
        v
[Presentation: StateNotifier / AsyncNotifier Controller]
        | mengeksekusi operasi bisnis
        v
[Domain: Repository Interface] <-----------+
        |                                 | implementasi polimorfik
        v                                 |
[Data: Repository Implementation] --------+
        | memanggil data source dan memetakan model DTO ke domain entity
        v
[Data: Remote Data Source]
        | mengeksekusi HTTP request menggunakan Dio
        v
[Core: Network Client & Interceptor]
        | menambahkan Bearer token, logging, error interceptor
        v
[Backend API Server (Go Fiber)]
```

### Alur Respons Balik
1. Backend mengembalikan JSON berformat `WebResponse[T]`.
2. `DioClient` menerima respons dan melewatkannya ke Remote Data Source.
3. Remote Data Source mem-parsing JSON menjadi Model DTO (`*.fromJson`). Jika terjadi kegagalan HTTP, DioException dipetakan menjadi `AppException` via `ErrorMapper`.
4. Repository Implementation mengonversi Model DTO menjadi Domain Entity murni dan mengembalikannya ke Controller.
5. Controller memperbarui state (`AsyncValue.data`, `AsyncValue.error`, atau `AsyncValue.loading`).
6. UI Widget yang mengamati controller (`ref.watch`) secara reaktif merender perubahan tampilan.

---

## 4. Manajemen State (Riverpod 3 + Code Generation)

Proyek menggunakan Riverpod 3 dengan generator anotasi `@riverpod`:

1. Provider / Controller ditulis menggunakan class berbasis `_$NamaController`:
   ```dart
   @riverpod
   class JobController extends _$JobController {
     @override
     FutureOr<List<Job>> build() async {
       return ref.read(jobRepositoryProvider).getJobs();
     }
   }
   ```
2. Setiap pembuatan atau perubahan anotasi wajib diikuti eksekusi build runner:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. Akses state di widget UI dilakukan melalui `ConsumerWidget` atau `ConsumerStatefulWidget`:
   - `ref.watch(provider)`: untuk membaca nilai state dan mendengarkan perubahannya secara reaktif.
   - `ref.read(provider.notifier)`: untuk memanggil method aksi pada controller.

---

## 5. Manajemen Error dan Exception Terpusat

Seluruh kegagalan sistem distandarisasi di `lib/core/errors/`:

- `AppException`: Base class abstract untuk seluruh error aplikasi.
  - `NetworkException`: Masalah koneksi internet, timeout, atau host tidak terjangkau.
  - `ServerException`: Respons error dari server (4xx, 5xx) dengan pesan dari server (`message`).
  - `UnauthorizedException`: Sesi login berakhir atau token JWT tidak valid (401).
  - `ValidationException`: Input formulir tidak memenuhi aturan validasi.
- `ErrorMapper`: Kelas utilitas yang mengubah `DioException` atau objek error generik menjadi turunan `AppException` yang siap disajikan ke pengguna.

---

## 6. Konfigurasi Jaringan (Network)

Klien HTTP dikelola di `lib/core/network/`:
- `Env.baseUrl` di `lib/core/config/env.dart` mendeteksi platform runtime:
  - Android Emulator: `http://10.0.2.2:3000`
  - iOS Simulator / Desktop: `http://127.0.0.1:3000`
  - Perangkat Fisik: Menggunakan nilai dari `--dart-define=BASE_URL=...`
- `createDioClient`: Menyetel header global (`application/json`), durasi timeout (15 detik), `LogInterceptor`, dan `AuthInterceptor` untuk otomatis menyematkan header `Authorization: Bearer <token>` dari secure storage.

---

## 7. Layanan Notifikasi (FCM)

Layanan push notification dikelola di `lib/core/notifications/`:
- `FcmService`: Menangani inisialisasi Firebase Messaging, perizinan notifikasi OS, registrasi background handler, serta listener saat notifikasi ditekan.
- Token FCM yang diperoleh dari perangkat dikirimkan ke backend melalui `PATCH /api/users/fcm-token` agar backend dapat mengirimkan pembaruan status lamaran secara real-time.
