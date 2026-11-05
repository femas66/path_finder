import 'entities/auth_session.dart';
import 'entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> saveUser(AuthUser user);

  Future<AuthUser?> getUser();

  Future<void> clearSession();

  Future<AuthSession?> getCurrentSession();
}
