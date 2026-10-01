# Panduan Menambah Halaman Baru (Contoh: Splash Screen)

Panduan ini mengikuti struktur projek **feature-first** dengan **Riverpod 3** (`flutter_riverpod` ^3.4.3, code generation) dan **go_router**. Semua nama file dan folder memakai bahasa Inggris dengan format `snake_case`.

---

## 1. Konsep Dasar

Setiap halaman baru = **satu fitur baru** di dalam `lib/features/`. Jangan menaruh halaman di `lib/` langsung atau di `core/`.

Lapisan yang dipakai tergantung kebutuhan halaman:

| Jenis halaman | Lapisan yang dibuat |
|---|---|
| Hanya tampilan (statis) | `presentation/` |
| Punya logika/state sendiri | `presentation/` + `providers/` |
| Mengambil data dari backend | `presentation/` + `domain/` + `data/` |

Splash screen termasuk jenis kedua: ia butuh sedikit logika (menunggu beberapa detik lalu pindah halaman), tapi tidak perlu `domain/` atau `data/`.

---

## 2. Checklist Umum (Berlaku untuk Halaman Apa Pun)

1. Buat folder fitur di `lib/features/<feature_name>/`.
2. Buat subfolder `presentation/pages/` dan `presentation/widgets/`.
3. Tulis halaman (`<feature_name>_page.dart`).
4. (Jika perlu) tulis provider/controller di `presentation/providers/`.
5. Daftarkan route di `lib/app/router.dart`.
6. Jalankan code generator jika memakai `@riverpod`.
7. Hubungkan navigasi dari/ke halaman lain.
8. Tulis test.
9. Jalankan `flutter analyze` dan coba di emulator.

---

## 3. Contoh Lengkap: Splash Screen

### 3.1 Target

- Menampilkan logo + nama aplikasi selama minimal 2 detik.
- Setelah itu pindah otomatis ke halaman `/story`.
- Jika ada pemeriksaan awal yang gagal (misalnya backend tidak bisa dihubungi), tampilkan pesan error dan tombol **Coba lagi**.

### 3.2 Struktur Folder

```
lib/features/splash/
└── presentation/
    ├── pages/
    │   └── splash_page.dart
    ├── providers/
    │   └── splash_providers.dart
    └── widgets/
        └── splash_logo.dart
```

Tambahkan juga aset logo:

```
assets/
└── images/
    └── logo.png
```

Daftarkan di `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

### 3.3 Langkah 1 — Buat Provider Inisialisasi

File: `lib/features/splash/presentation/providers/splash_providers.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_providers.g.dart';

/// Menjalankan pekerjaan awal aplikasi.
/// Selesai setelah SEMUA pekerjaan selesai, minimal 2 detik.
@riverpod
Future<void> splashInit(Ref ref) async {
  await Future.wait([
    Future<void>.delayed(const Duration(seconds: 2)), // durasi minimum splash
    // Opsional: cek backend Python, contoh:
    // ref.read(recommendationRemoteSourceProvider).checkHealth(),
  ]);
}
```

Catatan:
- `part 'splash_providers.g.dart';` wajib ada. File `.g.dart` dibuat otomatis oleh generator.
- Provider hasil codegen bersifat **auto-dispose** secara default. Untuk splash ini sudah sesuai, karena state-nya tidak perlu bertahan setelah halaman ditinggalkan.

### 3.4 Langkah 2 — Buat Widget Pendukung

File: `lib/features/splash/presentation/widgets/splash_logo.dart`

```dart
import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo.png', width: 120, height: 120),
        const SizedBox(height: 16),
        Text('Cari Bidang IT-mu', style: textTheme.headlineSmall),
      ],
    );
  }
}
```

Teks yang tampil di layar boleh berbahasa Indonesia. Aturan bahasa Inggris hanya berlaku untuk nama file, folder, dan identifier kode.

### 3.5 Langkah 3 — Buat Halaman

File: `lib/features/splash/presentation/pages/splash_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/splash_providers.dart';
import '../widgets/splash_logo.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch: menjalankan provider dan membangun ulang UI saat state berubah
    final init = ref.watch(splashInitProvider);

    // listen: untuk efek samping (navigasi), bukan untuk membangun UI
    ref.listen(splashInitProvider, (_, next) {
      if (next.hasValue && context.mounted) {
        context.go('/story');
      }
    });

    return Scaffold(
      body: Center(
        child: init.hasError
            ? _ErrorContent(onRetry: () => ref.invalidate(splashInitProvider))
            : const SplashLogo(),
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Gagal memulai aplikasi'),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ],
    );
  }
}
```

Penjelasan singkat:
- `ref.watch` dan `ref.listen` dipakai bersamaan. `watch` mengaktifkan provider, `listen` menangani perpindahan halaman.
- `context.go` mengganti seluruh stack, jadi user tidak bisa menekan tombol Back kembali ke splash. Jangan pakai `context.push` untuk splash.
- `ref.invalidate` memaksa provider dijalankan ulang untuk tombol **Coba lagi**.

### 3.6 Langkah 4 — Daftarkan Route

File: `lib/app/router.dart`

```dart
import 'package:go_router/go_router.dart';

