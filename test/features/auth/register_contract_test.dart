import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/auth/data/models/register_request.dart';
import 'package:path_finder/features/auth/data/models/register_response.dart';

/// Mengunci bentuk payload agar tetap cocok dengan backend Go
/// (`internal/model/user_model.go` → `RegisterUserRequest`).
void main() {
  group('Register contract against Go backend', () {
    test('request uses name/email/password/confirm_password/role', () {
      const request = RegisterRequest(
        name: 'Budi Santoso',
        email: 'budi@example.com',
        password: 'PasswordAman123',
        passwordConfirmation: 'PasswordAman123',
      );

      final json = request.toJson();

      expect(json, equals({
        'name': 'Budi Santoso',
        'email': 'budi@example.com',
        'password': 'PasswordAman123',
        'confirm_password': 'PasswordAman123',
        'role': 'mahasiswa',
      }));

      // Backend Go tidak mengenal field ini.
      expect(json.containsKey('username'), isFalse);
      expect(json.containsKey('password_confirmation'), isFalse);
    });

    test('role can be overridden', () {
      const request = RegisterRequest(
        name: 'PT Mitra Jaya',
        email: 'mitra@example.com',
        password: 'PasswordAman123',
        passwordConfirmation: 'PasswordAman123',
        role: 'mitra',
      );

      expect(request.toJson()['role'], equals('mitra'));
    });

    test('response parses user-only data without a token', () {
      final response = RegisterResponse.fromJson({
        'success': true,
        'message': 'Registrasi berhasil',
        'data': {
          'id': 'usr-1',
          'name': 'Budi Santoso',
          'email': 'budi@example.com',
          'role': 'mahasiswa',
          'created_at': '2026-11-18T10:00:00Z',
          'updated_at': '2026-11-18T10:00:00Z',
        },
      });

      expect(response.success, isTrue);
      expect(response.message, equals('Registrasi berhasil'));
      expect(response.data, isNotNull);
      expect(response.data!.id, equals('usr-1'));
      expect(response.data!.email, equals('budi@example.com'));
      expect(response.data!.role, equals('mahasiswa'));
    });

    test('response parses duplicate email error', () {
      final response = RegisterResponse.fromJson({
        'success': false,
        'message': 'email sudah terdaftar',
        'errors': 'email sudah terdaftar',
      });

      expect(response.success, isFalse);
      expect(response.message, equals('email sudah terdaftar'));
      expect(response.data, isNull);
      expect(response.errors, equals('email sudah terdaftar'));
    });
  });
}
