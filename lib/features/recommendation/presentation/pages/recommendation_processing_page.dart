import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/recommendation_controller.dart';
import '../widgets/ml_processing_view.dart';

/// Halaman layar penuh yang tampil selama backend menganalisis narasi user.
///
/// Halaman ini memicu `POST /recommendations` sekali saat dibuka, lalu:
/// - menampilkan [MlProcessingView] selama request berjalan,
/// - pindah ke halaman hasil setelah response diterima,
/// - menampilkan pesan error + tombol "Coba Lagi" bila gagal (tidak pernah
///   menunggu tanpa batas seperti versi animasi sebelumnya).
///
/// Tombol Back dan tombol "Batalkan" sama-sama meminta konfirmasi lebih dulu.
class RecommendationProcessingPage extends ConsumerStatefulWidget {
  const RecommendationProcessingPage({
    super.key,
    this.storyId,
    this.topK,
  });

  /// Cerita yang akan dianalisis. `null` berarti cerita terakhir pengguna.
  final String? storyId;

  /// Jumlah rekomendasi yang diminta. `null` berarti default server (3).
  final int? topK;

  @override
  ConsumerState<RecommendationProcessingPage> createState() =>
      _RecommendationProcessingPageState();
}

class _RecommendationProcessingPageState
    extends ConsumerState<RecommendationProcessingPage> {
  @override
  void initState() {
    super.initState();
    // Dijalankan setelah frame pertama agar `ref` sudah siap dan UI sempat
    // menampilkan indikator loading.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted) return;

    try {
      await ref
          .read(recommendationControllerProvider.notifier)
          .generate(storyId: widget.storyId, topK: widget.topK);
    } catch (_) {
      // Kegagalan sudah tersimpan pada state controller; UI menampilkannya
      // lewat ErrorView di bawah.
      return;
    }

    if (!mounted) return;
    context.go(AppRoutePaths.recommendation);
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan analisis?'),
        content: const Text(
          'Proses analisis ceritamu akan dihentikan dan kamu perlu '
          'mengirim ulang ceritamu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Lanjut Menunggu'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    ref.read(recommendationControllerProvider.notifier).reset();

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutePaths.story);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationControllerProvider);
    final isCompleted = state.hasValue && state.value != null;
    final hasError = state.hasError;

    return PopScope(
      canPop: isCompleted || hasError,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmCancel();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: hasError ? _buildError(state.error!) : _buildProcessing(isCompleted),
        ),
      ),
    );
  }

  Widget _buildProcessing(bool isCompleted) {
    return MlProcessingView(
      isCompleted: isCompleted,
      onCancel: _confirmCancel,
    );
  }

  Widget _buildError(Object error) {
    final exception = ErrorMapper.fromObject(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ErrorView(
              message: exception.message,
              icon: _iconFor(exception),
              onRetry: _start,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutePaths.story),
              child: const Text('Ubah cerita'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(AppException exception) => switch (exception) {
        NetworkException() => Icons.wifi_off_rounded,
        ServerException() => Icons.cloud_off_rounded,
        ValidationException() => Icons.edit_note_rounded,
        _ => Icons.error_outline_rounded,
      };
}
