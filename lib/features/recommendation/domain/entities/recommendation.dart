/// Keahlian yang berhasil dikenali backend dari cerita pengguna.
class RecommendationProfile {
  const RecommendationProfile({
    this.hardSkills = const [],
    this.softSkills = const [],
    this.interests = const [],
    this.profileStatus = 'tanpa_skill',
  });

  final List<String> hardSkills;
  final List<String> softSkills;
  final List<String> interests;

  /// `lengkap` atau `tanpa_skill`.
  final String profileStatus;

  bool get hasSkills => hardSkills.isNotEmpty || softSkills.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationProfile &&
          runtimeType == other.runtimeType &&
          _listEquals(hardSkills, other.hardSkills) &&
          _listEquals(softSkills, other.softSkills) &&
          _listEquals(interests, other.interests) &&
          profileStatus == other.profileStatus;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(hardSkills),
        Object.hashAll(softSkills),
        Object.hashAll(interests),
        profileStatus,
      );
}

/// Satu lowongan beserta skor kecocokannya.
class RecommendationItem {
  const RecommendationItem({
    required this.jobId,
    required this.title,
    required this.category,
    this.company = '',
    this.location = '',
    this.workType = '',
    this.source = '',
    this.sourceUrl = '',
    this.matchingScore,
    this.cosineSimilarity,
    this.readinessScore,
    this.matchedSkills = const [],
    this.missingSkills = const [],
    this.scoreStatus = 'skor_belum_tersedia',
    this.rank,
  });

  final String jobId;
  final String title;
  final String category;
  final String company;
  final String location;
  final String workType;
  final String source;
  final String sourceUrl;

  /// Skor kecocokan 0-100. `null` bila backend belum bisa menghitungnya.
  final int? matchingScore;

  /// Kemiripan semantik 0-1. `null` selama encoder ML belum tersedia.
  final double? cosineSimilarity;

  /// Skor kesiapan kerja 0-100.
  final int? readinessScore;

  final List<String> matchedSkills;
  final List<String> missingSkills;

  /// `ok`, `skor_belum_tersedia`, `persyaratan_belum_tersedia`,
  /// atau `profil_tanpa_keterampilan`.
  final String scoreStatus;

  final int? rank;

  bool get hasScore => matchingScore != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationItem &&
          runtimeType == other.runtimeType &&
          jobId == other.jobId &&
          title == other.title &&
          category == other.category &&
          company == other.company &&
          location == other.location &&
          workType == other.workType &&
          source == other.source &&
          sourceUrl == other.sourceUrl &&
          matchingScore == other.matchingScore &&
          cosineSimilarity == other.cosineSimilarity &&
          readinessScore == other.readinessScore &&
          _listEquals(matchedSkills, other.matchedSkills) &&
          _listEquals(missingSkills, other.missingSkills) &&
          scoreStatus == other.scoreStatus &&
          rank == other.rank;

  @override
  int get hashCode => Object.hash(
        jobId,
        title,
        category,
        company,
        location,
        workType,
        source,
        sourceUrl,
        matchingScore,
        cosineSimilarity,
        readinessScore,
        Object.hashAll(matchedSkills),
        Object.hashAll(missingSkills),
        scoreStatus,
        rank,
      );
}

/// Hasil analisis cerita diri: daftar lowongan yang paling cocok.
class Recommendation {
  const Recommendation({
    required this.id,
    required this.studentId,
    required this.storyId,
    required this.generatedAt,
    this.schemaVersion = '1.0',
    this.modelVersion = '',
    this.topK = 3,
    this.status = 'ok',
    this.profile = const RecommendationProfile(),
    this.items = const [],
  });

  final String id;
  final String studentId;
  final String storyId;
  final DateTime? generatedAt;
  final String schemaVersion;
  final String modelVersion;
  final int topK;

  /// `ok`, `parsial`, atau `profil_tidak_lengkap`.
  final String status;

  final RecommendationProfile profile;
  final List<RecommendationItem> items;

  /// Backend tidak menemukan keahlian apa pun pada cerita pengguna.
  bool get isProfileIncomplete => status == 'profil_tidak_lengkap';

  bool get isEmpty => items.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recommendation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          storyId == other.storyId &&
          generatedAt == other.generatedAt &&
          schemaVersion == other.schemaVersion &&
          modelVersion == other.modelVersion &&
          topK == other.topK &&
          status == other.status &&
          profile == other.profile &&
          _listEquals(items, other.items);

  @override
  int get hashCode => Object.hash(
        id,
        studentId,
        storyId,
        generatedAt,
        schemaVersion,
        modelVersion,
        topK,
        status,
        profile,
        Object.hashAll(items),
      );
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
