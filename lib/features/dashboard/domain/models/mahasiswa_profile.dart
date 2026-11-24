class MahasiswaProfile {
  const MahasiswaProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nim,
    this.profilePicture,
    this.location,
    this.cv,
    this.portfolioUrl,
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

  factory MahasiswaProfile.fromJson(Map<String, dynamic> json) {
    return MahasiswaProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'mahasiswa',
      nim: json['nim']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      location: json['location']?.toString(),
      cv: json['cv']?.toString(),
      portfolioUrl: json['portfolio_url']?.toString(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (location != null && location!.isNotEmpty) 'location': location,
      if (profilePicture != null && profilePicture!.isNotEmpty) 'profile_picture': profilePicture,
      if (cv != null && cv!.isNotEmpty) 'cv': cv,
      if (portfolioUrl != null && portfolioUrl!.isNotEmpty) 'portfolio_url': portfolioUrl,
    };
  }
}
