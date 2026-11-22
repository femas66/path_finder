import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/auth/data/models/login_response.dart';
import 'package:path_finder/features/auth/domain/entities/auth_user.dart';

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

    const studentFullJsonResponse = {
      "success": true,
      "message": "Login berhasil",
      "data": {
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.fullpayload",
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

    const studentMinimalJsonResponse = {
      "success": true,
      "message": "Login berhasil",
      "data": {
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.minimal",
        "user": {
          "id": "c0a80101-minimal-user",
          "name": "User Tanpa Opsional",
          "email": "minimal@example.com",
          "role": "mahasiswa",
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

    test(
        'LoginResponse correctly parses user with all optional fields (nim, location, cv, portfolio_url)',
        () {
      final response = LoginResponse.fromJson(studentFullJsonResponse);

      expect(response.success, isTrue);
      expect(response.message, equals('Login berhasil'));
      expect(response.data, isNotNull);

      final user = response.data!.user;
      expect(user.id, equals('c0a80101-xxxx-xxxx-xxxx-xxxxxxxxxxxx'));
      expect(user.nim, equals('12345678'));
      expect(user.name, equals('Nama User'));
      expect(user.email, equals('user@example.com'));
      expect(user.role, equals('mahasiswa'));
      expect(user.profilePicture, equals('https://example.com/photo.jpg'));
      expect(user.location, equals('Batam'));
      expect(user.cv, equals('https://example.com/cv.pdf'));
      expect(user.portfolioUrl, equals('https://portfolio.com'));

      final entity = user.toEntity();
      expect(entity.nim, equals('12345678'));
      expect(entity.location, equals('Batam'));
      expect(entity.cv, equals('https://example.com/cv.pdf'));
      expect(entity.portfolioUrl, equals('https://portfolio.com'));
      expect(entity.isMahasiswa, isTrue);
      expect(entity.isMitra, isFalse);
    });

    test('LoginResponse correctly handles omitted optional fields as null', () {
      final response = LoginResponse.fromJson(studentMinimalJsonResponse);

      expect(response.success, isTrue);
      final user = response.data!.user;
      expect(user.nim, isNull);
      expect(user.profilePicture, isNull);
      expect(user.location, isNull);
      expect(user.cv, isNull);
      expect(user.portfolioUrl, isNull);

      final entity = user.toEntity();
      expect(entity.nim, isNull);
      expect(entity.location, isNull);
    });

    test('LoginResponse correctly parses error payload from user requirement',
        () {
      final response = LoginResponse.fromJson(errorJsonResponse);

      expect(response.success, isFalse);
      expect(response.message, equals('email atau password salah'));
      expect(response.data, isNull);
      expect(response.errors, equals('email atau password salah'));
    });

    test('AuthUser correctly classifies mitra and perusahaan identically', () {
      const mitraUser = AuthUser(
        id: '1',
        name: 'Mitra User',
        email: 'mitra@example.com',
        role: AuthRoles.mitra,
      );
      expect(mitraUser.isMitra, isTrue);
      expect(mitraUser.isMahasiswa, isFalse);

      const perusahaanUser = AuthUser(
        id: '2',
        name: 'Perusahaan User',
        email: 'company@example.com',
        role: AuthRoles.perusahaan,
      );
      expect(perusahaanUser.isMitra, isTrue);
      expect(perusahaanUser.isMahasiswa, isFalse);

      const mahasiswaUser = AuthUser(
        id: '3',
        name: 'Mahasiswa User',
        email: 'mhs@example.com',
        role: AuthRoles.mahasiswa,
      );
      expect(mahasiswaUser.isMahasiswa, isTrue);
      expect(mahasiswaUser.isMitra, isFalse);
    });
  });
}
