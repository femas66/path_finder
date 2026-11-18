import 'recommendation_model.dart';

class RecommendationResponse {
  const RecommendationResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  final bool success;
  final String? message;
  final RecommendationModel? data;
  final dynamic errors;

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    return RecommendationResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
      data: rawData is Map<String, dynamic>
          ? RecommendationModel.fromJson(rawData)
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
