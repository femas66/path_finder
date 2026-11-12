import 'dart:async';

import 'package:flutter/material.dart';

import 'ml_processing_stage.dart';

const Color _primary = Color(0xFF2373F4);
const Color _primaryLight = Color(0xFF5B9BFF);
const Color _success = Color(0xFF10B981);
const Color _textDark = Color(0xFF0F172A);
const Color _textBody = Color(0xFF334155);
const Color _textMuted = Color(0xFF64748B);
const Color _textDisabled = Color(0xFF94A3B8);
const Color _border = Color(0xFFE2E8F0);
const Color _surfaceTint = Color(0xFFF0F5FA);

/// Komponen loading khusus saat model ML sedang memproses narasi user.
///
/// Menampilkan animasi, daftar tahap pemrosesan yang maju berdasarkan waktu,
/// progress bar, tips yang berganti, peringatan jika proses lebih lama
/// dari biasanya, dan tombol batal (opsional).
///
/// Tahap terakhir tidak pernah ditandai selesai sampai [isCompleted] bernilai
/// `true`, sehingga UI tidak pernah "mendahului" backend.
class MlProcessingView extends StatefulWidget {
  const MlProcessingView({
    super.key,
    this.title = 'Menganalisis ceritamu',
    this.subtitle =
        'Model kami sedang membaca narasimu untuk menemukan bidang IT '
        'yang paling cocok.',
    this.stages = defaultMlProcessingStages,
    this.tips = defaultMlProcessingTips,
    this.stageInterval = const Duration(milliseconds: 2500),
    this.tipInterval = const Duration(seconds: 5),
    this.slowThreshold = const Duration(seconds: 12),
    this.isCompleted = false,
    this.onCancel,
  });

  final String title;
  final String subtitle;
  final List<MlProcessingStage> stages;
  final List<String> tips;

  /// Jeda sebelum tahap berikutnya ditampilkan sebagai aktif.
  final Duration stageInterval;

  /// Jeda pergantian tips.
  final Duration tipInterval;

  /// Setelah durasi ini, tampilkan pesan bahwa proses lebih lama dari biasanya.
  final Duration slowThreshold;

  /// `true` saat backend sudah mengembalikan hasil: semua tahap ditandai selesai.
  final bool isCompleted;

  /// Dipanggil saat user menekan tombol "Batalkan". Tombol disembunyikan jika `null`.
  final VoidCallback? onCancel;

  @override
  State<MlProcessingView> createState() => _MlProcessingViewState();
}

