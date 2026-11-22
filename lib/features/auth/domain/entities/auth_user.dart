abstract class AuthRoles {
  static const String mitra = 'mitra';
  static const String perusahaan = 'perusahaan';
  static const String mahasiswa = 'mahasiswa';
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nim,
    this.profilePicture,
    this.location,
    this.cv,
    this.portfolioUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? nim;
  final String? profilePicture;
  final String? location;
  final String? cv;
  final String? portfolioUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAdmin => role.toLowerCase().trim() == 'admin';

  /// Mitra sama dengan perusahaan
  bool get isMitra {
    final r = role.toLowerCase().trim();
    return r == AuthRoles.mitra ||
        r == AuthRoles.perusahaan ||
        r == 'company';
  }

  bool get isMahasiswa {
    final r = role.toLowerCase().trim();
    return r == AuthRoles.mahasiswa ||
        r == 'student' ||
        r == 'user';
  }

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? nim,
    String? profilePicture,
    String? location,
    String? cv,
    String? portfolioUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      nim: nim ?? this.nim,
      profilePicture: profilePicture ?? this.profilePicture,
      location: location ?? this.location,
      cv: cv ?? this.cv,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          role == other.role &&
          nim == other.nim &&
          profilePicture == other.profilePicture &&
          location == other.location &&
          cv == other.cv &&
          portfolioUrl == other.portfolioUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      role.hashCode ^
      (nim?.hashCode ?? 0) ^
      (profilePicture?.hashCode ?? 0) ^
      (location?.hashCode ?? 0) ^
      (cv?.hashCode ?? 0) ^
      (portfolioUrl?.hashCode ?? 0);
}
