import 'package:path_finder/features/auth/domain/entities/auth_user.dart';

class UserModel {
  const UserModel({
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
  final String? createdAt;
  final String? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'mahasiswa',
      nim: json['nim']?.toString(),
      profilePicture: json['profile_picture']?.toString() ??
          json['foto_profile']?.toString(),
      location: json['location']?.toString() ?? json['lokasi']?.toString(),
      cv: json['cv']?.toString(),
      portfolioUrl: json['portfolio_url']?.toString() ??
          json['link_portofolio']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
    if (nim != null && nim!.isNotEmpty) map['nim'] = nim;
    if (profilePicture != null && profilePicture!.isNotEmpty) {
      map['profile_picture'] = profilePicture;
    }
    if (location != null && location!.isNotEmpty) map['location'] = location;
    if (cv != null && cv!.isNotEmpty) map['cv'] = cv;
    if (portfolioUrl != null && portfolioUrl!.isNotEmpty) {
      map['portfolio_url'] = portfolioUrl;
    }
    if (createdAt != null && createdAt!.isNotEmpty) {
      map['created_at'] = createdAt;
    }
    if (updatedAt != null && updatedAt!.isNotEmpty) {
      map['updated_at'] = updatedAt;
    }
    return map;
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      role: role,
      nim: nim,
      profilePicture: profilePicture,
      location: location,
      cv: cv,
      portfolioUrl: portfolioUrl,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  factory UserModel.fromEntity(AuthUser entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      nim: entity.nim,
      profilePicture: entity.profilePicture,
      location: entity.location,
      cv: entity.cv,
      portfolioUrl: entity.portfolioUrl,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}
