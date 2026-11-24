/// Data model sebuah lowongan magang/kerja yang ditampilkan di daftar lowongan
/// serta di halaman detail (Detail Magang).
///
/// Menyimpan seluruh informasi yang dibutuhkan halaman detail: deskripsi
/// posisi, syarat/kualifikasi, profil industri, dan informasi pendukung.
class JobVacancy {
  const JobVacancy({
    this.id = '',
    required this.title,
    required this.company,
    required this.location,
    this.type,
    this.matchScore,
    this.description = '',
    this.requirements = const [],
    this.industryProfile = '',
    this.facilities = const [],
    this.category = '',
    this.source = '',
    this.sourceUrl = '',
    this.mitraId,
    this.createdAt,
  });

  /// ID unik lowongan dari backend (UUID).
  final String id;

  /// Judul / nama posisi, misal "Frontend Developer Intern".
  final String title;

  /// Nama perusahaan / penyelenggara program, misal "PT Telkom Indonesia".
  final String company;

  /// Lokasi penempatan, misal "Bandung" atau "Remote".
  final String location;

  /// Jenis pekerjaan, misal "Magang", "Full-time", "Hybrid".
  final String? type;

  /// Kategori pekerjaan, misal "Teknologi", "Desain", "Bisnis".
  final String category;

  /// Persentase kecocokan dengan profil/cerita mahasiswa (0-100).
  final int? matchScore;

  /// Deskripsi posisi (deskripsi magang).
  final String description;

  /// Daftar syarat & kualifikasi yang dibutuhkan.
  final List<String> requirements;

  /// Profil industri / perusahaan penyelenggara.
  final String industryProfile;

  /// Fasilitas / keahlian opsional yang diberikan.
  final List<String> facilities;

  final String source;
  final String sourceUrl;
  final String? mitraId;
  final DateTime? createdAt;

  String get initial {
    final clean = company.replaceFirst(RegExp(r'^PT\s+', caseSensitive: false), '');
    final trimmed = clean.trim();
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : 'IT';
  }

  factory JobVacancy.fromJson(Map<String, dynamic> json) {
    final reqs = json['required_skills'];
    final opts = json['optional_skills'];

    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return JobVacancy(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      type: json['work_type']?.toString(),
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      requirements: parseList(reqs),
      facilities: parseList(opts),
      industryProfile: json['company']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      sourceUrl: json['source_url']?.toString() ?? '',
      mitraId: json['mitra_id']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'work_type': type,
      'category': category,
      'description': description,
      'required_skills': requirements,
      'optional_skills': facilities,
      'source': source,
      'source_url': sourceUrl,
      'mitra_id': mitraId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
