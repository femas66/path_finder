import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/auth/data/models/login_response.dart';

void main() {
  group('Auth Models & Contract Mapping Tests', () {
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

    test('LoginResponse correctly parses success payload from user requirement',
        () {
      final response = LoginResponse.fromJson(successJsonResponse);

      expect(response.success, isTrue);
      expect(response.message, equals('Login berhasil'));
      expect(response.data, isNotNull);
      expect(
        response.data!.token,
        equals(
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImFkbWluQHBhdGhmaW5kZXIuY29tIiwiZXhwIjoxNzkzOTI3ODMzLCJpYXQiOjE3OTM4NDE0MzMsIm5hbWUiOiJBZG1pbmlzdHJhdG9yIFBhdGhGaW5kZXIiLCJyb2xlIjoiYWRtaW4iLCJ1c2VyX2lkIjoiNWI1Nzk4NjYtNjFjOS00YzIxLWEzOGQtMTRiNmY1ZjRmZjI0In0.8TuMfzSUIinIlL3QU3Kz34qhW_6SggEwkXRx_1re7yw',
        ),
      );

      final user = response.data!.user;
      expect(user.id, equals('5b579866-61c9-4c21-a38d-14b6f5f4ff24'));
      expect(user.name, equals('Administrator PathFinder'));
      expect(user.email, equals('admin@pathfinder.com'));
      expect(user.role, equals('admin'));
      expect(
        user.profilePicture,
        equals(
          'https://ui-avatars.com/api/?name=Admin+PathFinder&background=0D8ABC&color=fff',
        ),
      );
      expect(user.createdAt, equals('2026-11-05T08:16:13.918474+07:00'));
      expect(user.updatedAt, equals('2026-11-05T08:16:13.918474+07:00'));

      final entity = response.data!.toEntity();
      expect(entity.user.isAdmin, isTrue);
      expect(entity.user.isMitra, isFalse);
      expect(entity.token, equals(response.data!.token));
    });

    test('LoginResponse correctly parses error payload from user requirement',
        () {
      final response = LoginResponse.fromJson(errorJsonResponse);

      expect(response.success, isFalse);
      expect(response.message, equals('email atau password salah'));
      expect(response.data, isNull);
      expect(response.errors, equals('email atau password salah'));
    });
  });
}