import '../features/splash/presentation/pages/splash_page.dart';
import '../features/story/presentation/pages/story_page.dart';
import '../features/recommendation/presentation/pages/recommendation_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash', // halaman pertama yang dibuka
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: '/story', builder: (_, __) => const StoryPage()),
    GoRoute(path: '/recommendation', builder: (_, __) => const RecommendationPage()),
  ],
);
```

Perubahan pentingnya hanya dua: tambahkan route `/splash` dan ubah `initialLocation` menjadi `/splash`.

Jika router kamu dibuat sebagai provider, pola yang sama berlaku. Tambahkan route dan ubah `initialLocation` di tempat yang sama.

### 3.7 Langkah 5 — Jalankan Code Generator

```bash
dart run build_runner build --delete-conflicting-outputs
```

Atau mode pantau saat development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

Setelah ini file `splash_providers.g.dart` akan muncul. Jika `splashInitProvider` merah di editor, hampir pasti generator belum dijalankan.

### 3.8 Langkah 6 — Tes

File: `test/features/splash/splash_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:your_app/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets('splash navigates to /story after init', (tester) async {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/story', builder: (_, __) => const Text('story-page')),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('story-page'), findsOneWidget);
  });
}
```

Ganti `your_app` dengan nama package di `pubspec.yaml`.

---

## 4. Catatan: Splash Native vs Splash Flutter

Ada **dua** splash yang berbeda, dan keduanya sering tertukar:

| | Splash native | Splash Flutter (`SplashPage`) |
|---|---|---|
| Tampil saat | Engine Flutter sedang dimuat | Setelah Flutter siap |
| Dibuat dengan | Konfigurasi Android/iOS | Widget Flutter (panduan ini) |
| Bisa punya logika | Tidak | Ya |

Agar tidak ada layar putih sebelum `SplashPage` muncul, kamu bisa menyamakan keduanya dengan paket `flutter_native_splash`:

```bash
flutter pub add dev:flutter_native_splash
```

Tambahkan di `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#FFFFFF"
  image: assets/images/logo.png
```

Lalu jalankan:

```bash
dart run flutter_native_splash:create
```

Android 12 ke atas memakai Splash Screen API sistem, jadi tampilannya bisa sedikit berbeda dari versi Android lama (ikon di tengah dengan latar polos). Itu perilaku sistem, bukan kesalahan konfigurasi.

---

## 5. Template Singkat untuk Halaman Lain

Untuk halaman baru selain splash, pola yang sama bisa disalin:

```
lib/features/<feature_name>/
├── presentation/
│   ├── pages/<feature_name>_page.dart
│   ├── providers/<feature_name>_providers.dart   # jika ada state
│   └── widgets/
├── domain/                                        # jika ada aturan bisnis/entity
└── data/                                          # jika mengambil data dari backend
```

Urutan kerja yang disarankan:

1. Buat halaman kosong (`Scaffold` + teks).
2. Daftarkan route, pastikan bisa dibuka.
3. Tambahkan provider dan logika.
4. Pecah UI menjadi widget kecil di `widgets/`.
5. Tulis test.

---

## 6. Masalah Umum

| Masalah | Penyebab | Solusi |
|---|---|---|
| `splashInitProvider` tidak ditemukan | Generator belum dijalankan | Jalankan `build_runner` |
| Error `part ... was not found` | File `.g.dart` belum ada | Jalankan `build_runner` |
| Tombol Back kembali ke splash | Memakai `context.push` | Ganti dengan `context.go` |
| Muncul layar putih sebelum splash | Belum ada splash native | Pasang `flutter_native_splash` |
| Halaman pertama bukan splash | `initialLocation` belum diubah | Set ke `/splash` |
| Init yang memanggil API terulang sendiri | Retry otomatis Riverpod 3 | Atur `retry` di `ProviderScope`, atau matikan dengan `retry: (_, __) => null` |
