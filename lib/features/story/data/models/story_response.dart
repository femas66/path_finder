import 'story_model.dart';

class StoryResponse {
  const StoryResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  final bool success;
  final String? message;
  final StoryModel? data;
  final dynamic errors;

  factory StoryResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    return StoryResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
      data: rawData is Map<String, dynamic>
          ? StoryModel.fromJson(rawData)
          : null,
      errors: json['errors'] ?? json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'errors': errors,
    };
  }
}
