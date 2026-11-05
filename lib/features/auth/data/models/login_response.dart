import 'auth_data_model.dart';

class LoginResponse {
  const LoginResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  final bool success;
  final String? message;
  final AuthDataModel? data;
  final dynamic errors;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? AuthDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
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
