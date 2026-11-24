import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../domain/models/mahasiswa_profile.dart';

class MahasiswaRemoteSource {
  MahasiswaRemoteSource(this._dio);

  final Dio _dio;

  String get _mahasiswaBasePath {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (baseUrl.endsWith('/api')) {
      return '/mahasiswa';
    }
    return '/api/mahasiswa';
  }

  /// Mengambil profil mahasiswa saat ini.
  Future<MahasiswaProfile> getProfile() async {
    try {
      final response = await _dio.get('$_mahasiswaBasePath/profile');
      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is Map) {
        return MahasiswaProfile.fromJson(_asMap(rawData));
      }

      throw const UnexpectedException(message: 'Data profil mahasiswa tidak ditemukan.');
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Memperbarui informasi profil mahasiswa.
  Future<MahasiswaProfile> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put(
        '$_mahasiswaBasePath/profile',
        data: updates,
      );

      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is Map) {
        return MahasiswaProfile.fromJson(_asMap(rawData));
      }

      return await getProfile();
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Mengambil ringkasan dashboard mahasiswa.
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dio.get('$_mahasiswaBasePath/dashboard');
      final map = _asMap(response.data);
      final rawData = map['data'];
      if (rawData is Map) {
        return _asMap(rawData);
      }
      return map;
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
