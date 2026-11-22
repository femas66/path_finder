import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/features/auth/domain/auth_repository.dart';
import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'package:path_finder/features/auth/domain/entities/auth_user.dart';
import 'package:path_finder/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockForgotPasswordAuthRepository implements AuthRepository {
  bool failForgotPassword = false;
  bool failVerifyCode = false;
  bool failResetPassword = false;

  String? lastSubmittedEmail;
  String? lastVerifiedCode;
  String? lastNewPassword;

  @override
  Future<void> forgotPassword(String email) async {
    lastSubmittedEmail = email;
    if (failForgotPassword) {
      throw const NotFoundException(message: 'email tidak ditemukan');
    }
  }

  @override
  Future<bool> verifyResetCode({
    required String email,
    required String code,
  }) async {
    lastVerifiedCode = code;
    if (failVerifyCode) {
      throw const ValidationException(message: 'kode verifikasi salah');
    }
    return true;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    lastNewPassword = password;
    if (failResetPassword) {
      throw const ValidationException(message: 'gagal mengubah password');
    }
  }

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

  @override
  Future<AuthUser?> validateCurrentSession() async => null;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ForgotPasswordPage & ForgotPasswordForm Flow Tests', () {
    testWidgets('renders step 1 (Email) initial elements', (tester) async {
      final mockRepo = _MockForgotPasswordAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(home: ForgotPasswordPage()),
        ),
      );

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('KIRIM KODE OTP'), findsOneWidget);
      expect(find.text('Ingat kata sandi akun Anda? '), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty or invalid email format', (tester) async {
      final mockRepo = _MockForgotPasswordAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(home: ForgotPasswordPage()),
        ),
      );

      // Submit empty
      await tester.tap(find.text('KIRIM KODE OTP'));
      await tester.pumpAndSettle();
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'invalid-email');
      await tester.tap(find.text('KIRIM KODE OTP'));
      await tester.pumpAndSettle();
      expect(
        find.text('Format email tidak valid (contoh: user@gmail.com)'),
        findsOneWidget,
      );
    });

    testWidgets('full 4-step forgot password flow succeeds seamlessly', (tester) async {
      final mockRepo = _MockForgotPasswordAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(home: ForgotPasswordPage()),
        ),
      );

      // --- STEP 1: Input valid email ---
      await tester.enterText(find.byType(TextFormField), 'mahasiswa@gmail.com');
      await tester.tap(find.text('KIRIM KODE OTP'));
      await tester.pumpAndSettle();

      expect(mockRepo.lastSubmittedEmail, 'mahasiswa@gmail.com');

      // --- STEP 2: Verify OTP ---
      expect(find.text('Verifikasi Kode'), findsOneWidget);
      expect(find.text('mahasiswa@gmail.com'), findsOneWidget);
      expect(find.text('KODE VERIFIKASI (6 DIGIT)'), findsOneWidget);
      expect(find.text('VERIFIKASI KODE'), findsOneWidget);

      // Fill in 6 digit code
      final digitFields = find.byType(TextFormField);
      expect(digitFields, findsNWidgets(6));

      for (int i = 0; i < 6; i++) {
        await tester.enterText(digitFields.at(i), '${i + 1}');
      }
      await tester.pumpAndSettle();

      await tester.tap(find.text('VERIFIKASI KODE'));
      await tester.pumpAndSettle();

      expect(mockRepo.lastVerifiedCode, '123456');

      // --- STEP 3: Reset Password ---
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('PASSWORD BARU'), findsOneWidget);
      expect(find.text('KONFIRMASI PASSWORD BARU'), findsOneWidget);
      expect(find.text('SIMPAN PASSWORD'), findsOneWidget);

      // Fill new password and mismatched confirmation
      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.at(0), 'newpassword123');
      await tester.enterText(passwordFields.at(1), 'mismatch');
      await tester.tap(find.text('SIMPAN PASSWORD'));
      await tester.pumpAndSettle();

      expect(
        find.text('Konfirmasi password tidak cocok dengan password baru'),
        findsOneWidget,
      );

      // Fix confirmation password
      await tester.enterText(passwordFields.at(1), 'newpassword123');
      await tester.tap(find.text('SIMPAN PASSWORD'));
      await tester.pumpAndSettle();

      expect(mockRepo.lastNewPassword, 'newpassword123');

      // --- STEP 4: Completed screen ---
      expect(find.text('Password Berhasil Diubah!'), findsOneWidget);
      expect(find.text('MASUK SEKARANG'), findsOneWidget);
    });

    testWidgets('shows error snackbar when email is not found (anti-bruteforce check)', (tester) async {
      final mockRepo = _MockForgotPasswordAuthRepository()..failForgotPassword = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: const MaterialApp(home: ForgotPasswordPage()),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'tidakada@example.com');
      await tester.tap(find.text('KIRIM KODE OTP'));
      await tester.pumpAndSettle();

      expect(find.text('email tidak ditemukan'), findsOneWidget);
      // Stays on step 1
      expect(find.text('Forgot Password'), findsOneWidget);
    });
  });
}
