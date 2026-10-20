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
            // Slide 1: Bingung Menentukan Jalur IT?
            PageViewModel(
              title: 'Bingung Menentukan Jalur IT?',
              body: 'Dunia teknologi begitu luas. Mengetahui bidang mana yang paling cocok dengan minat dan potensimu sering kali membingungkan.',
              image: Image.asset(
                'assets/onboarding/undraw_ask-online_8zdn.png',
                height: 220,
                fit: BoxFit.contain,
              ),
              decoration: pageDecoration,
            ),

            // Slide 2: Cukup Ceritakan Dirimu
            PageViewModel(
              title: 'Cukup Ceritakan Dirimu',
              body: 'Tanpa tes teknis yang kaku, ceritakan minat, hobi, dan caramu menyelesaikan masalah dengan bahasamu sendiri.',
              image: Image.asset(
                'assets/onboarding/undraw_casual-browsing_c09r.png',
                height: 220,
                fit: BoxFit.contain,
              ),
              decoration: pageDecoration,
            ),

            // Slide 3: Rekomendasi Karir yang Tepat
            PageViewModel(
              title: 'Rekomendasi Karir yang Tepat',
              body: 'AI menganalisis ceritamu untuk memberikan rekomendasi bidang IT terbaik beserta langkah awal untuk memulainya.',
              image: Image.asset(
                'assets/onboarding/undraw_career-growth_wjul.png',
                height: 220,
                fit: BoxFit.contain,
              ),
              decoration: pageDecoration,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context),
          showSkipButton: true,
          skip: Text(
            'Lewati',
            style: GoogleFonts.sen(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
          next: const Icon(
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
}
