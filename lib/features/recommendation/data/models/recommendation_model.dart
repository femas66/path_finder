import '../../domain/entities/recommendation.dart';

class RecommendationModel {
  const RecommendationModel({
    required this.id,
    required this.studentId,
    required this.storyId,
    this.generatedAt,
    this.schemaVersion = '1.0',
    this.modelVersion = '',
    this.topK = 3,
    this.status = 'ok',
    this.profile = const RecommendationProfileModel(),
    this.items = const [],
  });

  final String id;
  final String studentId;
  final String storyId;
  final String? generatedAt;
  final String schemaVersion;
  final String modelVersion;
  final int topK;
  final String status;
  final RecommendationProfileModel profile;
  final List<RecommendationItemModel> items;

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    final rawProfile = json['profile'];
    final rawItems = json['items'];

    return RecommendationModel(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      storyId: json['story_id']?.toString() ?? '',
      generatedAt: json['generated_at']?.toString(),
      schemaVersion: json['schema_version']?.toString() ?? '1.0',
      modelVersion: json['model_version']?.toString() ?? '',
      topK: _asInt(json['top_k']) ?? 3,
      status: json['status']?.toString() ?? 'ok',
      profile: rawProfile is Map<String, dynamic>
          ? RecommendationProfileModel.fromJson(rawProfile)
          : const RecommendationProfileModel(),
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(RecommendationItemModel.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'story_id': storyId,
      'generated_at': generatedAt,
      'schema_version': schemaVersion,
      'model_version': modelVersion,
      'top_k': topK,
      'status': status,
      'profile': profile.toJson(),
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };
  }

  Recommendation toEntity() {
    return Recommendation(
      id: id,
      studentId: studentId,
      storyId: storyId,
      generatedAt: generatedAt != null ? DateTime.tryParse(generatedAt!) : null,
      schemaVersion: schemaVersion,
      modelVersion: modelVersion,
      topK: topK,
      status: status,
      profile: profile.toEntity(),
      items: items.map((item) => item.toEntity()).toList(growable: false),
    );
  }
}

class RecommendationProfileModel {
  const RecommendationProfileModel({
    this.hardSkills = const [],
    this.softSkills = const [],
    this.interests = const [],
    this.profileStatus = 'tanpa_skill',
  });

  final List<String> hardSkills;
  final List<String> softSkills;
  final List<String> interests;
  final String profileStatus;

  factory RecommendationProfileModel.fromJson(Map<String, dynamic> json) {
    return RecommendationProfileModel(
      hardSkills: _asStringList(json['hard_skills']),
      softSkills: _asStringList(json['soft_skills']),
      interests: _asStringList(json['interests']),
      profileStatus: json['profile_status']?.toString() ?? 'tanpa_skill',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hard_skills': hardSkills,
      'soft_skills': softSkills,
      'interests': interests,
      'profile_status': profileStatus,
    };
  }

  RecommendationProfile toEntity() {
    return RecommendationProfile(
      hardSkills: hardSkills,
      softSkills: softSkills,
      interests: interests,
      profileStatus: profileStatus,
    );
  }
}

class RecommendationItemModel {
  const RecommendationItemModel({
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
  final int? matchingScore;
  final double? cosineSimilarity;
  final int? readinessScore;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final String scoreStatus;
  final int? rank;

  factory RecommendationItemModel.fromJson(Map<String, dynamic> json) {
    return RecommendationItemModel(
      jobId: json['job_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      workType: json['work_type']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      sourceUrl: json['source_url']?.toString() ?? '',
      matchingScore: _asInt(json['matching_score']),
      cosineSimilarity: _asDouble(json['cosine_similarity']),
      readinessScore: _asInt(json['readiness_score']),
      matchedSkills: _asStringList(json['matched_skills']),
      missingSkills: _asStringList(json['missing_skills']),
      scoreStatus: json['score_status']?.toString() ?? 'skor_belum_tersedia',
      rank: _asInt(json['rank']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'title': title,
      'category': category,
      'company': company,
      'location': location,
      'work_type': workType,
      'source': source,
      'source_url': sourceUrl,
      'matching_score': matchingScore,
      'cosine_similarity': cosineSimilarity,
      'readiness_score': readinessScore,
      'matched_skills': matchedSkills,
      'missing_skills': missingSkills,
      'score_status': scoreStatus,
      'rank': rank,
    };
  }

  RecommendationItem toEntity() {
    return RecommendationItem(
      jobId: jobId,
      title: title,
      category: category,
      company: company,
      location: location,
      workType: workType,
      source: source,
      sourceUrl: sourceUrl,
      matchingScore: matchingScore,
      cosineSimilarity: cosineSimilarity,
      readinessScore: readinessScore,
      matchedSkills: matchedSkills,
      missingSkills: missingSkills,
      scoreStatus: scoreStatus,
      rank: rank,
    );
  }
}

int? _asInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString() ?? '')
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
