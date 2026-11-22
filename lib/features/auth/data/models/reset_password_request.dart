class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.email,
    required this.code,
    required this.password,
    required this.confirmPassword,
  });

  final String email;
  final String code;
  final String password;
  final String confirmPassword;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      'password': password,
      'confirm_password': confirmPassword,
    };
  }
}
