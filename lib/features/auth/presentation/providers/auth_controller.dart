import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'auth_providers.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthSession?> build() async {
    final repository = ref.watch(authRepositoryProvider);
    return repository.getCurrentSession();
  }

  Future<AuthSession?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      return await repository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
    });

    if (!ref.mounted) return null;

    state = result;

    if (state.hasError) {
      throw state.error!;
    }

    return state.value;
  }

  /// Mendaftarkan akun baru lalu langsung membentuk sesi lewat login otomatis.
  ///
  /// Mengembalikan `null` bila akun berhasil dibuat tetapi sesi gagal dibuat,
  /// sehingga UI dapat mengarahkan pengguna ke halaman login terlebih dahulu.
  Future<AuthSession?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      return await repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    });

    if (!ref.mounted) return null;

    state = result;

    if (state.hasError) {
      throw state.error!;
    }

    return state.value;
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    final result = await AsyncValue.guard(() async {
      await repository.clearSession();
      return null;
    });

    if (!ref.mounted) return;

    state = result;
  }
}
