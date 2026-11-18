import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_finder/core/network/dio_client.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_providers.dart';
import 'package:path_finder/features/recommendation/data/recommendation_remote_source.dart';
import 'package:path_finder/features/recommendation/data/recommendation_repository_impl.dart';
import 'package:path_finder/features/recommendation/domain/recommendation_repository.dart';

part 'recommendation_providers.g.dart';

@riverpod
RecommendationRemoteSource recommendationRemoteSource(Ref ref) {
  // `POST /recommendations` wajib menyertakan header Authorization. Dio khusus
  // fitur ini dipasangi pembaca token dari repository auth agar `core/` tetap
  // tidak mengimpor `features/`.
  final authRepository = ref.watch(authRepositoryProvider);
  final dio = createDioClient(getToken: authRepository.getToken);
  return RecommendationRemoteSource(dio);
}

@riverpod
RecommendationRepository recommendationRepository(Ref ref) {
  final remoteSource = ref.watch(recommendationRemoteSourceProvider);
  return RecommendationRepositoryImpl(remoteSource: remoteSource);
}
