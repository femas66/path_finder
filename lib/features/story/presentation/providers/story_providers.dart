import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_finder/core/network/dio_client.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_providers.dart';
import 'package:path_finder/features/story/data/story_remote_source.dart';
import 'package:path_finder/features/story/data/story_repository_impl.dart';
import 'package:path_finder/features/story/domain/story_repository.dart';

part 'story_providers.g.dart';

@riverpod
StoryRemoteSource storyRemoteSource(Ref ref) {
  // `POST /stories` wajib menyertakan header Authorization. Dio khusus fitur
  // ini dipasangi pembaca token dari repository auth agar `core/` tetap tidak
  // mengimpor `features/` (berbagi data lewat provider).
  final authRepository = ref.watch(authRepositoryProvider);
  final dio = createDioClient(getToken: authRepository.getToken);
  return StoryRemoteSource(dio);
}

@riverpod
StoryRepository storyRepository(Ref ref) {
  final remoteSource = ref.watch(storyRemoteSourceProvider);
  return StoryRepositoryImpl(remoteSource: remoteSource);
}
