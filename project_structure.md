# Struktur Projek (Ringkas)

Aplikasi Flutter untuk rekomendasi bidang IT. User bercerita tentang dirinya, lalu aplikasi menampilkan rekomendasi bidang (DevOps, Backend, Frontend, dll).

- **State management:** Riverpod 3 (`flutter_riverpod` ^3.4.3, code generation)
- **Navigasi:** go_router
- **HTTP client:** Dio
- **Backend:** Python (NLP dan machine learning ada di sana, Flutter hanya mengambil data)
- **Pola:** feature-first, nama file dan folder bahasa Inggris, `snake_case`

---

## Pohon Folder

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
│
├── core/
│   ├── config/
│   │   └── env.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── network_providers.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── error_mapper.dart
│   └── widgets/
│       ├── loading_view.dart
│       └── error_view.dart
│
└── features/
    ├── splash/
    │   └── presentation/
    │       ├── pages/splash_page.dart
    │       ├── providers/splash_providers.dart
    │       └── widgets/splash_logo.dart
    │
    ├── story/
    │   └── presentation/
    │       ├── pages/story_page.dart
    │       └── widgets/story_input_field.dart
    │
    └── recommendation/
        ├── domain/
        │   ├── entities/field_recommendation.dart
        │   └── recommendation_repository.dart
        ├── data/
        │   ├── recommendation_remote_source.dart
        │   ├── recommendation_repository_impl.dart
        │   └── models/
        │       ├── analyze_request.dart
        │       └── recommendation_response.dart
        └── presentation/
            ├── providers/
            │   ├── recommendation_providers.dart
            │   └── recommendation_controller.dart
            ├── pages/recommendation_page.dart
            └── widgets/
                ├── field_card.dart
                └── score_bar.dart

test/
├── features/
│   ├── splash/
│   └── recommendation/
└── helpers/
```

---

## Penjelasan Tiap Bagian

### `main.dart`
Titik masuk aplikasi. Membungkus aplikasi dengan `ProviderScope` dan menjalankan `App`.

### `app/`
Pengaturan tingkat aplikasi.

| File | Fungsi |
|---|---|
| `app.dart` | `MaterialApp.router` |
| `router.dart` | Daftar route: `/splash` → `/story` → `/recommendation` |
| `theme.dart` | Warna, tipografi, gaya komponen |

### `core/`
Kode yang dipakai bersama oleh semua fitur. Tidak boleh bergantung pada folder `features/`.

| Folder | Fungsi |
|---|---|
| `config/` | Konfigurasi, misalnya `baseUrl` backend untuk dev dan prod |
| `network/` | Dio client dan provider-nya |
| `errors/` | Tipe error aplikasi dan pengubah `DioException` menjadi error yang mudah dipahami UI |
| `widgets/` | Widget umum seperti loading dan tampilan error |

### `features/splash/`
Layar pembuka. Menunggu beberapa detik (atau pemeriksaan awal), lalu pindah ke `/story`. Hanya punya lapisan `presentation`.

### `features/story/`
Fitur **"Ceritakan dirimu"**. Berisi form input cerita user. Tidak punya `data` atau `domain` karena tidak menyimpan apa pun. Saat tombol ditekan, ia memanggil controller milik fitur `recommendation`.

### `features/recommendation/`
Fitur **"Menampilkan rekomendasi bidang"**. Ini satu-satunya fitur yang berhubungan dengan backend.

| Lapisan | Isi | Tugas |
|---|---|---|
| `domain/` | `field_recommendation.dart`, `recommendation_repository.dart` | Model murni dan kontrak repository (abstract). Tidak tahu soal Dio atau JSON. |
| `data/` | remote source, repository impl, `models/` | Memanggil API Python, mengubah JSON menjadi entity. |
| `presentation/` | page, widgets, providers, controller | Tampilan dan state. Controller memanggil repository, UI hanya mengamati state. |

### `test/`
Mengikuti struktur `lib/features/`. Tes controller dan remote source lebih penting daripada tes tampilan.

---

## Alur Data

```
StoryPage
   │  user menekan tombol
   ▼
RecommendationController.analyze(story)
   │
   ▼
RecommendationRepository (abstract)
   │
   ▼
RecommendationRepositoryImpl
   │
   ▼
RecommendationRemoteSource ──► POST /analyze ──► Backend Python (NLP + ML)
   │
   ▼
RecommendationResponse (JSON) → FieldRecommendation (entity)
   │
   ▼
RecommendationPage menampilkan daftar FieldCard
```

---

## Aturan Penting

1. Halaman baru = folder baru di `features/`.
2. UI tidak boleh memanggil Dio langsung. Selalu lewat controller dan repository.
3. `core/` tidak boleh mengimpor dari `features/`.
4. Satu fitur tidak mengimpor `data/` milik fitur lain. Berbagi data lewat provider.
5. Navigasi memakai `context.go`. Khusus splash, jangan pakai `push` agar tombol Back tidak kembali ke splash.
6. Setelah mengubah file yang memakai `@riverpod`, jalankan:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```