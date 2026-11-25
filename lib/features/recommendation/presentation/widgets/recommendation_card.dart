import 'package:flutter/material.dart';

import '../../domain/entities/recommendation.dart';

const Color _primary = Color(0xFF2373F4);
const Color _success = Color(0xFF10B981);
const Color _warning = Color(0xFFF59E0B);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);
const Color _surface = Colors.white;

/// Kartu satu lowongan hasil rekomendasi.
///
/// Susunan informasi mengikuti urutan yang dibaca pengguna: badge persentase
/// kecocokan, nama posisi, divisi, nama perusahaan, lalu lokasi. Keahlian yang
/// sudah cocok dan yang masih perlu dipelajari ditampilkan di bawahnya agar
/// kartu bisa dipakai ulang di katalog maupun di halaman hasil analisis.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final RecommendationItem item;

  /// Aksi saat kartu ditekan. `null` membuat kartu tidak interaktif.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
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
              Expanded(child: _buildIdentity()),
              const SizedBox(width: 12),
              _ScoreBadge(score: item.matchingScore),
            ],
          ),
          if (item.matchedSkills.isNotEmpty) ..._buildSkillSection(
            title: null,
            skills: item.matchedSkills,
            background: _success.withValues(alpha: 0.1),
            foreground: _success,
            icon: Icons.check_rounded,
          ),
          if (item.missingSkills.isNotEmpty) ..._buildSkillSection(
            title: 'Perlu dipelajari',
            skills: item.missingSkills,
            background: const Color(0xFFF1F5F9),
            foreground: _textMuted,
          ),
          if (item.readinessScore != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  size: 15,
                  color: _textMuted,
                ),
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

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: card,
      ),
    );
  }

  /// Nama posisi, divisi, perusahaan, dan lokasi.
  Widget _buildIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (item.rank != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        if (item.category.isNotEmpty) ...[
          const SizedBox(height: 8),
          _DivisionChip(label: item.category),
        ],
        if (item.company.isNotEmpty) ...[
          const SizedBox(height: 10),
          _MetaRow(
            icon: Icons.business_center_outlined,
            label: item.company,
          ),
        ],
        if (item.location.isNotEmpty) ...[
          const SizedBox(height: 4),
          _MetaRow(
            icon: Icons.location_on_outlined,
            label: item.workType.isEmpty
                ? item.location
                : '${item.location} • ${item.workType}',
          ),
        ],
      ],
    );
  }

  List<Widget> _buildSkillSection({
    required String? title,
    required List<String> skills,
    required Color background,
    required Color foreground,
    IconData? icon,
  }) {
    return [
      SizedBox(height: title == null ? 14 : 12),
      if (title != null) ...[
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: _textMuted,
          ),
        ),
        const SizedBox(height: 6),
      ],
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills
            .map(
              (skill) => _SkillChip(
                label: skill,
                background: background,
                foreground: foreground,
                icon: icon,
              ),
            )
            .toList(growable: false),
      ),
    ];
  }
}

/// Badge persentase kecocokan di sisi kanan kartu.
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

    return Semantics(
      label: value == null
          ? 'Kecocokan belum tersedia'
          : 'Kecocokan $value persen',
      child: Container(
        width: 62,
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
              value == null ? '—' : '$value%',
              style: TextStyle(
                fontSize: 17,
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
      ),
    );
  }
}

/// Label divisi/posisi pada kartu.
class _DivisionChip extends StatelessWidget {
  const _DivisionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspaces_outline, size: 11, color: _primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: _textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({
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
