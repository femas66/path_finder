import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/story/data/models/create_story_request.dart';
import 'package:path_finder/features/story/data/models/story_model.dart';
import 'package:path_finder/features/story/data/models/story_response.dart';
import 'package:path_finder/features/story/presentation/widgets/story_input_field.dart';

void main() {
  group('Story Models & Contract Mapping Tests', () {
    test('CreateStoryRequest serializes content into JSON body', () {
      const request = CreateStoryRequest(content: 'Saya suka frontend.');

      expect(request.toJson(), equals({'content': 'Saya suka frontend.'}));
    });

    test('StoryResponse parses 201 Created success payload', () {
      final response = StoryResponse.fromJson({
        'success': true,
        'message': 'Cerita berhasil disimpan dan sedang dianalisis',
        'data': {
          'id': 'story_7d1c9a54',
          'content': 'Saya suka mengotak-atik tampilan aplikasi.',
          'word_count': 34,
          'analysis_status': 'processing',
          'created_at': '2026-11-18T09:24:00Z',
        },
      });

      expect(response.success, isTrue);
      expect(response.message, contains('berhasil disimpan'));
      expect(response.data, isNotNull);
      expect(response.data!.id, equals('story_7d1c9a54'));
      expect(response.data!.wordCount, equals(34));
      expect(response.data!.analysisStatus, equals('processing'));
    });

    test('StoryResponse parses standard error envelope', () {
      final response = StoryResponse.fromJson({
        'success': false,
        'error': {
          'code': 'STORY_TOO_SHORT',
          'message': 'Cerita terlalu pendek untuk dianalisis',
          'details': [
            {'field': 'content', 'issue': 'Minimal 50 karakter'},
          ],
        },
      });

      expect(response.success, isFalse);
      expect(response.data, isNull);
      expect(response.errors, isA<Map<String, dynamic>>());
      expect(
        (response.errors as Map)['code'],
        equals('STORY_TOO_SHORT'),
      );
    });

    test('StoryModel.toEntity maps JSON fields to UserStory entity', () {
      const model = StoryModel(
        id: 'story_1',
        content: 'Cerita panjang tentang minat saya.',
        wordCount: 6,
        analysisStatus: 'processing',
        createdAt: '2026-11-18T09:24:00Z',
      );

      final entity = model.toEntity();

      expect(entity.id, equals('story_1'));
      expect(entity.content, equals('Cerita panjang tentang minat saya.'));
      expect(entity.wordCount, equals(6));
      expect(entity.isProcessing, isTrue);
      expect(entity.isCompleted, isFalse);
      expect(entity.createdAt, isNotNull);
      expect(entity.createdAt!.year, equals(2026));
    });

    test('StoryModel tolerates missing optional fields', () {
      final model = StoryModel.fromJson({
        'id': 'story_2',
        'content': 'Isi cerita.',
      });

      final entity = model.toEntity();

      expect(entity.wordCount, isNull);
      expect(entity.analysisStatus, isNull);
      expect(entity.createdAt, isNull);
      expect(entity.isProcessing, isFalse);
    });
  });

  group('StoryInputField Validation Rules', () {
    test('rejects empty content', () {
      expect(
        StoryInputField.validate('   '),
        equals('Cerita tidak boleh kosong'),
      );
    });

    test('rejects content shorter than minimum length', () {
      final message = StoryInputField.validate('Terlalu pendek');

      expect(message, isNotNull);
      expect(message, contains('minimal 50 karakter'));
    });

    test('accepts content that meets the minimum length', () {
      final content = 'a' * StoryInputField.minStoryLength;

      expect(StoryInputField.validate(content), isNull);
    });

    test('trims surrounding whitespace before counting characters', () {
      final content = '   ${'a' * StoryInputField.minStoryLength}   ';

      expect(StoryInputField.validate(content), isNull);
    });

    test('rejects content longer than maximum length', () {
      final content = 'a' * (StoryInputField.maxStoryLength + 1);

      expect(
        StoryInputField.validate(content),
        contains('maksimal'),
      );
    });
  });
}
