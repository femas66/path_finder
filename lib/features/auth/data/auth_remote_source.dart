import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/core/errors/error_mapper.dart';
import 'models/login_request.dart';
import 'models/login_response.dart';
import 'models/register_request.dart';
import 'models/register_response.dart';

class AuthRemoteSource {
  AuthRemoteSource(this._dio);

  final Dio _dio;

  /// Menyusun path endpoint dengan tetap mendukung `baseUrl` yang sudah
  /// menyertakan prefix `/api` maupun yang belum.
  String _path(String endpoint) {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (baseUrl.endsWith('/api')) {
      return endpoint;
    }
    return '/api$endpoint';
  }

  String get _loginPath => _path('/auth/login');

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        _loginPath,
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(_asMap(response.data));

      if (!loginResponse.success) {
        final errorMessage = loginResponse.message ??
            (loginResponse.errors is String
                ? loginResponse.errors as String
                : 'email atau password salah');
        throw UnauthorizedException(
          message: errorMessage,
          statusCode: response.statusCode ?? 401,
        );
      }

      if (loginResponse.data == null) {
        throw const UnexpectedException(
          message: 'Data autentikasi kosong dari server.',
        );
      }

      return loginResponse;
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        _path('/auth/register'),
        data: request.toJson(),
      );

      final registerResponse = RegisterResponse.fromJson(
        _asMap(response.data),
      );

      if (!registerResponse.success) {
        throw ValidationException(
          message: registerResponse.message ?? 'Pendaftaran akun gagal.',
          statusCode: response.statusCode ?? 400,
        );
      }

      if (registerResponse.data == null) {
        throw const UnexpectedException(
          message: 'Data pendaftaran kosong dari server.',
        );
      }

      return registerResponse;
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
