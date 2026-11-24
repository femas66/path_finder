import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import 'models/admin_mahasiswa_model.dart';

class AdminRemoteSource {
  AdminRemoteSource(this._dio);

  final Dio _dio;

  String get _adminBasePath {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (baseUrl.endsWith('/api')) {
      return '/admin';
    }
    return '/api/admin';
  }

  /// Mengambil data dashboard admin (GET /api/admin/dashboard)
  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final response = await _dio.get('$_adminBasePath/dashboard');
      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is Map) {
        return AdminDashboardStats.fromJson(_asMap(rawData));
      }

      return AdminDashboardStats.fromJson(map);
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Mengambil daftar seluruh mahasiswa (GET /api/admin/mahasiswa)
  Future<List<AdminMahasiswaItem>> listMahasiswa({
    int page = 1,
    int size = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _dio.get(
        '$_adminBasePath/mahasiswa',
        queryParameters: queryParams,
      );

      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is List) {
        return rawData
            .map((item) => AdminMahasiswaItem.fromJson(_asMap(item)))
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

  /// Menambahkan akun mahasiswa baru (POST /api/admin/mahasiswa)
  Future<AdminMahasiswaItem> createMahasiswa({
    required String name,
    required String email,
    required String nim,
    String? profilePicture,
    String? cv,
    String? portfolioUrl,
  }) async {
    try {
      final payload = {
        'name': name,
        'email': email,
        'nim': nim,
        if (profilePicture != null && profilePicture.isNotEmpty)
          'profile_picture': profilePicture,
        if (cv != null && cv.isNotEmpty) 'cv': cv,
        if (portfolioUrl != null && portfolioUrl.isNotEmpty)
          'portfolio_url': portfolioUrl,
      };

      final response = await _dio.post('$_adminBasePath/mahasiswa', data: payload);
      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is Map) {
        return AdminMahasiswaItem.fromJson(_asMap(rawData));
      }

      throw const UnexpectedException(message: 'Gagal membuat akun mahasiswa.');
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Mengambil detail satu mahasiswa (GET /api/admin/mahasiswa/:id)
  Future<AdminMahasiswaItem> getMahasiswa(String id) async {
    try {
      final response = await _dio.get('$_adminBasePath/mahasiswa/$id');
      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is Map) {
        return AdminMahasiswaItem.fromJson(_asMap(rawData));
      }

      throw const UnexpectedException(message: 'Mahasiswa tidak ditemukan.');
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Memperbarui akun mahasiswa (PUT /api/admin/mahasiswa/:id)
  Future<AdminMahasiswaItem> updateMahasiswa(
    String id, {
    String? name,
    String? email,
    String? nim,
    String? password,
    String? profilePicture,
    String? cv,
    String? portfolioUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (name != null && name.isNotEmpty) 'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (nim != null && nim.isNotEmpty) 'nim': nim,
        if (password != null && password.isNotEmpty) 'password': password,
        if (profilePicture != null && profilePicture.isNotEmpty)
          'profile_picture': profilePicture,
        if (cv != null && cv.isNotEmpty) 'cv': cv,
        if (portfolioUrl != null && portfolioUrl.isNotEmpty)
          'portfolio_url': portfolioUrl,
      };

      final response = await _dio.put('$_adminBasePath/mahasiswa/$id', data: payload);
      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is Map) {
        return AdminMahasiswaItem.fromJson(_asMap(rawData));
      }

      return await getMahasiswa(id);
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Menghapus akun mahasiswa (DELETE /api/admin/mahasiswa/:id)
  Future<bool> deleteMahasiswa(String id) async {
    try {
      final response = await _dio.delete('$_adminBasePath/mahasiswa/$id');
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
