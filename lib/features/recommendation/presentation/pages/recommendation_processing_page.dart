import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../widgets/ml_processing_view.dart';

/// Halaman layar penuh yang tampil selama model ML memproses narasi user.
///
/// Tombol Back dan tombol "Batalkan" sama-sama meminta konfirmasi terlebih
/// dahulu agar analisis tidak terhenti karena salah tekan.
class RecommendationProcessingPage extends StatelessWidget {
  const RecommendationProcessingPage({
    super.key,
    this.isCompleted = false,
    this.onCancel,
  });

  /// `true` saat backend sudah mengembalikan hasil.
  final bool isCompleted;

  /// Aksi setelah user mengonfirmasi pembatalan. Jika `null`, halaman
  /// kembali ke halaman sebelumnya atau ke `/story`.
  final VoidCallback? onCancel;

  Future<void> _confirmCancel(BuildContext context) async {
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

    if (confirmed != true || !context.mounted) return;

    if (onCancel != null) {
      onCancel!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutePaths.story);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isCompleted,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmCancel(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: MlProcessingView(
            isCompleted: isCompleted,
            onCancel: () => _confirmCancel(context),
          ),
        ),
      ),
    );
  }
}
