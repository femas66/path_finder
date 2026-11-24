import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_controller.dart';
import 'package:path_finder/features/company/domain/company_jobs_repository.dart';
import 'package:path_finder/features/company/presentation/providers/company_jobs_provider.dart';
import 'package:path_finder/features/company/presentation/widgets/tabs/company_home_tab.dart';

import 'candidates_tab_test.dart' show MitraAuth, NoSession;
import 'company_jobs_test_support.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    FakeJobsRepository repo, {
    bool signedIn = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            signedIn ? MitraAuth.new : NoSession.new,
          ),
          companyJobsRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: CompanyHomeTab(
            onNavigateToPostJob: () {},
            onNavigateToCandidates: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('loading then active jobs; pagination and refresh', (
    tester,
  ) async {
    final repo = FakeJobsRepository()
      ..pendingList = Completer<CompanyJobsPage>();
    await mount(tester, repo);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repo.pendingList!.complete(CompanyJobsPage([jobFixture()], 1, true, 2));
    await tester.pumpAndSettle();
    repo.pendingList = null;
    expect(find.text('Lowongan Aktif: 2'), findsOneWidget);
    expect(find.textContaining('Kuota'), findsNothing);
    final more = find.text('Muat lebih banyak');
    await tester.ensureVisible(more);
    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(find.text('Flutter Intern job-2'), findsOneWidget);
    final refresh = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    await refresh.onRefresh();
    await tester.pumpAndSettle();
    expect(repo.listCalls, 3);
    expect(find.text('Flutter Intern job-2'), findsNothing);
  });
  testWidgets('empty, error retry, pagination failure retains jobs', (
    tester,
  ) async {
    final repo = FakeJobsRepository()..fail = true;
    await mount(tester, repo);
    await tester.pumpAndSettle();
    expect(find.text('Coba lagi'), findsOneWidget);
    repo.fail = false;
    repo.empty = true;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada lowongan aktif.'), findsOneWidget);
    repo.empty = false;
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();
    repo.fail = true;
    await tester.ensureVisible(find.text('Muat lebih banyak'));
    await tester.tap(find.text('Muat lebih banyak'));
    await tester.pumpAndSettle();
    expect(find.text('Flutter Intern job-1'), findsOneWidget);
    expect(find.text('Coba muat lagi'), findsOneWidget);
    repo.fail = false;
    await tester.ensureVisible(find.text('Coba muat lagi'));
    await tester.tap(find.text('Coba muat lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Flutter Intern job-2'), findsOneWidget);
  });
  testWidgets('jobs reject missing session', (tester) async {
    final repo = FakeJobsRepository();
    await mount(tester, repo, signedIn: false);
    await tester.pumpAndSettle();
    expect(repo.listCalls, 0);
    expect(find.text('Flutter Intern job-1'), findsNothing);
  });
}
