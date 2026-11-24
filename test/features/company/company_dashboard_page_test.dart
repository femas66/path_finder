import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_controller.dart';
import 'package:path_finder/features/company/presentation/providers/applicants_provider.dart';

import 'candidates_tab_test.dart' show MitraAuth, FakeRepository;
import 'company_jobs_test_support.dart';

import 'package:path_finder/features/company/presentation/providers/company_jobs_provider.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/app/router.dart';
import 'package:path_finder/features/company/presentation/pages/company_dashboard_page.dart';

void main() {
  group('CompanyDashboardPage', () {
    testWidgets('switches between all 4 tabs seamlessly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(MitraAuth.new),
            applicantsRepositoryProvider.overrideWithValue(FakeRepository()),
            companyJobsRepositoryProvider.overrideWithValue(
              FakeJobsRepository(),
            ),
          ],
          child: MaterialApp(home: CompanyDashboardPage()),
        ),
      );

      // Tab 0: Ringkasan
      expect(find.text('Lowongan Magang Anda'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Lowongan Aktif: 2'), findsOneWidget);

      // Switch to Tab 1: Buat Lowongan
      await tester.tap(find.text('Buat Lowongan'));
      await tester.pumpAndSettle();

      expect(find.text('Buka Peluang Magang Baru'), findsOneWidget);
      expect(find.text('Judul Posisi'), findsOneWidget);

      // Switch to Tab 2: Kandidat
      await tester.tap(find.text('Kandidat'));
      await tester.pumpAndSettle();

      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Belum ada pelamar untuk filter ini.'), findsOneWidget);

      // Switch to Tab 3: Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Profil Perusahaan'), findsOneWidget);
      final logoutBtn = find.text('Keluar dari Akun');
      await tester.scrollUntilVisible(
        logoutBtn,
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(logoutBtn, findsOneWidget);
    });

    testWidgets(
      'AppRoutePaths.companyDashboard route is registered and navigable',
      (tester) async {
        expect(AppRoutePaths.companyDashboard, '/company-dashboard');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authControllerProvider.overrideWith(MitraAuth.new),
              applicantsRepositoryProvider.overrideWithValue(FakeRepository()),
              companyJobsRepositoryProvider.overrideWithValue(
                FakeJobsRepository(),
              ),
            ],
            child: MaterialApp.router(routerConfig: appRouter),
          ),
        );

        appRouter.go(AppRoutePaths.companyDashboard);
        await tester.pumpAndSettle();

        expect(find.byType(CompanyDashboardPage), findsOneWidget);
        expect(find.text('PT Inovasi Teknologi Nusantara'), findsOneWidget);
      },
    );

    testWidgets('editing company profile updates CompanyAppBar name', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(MitraAuth.new),
            applicantsRepositoryProvider.overrideWithValue(FakeRepository()),
            companyJobsRepositoryProvider.overrideWithValue(
              FakeJobsRepository(),
            ),
          ],
          child: MaterialApp(home: CompanyDashboardPage(initialIndex: 3)),
        ),
      );

      await tester.tap(find.byKey(const Key('edit_company_profile_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('company_name_field')),
        'PT Sinar Karya Digital',
      );
      final saveBtn = find.byKey(const Key('save_company_profile_button'));
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('PT Sinar Karya Digital'), findsWidgets);
      expect(
        find.text('Profil perusahaan berhasil diperbarui'),
        findsOneWidget,
      );
    });
  });
}
