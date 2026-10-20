import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:path_finder/features/dashboard/presentation/widgets/dashboard_bottom_navbar.dart';

void main() {
  group('DashboardPage & Navbar Tests', () {
    testWidgets('renders all 4 navbar menu items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      expect(find.byType(DashboardBottomNavbar), findsOneWidget);
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Lowongan'), findsOneWidget);
      expect(find.text('Lamaran'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('shows Beranda by default with greeting and story banner', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      expect(find.text('Halo, Mahasiswa 👋'), findsOneWidget);
      expect(
        find.text('Ceritakan Dirimu untuk Rekomendasi Lowongan'),
        findsOneWidget,
      );
      expect(find.text('Status Lamaran Terkini'), findsOneWidget);
    });

    testWidgets('switches to Lowongan tab when tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.tap(find.text('Lowongan'));
      await tester.pumpAndSettle();

      expect(find.text('Daftar Lowongan IT'), findsOneWidget);
      expect(find.text('Semua Lowongan'), findsOneWidget);
      expect(find.text('Rekomendasi Matching (AI)'), findsOneWidget);
    });

    testWidgets('switches to Lamaran tab when tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.tap(find.text('Lamaran'));
      await tester.pumpAndSettle();

      expect(find.text('Status Lamaran'), findsOneWidget);
      expect(find.textContaining('PT Tokopedia'), findsWidgets);
      expect(find.text('Seleksi Berkas'), findsWidgets);
    });

    testWidgets('switches to Profil tab when tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Profil Mahasiswa'), findsOneWidget);
      expect(find.text('Riwayat Cerita & Analisis Minat'), findsOneWidget);
      expect(find.text('Keluar dari Akun'), findsOneWidget);
    });
  });
}
