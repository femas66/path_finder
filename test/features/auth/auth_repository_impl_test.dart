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
          "id": "c0a80101-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
          "nim": "12345678",
          "name": "Nama User",
          "email": "user@example.com",
          "role": "mahasiswa",
          "profile_picture": "https://example.com/photo.jpg",
          "location": "Batam",
          "cv": "https://example.com/cv.pdf",
          "portfolio_url": "https://portfolio.com",
          "created_at": "2026-11-12T10:00:00Z",
          "updated_at": "2026-11-12T10:00:00Z"
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

    test('login automatically saves token & user to local storage with all optional fields', () async {
      expect(await repository.getToken(), isNull);
      expect(await repository.getCurrentSession(), isNull);

      final session = await repository.login(
        email: 'user@example.com',
        password: 'password123',
        rememberMe: true,
      );

      expect(session.token, equals('valid_jwt_token_sample'));
      expect(session.user.nim, equals('12345678'));
      expect(session.user.name, equals('Nama User'));
      expect(session.user.email, equals('user@example.com'));
      expect(session.user.role, equals('mahasiswa'));
      expect(session.user.location, equals('Batam'));
      expect(session.user.cv, equals('https://example.com/cv.pdf'));
      expect(session.user.portfolioUrl, equals('https://portfolio.com'));

      // Verify token persisted in AuthLocalSource
      final storedToken = await repository.getToken();
      expect(storedToken, equals('valid_jwt_token_sample'));

      // Verify current session
      final currentSession = await repository.getCurrentSession();
      expect(currentSession, isNotNull);
      expect(currentSession!.token, equals('valid_jwt_token_sample'));
      expect(currentSession.user.nim, equals('12345678'));
      expect(currentSession.user.location, equals('Batam'));
      expect(currentSession.user.cv, equals('https://example.com/cv.pdf'));
      expect(currentSession.user.portfolioUrl, equals('https://portfolio.com'));
    });

    test('clearSession clears both token and user state', () async {
      await repository.login(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(await repository.getToken(), isNotNull);

      await repository.clearSession();

      expect(await repository.getToken(), isNull);
      expect(await repository.getCurrentSession(), isNull);
    });

    test('validateCurrentSession returns AuthUser when token is valid', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  "success": true,
                  "message": "Berhasil mengambil data pengguna",
                  "data": {
                    "id": "e4b6c891-1234-4567-89ab-cdef01234567",
                    "nim": "2201010001",
                    "name": "Budi Santoso",
                    "email": "budi@kampus.ac.id",
                    "role": "mahasiswa",
                    "location": "Semarang, Jawa Tengah"
                  }
                },
              ),
            );
          },
        ),
      );

      final repo = AuthRepositoryImpl(
        remoteSource: AuthRemoteSource(dio),
        localSource: localSource,
      );

      // Save token first
      await localSource.saveToken('valid_user_token');

      final user = await repo.validateCurrentSession();

      expect(user, isNotNull);
      expect(user!.name, equals('Budi Santoso'));
      expect(user.nim, equals('2201010001'));
      expect(user.isMahasiswa, isTrue);

      // Verify cached user was updated
      final cached = await localSource.getUser();
      expect(cached!.name, equals('Budi Santoso'));
    });

    test('validateCurrentSession clears session and returns null when token 401', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {
                    "success": false,
                    "message": "Missing or malformed JWT",
                    "errors": "Missing or malformed JWT"
                  },
                ),
              ),
            );
          },
        ),
      );

      final repo = AuthRepositoryImpl(
        remoteSource: AuthRemoteSource(dio),
        localSource: localSource,
      );

      await localSource.saveToken('expired_token');

      final user = await repo.validateCurrentSession();

      expect(user, isNull);
      expect(await localSource.getToken(), isNull);
    });

    test('validateCurrentSession returns null immediately when no token exists', () async {
      final user = await repository.validateCurrentSession();
      expect(user, isNull);
    });
  });

  group('AuthRepositoryImpl register (Go backend flow)', () {
    const registerJsonResponse = {
      'success': true,
      'message': 'Registrasi berhasil',
      'data': {
        'id': 'usr-registered',
        'name': 'Budi Santoso',
        'email': 'budi@example.com',
        'role': 'mahasiswa',
      },
    };

    const loginJsonResponse = {
      'success': true,
      'message': 'Login berhasil',
      'data': {
        'token': 'jwt_from_auto_login',
        'user': {
          'id': 'usr-registered',
          'name': 'Budi Santoso',
          'email': 'budi@example.com',
          'role': 'mahasiswa',
        },
      },
    };

    late List<String> requestedPaths;

    AuthRepositoryImpl buildRepository({
      required bool loginSucceeds,
    }) {
      requestedPaths = <String>[];
      SharedPreferences.setMockInitialValues({});

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPaths.add(options.path);

            if (options.path.endsWith('/auth/register')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 201,
                  data: registerJsonResponse,
                ),
              );
            }

            if (!loginSucceeds) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response(
                    requestOptions: options,
                    statusCode: 401,
                    data: const {
                      'success': false,
                      'message': 'email atau password salah',
                    },
                  ),
                ),
              );
            }

            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: loginJsonResponse,
              ),
            );
          },
        ),
      );

      return AuthRepositoryImpl(
        remoteSource: AuthRemoteSource(dio),
        localSource: AuthLocalSource(),
      );
    }

    test('register calls /api/auth/register then logs in to build a session',
        () async {
      final repository = buildRepository(loginSucceeds: true);

      final session = await repository.register(
        name: 'Budi Santoso',
        email: 'budi@example.com',
        password: 'PasswordAman123',
        passwordConfirmation: 'PasswordAman123',
      );

      expect(requestedPaths, equals(['/api/auth/register', '/api/auth/login']));
      expect(session, isNotNull);
      expect(session!.token, equals('jwt_from_auto_login'));
      expect(session.user.email, equals('budi@example.com'));

      // Sesi hasil login otomatis ikut tersimpan.
      expect(await repository.getToken(), equals('jwt_from_auto_login'));
    });

    test('register returns null when the account is created but login fails',
        () async {
      final repository = buildRepository(loginSucceeds: false);

      final session = await repository.register(
        name: 'Budi Santoso',
        email: 'budi@example.com',
        password: 'PasswordAman123',
        passwordConfirmation: 'PasswordAman123',
      );

      expect(requestedPaths, equals(['/api/auth/register', '/api/auth/login']));
      expect(session, isNull);
      expect(await repository.getToken(), isNull);
    });
  });
}
