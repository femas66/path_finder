import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/dashboard/presentation/widgets/job_vacancy_card.dart';

void main() {
  group('JobVacancyCard Widget Tests', () {
    testWidgets('renders 1:1 rounded logo on left and details on right', (
      WidgetTester tester,
    ) async {
      bool cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: JobVacancyCard(
                title: 'Mobile Engineer Intern',
                company: 'PT Teknologi Hebat',
                location: 'Jakarta Selatan',
                type: 'Hybrid',
                matchScore: 92,
                onTap: () => cardTapped = true,
              ),
            ),
          ),
        ),
      );

      // Verify Title, Company, Location, Match Score
      expect(find.text('Mobile Engineer Intern'), findsOneWidget);
      expect(find.text('PT Teknologi Hebat'), findsOneWidget);
      expect(find.text('Jakarta Selatan • Hybrid'), findsOneWidget);
      expect(find.text('92% Cocok dengan Ceritamu'), findsOneWidget);

      // Verify initial letter inside 1:1 rounded container
      expect(find.text('T'), findsOneWidget);

      // Verify AspectRatio 1.0 is present for logo
      final aspectRatioFinder = find.byType(AspectRatio);
      expect(aspectRatioFinder, findsOneWidget);
      final AspectRatio aspectRatioWidget = tester.widget(aspectRatioFinder);
      expect(aspectRatioWidget.aspectRatio, 1.0);

      // Tap card
      await tester.tap(find.text('Mobile Engineer Intern'));
      expect(cardTapped, isTrue);
    });

    testWidgets('renders custom logo widget when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: JobVacancyCard(
              title: 'DevOps Engineer',
              company: 'PT Cloud Pintar',
              location: 'Bandung',
              logo: Icon(Icons.cloud_rounded, key: Key('custom_logo_icon')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom_logo_icon')), findsOneWidget);
      expect(find.text('DevOps Engineer'), findsOneWidget);
      expect(find.text('PT Cloud Pintar'), findsOneWidget);
      expect(find.text('Bandung'), findsOneWidget);
    });

    testWidgets('truncates long title with maxLines: 1 and ellipsis', (
      WidgetTester tester,
    ) async {
      const longTitle =
          'Senior Lead Full Stack Mobile Flutter and Cloud Infrastructure DevOps Architect Engineer Intern';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: JobVacancyCard(
                title: longTitle,
                company: 'PT Super Long Company Name Indonesia',
                location: 'Jakarta',
              ),
            ),
          ),
        ),
      );

      final titleTextFinder = find.text(longTitle);
      expect(titleTextFinder, findsOneWidget);

      final Text titleWidget = tester.widget(titleTextFinder);
      expect(titleWidget.maxLines, 1);
      expect(titleWidget.overflow, TextOverflow.ellipsis);
    });
  });
}
