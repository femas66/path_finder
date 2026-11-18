import 'package:path_finder/features/recommendation/domain/entities/recommendation.dart';
import 'package:path_finder/features/recommendation/domain/recommendation_repository.dart';

import 'recommendation_remote_source.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  RecommendationRepositoryImpl({required this.remoteSource});

  final RecommendationRemoteSource remoteSource;

  @override
  Future<Recommendation> generate({String? storyId, int? topK}) async {
    final response = await remoteSource.generate(storyId: storyId, topK: topK);
    return response.data!.toEntity();
  }

  @override
  Future<Recommendation> latest() async {
    final response = await remoteSource.latest();
    return response.data!.toEntity();
  }
}
