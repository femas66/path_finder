import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/auth/data/auth_local_source.dart';
import 'package:path_finder/features/auth/data/auth_remote_source.dart';
import 'package:path_finder/features/auth/data/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthRepositoryImpl Integration Tests', () {
    const successJsonResponse = {
      "success": true,
      "message": "Login berhasil",
      "data": {
        "token": "valid_jwt_token_sample",
        "user": {
          "id": "5b579866-61c9-4c21-a38d-14b6f5f4ff24",
          "name": "Administrator PathFinder",
          "email": "admin@pathfinder.com",
          "role": "admin",
          "profile_picture":
              "https://ui-avatars.com/api/?name=Admin+PathFinder&background=0D8ABC&color=fff",
          "created_at": "2026-11-05T08:16:13.918474+07:00",
          "updated_at": "2026-11-05T08:16:13.918474+07:00"
        }
      }
    };

    late AuthLocalSource localSource;
    late AuthRemoteSource remoteSource;
    late AuthRepositoryImpl repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      localSource = AuthLocalSource();

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: successJsonResponse,
              ),
            );
          },
        ),
      );
      remoteSource = AuthRemoteSource(dio);

      repository = AuthRepositoryImpl(
        remoteSource: remoteSource,
        localSource: localSource,
      );
    });

    test('login automatically saves token & user to local storage', () async {
      expect(await repository.getToken(), isNull);
      expect(await repository.getCurrentSession(), isNull);

      final session = await repository.login(
        email: 'admin@pathfinder.com',
        password: 'password123',
        rememberMe: true,
      );

      expect(session.token, equals('valid_jwt_token_sample'));
      expect(session.user.name, equals('Administrator PathFinder'));
      expect(session.user.email, equals('admin@pathfinder.com'));
      expect(session.user.role, equals('admin'));

      // Verify token persisted in AuthLocalSource
      final storedToken = await repository.getToken();
      expect(storedToken, equals('valid_jwt_token_sample'));

      // Verify current session
      final currentSession = await repository.getCurrentSession();
      expect(currentSession, isNotNull);
      expect(currentSession!.token, equals('valid_jwt_token_sample'));
      expect(currentSession.user.email, equals('admin@pathfinder.com'));
    });

    test('clearSession clears both token and user state', () async {
      await repository.login(
        email: 'admin@pathfinder.com',
        password: 'password123',
      );

      expect(await repository.getToken(), isNotNull);

      await repository.clearSession();

      expect(await repository.getToken(), isNull);
      expect(await repository.getCurrentSession(), isNull);
    });
  });
}
