import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../domain/models/job_vacancy.dart';

class JobRemoteSource {
  JobRemoteSource(this._dio);

  final Dio _dio;

  String get _jobsPath {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (baseUrl.endsWith('/api')) {
      return '/jobs';
    }
    return '/api/jobs';
  }

  /// Mengambil daftar lowongan dengan paginasi, pencarian, dan kategori.
  Future<List<JobVacancy>> getJobs({
    int page = 1,
    int size = 20,
    String? search,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (category != null && category.trim().isNotEmpty && category != 'Semua') {
        queryParams['category'] = category.trim();
      }

      final response = await _dio.get(
        _jobsPath,
        queryParameters: queryParams,
      );

      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is List) {
        return rawData
            .map((item) => JobVacancy.fromJson(_asMap(item)))
            .toList();
      }

      return const [];
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Mengambil detail lowongan berdasarkan ID.
  Future<JobVacancy> getJobDetail(String id) async {
    try {
      final response = await _dio.get('$_jobsPath/$id');
      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is Map) {
        return JobVacancy.fromJson(_asMap(rawData));
      }

      throw const UnexpectedException(message: 'Data lowongan tidak ditemukan.');
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Mendaftarkan lamaran magang pada lowongan tertentu (`POST /api/jobs/:id/apply`).
  Future<bool> applyJob(String jobId) async {
    try {
      final response = await _dio.post(
        '$_jobsPath/$jobId/apply',
        data: {'job_id': jobId},
      );

      final map = _asMap(response.data);
      return map['success'] == true;
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
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }
}
