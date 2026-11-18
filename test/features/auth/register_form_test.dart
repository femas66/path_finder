import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path_finder/app/router.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/features/auth/domain/auth_repository.dart';
import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'package:path_finder/features/auth/domain/entities/auth_user.dart';
import 'package:path_finder/features/auth/presentation/pages/register_page.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.returnSession = true, this.shouldFail = false});

  bool returnSession;
  bool shouldFail;
  int registerCount = 0;
  String? lastEmail;
  String? lastPasswordConfirmation;

  @override
  Future<AuthSession?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    registerCount++;
    lastEmail = email;
    lastPasswordConfirmation = passwordConfirmation;

    if (shouldFail) {
      throw const ValidationException(
        message: 'Email sudah terdaftar. Silakan gunakan email lain.',
      );
    }

    if (!returnSession) return null;

    return AuthSession(
      token: 'jwt_register_token',
      user: AuthUser(
        id: 'usr_new',
        name: name,
        email: email,
        role: 'mahasiswa',
      ),
    );
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> clearSession() async {}

  @override
  Future<AuthSession?> getCurrentSession() async => null;

  @override
  Future<String?> getToken() async => null;

  @override
  Future<AuthUser?> getUser() async => null;

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> saveUser(AuthUser user) async {}
}

Widget _buildApp(_FakeAuthRepository repository) {
  final router = GoRouter(
    initialLocation: AppRoutePaths.register,
    routes: [
      GoRoute(
        path: AppRoutePaths.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutePaths.story,
        builder: (context, state) =>
            const Scaffold(body: Text('Story Screen')),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        builder: (context, state) =>
            const Scaffold(body: Text('Login Screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'Budi Santoso');
  await tester.enterText(
    find.byType(TextFormField).at(1),
    'budi.santoso@example.com',
  );
  await tester.enterText(find.byType(TextFormField).at(2), 'PasswordAman123');
  await tester.enterText(find.byType(TextFormField).at(3), 'PasswordAman123');
  await tester.pump();
}

Future<void> _tapSubmit(WidgetTester tester) async {
  final button = find.text('DAFTAR');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RegisterPage & RegisterForm Tests', () {
    testWidgets('renders all register fields and submit button',
        (tester) async {
      await tester.pumpWidget(_buildApp(_FakeAuthRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Daftar Akun'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Konfirmasi Password'), findsOneWidget);
      expect(find.text('DAFTAR'), findsOneWidget);
      expect(find.text('Sudah punya akun? '), findsOneWidget);

      // Backend Go tidak punya field username, jadi form tidak boleh
      // menampilkannya lagi.
      expect(find.text('Username'), findsNothing);
    });

    testWidgets('shows validation errors when submitted empty',
        (tester) async {
      final repository = _FakeAuthRepository();
      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await _tapSubmit(tester);

      expect(find.text('Nama lengkap tidak boleh kosong'), findsOneWidget);
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Kata sandi tidak boleh kosong'), findsOneWidget);
      expect(
        find.text('Konfirmasi kata sandi tidak boleh kosong'),
        findsOneWidget,
      );
      expect(repository.registerCount, equals(0));
    });

    testWidgets('rejects invalid email format', (tester) async {
      final repository = _FakeAuthRepository();
      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Budi Santoso');
      await tester.enterText(find.byType(TextFormField).at(1), 'bukan-email');
      await tester.enterText(find.byType(TextFormField).at(2), 'PasswordAman123');
      await tester.enterText(find.byType(TextFormField).at(3), 'PasswordAman123');

      await _tapSubmit(tester);

      expect(find.text('Masukkan alamat email yang valid'), findsOneWidget);
      expect(repository.registerCount, equals(0));
    });

    testWidgets('rejects password confirmation that does not match',
        (tester) async {
      final repository = _FakeAuthRepository();
      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Budi Santoso');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'budi.santoso@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'PasswordAman123');
      await tester.enterText(find.byType(TextFormField).at(3), 'PasswordBeda123');

      await _tapSubmit(tester);

      expect(find.text('Konfirmasi kata sandi tidak cocok'), findsOneWidget);
      expect(repository.registerCount, equals(0));
    });

    testWidgets('rejects password shorter than 8 characters', (tester) async {
      final repository = _FakeAuthRepository();
      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Budi Santoso');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'budi.santoso@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'pendek');
      await tester.enterText(find.byType(TextFormField).at(3), 'pendek');

      await _tapSubmit(tester);

      expect(find.text('Kata sandi minimal 8 karakter'), findsOneWidget);
      expect(repository.registerCount, equals(0));
    });

    testWidgets('successful register navigates to story page', (tester) async {
      final repository = _FakeAuthRepository();
      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await _fillValidForm(tester);
      await _tapSubmit(tester);

      expect(repository.registerCount, equals(1));
      expect(repository.lastEmail, equals('budi.santoso@example.com'));
      expect(repository.lastPasswordConfirmation, equals('PasswordAman123'));
      expect(find.text('Story Screen'), findsOneWidget);
    });

    testWidgets('register without session redirects to login page',
        (tester) async {
      final repository = _FakeAuthRepository(returnSession: false);
      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await _fillValidForm(tester);
      await _tapSubmit(tester);

      expect(repository.registerCount, equals(1));
      expect(find.text('Login Screen'), findsOneWidget);
      expect(
        find.text('Pendaftaran berhasil. Silakan masuk ke akunmu.'),
        findsOneWidget,
      );
    });

    testWidgets('shows backend error message when register fails',
        (tester) async {
      final repository = _FakeAuthRepository(shouldFail: true);
      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await _fillValidForm(tester);
      await _tapSubmit(tester);

      expect(
        find.text('Email sudah terdaftar. Silakan gunakan email lain.'),
        findsOneWidget,
      );
      expect(find.text('Story Screen'), findsNothing);
    });
  });
}
