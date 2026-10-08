import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../../../app/router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  void _onIntroEnd(BuildContext context) {
    context.go(AppRoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: GoogleFonts.sen(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF121223),
        letterSpacing: -0.4,
      ),
      bodyTextStyle: GoogleFonts.sen(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF64748B),
        height: 1.5,
      ),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.only(top: 16, bottom: 8),
      imagePadding: const EdgeInsets.only(top: 16),
      pageColor: Colors.white,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IntroductionScreen(
          globalBackgroundColor: Colors.white,
          allowImplicitScrolling: true,
          pages: [
            // Slide 1: Jelajahi Karir IT
            PageViewModel(
              title: 'Jelajahi Jalur Karir IT',
              body: 'Temukan beragam profesi teknologi masa kini mulai dari Software Engineer, Data Scientist, hingga Cyber Security.',
              image: Image.asset(
                'assets/onboarding/undraw_random-idea_a29k.png',
              ),
              decoration: pageDecoration,
            ),

            // Slide 2: Tes Minat & Bakat
            PageViewModel(
              title: 'Kenali Potensi Terbaikmu',
              body: 'Ikuti penilaian interaktif terstruktur untuk memetakan minat, pola pikir logika, dan kecocokan keahlian Anda.',
              image: _buildGraphic(
                icon: Icons.psychology_rounded,
                badgeColor: const Color(0xFFF5F3FF),
                chips: const [
                  'Analisis Logika',
                  'Kreativitas Solusi',
                  'Tech Readiness',
                ],
              ),
              decoration: pageDecoration,
            ),

            // Slide 3: Rekomendasi & Peta Belajar
            PageViewModel(
              title: 'Raih Karir Impianmu',
              body: 'Dapatkan rekomendasi karir personal dan panduan peta belajar untuk mempersiapkan masa depan digital Anda.',
              image: _buildGraphic(
                icon: Icons.rocket_launch_rounded,
                badgeColor: const Color(0xFFECFDF5),
                chips: const [
                  'Roadmap Belajar',
                  'Portofolio Industri',
                  'Karier Impian',
                ],
              ),
              decoration: pageDecoration,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          showSkipButton: false,
          skip: Text(
            'Lewati',
            style: GoogleFonts.sen(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
          next: Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: Colors.black,
          ),
          done: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2373F4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Mulai',
              style: GoogleFonts.sen(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          dotsDecorator: DotsDecorator(
            size: const Size.square(8.0),
            activeSize: const Size(22.0, 8.0),
            activeColor: const Color(0xFF2373F4),
            color: const Color(0xFFE2E8F0),
            spacing: const EdgeInsets.symmetric(horizontal: 4.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraphic({
    required IconData icon,
    required Color badgeColor,
    required List<String> chips,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Center Hero Illustration / Squircle
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer subtle ring
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // Inner ring
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2373F4).withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
                // Main Icon Squircle
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2373F4),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2373F4).withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, size: 28, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Floating tag chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: chips.map((label) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.sen(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
