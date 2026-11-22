# Panduan Menambah Endpoint Baru (Add Endpoint)

Panduan praktis langkah demi langkah untuk mengintegrasikan endpoint REST API backend Go ke dalam arsitektur aplikasi mobile PathFinder.

---

## 1. Alur Menghubungkan Endpoint

Integrasi endpoint baru melibatkan penambahan kode pada 4 lapisan secara teratur:
1. `data/models/`: Serialisasi JSON (DTO).
2. `data/*_remote_source.dart`: Pemanggilan HTTP via Dio dan penanganan error.
3. `domain/`: Definisi Entity murni dan interface Abstract Repository.
4. `data/*_repository_impl.dart`: Implementasi repository dan konversi DTO ke Entity.
5. `presentation/providers/`: Riverpod Controller untuk konsumsi UI.

---

## 2. Langkah 1: Buat Model DTO (Data Transfer Object)

Buat model DTO di `lib/features/<fitur>/data/models/` untuk membaca respons JSON dari server backend.

Contoh: `lib/features/dashboard/data/models/application_dto.dart`

```dart
class ApplicationDto {
  const ApplicationDto({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final String company;
  final String status;
  final DateTime createdAt;

  factory ApplicationDto.fromJson(Map<String, dynamic> json) {
    return ApplicationDto(
      id: json['id'] as String? ?? '',
      jobId: json['job_id'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
```

---

## 3. Langkah 2: Tambahkan Method di Remote Data Source

Buka berkas remote data source pada fitur terkait (misalnya `lib/features/dashboard/data/application_remote_source.dart`):

```dart
import 'package:dio/dio.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/core/errors/error_mapper.dart';
import 'models/application_dto.dart';

class ApplicationRemoteSource {
  ApplicationRemoteSource(this._dio);

  final Dio _dio;

  Future<List<ApplicationDto>> getMyApplications() async {
    try {
      final response = await _dio.get('/api/mahasiswa/applications');
      final body = response.data as Map<String, dynamic>;

      if (body['success'] != true) {
        throw ServerException(
          message: body['message'] as String? ?? 'Gagal mengambil daftar lamaran',
          statusCode: response.statusCode,
        );
      }

      final list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((item) => ApplicationDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }
}
```

---

## 4. Langkah 3: Definisikan Entity dan Abstract Repository di Domain

### A. Entity Murni
Buat entitas bisnis di `lib/features/<fitur>/domain/entities/application.dart`:

```dart
class Application {
  const Application({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.status,
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final String company;
  final String status;
}
```

### B. Interface Abstract Repository
Buat kontrak di `lib/features/<fitur>/domain/repositories/application_repository.dart`:

```dart
import '../entities/application.dart';

abstract class ApplicationRepository {
  Future<List<Application>> getMyApplications();
}
```

---

## 5. Langkah 4: Implementasikan Repository

Buat atau perbarui berkas implementasi di `lib/features/<fitur>/data/application_repository_impl.dart`:

```dart
import '../domain/entities/application.dart';
import '../domain/repositories/application_repository.dart';
import 'application_remote_source.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  ApplicationRepositoryImpl(this._remoteSource);

  final ApplicationRemoteSource _remoteSource;

  @override
  Future<List<Application>> getMyApplications() async {
    final dtos = await _remoteSource.getMyApplications();
    return dtos.map((dto) => Application(
      id: dto.id,
      jobId: dto.jobId,
      jobTitle: dto.jobTitle,
      company: dto.company,
      status: dto.status,
    )).toList();
  }
}
```

---

## 6. Langkah 5: Buat Riverpod Controller dan Provider

Buat controller di `lib/features/<fitur>/presentation/providers/application_controller.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/application.dart';
import 'application_providers.dart';

part 'application_controller.g.dart';

@riverpod
class ApplicationController extends _$ApplicationController {
  @override
  FutureOr<List<Application>> build() async {
    return _fetch();
  }

  Future<List<Application>> _fetch() async {
    final repository = ref.read(applicationRepositoryProvider);
    return repository.getMyApplications();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }
}
```

---

## 7. Langkah 6: Jalankan Generator Kode

Jalankan build runner untuk menghasilkan file part `*.g.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 8. Langkah 7: Hubungkan ke Widget UI

Di file tampilan UI (`presentation/pages/` atau `presentation/widgets/`), baca state controller menggunakan `ref.watch`:

```dart
final applicationState = ref.watch(applicationControllerProvider);

return applicationState.when(
  data: (data) => ListView(...),
  loading: () => const LoadingView(),
  error: (err, _) => ErrorView(
    message: err.toString(),
    onRetry: () => ref.read(applicationControllerProvider.notifier).refresh(),
  ),
);
```
