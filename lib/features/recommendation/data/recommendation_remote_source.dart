import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/core/errors/error_mapper.dart';

import 'models/recommendation_response.dart';

/// Klien HTTP untuk modul rekomendasi.
///
/// Backend menghitung analisis secara sinkron, sehingga satu request sudah
/// mengembalikan hasil lengkap. `receiveTimeout` pada Dio menjadi batas atas
/// waktu tunggu aplikasi.
class RecommendationRemoteSource {
  RecommendationRemoteSource(this._dio);

  final Dio _dio;

  /// Menyusun path endpoint dengan tetap mendukung `baseUrl` yang sudah
  /// menyertakan prefix `/api` maupun yang belum.
  String get _recommendationsPath {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (baseUrl.endsWith('/api')) {
      return '/recommendations';
    }
    return '/api/recommendations';
  }

  /// Meminta analisis baru. `storyId` kosong berarti memakai cerita terakhir.
  Future<RecommendationResponse> generate({
    String? storyId,
    int? topK,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (storyId != null && storyId.isNotEmpty) {
        payload['story_id'] = storyId;
      }
      if (topK != null) {
        payload['top_k'] = topK;
      }

      final response = await _dio.post(
        _recommendationsPath,
        data: payload,
      );

      return _parse(response);
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (error, stackTrace) {
      if (error is AppException) rethrow;
      throw ErrorMapper.fromObject(error, stackTrace);
    }
  }

  /// Mengambil rekomendasi terakhir milik pengguna yang sedang login.
  Future<RecommendationResponse> latest() async {
    try {
      final response = await _dio.get('$_recommendationsPath/me/latest');
      return _parse(response);
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (error, stackTrace) {
      if (error is AppException) rethrow;
      throw ErrorMapper.fromObject(error, stackTrace);
    }
  }

  RecommendationResponse _parse(Response<dynamic> response) {
    final parsed = RecommendationResponse.fromJson(_asMap(response.data));

    if (!parsed.success) {
      throw ServerException(
        message: parsed.message ?? 'Rekomendasi gagal dibuat.',
        statusCode: response.statusCode,
      );
    }

    if (parsed.data == null) {
      throw const UnexpectedException(
        message: 'Data rekomendasi kosong dari server.',
      );
    }

    return parsed;
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
