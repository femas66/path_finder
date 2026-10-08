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
      expect(find.text('Jelajahi Jalur Karir IT'), findsOneWidget);
      expect(
        find.text(
          'Temukan beragam profesi teknologi masa kini mulai dari Software Engineer, Data Scientist, hingga Cyber Security.',
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

      expect(find.text('Kenali Potensi Terbaikmu'), findsOneWidget);

      // Tap Next button to go to slide 3
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Raih Karir Impianmu'), findsOneWidget);
      expect(find.text('Mulai'), findsOneWidget);
    });
  });
}
