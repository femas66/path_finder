import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../domain/models/application_item.dart';

class ApplicationRemoteSource {
  ApplicationRemoteSource(this._dio);

  final Dio _dio;

  String get _applicationsPath {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (baseUrl.endsWith('/api')) {
      return '/mahasiswa/applications';
    }
    return '/api/mahasiswa/applications';
  }

  /// Mengambil seluruh riwayat lamaran yang diajukan oleh mahasiswa saat ini.
  Future<List<ApplicationItem>> getMyApplications() async {
    try {
      final response = await _dio.get(_applicationsPath);
      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is List) {
        return rawData
            .map((item) => ApplicationItem.fromJson(_asMap(item)))
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
