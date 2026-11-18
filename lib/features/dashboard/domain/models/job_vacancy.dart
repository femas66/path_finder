/// Data model sebuah lowongan magang/kerja yang ditampilkan di daftar lowongan
/// serta di halaman detail (Detail Magang).
///
/// Menyimpan seluruh informasi yang dibutuhkan halaman detail: deskripsi
/// posisi, syarat/kualifikasi, profil industri, dan informasi pendukung.
class JobVacancy {
  const JobVacancy({
    required this.title,
    required this.company,
    required this.location,
    this.type,
    this.matchScore,
    this.description = '',
    this.requirements = const [],
    this.industryProfile = '',
    this.facilities = const [],
  });

  /// Judul / nama posisi, misal "Frontend Developer Intern".
  final String title;

  /// Nama perusahaan / penyelenggara program, misal "PT Telkom Indonesia".
  final String company;

  /// Lokasi penempatan, misal "Bandung" atau "Remote".
  final String location;

  /// Jenis pekerjaan, misal "Magang", "Full-time", "Hybrid".
  final String? type;

  /// Persentase kecocokan dengan profil/cerita mahasiswa (0-100).
  final int? matchScore;

  /// Deskripsi posisi (deskripsi magang).
  final String description;

  /// Daftar syarat & kualifikasi yang dibutuhkan.
  final List<String> requirements;

  /// Profil industri / perusahaan penyelenggara.
  final String industryProfile;

  /// Fasilitas / benefit yang diberikan.
  final List<String> facilities;

  String get initial {
    final clean = company.replaceFirst(RegExp(r'^PT\s+', caseSensitive: false),
        '');
    final trimmed = clean.trim();
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : 'IT';
  }
}