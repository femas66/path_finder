import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApplicationStatusCard extends StatelessWidget {
  const ApplicationStatusCard({
    super.key,
    required this.title,
    required this.company,
    required this.appliedDate,
    required this.status,
    this.isCompact = false,
    this.currentStep,
    this.totalSteps = 4,
    this.note,
    this.statusColor,
    this.statusBgColor,
    this.onTap,
  });

  final String title;
  final String company;
  final String appliedDate;
  final String status;

  /// When true, renders a thinner, simpler card ideal for Dashboard Home.
  /// When false (default), renders the comprehensive card with segmented tracker and notes.
  final bool isCompact;

  final int? currentStep;
  final int totalSteps;
  final String? note;
  final Color? statusColor;
  final Color? statusBgColor;
  final VoidCallback? onTap;

  String _getInitial(String name) {
    final cleanName =
        name.replaceFirst(RegExp(r'^PT\s+', caseSensitive: false), '').trim();
    return cleanName.isNotEmpty ? cleanName[0].toUpperCase() : 'B';
  }

  Color _resolveStatusColor() {
    if (statusColor != null) return statusColor!;
    final lower = status.toLowerCase();
    if (lower.contains('terima') || lower.contains('lolos')) {
      return const Color(0xFF059669); // Emerald
    }
    if (lower.contains('wawancara') || lower.contains('interview')) {
      return const Color(0xFF2563EB); // Blue
    }
    if (lower.contains('berkas') ||
        lower.contains('review') ||
        lower.contains('seleksi')) {
      return const Color(0xFFD97706); // Amber
    }
    if (lower.contains('tolak') || lower.contains('gagal')) {
      return const Color(0xFFDC2626); // Red
    }
    return const Color(0xFF2373F4); // Primary
  }

  Color _resolveStatusBgColor() {
    if (statusBgColor != null) return statusBgColor!;
    final lower = status.toLowerCase();
    if (lower.contains('terima') || lower.contains('lolos')) {
      return const Color(0xFFECFDF5);
    }
    if (lower.contains('wawancara') || lower.contains('interview')) {
      return const Color(0xFFEFF6FF);
    }
    if (lower.contains('berkas') ||
        lower.contains('review') ||
        lower.contains('seleksi')) {
      return const Color(0xFFFEF3C7);
    }
    if (lower.contains('tolak') || lower.contains('gagal')) {
      return const Color(0xFFFEE2E2);
    }
    return const Color(0xFFF0F5FA);
  }

  int _resolveCurrentStep() {
    if (currentStep != null) return currentStep!;
    final lower = status.toLowerCase();
    if (lower.contains('terima') || lower.contains('lolos')) return 4;
    if (lower.contains('wawancara') || lower.contains('interview')) return 3;
    if (lower.contains('berkas') ||
        lower.contains('review') ||
        lower.contains('seleksi')) {
      return 2;
    }
    return 1;
  }

  String _getStepLabel(int step) {
    switch (step) {
      case 1:
        return 'Terkirim';
      case 2:
        return 'Seleksi Berkas';
      case 3:
        return 'Wawancara';
      case 4:
        return 'Keputusan Akhir';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = _resolveStatusColor();
    final resolvedBg = _resolveStatusBgColor();
    final step = _resolveCurrentStep();

    final cardContent = isCompact
        ? _buildCompactContent(context, resolvedColor, resolvedBg)
        : _buildFullContent(context, resolvedColor, resolvedBg, step);

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isCompact ? 14 : 16),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  /// Compact, thin layout specifically tuned for Home (Beranda) feed.
  Widget _buildCompactContent(
    BuildContext context,
    Color resolvedColor,
    Color resolvedBg,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Status Accent Stripe (thin 4px indicator)
            Container(
              width: 4,
              color: resolvedColor,
            ),
            // Compact Content Row
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Company Initial Avatar
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getInitial(company),
                          style: GoogleFonts.sen(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2373F4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and Company / Date Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sen(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$company • $appliedDate',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sen(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Status Badge with dot & subtle chevron
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: resolvedBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: resolvedColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: resolvedColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                status,
                                style: GoogleFonts.sen(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: resolvedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onTap != null) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Full, comprehensive layout for Lamaran (Applications) tab.
  Widget _buildFullContent(
    BuildContext context,
    Color resolvedColor,
    Color resolvedBg,
    int step,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Status Accent Stripe (5px)
            Container(
              width: 5,
              color: resolvedColor,
            ),
            // Main Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Row: Company Avatar + Name & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitial(company),
                                    style: GoogleFonts.sen(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2373F4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$company • $appliedDate',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.sen(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status Badge with pulse dot
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: resolvedBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: resolvedColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: resolvedColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                status,
                                style: GoogleFonts.sen(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: resolvedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Position Title (Bold & Clear)
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sen(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Segmented Step Progress Tracker
                    _buildSegmentedTracker(step, totalSteps, resolvedColor),
                    if (note != null && note!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      // Info Note Panel
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                note!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.sen(
                                  fontSize: 11,
                                  color: const Color(0xFF334155),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTracker(
    int step,
    int total,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(total, (index) {
            final isCompleted = index < step;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < total - 1 ? 4 : 0),
                decoration: BoxDecoration(
                  color: isCompleted ? accentColor : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getStepLabel(step),
              style: GoogleFonts.sen(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            Text(
              'Tahap $step dari $total',
              style: GoogleFonts.sen(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
