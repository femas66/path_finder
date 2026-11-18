import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/features/story/data/models/create_story_request.dart';
import 'package:path_finder/features/story/data/story_remote_source.dart';

void main() {
  group('StoryRemoteSource API Response Tests', () {
    const successJsonResponse = {
      'success': true,
      'message': 'Cerita berhasil disimpan dan sedang dianalisis',
      'data': {
        'id': 'story_7d1c9a54',
        'content': 'Saya suka mengotak-atik tampilan aplikasi.',
        'word_count': 34,
        'analysis_status': 'processing',
        'created_at': '2026-11-18T09:24:00Z',
      },
    };

    const validationErrorJson = {
      'success': false,
      'error': {
        'code': 'STORY_TOO_SHORT',
        'message': 'Cerita terlalu pendek untuk dianalisis',
        'details': [
          {'field': 'content', 'issue': 'Minimal 50 karakter'},
        ],
      },
    };

    const unauthorizedJson = {
      'success': false,
      'error': {
        'code': 'TOKEN_EXPIRED',
        'message': 'Sesi autentikasi telah kedaluwarsa.',
        'details': null,
      },
    };

    test('submitStory returns StoryResponse on 201 Created', () async {
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

      final remoteSource = StoryRemoteSource(dio);
      final response = await remoteSource.submitStory(
        const CreateStoryRequest(content: 'Saya suka tampilan aplikasi.'),
      );

      expect(response.success, isTrue);
      expect(response.data!.id, equals('story_7d1c9a54'));
      expect(response.data!.analysisStatus, equals('processing'));
    });

    test('submitStory sends content to /stories endpoint', () async {
      final dio = Dio();
      String? capturedPath;
      String? capturedMethod;
      dynamic capturedBody;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedPath = options.path;
            capturedMethod = options.method;
            capturedBody = options.data;
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

      final remoteSource = StoryRemoteSource(dio);
      await remoteSource.submitStory(
        const CreateStoryRequest(content: 'Cerita saya.'),
      );

      expect(capturedMethod, equals('POST'));
      expect(capturedPath, endsWith('/stories'));
      expect(capturedBody, equals({'content': 'Cerita saya.'}));
    });

    test('submitStory maps 422 response to ValidationException', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 422,
                  data: validationErrorJson,
                ),
              ),
            );
          },
        ),
      );

      final remoteSource = StoryRemoteSource(dio);

      expect(
        () => remoteSource.submitStory(
          const CreateStoryRequest(content: 'Pendek'),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            equals('Cerita terlalu pendek untuk dianalisis'),
          ),
        ),
      );
    });

    test('submitStory maps 401 response to UnauthorizedException', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: unauthorizedJson,
                ),
              ),
            );
          },
        ),
      );

      final remoteSource = StoryRemoteSource(dio);

      expect(
        () => remoteSource.submitStory(
          const CreateStoryRequest(content: 'Cerita yang cukup panjang.'),
        ),
        throwsA(
          isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            equals('Sesi autentikasi telah kedaluwarsa.'),
          ),
        ),
      );
    });

    test('submitStory throws ValidationException when success is false', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': false,
                  'message': 'Cerita gagal dikirim',
                  'data': null,
                },
              ),
            );
          },
        ),
      );

      final remoteSource = StoryRemoteSource(dio);

      expect(
        () => remoteSource.submitStory(
          const CreateStoryRequest(content: 'Cerita yang cukup panjang.'),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
