import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/features/auth/data/auth_remote_source.dart';
import 'package:path_finder/features/auth/data/models/login_request.dart';

void main() {
  group('AuthRemoteSource API Response Tests', () {
    const successJsonResponse = {
      "success": true,
      "message": "Login berhasil",
      "data": {
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummytoken",
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

    const errorJsonResponse = {
      "success": false,
      "message": "email atau password salah",
      "errors": "email atau password salah"
    };

    test('login success targets /api/auth/login and returns LoginResponse',
        () async {
      String? requestedPath;
      dynamic requestedBody;

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            requestedBody = options.data;
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

      final remoteSource = AuthRemoteSource(dio);
      final response = await remoteSource.login(
        const LoginRequest(
          email: 'user@example.com',
          password: 'password123',
        ),
      );

      expect(requestedPath, equals('/api/auth/login'));
      expect(
        requestedBody,
        equals({'email': 'user@example.com', 'password': 'password123'}),
      );
      expect(response.success, isTrue);
      expect(response.message, equals('Login berhasil'));
      expect(response.data!.token, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummytoken'));
      expect(response.data!.user.nim, equals('12345678'));
      expect(response.data!.user.location, equals('Batam'));
      expect(response.data!.user.cv, equals('https://example.com/cv.pdf'));
      expect(response.data!.user.portfolioUrl, equals('https://portfolio.com'));
    });

    test(
        'login falls back to /api/users/login when /api/auth/login returns 404',
        () async {
      final pathsCalled = <String>[];

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            pathsCalled.add(options.path);
            if (options.path == '/api/auth/login') {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response(
                    requestOptions: options,
                    statusCode: 404,
                    data: {'message': 'Route not found'},
                  ),
                ),
              );
            }
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

      final remoteSource = AuthRemoteSource(dio);
      final response = await remoteSource.login(
        const LoginRequest(
          email: 'user@example.com',
          password: 'password123',
        ),
      );

      expect(pathsCalled, equals(['/api/auth/login', '/api/users/login']));
      expect(response.success, isTrue);
      expect(response.data!.user.email, equals('user@example.com'));
    });

    test(
        'login error with 401 status and error JSON throws UnauthorizedException with proper message',
        () async {
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
                  data: errorJsonResponse,
                ),
              ),
            );
          },
        ),
      );

      final remoteSource = AuthRemoteSource(dio);

      expect(
        () => remoteSource.login(
          const LoginRequest(
            email: 'user@example.com',
            password: 'wrongpassword',
          ),
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

    test('login 200 OK with success=false throws UnauthorizedException',
        () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: errorJsonResponse,
              ),
            );
          },
        ),
      );

      final remoteSource = AuthRemoteSource(dio);

      expect(
        () => remoteSource.login(
          const LoginRequest(
            email: 'user@example.com',
            password: 'wrongpassword',
          ),
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

    test('getCurrentUser success returns UserModel with Bearer token header',
        () async {
      String? requestedPath;
      String? authHeader;

      const mahasiswaProfileResponse = {
        "success": true,
        "message": "Berhasil mengambil data pengguna",
        "data": {
          "id": "e4b6c891-1234-4567-89ab-cdef01234567",
          "nim": "2201010001",
          "name": "Budi Santoso",
          "email": "budi@kampus.ac.id",
          "role": "mahasiswa",
          "location": "Semarang, Jawa Tengah",
          "profile_picture": "https://storage.googleapis.com/avatars/budi.jpg",
          "cv": "https://storage.googleapis.com/resumes/cv_budi.pdf",
          "portfolio_url": "https://budi-santoso.dev",
          "created_at": "2026-11-12T10:00:00Z",
          "updated_at": "2026-11-12T10:05:00Z"
        }
      };

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            authHeader = options.headers['Authorization']?.toString();
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: mahasiswaProfileResponse,
              ),
            );
          },
        ),
      );

      final remoteSource = AuthRemoteSource(dio);
      final user = await remoteSource.getCurrentUser(token: 'valid_jwt_token_123');

      expect(requestedPath, equals('/api/auth/me'));
      expect(authHeader, equals('Bearer valid_jwt_token_123'));
      expect(user.id, equals('e4b6c891-1234-4567-89ab-cdef01234567'));
      expect(user.nim, equals('2201010001'));
      expect(user.name, equals('Budi Santoso'));
      expect(user.role, equals('mahasiswa'));
      expect(user.location, equals('Semarang, Jawa Tengah'));
      expect(user.cv, equals('https://storage.googleapis.com/resumes/cv_budi.pdf'));
      expect(user.portfolioUrl, equals('https://budi-santoso.dev'));
      expect(user.toEntity().isMahasiswa, isTrue);
      expect(user.toEntity().isMitra, isFalse);
    });

    test('getCurrentUser success returns Mitra user model', () async {
      const mitraProfileResponse = {
        "success": true,
        "message": "Berhasil mengambil data pengguna",
        "data": {
          "id": "a1b2c3d4-5678-90ab-cdef-1234567890ab",
          "name": "PT Solusi Teknologi Nusantara",
          "email": "mitra@tech.com",
          "role": "mitra",
          "location": "Jakarta Selatan, DKI Jakarta",
          "profile_picture": "https://storage.googleapis.com/logos/mitra.png",
          "created_at": "2026-11-12T09:00:00Z",
          "updated_at": "2026-11-12T09:30:00Z"
        }
      };

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: mitraProfileResponse,
              ),
            );
          },
        ),
      );

      final remoteSource = AuthRemoteSource(dio);
      final user = await remoteSource.getCurrentUser(token: 'mitra_token');

      expect(user.id, equals('a1b2c3d4-5678-90ab-cdef-1234567890ab'));
      expect(user.name, equals('PT Solusi Teknologi Nusantara'));
      expect(user.role, equals('mitra'));
      expect(user.nim, isNull);
      expect(user.toEntity().isMitra, isTrue);
      expect(user.toEntity().isMahasiswa, isFalse);
    });

    test('getCurrentUser falls back to /api/users/current when /api/auth/me is 404',
        () async {
      final paths = <String>[];
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            paths.add(options.path);
            if (options.path == '/api/auth/me') {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response(
                    requestOptions: options,
                    statusCode: 404,
                  ),
                ),
              );
            }
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  "success": true,
                  "message": "Berhasil mengambil data pengguna",
                  "data": {
                    "id": "fallback-id",
                    "name": "Fallback User",
                    "email": "user@fb.com",
                    "role": "mahasiswa"
                  }
                },
              ),
            );
          },
        ),
      );

      final remoteSource = AuthRemoteSource(dio);
      final user = await remoteSource.getCurrentUser(token: 'sample_token');

      expect(paths, equals(['/api/auth/me', '/api/users/current']));
      expect(user.id, equals('fallback-id'));
    });

    test('getCurrentUser throws UnauthorizedException when token expired (401)',
        () async {
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

      final remoteSource = AuthRemoteSource(dio);

      expect(
        () => remoteSource.getCurrentUser(token: 'expired_or_invalid_token'),
        throwsA(
          isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            equals('Missing or malformed JWT'),
          ),
        ),
      );
    });
  });
}
