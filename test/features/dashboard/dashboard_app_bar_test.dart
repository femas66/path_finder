import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/dashboard/presentation/widgets/dashboard_app_bar.dart';

void main() {
  group('Dashboard App Bar Tests', () {
    testWidgets('DashboardHomeAppBar renders title and subtitle cleanly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: DashboardHomeAppBar(),
          ),
        ),
      );

      expect(find.text('Halo, Mahasiswa 👋'), findsOneWidget);
      expect(find.text('Siap temukan karir IT impianmu?'), findsOneWidget);
      expect(find.byType(DashboardHomeAppBar), findsOneWidget);
    });

    testWidgets('DashboardTabAppBar renders title cleanly and compactly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: DashboardTabAppBar(
              title: 'Daftar Lowongan IT',
            ),
          ),
        ),
      );

      expect(find.text('Daftar Lowongan IT'), findsOneWidget);
      expect(find.byType(DashboardTabAppBar), findsOneWidget);
    });
  });
}
