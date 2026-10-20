import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/dashboard/presentation/widgets/application_status_card.dart';

void main() {
  group('ApplicationStatusCard Tests', () {
    testWidgets('renders full version with title, company, tracker, and note', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ApplicationStatusCard(
              title: 'Backend Engineer Intern',
              company: 'PT Tokopedia',
              appliedDate: 'Dilamar 2 hari lalu',
              status: 'Seleksi Berkas',
              note: 'Berkas lamaran sedang ditinjau.',
            ),
          ),
        ),
      );

      expect(find.text('Backend Engineer Intern'), findsOneWidget);
      expect(
        find.textContaining('PT Tokopedia • Dilamar 2 hari lalu'),
        findsOneWidget,
      );
      expect(find.text('Seleksi Berkas'), findsNWidgets(2)); // Badge + Stepper label
      expect(find.text('Tahap 2 dari 4'), findsOneWidget);
      expect(find.text('Berkas lamaran sedang ditinjau.'), findsOneWidget);
    });

    testWidgets('renders compact version for Home: thin, simple, no tracker or note', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApplicationStatusCard(
              title: 'Backend Engineer Intern',
              company: 'PT Tokopedia',
              appliedDate: 'Dilamar 2 hari lalu',
              status: 'Seleksi Berkas',
              isCompact: true,
              note: 'Catatan tersembunyi di compact',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Backend Engineer Intern'), findsOneWidget);
      expect(
        find.textContaining('PT Tokopedia • Dilamar 2 hari lalu'),
        findsOneWidget,
      );
      expect(find.text('Seleksi Berkas'), findsOneWidget); // Only badge in compact
      expect(find.text('Tahap 2 dari 4'), findsNothing); // No tracker
      expect(find.text('Catatan tersembunyi di compact'), findsNothing); // No note
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      await tester.tap(find.byType(ApplicationStatusCard));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('triggers onTap callback when pressed in full mode', (
      WidgetTester tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApplicationStatusCard(
              title: 'Frontend Developer Intern',
              company: 'PT Telkom Indonesia',
              appliedDate: '15 Okt 2026',
              status: 'Wawancara User',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ApplicationStatusCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders accepted status with step 4', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ApplicationStatusCard(
              title: 'Mobile App Developer Apprentice',
              company: 'Shopee Indonesia',
              appliedDate: '10 Okt 2026',
              status: 'Diterima Magang',
            ),
          ),
        ),
      );

      expect(find.text('Diterima Magang'), findsOneWidget);
      expect(find.text('Tahap 4 dari 4'), findsOneWidget);
      expect(find.text('Keputusan Akhir'), findsOneWidget);
    });
  });
}
