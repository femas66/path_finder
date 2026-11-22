class VerifyResetCodeRequest {
  const VerifyResetCodeRequest({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}
