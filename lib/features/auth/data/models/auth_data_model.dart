import 'package:path_finder/features/auth/domain/entities/auth_session.dart';
import 'user_model.dart';

class AuthDataModel {
  const AuthDataModel({
    required this.token,
    required this.user,
  });

  final String token;
  final UserModel user;

  factory AuthDataModel.fromJson(Map<String, dynamic> json) {
    // Kontrak API memakai `access_token`; sebagian response lama memakai
    // `token`. Keduanya diterima agar client tetap kompatibel.
    final token = (json['token'] ?? json['access_token'])?.toString() ?? '';
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    return AuthDataModel(
      token: token,
      user: UserModel.fromJson(userJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }

  AuthSession toEntity() {
    return AuthSession(
      token: token,
      user: user.toEntity(),
    );
  }
}
