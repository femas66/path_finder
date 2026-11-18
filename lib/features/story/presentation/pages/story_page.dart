import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/error_mapper.dart';
import '../providers/story_controller.dart';
import '../widgets/story_input_field.dart';

/// Form satu halaman untuk menuliskan cerita diri.
///
/// Halaman ini menjadi langkah pertama setelah pengguna mendaftar akun:
/// narasi yang diketik di sini dikirim ke backend untuk dianalisis NLP.
class StoryPage extends ConsumerStatefulWidget {
  const StoryPage({super.key});

  @override
  ConsumerState<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends ConsumerState<StoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _storyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutePaths.dashboard);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final story = await ref
          .read(storyControllerProvider.notifier)
          .submit(_storyController.text.trim());

      if (!mounted || story == null) return;

      // Backend sudah menerima cerita; lanjut ke layar analisis rekomendasi.
      // `story_id` dikirim eksplisit agar yang dianalisis pasti cerita ini.
      context.go(
        '${AppRoutePaths.recommendationProcessing}'
        '?story_id=${Uri.encodeQueryComponent(story.id)}',
      );
    } catch (error) {
      if (!mounted) return;

      final exception = ErrorMapper.fromObject(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(exception.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: _isSubmitting ? null : _goBack,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF0F172A),
          ),
          tooltip: 'Kembali',
        ),
        title: Text(
          'Cerita Diri',
          style: GoogleFonts.sen(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildGuideCard(),
            const SizedBox(height: 20),
            _buildFieldLabel(),
            StoryInputField(
              controller: _storyController,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => context.go(AppRoutePaths.dashboard),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                ),
                child: Text(
                  'Nanti saja',
                  style: GoogleFonts.sen(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2373F4), Color(0xFF5B9BFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2373F4).withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: const Color(0xFF2373F4).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'LANGKAH TERAKHIR',
            style: GoogleFonts.sen(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: const Color(0xFF2373F4),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ceritakan dirimu',
          style: GoogleFonts.sen(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.25,
            letterSpacing: -0.4,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tulis dengan bahasamu sendiri. AI kami akan membaca ceritamu untuk '
          'menemukan bidang IT dan lowongan yang paling cocok.',
          style: GoogleFonts.sen(
            fontSize: 13.5,
            height: 1.55,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agar hasilnya lebih akurat, ceritakan:',
            style: GoogleFonts.sen(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 12),
          _buildGuideItem(
            icon: Icons.favorite_border_rounded,
            text: 'Minat dan hal yang paling kamu sukai',
          ),
          _buildGuideItem(
            icon: Icons.psychology_outlined,
            text: 'Caramu menyelesaikan masalah sehari-hari',
          ),
          _buildGuideItem(
            icon: Icons.workspaces_outline,
            text: 'Pengalaman, proyek, atau kegiatan yang pernah diikuti',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required String text,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FA),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF2373F4)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: GoogleFonts.sen(
                  fontSize: 12.5,
                  height: 1.4,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            'Cerita kamu',
            style: GoogleFonts.sen(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32343E),
            ),
          ),
          Text(
            ' *',
            style: GoogleFonts.sen(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2373F4),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF9CBEF9),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Mengirim ceritamu...',
                    style: GoogleFonts.sen(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Analisis Ceritaku',
                    style: GoogleFonts.sen(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }
}