class _MlProcessingViewState extends State<MlProcessingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _stageTimer;
  Timer? _tipTimer;
  Timer? _slowTimer;

  int _activeIndex = 0;
  int _tipIndex = 0;
  bool _isSlow = false;
  bool _reduceMotion = false;

  int get _lastIndex =>
      widget.stages.isEmpty ? 0 : widget.stages.length - 1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _startProcessingTimers();
    _startTipTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant MlProcessingView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCompleted && !oldWidget.isCompleted) {
      _stopProcessingTimers();
      _isSlow = false;
    } else if (!widget.isCompleted && oldWidget.isCompleted) {
      // Dipakai ulang untuk analisis baru (misalnya setelah "Coba Lagi").
      _activeIndex = 0;
      _isSlow = false;
      _startProcessingTimers();
    }

    if (_activeIndex > _lastIndex) {
      _activeIndex = _lastIndex;
    }

    if (widget.tips.length != oldWidget.tips.length ||
        widget.tipInterval != oldWidget.tipInterval) {
      _tipIndex = 0;
      _startTipTimer();
    }

    _syncPulse();
  }

  @override
  void dispose() {
    _stopProcessingTimers();
    _tipTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startProcessingTimers() {
    _stopProcessingTimers();
    if (widget.isCompleted) return;

    _stageTimer = Timer.periodic(widget.stageInterval, (timer) {
      if (!mounted || _activeIndex >= _lastIndex) {
        timer.cancel();
        return;
      }
      setState(() => _activeIndex++);
    });

    _slowTimer = Timer(widget.slowThreshold, () {
      if (mounted) setState(() => _isSlow = true);
    });
  }

  void _stopProcessingTimers() {
    _stageTimer?.cancel();
    _slowTimer?.cancel();
    _stageTimer = null;
    _slowTimer = null;
  }

  void _startTipTimer() {
    _tipTimer?.cancel();
    _tipTimer = null;
    if (widget.tips.length < 2) return;

    _tipTimer = Timer.periodic(widget.tipInterval, (_) {
      if (!mounted) return;
      setState(() => _tipIndex = (_tipIndex + 1) % widget.tips.length);
    });
  }

  void _syncPulse() {
    if (_reduceMotion || widget.isCompleted) {
      _pulseController.stop();
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat();
    }
  }

  _StageStatus _statusOf(int index) {
    if (widget.isCompleted || index < _activeIndex) return _StageStatus.done;
    if (index == _activeIndex) return _StageStatus.active;
    return _StageStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completed = widget.isCompleted;
    final stages = widget.stages;
    final currentStage = stages.isEmpty
        ? null
        : stages[completed ? _lastIndex : _activeIndex];

    // Tidak pernah mencapai 100% sebelum backend benar-benar selesai.
    final progress =
        completed ? 1.0 : (_activeIndex + 1) / (stages.length + 1);

    final headline = completed ? 'Analisis selesai' : widget.title;
    final description = completed
        ? 'Menyiapkan rekomendasi bidang IT untukmu...'
        : widget.subtitle;

    return Semantics(
      container: true,
      liveRegion: true,
      label: completed
          ? headline
          : 'Sedang memproses: ${currentStage?.title ?? widget.title}',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: _ProcessingOrb(
                    animation: _pulseController,
                    icon: completed
                        ? Icons.check_rounded
                        : currentStage?.icon ?? Icons.auto_awesome_rounded,
                    isCompleted: completed,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: _textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _ProgressBar(value: progress, isCompleted: completed),
                if (stages.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _StageList(stages: stages, statusOf: _statusOf),
                ],
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isSlow && !completed
                      ? const Padding(
                          key: ValueKey('ml-slow-notice'),
                          padding: EdgeInsets.only(top: 16),
                          child: _SlowNotice(),
                        )
                      : const SizedBox.shrink(),
                ),
                if (widget.tips.isNotEmpty && !completed) ...[
                  const SizedBox(height: 16),
                  _TipCard(
                    tip: widget.tips[_tipIndex % widget.tips.length],
                    tipKey: _tipIndex,
                  ),
                ],
                if (widget.onCancel != null && !completed) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: widget.onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: _textMuted,
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Batalkan'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _StageStatus { done, active, pending }

// ---------------------------------------------------------------------------
// Orb animasi di bagian atas
// ---------------------------------------------------------------------------
class _ProcessingOrb extends StatelessWidget {
  const _ProcessingOrb({
    required this.animation,
    required this.icon,
    required this.isCompleted,
  });

  final Animation<double> animation;
  final IconData icon;
  final bool isCompleted;

  static const double _coreSize = 88;
  static const double _maxSize = 156;

  @override
  Widget build(BuildContext context) {
    final accent = isCompleted ? _success : _primary;

    return SizedBox(
      width: _maxSize,
      height: _maxSize,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (!isCompleted)
                for (var i = 0; i < 2; i++)
                  _buildRing((animation.value + i * 0.5) % 1.0, accent),
              child!,
            ],
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: _coreSize,
          height: _coreSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCompleted
                  ? const [_success, Color(0xFF34D399)]
                  : const [_primary, _primaryLight],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.30),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: Icon(
              icon,
              key: ValueKey(icon),
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRing(double phase, Color color) {
    final size = _coreSize + (_maxSize - _coreSize) * phase;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: (1 - phase) * 0.18),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress bar
// ---------------------------------------------------------------------------
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.isCompleted});

  final double value;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: 6,
            backgroundColor: _border,
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? _success : _primary,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Daftar tahap
// ---------------------------------------------------------------------------
class _StageList extends StatelessWidget {
  const _StageList({required this.stages, required this.statusOf});

  final List<MlProcessingStage> stages;
  final _StageStatus Function(int index) statusOf;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stages.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _StageTile(stage: stages[i], number: i + 1, status: statusOf(i)),
          ],
        ],
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({
    required this.stage,
    required this.number,
    required this.status,
  });

  final MlProcessingStage stage;
  final int number;
  final _StageStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isActive = status == _StageStatus.active;

    final titleColor = switch (status) {
      _StageStatus.done => _textBody,
      _StageStatus.active => _textDark,
      _StageStatus.pending => _textDisabled,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StageIndicator(status: status, number: number),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  alignment: Alignment.topLeft,
                  child: isActive
                      ? Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            stage.description,
                            style: textTheme.bodySmall?.copyWith(
                              color: _textMuted,
                              height: 1.4,
                            ),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StageIndicator extends StatelessWidget {
  const _StageIndicator({required this.status, required this.number});

  final _StageStatus status;
  final int number;

  static const double _size = 28;

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (status) {
      _StageStatus.done => Container(
          key: const ValueKey('done'),
          width: _size,
          height: _size,
          decoration: const BoxDecoration(
            color: _success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
        ),
      _StageStatus.active => Container(
          key: const ValueKey('active'),
          width: _size,
          height: _size,
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(_primary),
          ),
        ),
      _StageStatus.pending => Container(
          key: const ValueKey('pending'),
          width: _size,
          height: _size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _border, width: 1.5),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _textDisabled,
            ),
          ),
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Pesan proses lambat & kartu tips
// ---------------------------------------------------------------------------
class _SlowNotice extends StatelessWidget {
  const _SlowNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.hourglass_top_rounded,
            size: 20,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Proses ini memakan waktu lebih lama dari biasanya. '
              'Mohon tunggu sebentar, kami masih bekerja.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF92400E),
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip, required this.tipKey});

  final String tip;
  final int tipKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 20, color: _primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahukah kamu?',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.topLeft,
                    children: [...previousChildren, ?currentChild],
                  ),
                  child: Text(
                    tip,
                    key: ValueKey(tipKey),
                    style: textTheme.bodySmall?.copyWith(
                      color: _textBody,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
