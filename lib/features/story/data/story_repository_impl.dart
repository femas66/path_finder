import 'package:path_finder/features/story/domain/entities/user_story.dart';
import 'package:path_finder/features/story/domain/story_repository.dart';
import 'models/create_story_request.dart';
import 'story_remote_source.dart';

class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl({required this.remoteSource});

  final StoryRemoteSource remoteSource;

  @override
  Future<UserStory> submitStory({required String content}) async {
    final response = await remoteSource.submitStory(
      CreateStoryRequest(content: content),
    );

    return response.data!.toEntity();
  }
}
