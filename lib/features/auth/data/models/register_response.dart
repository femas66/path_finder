import 'user_model.dart';

/// Response `POST /api/auth/register` pada backend Go.
///
/// Backend mengembalikan `data` berisi objek user saja (tanpa token). Token
/// baru diterbitkan lewat `POST /api/auth/login`, sehingga repository melakukan
/// login otomatis setelah pendaftaran berhasil.
class RegisterResponse {
  const RegisterResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  final bool success;
  final String? message;
  final UserModel? data;
  final dynamic errors;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    return RegisterResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
      data: rawData is Map<String, dynamic> ? UserModel.fromJson(rawData) : null,
      errors: json['errors'] ?? json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'errors': errors,
    };
  }
}
