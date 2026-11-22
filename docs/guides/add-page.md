# Panduan Membuat Halaman Baru (Add Page)

Panduan praktis langkah demi langkah untuk menambahkan layar/halaman antarmuka baru pada aplikasi mobile PathFinder sesuai konvensi Feature-First dan Clean Architecture.

---

## 1. Lokasi Berkas

Halaman antarmuka ditempatkan di dalam folder `presentation/pages/` pada fitur terkait:

```
lib/features/<nama_fitur>/presentation/pages/<nama_halaman>_page.dart
```

Contoh:
- Halaman riwayat lamaran mahasiswa: `lib/features/dashboard/presentation/pages/application_history_page.dart`
- Halaman kelola profil mitra: `lib/features/company/presentation/pages/company_profile_page.dart`

Jika membuat fitur baru yang belum ada di `lib/features/`, buat struktur folder standar terlebih dahulu:
```
lib/features/<nama_fitur>/
|-- domain/
|-- data/
+-- presentation/
    |-- pages/
    |-- widgets/
    +-- providers/
```

---

## 2. Struktur Kode Halaman Baru

Gunakan `ConsumerWidget` jika halaman hanya mengamati state, atau `ConsumerStatefulWidget` jika halaman membutuhkan lifecycle lokal (misalnya `TextEditingController` atau `AnimationController`).

Contoh implementasi `lib/features/dashboard/presentation/pages/application_history_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_finder/core/widgets/error_view.dart';
import 'package:path_finder/core/widgets/loading_view.dart';
import '../providers/application_controller.dart';

class ApplicationHistoryPage extends ConsumerWidget {
  const ApplicationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationState = ref.watch(applicationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Lamaran'),
      ),
      body: applicationState.when(
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(
              child: Text('Belum ada lamaran yang diajukan.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final app = applications[index];
              return ListTile(
                title: Text(app.jobTitle),
                subtitle: Text(app.company),
                trailing: Chip(label: Text(app.status)),
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(applicationControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }
}
```

---

## 3. Daftarkan Rute di Router Global

Seluruh rute navigasi dikelola secara terpusat di `lib/app/router.dart` menggunakan pustaka `go_router`.

### Langkah A: Tambahkan Konstanta Path
Buka `lib/app/router.dart` dan tambahkan nama rute ke dalam class `AppRoutePaths`:

```dart
class AppRoutePaths {
  // Rute yang sudah ada...
  static const String applicationHistory = '/applications';
}
```

### Langkah B: Daftarkan GoRoute
Tambahkan rute ke dalam `routes` pada konfigurasi `GoRouter`:

```dart
GoRoute(
  path: AppRoutePaths.applicationHistory,
  builder: (context, state) => const ApplicationHistoryPage(),
),
```

### Langkah C: Tambahkan Proteksi Autentikasi (Jika Diperlukan)
Jika halaman tersebut membutuhkan login pengguna, pastikan path terdaftar pada kondisi pengalihan (redirect guard) di `lib/app/router.dart`:

```dart
final isLoggedIn = authState.valueOrNull != null;
final isAuthRoute = location == AppRoutePaths.login || location == AppRoutePaths.register;

if (!isLoggedIn && !isAuthRoute) {
  return AppRoutePaths.login;
}
```

---

## 4. Cara Navigasi ke Halaman Baru

Gunakan ekstensi navigasi dari `go_router`:

```dart
import 'package:go_router/go_router.dart';
import 'package:path_finder/app/router.dart';

// Berpindah dan mengganti rute saat ini:
context.go(AppRoutePaths.applicationHistory);

// Menumpuk rute di atas layar saat ini (push):
context.push(AppRoutePaths.applicationHistory);

// Navigasi dengan membawa parameter path atau query:
context.push('${AppRoutePaths.jobDetail}/$jobId');
```

---

## 5. Checklist Verifikasi Halaman Baru

- Halaman diletakkan di `lib/features/<fitur>/presentation/pages/`.
- Menggunakan widget shared dari `lib/core/widgets/` untuk loading (`LoadingView`) dan error (`ErrorView`).
- Didaftarkan di `AppRoutePaths` dan `GoRouter` di `lib/app/router.dart`.
- Tidak ada panggilan `Dio` langsung di dalam file widget.
- Jalankan analisis statis untuk memastikan kode bersih:
  ```bash
  flutter analyze
  ```
