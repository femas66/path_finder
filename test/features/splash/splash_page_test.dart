import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path_finder/app/router.dart';
import 'package:path_finder/features/auth/domain/auth_repository.dart';
import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'package:path_finder/features/auth/domain/entities/auth_user.dart';
import 'package:path_finder/features/splash/presentation/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.userToReturn});

  AuthUser? userToReturn;

  @override
  Future<AuthUser?> validateCurrentSession() async {
    return userToReturn;
  }

  @override
  Future<void> clearSession() async {
    userToReturn = null;
  }

  @override
  Future<AuthSession?> getCurrentSession() async => null;

  @override
  Future<String?> getToken() async => userToReturn != null ? 'mock_token' : null;

  @override
  Future<AuthUser?> getUser() async => userToReturn;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<AuthSession?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> saveUser(AuthUser user) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SplashPage Session Validation & Redirection Tests', () {
    testWidgets(
      'redirects to /dashboard when token is valid and user role is mahasiswa',
      (tester) async {
        final mockRepo = MockAuthRepository(
          userToReturn: const AuthUser(
            id: 'e4b6c891-1234-4567-89ab-cdef01234567',
            name: 'Budi Santoso',
            email: 'budi@kampus.ac.id',
            role: 'mahasiswa',
            nim: '2201010001',
          ),
        );

        final router = GoRouter(
          initialLocation: AppRoutePaths.splash,
          routes: [
            GoRoute(
              path: AppRoutePaths.splash,
              builder: (context, state) => SplashPage(
                navigationDelay: const Duration(milliseconds: 100),
                authRepository: mockRepo,
              ),
            ),
            GoRoute(
              path: AppRoutePaths.dashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Student Dashboard Page')),
            ),
            GoRoute(
              path: AppRoutePaths.companyDashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Company Dashboard Page')),
            ),
            GoRoute(
              path: AppRoutePaths.onboarding,
              builder: (context, state) =>
                  const Scaffold(body: Text('Onboarding Page')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        expect(find.text('PathFinder'), findsOneWidget);

        // Wait for splash timer
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pumpAndSettle();

        expect(find.text('Student Dashboard Page'), findsOneWidget);
      },
    );

    testWidgets(
      'redirects to /company-dashboard when token is valid and user role is mitra',
      (tester) async {
        final mockRepo = MockAuthRepository(
          userToReturn: const AuthUser(
            id: 'a1b2c3d4-5678-90ab-cdef-1234567890ab',
            name: 'PT Solusi Teknologi Nusantara',
            email: 'mitra@tech.com',
            role: 'mitra',
          ),
        );

        final router = GoRouter(
          initialLocation: AppRoutePaths.splash,
          routes: [
            GoRoute(
              path: AppRoutePaths.splash,
              builder: (context, state) => SplashPage(
                navigationDelay: const Duration(milliseconds: 100),
                authRepository: mockRepo,
              ),
            ),
            GoRoute(
              path: AppRoutePaths.dashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Student Dashboard Page')),
            ),
            GoRoute(
              path: AppRoutePaths.companyDashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Company Dashboard Page')),
            ),
            GoRoute(
              path: AppRoutePaths.onboarding,
              builder: (context, state) =>
                  const Scaffold(body: Text('Onboarding Page')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        await tester.pump(const Duration(milliseconds: 150));
        await tester.pumpAndSettle();

        expect(find.text('Company Dashboard Page'), findsOneWidget);
      },
    );

    testWidgets(
      'redirects to /onboarding when token is expired or invalid (null user)',
      (tester) async {
        final mockRepo = MockAuthRepository(userToReturn: null);

        final router = GoRouter(
          initialLocation: AppRoutePaths.splash,
          routes: [
            GoRoute(
              path: AppRoutePaths.splash,
              builder: (context, state) => SplashPage(
                navigationDelay: const Duration(milliseconds: 100),
                authRepository: mockRepo,
              ),
            ),
            GoRoute(
              path: AppRoutePaths.dashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Student Dashboard Page')),
            ),
            GoRoute(
              path: AppRoutePaths.onboarding,
              builder: (context, state) =>
                  const Scaffold(body: Text('Onboarding Page')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        await tester.pump(const Duration(milliseconds: 150));
        await tester.pumpAndSettle();

        expect(find.text('Onboarding Page'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping splash screen immediately skips timer and redirects',
      (tester) async {
        final mockRepo = MockAuthRepository(
          userToReturn: const AuthUser(
            id: 'e4b6c891-1234-4567-89ab-cdef01234567',
            name: 'Budi Santoso',
            email: 'budi@kampus.ac.id',
            role: 'mahasiswa',
          ),
        );

        final router = GoRouter(
          initialLocation: AppRoutePaths.splash,
          routes: [
            GoRoute(
              path: AppRoutePaths.splash,
              builder: (context, state) => SplashPage(
                navigationDelay: const Duration(seconds: 10),
                authRepository: mockRepo,
              ),
            ),
            GoRoute(
              path: AppRoutePaths.dashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Student Dashboard Page')),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        // Tap splash page to skip
        await tester.tap(find.byType(GestureDetector).first);
        await tester.pumpAndSettle();

        expect(find.text('Student Dashboard Page'), findsOneWidget);
      },
    );
  });
}
