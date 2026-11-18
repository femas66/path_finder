import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/auth/domain/auth_repository.dart';
import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'package:path_finder/features/auth/domain/entities/auth_user.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_controller.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_providers.dart';
import 'package:path_finder/features/story/domain/entities/user_story.dart';
import 'package:path_finder/features/story/domain/story_repository.dart';
import 'package:path_finder/features/story/presentation/providers/story_controller.dart';
import 'package:path_finder/features/story/presentation/providers/story_providers.dart';

/// Repository dengan latensi, meniru request jaringan sungguhan.
class _SlowAuthRepository implements AuthRepository {
  @override
  Future<AuthSession?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return const AuthSession(
      token: 'token',
      user: AuthUser(
        id: 'u1',
        name: 'Budi',
        email: 'budi@example.com',
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
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return const AuthSession(
      token: 'token',
      user: AuthUser(
        id: 'u1',
        name: 'Budi',
        email: 'budi@example.com',
        role: 'mahasiswa',
      ),
    );
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

class _SlowStoryRepository implements StoryRepository {
  @override
  Future<UserStory> submitStory({required String content}) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return UserStory(id: 'story_1', content: content);
  }
}

/// Regresi: halaman memanggil controller lewat `ref.read` tanpa listener.
/// Sebelum `keepAlive`, provider auto-dispose sudah dibuang saat request
/// berjalan sehingga `state = await ...` melempar
/// "Cannot use the Ref ... after it has been disposed" dan UI hanya
/// menampilkan pesan generik.
void main() {
  group('Controller lifecycle without widget listeners', () {
    test('AuthController.register survives an async gap', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_SlowAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authControllerProvider.notifier);

      // Beri kesempatan autoDispose berjalan sebelum request selesai.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final session = await notifier.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'Password123',
        passwordConfirmation: 'Password123',
      );

      expect(session, isNotNull);
      expect(session!.user.email, equals('budi@example.com'));
      expect(container.read(authControllerProvider).value, isNotNull);
    });

    test('AuthController.login survives an async gap', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_SlowAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final session = await notifier.login(
        email: 'budi@example.com',
        password: 'Password123',
      );

      expect(session, isNotNull);
      expect(session!.token, equals('token'));
    });

    test('StoryController.submit survives an async gap', () async {
      final container = ProviderContainer(
        overrides: [
          storyRepositoryProvider.overrideWithValue(_SlowStoryRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(storyControllerProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final story = await notifier.submit('a' * 60);

      expect(story, isNotNull);
      expect(story!.content.length, equals(60));
    });
  });
}
