class ApplicationItem {
  const ApplicationItem({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.mahasiswaId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final String company;
  final String mahasiswaId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Memetakan status backend (applied/pending, reviewed, interviewing, accepted, rejected)
  /// ke label teks Bahasa Indonesia yang ramah pengguna.
  String get displayStatus {
    switch (status.toLowerCase().trim()) {
      case 'accepted':
        return 'Diterima';
      case 'rejected':
        return 'Tidak Lolos';
      case 'interviewing':
        return 'Wawancara';
      case 'reviewed':
        return 'Direview';
      case 'applied':
      case 'pending':
      default:
        return 'Menunggu Seleksi';
    }
  }

  int get currentStep {
    switch (status.toLowerCase().trim()) {
      case 'applied':
      case 'pending':
        return 1;
      case 'reviewed':
        return 2;
      case 'interviewing':
        return 3;
      case 'accepted':
      case 'rejected':
        return 4;
      default:
        return 1;
    }
  }

  factory ApplicationItem.fromJson(Map<String, dynamic> json) {
    return ApplicationItem(
      id: json['id']?.toString() ?? '',
      jobId: json['job_id']?.toString() ?? '',
      jobTitle: json['job_title']?.toString() ?? 'Lowongan Magang',
      company: json['company']?.toString() ?? 'Perusahaan Mitra',
      mahasiswaId: json['mahasiswa_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
