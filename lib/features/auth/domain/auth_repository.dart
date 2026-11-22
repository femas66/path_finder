import 'entities/auth_session.dart';
import 'entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  /// Mendaftarkan akun baru.
  ///
  /// Backend Go (`POST /api/auth/register`) hanya mengembalikan data user tanpa
  /// token, sehingga implementasi melakukan login otomatis memakai email dan
  /// password yang sama untuk membentuk sesi.
  ///
  /// Mengembalikan `null` bila akun berhasil dibuat tetapi pembuatan sesi
  /// gagal; UI perlu meminta pengguna masuk secara manual.
  Future<AuthSession?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> saveUser(AuthUser user);

  Future<AuthUser?> getUser();

  Future<void> clearSession();

  Future<AuthSession?> getCurrentSession();

  Future<AuthUser?> validateCurrentSession();
}
