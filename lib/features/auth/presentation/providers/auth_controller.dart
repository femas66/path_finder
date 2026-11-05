import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'auth_providers.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthSession?> build() async {
    final repository = ref.read(authRepositoryProvider);
    return repository.getCurrentSession();
  }

  Future<AuthSession?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
    });

    if (state.hasError) {
      throw state.error!;
    }

    return state.value;
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repository.clearSession();
      return null;
    });
  }
}
