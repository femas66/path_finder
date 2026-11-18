import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/recommendation.dart';
import '../providers/recommendation_controller.dart';
import '../widgets/ml_processing_view.dart';

const Color _primary = Color(0xFF2373F4);
const Color _success = Color(0xFF10B981);
const Color _warning = Color(0xFFF59E0B);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _surface = Colors.white;

/// Halaman hasil analisis: daftar lowongan magang paling cocok.
class RecommendationPage extends ConsumerStatefulWidget {
  const RecommendationPage({super.key});

  @override
  ConsumerState<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends ConsumerState<RecommendationPage> {
  /// Mencegah percobaan pemulihan berulang saat build berikutnya.
  bool _restoreAttempted = false;

  /// `true` selama mengambil hasil lama. Dipakai agar indikator yang tampil
  /// adalah spinner biasa, bukan animasi "sedang menganalisis" — pada tahap
  /// ini tidak ada analisis baru yang berjalan.
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreIfNeeded());
  }

  /// Halaman bisa dibuka langsung tanpa lewat layar pemrosesan (mis. setelah
  /// aplikasi dibuka ulang). Dalam kondisi itu hasil terakhir diambil dari
  /// backend; bila memang belum pernah ada, tampilkan ajakan memulai.
  Future<void> _restoreIfNeeded() async {
    if (_restoreAttempted || !mounted) return;
    _restoreAttempted = true;

    final state = ref.read(recommendationControllerProvider);
    if (state.hasValue && state.value != null) return;

    setState(() => _isRestoring = true);

    try {
      await ref
          .read(recommendationControllerProvider.notifier)
          .loadLatest();
    } on NotFoundException {
      // Belum pernah ada rekomendasi: bukan error, cukup tampilkan ajakan.
      ref.read(recommendationControllerProvider.notifier).reset();
    } catch (_) {
      // Error lain ditampilkan oleh ErrorView di bawah.
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _reanalyze() async {
    final current = ref.read(recommendationControllerProvider).value;
    try {
      await ref.read(recommendationControllerProvider.notifier).generate(
            storyId: current?.storyId,
          );
    } catch (_) {
      return;
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Rekomendasi untukmu',
          style: TextStyle(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Analisis ulang',
            onPressed: state.isLoading ? null : _reanalyze,
            icon: const Icon(Icons.refresh_rounded, color: _textMuted),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(state)),
    );
  }

  Widget _buildBody(AsyncValue<Recommendation?> state) {
    if (_isRestoring) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isLoading) {
      return const MlProcessingView(onCancel: null);
    }

    if (state.hasError) {
      final exception = ErrorMapper.fromObject(state.error!);
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ErrorView(
                message: exception.message,
                icon: _iconFor(exception),
                onRetry: _reanalyze,
              ),
              TextButton(
                onPressed: () => context.go(AppRoutePaths.story),
                child: const Text('Perbaiki cerita'),
              ),
            ],
          ),
        ),
      );
    }

    final recommendation = state.value;
    if (recommendation == null) {
      return _EmptyRecommendation(onStart: () => context.go(AppRoutePaths.story));
    }

    return RefreshIndicator(
      onRefresh: _reanalyze,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _ProfileSummary(recommendation: recommendation),
          const SizedBox(height: 20),
          if (recommendation.isProfileIncomplete)
            _IncompleteProfileCard(
              onFixStory: () => context.go(AppRoutePaths.story),
            )
          else if (recommendation.isEmpty)
            _EmptyRecommendation(
              onStart: () => context.go(AppRoutePaths.story),
            )
          else
            ...recommendation.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _RecommendationCard(item: item),
              ),
            ),
          if (recommendation.items.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Skor kecocokan dihitung dari keahlian yang kamu sebutkan '
              'dibandingkan syarat setiap lowongan.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: _textMuted,
              ),
            ),
          ],
        ],
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

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.recommendation});

  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final profile = recommendation.profile;
    final skills = [...profile.hardSkills, ...profile.softSkills];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  skills.isEmpty
                      ? 'Belum ada keahlian yang dikenali'
                      : '${skills.length} keahlian dikenali dari ceritamu',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (skill) => _Chip(
                      label: skill,
                      background: _primary.withValues(alpha: 0.08),
                      foreground: _primary,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _IncompleteProfileCard extends StatelessWidget {
  const _IncompleteProfileCard({required this.onFixStory});

  final VoidCallback onFixStory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  size: 20, color: _warning),
              const SizedBox(width: 8),
              Text(
                'Ceritamu belum menyebut keahlian',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Sebutkan bahasa pemrograman, alat, atau bidang yang kamu kuasai — '
            'misalnya "saya memakai Go dan PostgreSQL" atau '
            '"saya mendesain antarmuka dengan Figma".',
            style: TextStyle(fontSize: 13, height: 1.6, color: _textMuted),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onFixStory,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Perbaiki cerita'),
            style: FilledButton.styleFrom(
              backgroundColor: _warning,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecommendation extends StatelessWidget {
  const _EmptyRecommendation({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          const Icon(Icons.psychology_alt_rounded, size: 44, color: _primary),
          const SizedBox(height: 14),
          const Text(
            'Belum ada rekomendasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ceritakan dirimu dulu, lalu kami carikan magang yang paling cocok.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, height: 1.6, color: _textMuted),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(backgroundColor: _primary),
            child: const Text('Tulis cerita diri'),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.item});

  final RecommendationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.rank != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#${item.rank}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: _textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (item.company.isNotEmpty) item.company,
                        if (item.location.isNotEmpty) item.location,
                        if (item.workType.isNotEmpty) item.workType,
                      ].join(' • '),
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ScoreBadge(score: item.matchingScore),
            ],
          ),
          if (item.matchedSkills.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.matchedSkills
                  .map(
                    (skill) => _Chip(
                      label: skill,
                      background: _success.withValues(alpha: 0.1),
                      foreground: _success,
                      icon: Icons.check_rounded,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if (item.missingSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Perlu dipelajari',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.missingSkills
                  .map(
                    (skill) => _Chip(
                      label: skill,
                      background: const Color(0xFFF1F5F9),
                      foreground: _textMuted,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if (item.readinessScore != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.trending_up_rounded,
                    size: 15, color: _textMuted),
                const SizedBox(width: 6),
                Text(
                  'Kesiapan kerja ${item.readinessScore}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({this.score});

  final int? score;

  @override
  Widget build(BuildContext context) {
    final value = score;
    final color = value == null
        ? _textMuted
        : value >= 70
            ? _success
            : value >= 40
                ? _primary
                : _warning;

    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value == null ? '—' : '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            'cocok',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
