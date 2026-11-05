import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/core/errors/error_mapper.dart';
import 'models/login_request.dart';
import 'models/login_response.dart';

class AuthRemoteSource {
  AuthRemoteSource(this._dio);

  final Dio _dio;

  String get _loginPath {
    final baseUrl = _dio.options.baseUrl;
    if (baseUrl.endsWith('/api/v1') || baseUrl.endsWith('/api/v1/')) {
      return '/auth/login';
    }
    return '/api/v1/auth/login';
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        _loginPath,
        data: request.toJson(),
      );

      final dynamic rawData = response.data;
      final Map<String, dynamic> dataMap = rawData is Map<String, dynamic>
          ? rawData
          : (rawData is String
              ? jsonDecode(rawData) as Map<String, dynamic>
              : <String, dynamic>{});

      final loginResponse = LoginResponse.fromJson(dataMap);

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
}
