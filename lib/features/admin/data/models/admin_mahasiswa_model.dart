class AdminMahasiswaItem {
  const AdminMahasiswaItem({
    required this.id,
    required this.nim,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
    this.cv,
    this.portfolioUrl,
    this.createdAt,
  });

  final String id;
  final String nim;
  final String name;
  final String email;
  final String role;
  final String? profilePicture;
  final String? cv;
  final String? portfolioUrl;
  final DateTime? createdAt;

  factory AdminMahasiswaItem.fromJson(Map<String, dynamic> json) {
    return AdminMahasiswaItem(
      id: json['id']?.toString() ?? '',
      nim: json['nim']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'mahasiswa',
      profilePicture: json['profile_picture']?.toString(),
      cv: json['cv']?.toString(),
      portfolioUrl: json['portfolio_url']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.userId,
    required this.email,
    required this.role,
    this.totalMahasiswa = 0,
    this.totalMitra = 0,
    this.totalJobs = 0,
  });

  final String userId;
  final String email;
  final String role;
  final int totalMahasiswa;
  final int totalMitra;
  final int totalJobs;

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'admin',
      totalMahasiswa: json['total_mahasiswa'] is int
          ? json['total_mahasiswa'] as int
          : (int.tryParse(json['total_mahasiswa']?.toString() ?? '') ?? 0),
      totalMitra: json['total_mitra'] is int
          ? json['total_mitra'] as int
          : (int.tryParse(json['total_mitra']?.toString() ?? '') ?? 0),
      totalJobs: json['total_jobs'] is int
          ? json['total_jobs'] as int
          : (int.tryParse(json['total_jobs']?.toString() ?? '') ?? 0),
    );
  }
}
