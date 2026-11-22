import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/features/auth/domain/auth_repository.dart';
import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'package:path_finder/features/auth/domain/entities/auth_user.dart';
import 'auth_local_source.dart';
import 'auth_remote_source.dart';
import 'models/login_request.dart';
import 'models/register_request.dart';
import 'models/forgot_password_request.dart';
import 'models/verify_reset_code_request.dart';
import 'models/reset_password_request.dart';
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
  Future<AuthSession?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final request = RegisterRequest(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    await remoteSource.register(request);

    // Backend Go tidak menerbitkan token pada register, jadi sesi dibentuk
    // lewat login otomatis. Bila langkah ini gagal, akun tetap sudah dibuat:
    // kembalikan `null` agar UI meminta pengguna masuk manual.
    try {
      return await login(email: email, password: password);
    } on AppException {
      return null;
    }
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

  @override
  Future<AuthUser?> validateCurrentSession() async {
    final token = await localSource.getToken();
    if (token == null || token.isEmpty) {
      await localSource.clearSession();
      return null;
    }

    try {
      final userModel = await remoteSource.getCurrentUser(token: token);
      await localSource.saveUser(userModel);
      return userModel.toEntity();
    } on UnauthorizedException {
      await localSource.clearSession();
      return null;
    } catch (_) {
      final cachedUser = await localSource.getUser();
      return cachedUser?.toEntity();
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    final request = ForgotPasswordRequest(email: email);
    await remoteSource.forgotPassword(request);
  }

  @override
  Future<bool> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final request = VerifyResetCodeRequest(email: email, code: code);
    return await remoteSource.verifyResetCode(request);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    final request = ResetPasswordRequest(
      email: email,
      code: code,
      password: password,
      confirmPassword: confirmPassword,
    );
    await remoteSource.resetPassword(request);
  }
}
