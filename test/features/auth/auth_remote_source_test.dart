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
        "token":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImFkbWluQHBhdGhmaW5kZXIuY29tIiwiZXhwIjoxNzkzOTI3ODMzLCJpYXQiOjE3OTM4NDE0MzMsIm5hbWUiOiJBZG1pbmlzdHJhdG9yIFBhdGhGaW5kZXIiLCJyb2xlIjoiYWRtaW4iLCJ1c2VyX2lkIjoiNWI1Nzk4NjYtNjFjOS00YzIxLWEzOGQtMTRiNmY1ZjRmZjI0In0.8TuMfzSUIinIlL3QU3Kz34qhW_6SggEwkXRx_1re7yw",
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

    const errorJsonResponse = {
      "success": false,
      "message": "email atau password salah",
      "data": null,
      "errors": "email atau password salah"
    };

    test('login success returns LoginResponse with token and user', () async {
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

      final remoteSource = AuthRemoteSource(dio);
      final response = await remoteSource.login(
        const LoginRequest(
          email: 'admin@pathfinder.com',
          password: 'password123',
        ),
      );

      expect(response.success, isTrue);
      expect(response.message, equals('Login berhasil'));
      expect(
        response.data!.token,
        startsWith('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'),
      );
      expect(response.data!.user.email, equals('admin@pathfinder.com'));
      expect(response.data!.user.role, equals('admin'));
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
            email: 'admin@pathfinder.com',
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
            email: 'admin@pathfinder.com',
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
  });
}
