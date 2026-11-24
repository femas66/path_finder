import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/core/errors/error_mapper.dart';
import 'models/create_story_request.dart';
import 'models/story_response.dart';

class StoryRemoteSource {
  StoryRemoteSource(this._dio);

  final Dio _dio;

  String get _storiesPath {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (baseUrl.endsWith('/api')) {
      return '/stories';
    }
    return '/api/stories';
  }

  /// Mengirim cerita reflektif baru (POST /api/stories)
  Future<StoryResponse> submitStory(CreateStoryRequest request) async {
    try {
      final response = await _dio.post(
        _storiesPath,
        data: request.toJson(),
      );

      final storyResponse = StoryResponse.fromJson(_asMap(response.data));

      if (!storyResponse.success) {
        throw ValidationException(
          message: storyResponse.message ?? 'Cerita gagal dikirim.',
          statusCode: response.statusCode ?? 422,
        );
      }

      if (storyResponse.data == null) {
        throw const UnexpectedException(
          message: 'Data cerita kosong dari server.',
        );
      }

      return storyResponse;
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Mengambil cerita aktif terakhir mahasiswa (GET /api/stories/me)
  Future<StoryResponse?> getLatestStory() async {
    try {
      final response = await _dio.get('$_storiesPath/me');
      final storyResponse = StoryResponse.fromJson(_asMap(response.data));
      if (!storyResponse.success || storyResponse.data == null) {
        return null;
      }
      return storyResponse;
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 404) {
        return null;
      }
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Memperbarui cerita yang sudah ada (PUT /api/stories/:id)
  Future<StoryResponse> updateStory(String id, String content) async {
    try {
      final response = await _dio.put(
        '$_storiesPath/$id',
        data: {'content': content},
      );

      final storyResponse = StoryResponse.fromJson(_asMap(response.data));

      if (!storyResponse.success) {
        throw ValidationException(
          message: storyResponse.message ?? 'Cerita gagal diperbarui.',
          statusCode: response.statusCode ?? 422,
        );
      }

      return storyResponse;
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  Map<String, dynamic> _asMap(dynamic rawData) {
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) return Map<String, dynamic>.from(rawData);
    if (rawData is String && rawData.trim().isNotEmpty) {
      final decoded = jsonDecode(rawData);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }
}
