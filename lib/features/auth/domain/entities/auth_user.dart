class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? profilePicture;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isMitra =>
      role.toLowerCase() == 'mitra' || role.toLowerCase() == 'company';
  bool get isMahasiswa =>
      role.toLowerCase() == 'mahasiswa' ||
      role.toLowerCase() == 'student' ||
      role.toLowerCase() == 'user';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          role == other.role &&
          profilePicture == other.profilePicture;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      role.hashCode ^
      (profilePicture?.hashCode ?? 0);
}
