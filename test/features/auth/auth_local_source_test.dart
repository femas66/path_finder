import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/auth/data/auth_local_source.dart';
import 'package:path_finder/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthLocalSource SharedPreferences Token Storage Tests', () {
    late AuthLocalSource localSource;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      localSource = AuthLocalSource();
    });

    test('stores, retrieves, and checks token in local storage', () async {
      expect(await localSource.hasToken(), isFalse);
      expect(await localSource.getToken(), isNull);

      const token = 'sample_jwt_token_12345';
      await localSource.saveToken(token);

      expect(await localSource.hasToken(), isTrue);
      expect(await localSource.getToken(), equals(token));

      await localSource.deleteToken();
      expect(await localSource.hasToken(), isFalse);
      expect(await localSource.getToken(), isNull);
    });

    test('stores and retrieves user entity in local storage', () async {
      const user = UserModel(
        id: 'usr-123',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'admin',
        profilePicture: 'https://example.com/pic.jpg',
      );

      await localSource.saveUser(user);
      final retrieved = await localSource.getUser();

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('usr-123'));
      expect(retrieved.name, equals('John Doe'));
      expect(retrieved.email, equals('john@example.com'));
      expect(retrieved.role, equals('admin'));
    });

    test('saveSession and clearSession manage full auth state', () async {
      const token = 'active_token_session';
      const user = UserModel(
        id: 'usr-456',
        name: 'Mitra Corp',
        email: 'mitra@corp.com',
        role: 'mitra',
      );

      await localSource.saveSession(token: token, user: user);

      expect(await localSource.hasToken(), isTrue);
      expect(await localSource.getToken(), equals(token));
      expect(await localSource.getUser(), isNotNull);

      await localSource.clearSession();

      expect(await localSource.hasToken(), isFalse);
      expect(await localSource.getToken(), isNull);
      expect(await localSource.getUser(), isNull);
    });
  });
}
