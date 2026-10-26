import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/app/router.dart';
import 'package:path_finder/features/company/presentation/pages/company_dashboard_page.dart';

void main() {
  group('CompanyDashboardPage', () {
    testWidgets('switches between all 4 tabs seamlessly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CompanyDashboardPage(),
        ),
      );

      // Tab 0: Ringkasan
      expect(find.text('Lowongan Magang Anda'), findsOneWidget);
      expect(find.text('Lowongan Aktif'), findsOneWidget);

      // Switch to Tab 1: Buat Lowongan
      await tester.tap(find.text('Buat Lowongan'));
      await tester.pumpAndSettle();

      expect(find.text('Buka Peluang Magang Baru'), findsOneWidget);
      expect(find.text('Judul Posisi'), findsOneWidget);

      // Switch to Tab 2: Kandidat
      await tester.tap(find.text('Kandidat'));
      await tester.pumpAndSettle();

      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Aditya Pratama'), findsOneWidget);

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

    testWidgets('AppRoutePaths.companyDashboard route is registered and navigable', (tester) async {
      expect(AppRoutePaths.companyDashboard, '/company-dashboard');

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter,
        ),
      );

      appRouter.go(AppRoutePaths.companyDashboard);
      await tester.pumpAndSettle();

      expect(find.byType(CompanyDashboardPage), findsOneWidget);
      expect(find.text('PT Inovasi Teknologi Nusantara'), findsOneWidget);
    });
  });
}
