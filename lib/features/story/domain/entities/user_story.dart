/// Narasi bebas pengguna tentang dirinya yang menjadi input analisis NLP.
class UserStory {
  const UserStory({
    required this.id,
    required this.content,
    this.wordCount,
    this.analysisStatus,
    this.createdAt,
  });

  final String id;
  final String content;
  final int? wordCount;

  /// Status analisis dari backend: `pending`, `done`, atau `failed`.
  final String? analysisStatus;

  final DateTime? createdAt;

  bool get isProcessing => analysisStatus == 'processing' || analysisStatus == 'pending';

  /// Backend menandai cerita selesai dianalisis dengan `done`
  /// (lihat `entity.StoryAnalysisDone`). Nilai `completed` tetap diterima
  /// agar data lama tidak dianggap belum selesai.
  bool get isCompleted =>
      analysisStatus == 'done' || analysisStatus == 'completed';

  bool get isFailed => analysisStatus == 'failed';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          wordCount == other.wordCount &&
          analysisStatus == other.analysisStatus &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      content.hashCode ^
      wordCount.hashCode ^
      analysisStatus.hashCode ^
      createdAt.hashCode;
}
