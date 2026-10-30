import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path_finder/app/router.dart';
import 'package:path_finder/features/auth/presentation/pages/login_page.dart';
import 'package:path_finder/features/auth/presentation/widgets/login_form.dart';

void main() {
  group('LoginPage & LoginForm Tests', () {
    testWidgets('renders login form and demo account selector chips', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Pilih Cepat Akun Demo:'), findsOneWidget);
      expect(find.text('Role Mitra'), findsOneWidget);
      expect(find.text('Mahasiswa'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('MASUK'), findsOneWidget);
    });

    testWidgets('tapping Role Mitra chip autofills mitra credentials', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: LoginForm())),
        ),
      );

      // Tap Role Mitra demo chip
      final mitraChip = find.text('Role Mitra');
      expect(mitraChip, findsOneWidget);
      await tester.tap(mitraChip);
      await tester.pumpAndSettle();

      expect(
        find.text('mitra@gmail.com'),
        findsNWidgets(2),
      ); // in chip & in textfield
      expect(find.text('mitra123'), findsOneWidget);
    });

    testWidgets('tapping Mahasiswa chip autofills student credentials', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: LoginForm())),
        ),
      );

      // Tap Mahasiswa demo chip
      final mhsChip = find.text('Mahasiswa');
      expect(mhsChip, findsOneWidget);
      await tester.tap(mhsChip);
      await tester.pumpAndSettle();

      expect(
        find.text('mahasiswa@gmail.com'),
        findsNWidgets(2),
      ); // in chip & in textfield
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('mitra with invalid password shows error SnackBar', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: LoginForm())),
        ),
      );

      // Enter mitra email with wrong password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'testing@gmail.com'),
        'mitra@gmail.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');

      final masukBtn = find.text('MASUK');
      await tester.tap(masukBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('Kata sandi salah. Gunakan "mitra123" untuk akun mitra.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'mitra with valid credentials navigates to company dashboard route',
      (tester) async {
        final router = GoRouter(
          initialLocation: AppRoutePaths.login,
          routes: [
            GoRoute(
              path: AppRoutePaths.login,
              builder: (context, state) => const LoginPage(),
            ),
            GoRoute(
              path: AppRoutePaths.companyDashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Company Dashboard Screen')),
            ),
            GoRoute(
              path: AppRoutePaths.dashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Student Dashboard Screen')),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        // Tap Role Mitra demo chip
        await tester.tap(find.text('Role Mitra'));
        await tester.pumpAndSettle();

        // Ensure MASUK button is visible in scrollview then tap
        final masukBtn = find.text('MASUK');
        await tester.ensureVisible(masukBtn);
        await tester.tap(masukBtn);
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();

        expect(find.text('Company Dashboard Screen'), findsOneWidget);
      },
    );
  });
}
