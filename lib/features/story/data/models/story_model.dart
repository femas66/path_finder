import 'package:path_finder/features/story/domain/entities/user_story.dart';

class StoryModel {
  const StoryModel({
    required this.id,
    required this.content,
    this.wordCount,
    this.analysisStatus,
    this.createdAt,
  });

  final String id;
  final String content;
  final int? wordCount;
  final String? analysisStatus;
  final String? createdAt;

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      wordCount: json['word_count'] is num
          ? (json['word_count'] as num).toInt()
          : int.tryParse(json['word_count']?.toString() ?? ''),
      analysisStatus: json['analysis_status']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'word_count': wordCount,
      'analysis_status': analysisStatus,
      'created_at': createdAt,
    };
  }

  UserStory toEntity() {
    return UserStory(
      id: id,
      content: content,
      wordCount: wordCount,
      analysisStatus: analysisStatus,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }
}
