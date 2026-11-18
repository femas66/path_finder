import 'entities/user_story.dart';

abstract class StoryRepository {
  /// Mengirim cerita diri pengguna ke backend untuk dianalisis.
  ///
  /// Melempar `AppException` bila request gagal.
  Future<UserStory> submitStory({required String content});
}
