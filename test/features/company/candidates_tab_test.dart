import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/company/data/company_mock_data.dart';
import 'package:path_finder/features/company/presentation/widgets/cards/candidate_card.dart';
import 'package:path_finder/features/company/presentation/widgets/tabs/candidates_tab.dart';

void main() {
  group('CandidateCard Widget', () {
    testWidgets('renders candidate information and triggers status update', (tester) async {
      final candidate = CompanyMockData.getInitialCandidates().first;
      String? updatedStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CandidateCard(
              candidate: candidate,
              onStatusChanged: (newStatus) {
                updatedStatus = newStatus;
              },
            ),
          ),
        ),
      );

      expect(find.text(candidate.candidateName), findsOneWidget);
      expect(find.text(candidate.jobTitle), findsOneWidget);
      expect(find.text('${candidate.matchScore}% Match'), findsOneWidget);
      expect(find.text(candidate.status), findsOneWidget);

      // Open status change sheet
      final changeStatusBtn = find.text('Ubah Status');
      expect(changeStatusBtn, findsOneWidget);
      await tester.tap(changeStatusBtn);
      await tester.pumpAndSettle();

      // Tap "Ditolak" in bottom sheet
      final ditolakOption = find.widgetWithText(ListTile, 'Ditolak');
      expect(ditolakOption, findsOneWidget);
      await tester.tap(ditolakOption);
      await tester.pumpAndSettle();

      expect(updatedStatus, 'Ditolak');
    });
  });

  group('CandidatesTab Widget', () {
    testWidgets('filters candidates based on selected chip', (tester) async {
      final candidates = CompanyMockData.getInitialCandidates();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CandidatesTab(
              candidates: candidates,
              onUpdateStatus: (id, status) {},
            ),
          ),
        ),
      );

      // Verify all initial candidates are present in "Semua" filter
      expect(find.text('Aditya Pratama'), findsOneWidget);
      expect(find.text('Farhan Rizki'), findsOneWidget);

      // Tap filter chip "Diterima"
      final diterimaChip = find.widgetWithText(InkWell, 'Diterima');
      expect(diterimaChip, findsOneWidget);
      await tester.ensureVisible(diterimaChip);
      await tester.tap(diterimaChip);
      await tester.pumpAndSettle();

      // Budi Santoso and Aditya Pratama are Diterima, Aulia Rahma is Ditolak
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Aditya Pratama'), findsOneWidget);
      expect(find.text('Aulia Rahma'), findsNothing);

      // Tap filter chip "Ditolak"
      final ditolakChip = find.widgetWithText(InkWell, 'Ditolak');
      expect(ditolakChip, findsOneWidget);
      await tester.ensureVisible(ditolakChip);
      await tester.tap(ditolakChip);
      await tester.pumpAndSettle();

      expect(find.text('Aulia Rahma'), findsOneWidget);
      expect(find.text('Siti Nurhaliza'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsNothing);
    });
  });
}
