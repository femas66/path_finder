import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/story/data/story_remote_source.dart';
import 'package:path_finder/features/story/data/story_repository_impl.dart';

void main() {
  group('StoryRepositoryImpl Tests', () {
    const successJsonResponse = {
      'success': true,
      'message': 'Cerita berhasil disimpan dan sedang dianalisis',
      'data': {
        'id': 'story_7d1c9a54',
        'content': 'Saya suka membuat prototipe antarmuka aplikasi.',
        'word_count': 8,
        'analysis_status': 'processing',
        'created_at': '2026-11-18T09:24:00Z',
      },
    };

    late StoryRepositoryImpl repository;

    setUp(() {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: successJsonResponse,
              ),
            );
          },
        ),
      );

      repository = StoryRepositoryImpl(
        remoteSource: StoryRemoteSource(dio),
      );
    });

    test('submitStory returns a UserStory entity from the API response',
        () async {
      final story = await repository.submitStory(
        content: 'Saya suka membuat prototipe antarmuka aplikasi.',
      );

      expect(story.id, equals('story_7d1c9a54'));
      expect(
        story.content,
        equals('Saya suka membuat prototipe antarmuka aplikasi.'),
      );
      expect(story.wordCount, equals(8));
      expect(story.isProcessing, isTrue);
      expect(story.createdAt, isNotNull);
    });
  });
}
