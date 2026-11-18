import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/recommendation.dart';
import 'recommendation_providers.dart';

part 'recommendation_controller.g.dart';

/// Mengelola satu siklus analisis rekomendasi.
///
/// `keepAlive` wajib: halaman memanggil controller lewat `ref.read` tanpa
/// listener. Tanpa ini provider di-dispose saat request masih berjalan dan
/// `state = await ...` akan melempar error "Ref after dispose".
@Riverpod(keepAlive: true)
class RecommendationController extends _$RecommendationController {
  /// Batas waktu tunggu total. Backend menghitung secara sinkron, jadi bila
  /// melewati batas ini server hampir pasti tidak merespons.
  static const Duration requestTimeout = Duration(seconds: 30);

  @override
  FutureOr<Recommendation?> build() => null;

  /// Menjalankan analisis baru.
  ///
  /// Melempar `AppException` bila gagal, sehingga UI bisa menampilkan pesan
  /// dari `ErrorMapper` dan tombol coba lagi.
  Future<Recommendation?> generate({String? storyId, int? topK}) async {
    state = const AsyncLoading();

    final repository = ref.read(recommendationRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository
          .generate(storyId: storyId, topK: topK)
          .timeout(
            requestTimeout,
            onTimeout: () => throw NetworkException(
              message:
                  'Analisis melebihi ${requestTimeout.inSeconds} detik. '
                  'Periksa koneksi ke backend lalu coba lagi.',
            ),
          );
    });

    if (state.hasError) {
      throw state.error!;
    }

    return state.value;
  }

  /// Mengambil hasil terakhir tanpa menghitung ulang.
  Future<Recommendation?> loadLatest() async {
    state = const AsyncLoading();

    final repository = ref.read(recommendationRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.latest().timeout(
            requestTimeout,
            onTimeout: () => throw NetworkException(
              message:
                  'Permintaan melebihi ${requestTimeout.inSeconds} detik. '
                  'Periksa koneksi ke backend lalu coba lagi.',
            ),
          );
    });

    if (state.hasError) {
      throw state.error!;
    }

    return state.value;
  }

  void reset() {
    state = const AsyncData(null);
  }
}
