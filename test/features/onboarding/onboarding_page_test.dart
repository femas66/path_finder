import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:path_finder/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  group('OnboardingPage Tests', () {
    testWidgets('renders introduction screen with initial page content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingPage(),
        ),
      );

      // Verify IntroductionScreen is present
      expect(find.byType(IntroductionScreen), findsOneWidget);

      // Verify first slide title and body
      expect(find.text('Bingung Menentukan Jalur IT?'), findsOneWidget);
      expect(
        find.text(
          'Dunia teknologi begitu luas. Mengetahui bidang mana yang paling cocok dengan minat dan potensimu sering kali membingungkan.',
        ),
        findsOneWidget,
      );

      // Verify controls
      expect(find.text('Lewati'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('can swipe through slides and reach Done button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingPage(),
        ),
      );

      // Tap Next button to go to slide 2
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Cukup Ceritakan Dirimu'), findsOneWidget);

      // Tap Next button to go to slide 3
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Rekomendasi Karir yang Tepat'), findsOneWidget);
      expect(find.text('Mulai'), findsOneWidget);
    });
  });
}
