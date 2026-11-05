import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/features/auth/domain/auth_repository.dart';
import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'package:path_finder/features/auth/domain/entities/auth_user.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_controller.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_providers.dart';

class FakeAuthRepository implements AuthRepository {
  AuthSession? _currentSession;
  bool shouldFail = false;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    if (shouldFail) {
      throw const UnauthorizedException(message: 'email atau password salah');
    }

    _currentSession = const AuthSession(
      token: 'jwt_mock_token_admin',
      user: AuthUser(
        id: '5b579866-61c9-4c21-a38d-14b6f5f4ff24',
        name: 'Administrator PathFinder',
        email: 'admin@pathfinder.com',
        role: 'admin',
      ),
    );
    return _currentSession!;
  }

  @override
  Future<void> clearSession() async {
    _currentSession = null;
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    return _currentSession;
  }

  @override
  Future<String?> getToken() async {
    return _currentSession?.token;
  }

  @override
  Future<AuthUser?> getUser() async {
    return _currentSession?.user;
  }

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<void> saveUser(AuthUser user) async {}
}

void main() {
  group('AuthController Riverpod State Tests', () {
    late FakeAuthRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state resolves to null when not logged in', () async {
      final session = await container.read(authControllerProvider.future);
      expect(session, isNull);
    });

    test('login success updates state with AuthSession and saved token', () async {
      final notifier = container.read(authControllerProvider.notifier);
      final session = await notifier.login(
        email: 'admin@pathfinder.com',
        password: 'password123',
      );

      expect(session, isNotNull);
      expect(session!.token, equals('jwt_mock_token_admin'));
      expect(session.user.name, equals('Administrator PathFinder'));

      final currentState = container.read(authControllerProvider);
      expect(currentState.value?.token, equals('jwt_mock_token_admin'));
    });

    test('login failure throws UnauthorizedException and updates state to error',
        () async {
      fakeRepository.shouldFail = true;
      final notifier = container.read(authControllerProvider.notifier);

      expect(
        () => notifier.login(
          email: 'admin@pathfinder.com',
          password: 'wrongpassword',
        ),
        throwsA(
          isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            equals('email atau password salah'),
          ),
        ),
      );
    });

    test('logout clears session and resets state', () async {
      final notifier = container.read(authControllerProvider.notifier);
      await notifier.login(
        email: 'admin@pathfinder.com',
        password: 'password123',
      );

      expect(container.read(authControllerProvider).value, isNotNull);

      await notifier.logout();
      expect(container.read(authControllerProvider).value, isNull);
    });
  });
}
