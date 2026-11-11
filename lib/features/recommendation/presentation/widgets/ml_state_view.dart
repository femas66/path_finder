import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/error_view.dart';
import 'ml_processing_view.dart';

/// Memetakan state analisis ML (`AsyncValue`) ke tampilan yang sesuai:
///
/// - loading  -> [MlProcessingView]
/// - error    -> [ErrorView] dengan pesan dari [ErrorMapper] + tombol coba lagi
/// - data     -> [dataBuilder]
///
/// Contoh pemakaian dengan controller rekomendasi:
/// ```dart
/// final state = ref.watch(recommendationControllerProvider);
/// return MlStateView(
///   state: state,
///   onRetry: () => ref.read(recommendationControllerProvider.notifier).retry(),
///   dataBuilder: (context, result) => RecommendationList(result),
/// );
/// ```
class MlStateView<T> extends StatelessWidget {
  const MlStateView({
    super.key,
    required this.state,
    required this.dataBuilder,
    this.onRetry,
    this.onCancel,
    this.loadingView,
  });

  final AsyncValue<T> state;
  final Widget Function(BuildContext context, T data) dataBuilder;

  /// Dipanggil dari tombol "Coba Lagi" saat analisis gagal.
  final VoidCallback? onRetry;

  /// Diteruskan ke tombol "Batalkan" pada tampilan loading.
  final VoidCallback? onCancel;

  /// Ganti tampilan loading default jika butuh teks/tahap berbeda.
  final Widget? loadingView;

  @override
  Widget build(BuildContext context) {
    // Saat refresh/retry, tetap tampilkan loading ML (bukan hasil/error lama).
    if (state.isLoading) {
      return loadingView ?? MlProcessingView(onCancel: onCancel);
    }

    if (state.hasError) {
      final exception = ErrorMapper.fromObject(state.error!, state.stackTrace);
      return ErrorView(
        message: exception.message,
        icon: _iconFor(exception),
        onRetry: onRetry,
      );
    }

    if (state.hasValue) {
      return dataBuilder(context, state.requireValue);
    }

    return loadingView ?? MlProcessingView(onCancel: onCancel);
  }

  IconData _iconFor(AppException exception) => switch (exception) {
        NetworkException() => Icons.wifi_off_rounded,
        ServerException() => Icons.cloud_off_rounded,
        ValidationException() => Icons.edit_note_rounded,
        _ => Icons.error_outline_rounded,
      };
}
