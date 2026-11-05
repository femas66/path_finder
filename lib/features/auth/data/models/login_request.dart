class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  final String email;
  final String password;
  final bool rememberMe;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
