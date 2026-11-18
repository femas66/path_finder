class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.role = 'mahasiswa',
  });

  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  /// Backend Go menerima `admin | mitra | perusahaan | mahasiswa` dan
  /// memakai `mahasiswa` sebagai default.
  final String role;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'confirm_password': passwordConfirmation,
      'role': role,
    };
  }
}
