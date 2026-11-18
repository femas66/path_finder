import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/core/errors/error_mapper.dart';
import 'models/create_story_request.dart';
import 'models/story_response.dart';

class StoryRemoteSource {
  StoryRemoteSource(this._dio);

  final Dio _dio;

  /// Menyusun path endpoint dengan tetap mendukung `baseUrl` yang sudah
  /// menyertakan prefix `/api` maupun yang belum.
  String get _storiesPath {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (baseUrl.endsWith('/api')) {
      return '/stories';
    }
    return '/api/stories';
  }

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

  /// Response Dio bisa berupa `Map` atau `String` JSON mentah tergantung
  /// `responseType` dan konfigurasi interceptor.
  Map<String, dynamic> _asMap(dynamic rawData) {
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is String && rawData.trim().isNotEmpty) {
      final decoded = jsonDecode(rawData);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return <String, dynamic>{};
  }
}
