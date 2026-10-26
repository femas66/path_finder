import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/company/data/company_mock_data.dart';
import 'package:path_finder/features/company/presentation/widgets/cards/company_job_card.dart';
import 'package:path_finder/features/company/presentation/widgets/tabs/company_home_tab.dart';

void main() {
  group('CompanyJobCard', () {
    testWidgets('renders job details and quota correctly', (tester) async {
      final job = CompanyMockData.getInitialJobs().first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompanyJobCard(
              job: job,
            ),
          ),
        ),
      );

      expect(find.text(job.title), findsOneWidget);
      expect(find.text(job.field), findsOneWidget);
      expect(find.text('Kuota: ${job.quota} orang'), findsOneWidget);
      expect(find.textContaining('8 Pelamar'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
    });
  });

  group('CompanyHomeTab', () {
    testWidgets('renders metrics and navigates to post job and candidates', (tester) async {
      final jobs = CompanyMockData.getInitialJobs();
      final candidates = CompanyMockData.getInitialCandidates();

      bool navigatedToPostJob = false;
      bool navigatedToCandidates = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompanyHomeTab(
              jobs: jobs,
              candidates: candidates,
              onNavigateToPostJob: () {
                navigatedToPostJob = true;
              },
              onNavigateToCandidates: () {
                navigatedToCandidates = true;
              },
            ),
          ),
        ),
      );

      // Verify Metrics Card titles
      expect(find.text('Lowongan Aktif'), findsOneWidget);
      expect(find.text('Total Pelamar'), findsOneWidget);
      expect(find.text('Diterima'), findsOneWidget);

      // Verify Job Items rendered
      expect(find.text(jobs.first.title), findsOneWidget);

      // Test quick action "Posting Lowongan Sekarang"
      final postButton = find.text('Posting Lowongan Baru');
      expect(postButton, findsOneWidget);
      await tester.ensureVisible(postButton);
      await tester.tap(postButton);
      await tester.pumpAndSettle();

      expect(navigatedToPostJob, isTrue);

      // Test "Lihat Semua" candidates button
      final seeCandidatesBtn = find.text('Lihat Semua');
      await tester.scrollUntilVisible(
        seeCandidatesBtn,
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(seeCandidatesBtn, findsOneWidget);
      await tester.tap(seeCandidatesBtn);
      await tester.pumpAndSettle();

      expect(navigatedToCandidates, isTrue);
    });
  });
}
