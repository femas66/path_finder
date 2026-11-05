import 'package:path_finder/features/auth/domain/auth_repository.dart';
import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'package:path_finder/features/auth/domain/entities/auth_user.dart';
import 'auth_local_source.dart';
import 'auth_remote_source.dart';
import 'models/login_request.dart';
import 'models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteSource,
    required this.localSource,
  });

  final AuthRemoteSource remoteSource;
  final AuthLocalSource localSource;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final request = LoginRequest(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    final response = await remoteSource.login(request);
    final data = response.data!;

    await localSource.saveSession(
      token: data.token,
      user: data.user,
    );
    await localSource.setRememberMe(rememberMe);

    return data.toEntity();
  }

  @override
  Future<void> saveToken(String token) async {
    await localSource.saveToken(token);
  }

  @override
  Future<String?> getToken() async {
    return localSource.getToken();
  }

  @override
  Future<void> saveUser(AuthUser user) async {
    await localSource.saveUser(UserModel.fromEntity(user));
  }

  @override
  Future<AuthUser?> getUser() async {
    final userModel = await localSource.getUser();
    return userModel?.toEntity();
  }

  @override
  Future<void> clearSession() async {
    await localSource.clearSession();
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    final token = await localSource.getToken();
    final userModel = await localSource.getUser();

    if (token == null || token.isEmpty || userModel == null) {
      return null;
    }

    return AuthSession(
      token: token,
      user: userModel.toEntity(),
    );
  }
}
