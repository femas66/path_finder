import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JobVacancyCard extends StatelessWidget {
  const JobVacancyCard({
    super.key,
    required this.title,
    required this.company,
    required this.location,
    this.type,
    this.matchScore,
    this.description,
    this.logo,
    this.onTap,
    this.onApply,
  });

  final String title;
  final String company;
  final String location;
  final String? type;
  final int? matchScore;
  final String? description;
  final Widget? logo;
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  Widget _buildLogo() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F5FA),
              Color(0xFFE2EBF8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Center(
          child: logo ??
              Text(
                _getInitial(company),
                style: GoogleFonts.sen(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2373F4),
                ),
              ),
        ),
      ),
    );
  }

  String _getInitial(String name) {
    final cleanName =
        name.replaceFirst(RegExp(r'^PT\s+', caseSensitive: false), '').trim();
    return cleanName.isNotEmpty ? cleanName[0].toUpperCase() : 'IT';
  }

  @override
  Widget build(BuildContext context) {
    const double paddingValue = 12.0;

    // Inner White Card (Card Lowongan)
    final cardContent = Container(
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
      child: Stack(
        children: [
          // Background Asset: Concentric Quarter Circles in Top-Right Corner
          Positioned(
            top: -28,
            right: -28,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2373F4).withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            top: -14,
            right: -14,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2373F4).withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2373F4).withValues(alpha: 0.08),
              ),
            ),
          ),

          // Main Card Content
          Padding(
            padding: const EdgeInsets.all(paddingValue),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo 1:1 di kiri, jarak atas, kiri, dan bawah sama (paddingValue)
                  _buildLogo(),
                  const SizedBox(width: 14),
                  // Sisi kanan: Title (bold di atas), Nama Perusahaan, Lokasi
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.sen(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          company,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.sen(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                type != null ? '$location • $type' : location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.sen(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // If matchScore exists, wrap in parent card with top banner visible
    if (matchScore != null) {
      final parentCard = Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF2373F4),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card Parent (Hanya kelihatan di bagian atas)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$matchScore% Cocok dengan Ceritamu',
                    style: GoogleFonts.sen(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
            // Child Card Lowongan (Card putih di dalamnya)
            cardContent,
          ],
        ),
      );

      if (onTap != null || onApply != null) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? onApply,
            borderRadius: BorderRadius.circular(18),
            child: parentCard,
          ),
        );
      }

      return parentCard;
    }

    // Default standalone card when no matchScore
    if (onTap != null || onApply != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? onApply,
          borderRadius: BorderRadius.circular(16),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
