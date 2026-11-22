import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/core/errors/error_mapper.dart';

import 'models/login_request.dart';
import 'models/login_response.dart';
import 'models/register_request.dart';
import 'models/register_response.dart';
import 'models/user_model.dart';

class AuthRemoteSource {
  AuthRemoteSource(this._dio);

  final Dio _dio;

  static const String primaryLoginPath = '/api/auth/login';
  static const String fallbackLoginPath = '/api/users/login';

  static const String primaryMePath = '/api/auth/me';
  static const String fallbackMePath = '/api/users/current';

  /// Menyusun path endpoint dengan tetap mendukung `baseUrl` yang sudah
  /// menyertakan prefix `/api` maupun yang belum.
  String _path(String endpoint) {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (baseUrl.endsWith('/api')) {
      return endpoint;
    }
    return '/api$endpoint';
  }

  Future<LoginResponse> login(LoginRequest request) async {
    Response response;
    try {
      response = await _dio.post(primaryLoginPath, data: request.toJson());
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 404) {
        try {
          response = await _dio.post(fallbackLoginPath, data: request.toJson());
        } on DioException catch (fallbackError) {
          throw _mapDioError(fallbackError);
        } catch (e, stackTrace) {
          if (e is AppException) rethrow;
          throw ErrorMapper.fromObject(e, stackTrace);
        }
      } else {
        throw _mapDioError(dioError);
      }
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }

    return _processResponse(response);
  }

  LoginResponse _processResponse(Response response) {
    final dynamic rawData = response.data;
    final Map<String, dynamic> dataMap;
    if (rawData is Map<String, dynamic>) {
      dataMap = rawData;
    } else if (rawData is String) {
      try {
        dataMap = jsonDecode(rawData) as Map<String, dynamic>;
      } catch (_) {
        throw const UnexpectedException(
          message: 'Format respon dari server tidak valid.',
        );
      }
    } else {
      dataMap = <String, dynamic>{};
    }

    final loginResponse = LoginResponse.fromJson(dataMap);

    if (!loginResponse.success) {
      final errorMessage =
          loginResponse.message ??
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
  }

  Future<UserModel> getCurrentUser({String? token}) async {
    Response response;
    final options = token != null && token.isNotEmpty
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    try {
      response = await _dio.get(primaryMePath, options: options);
    } on DioException catch (dioError) {
      if (dioError.response?.statusCode == 404) {
        try {
          response = await _dio.get(fallbackMePath, options: options);
        } on DioException catch (fallbackError) {
          throw _mapDioError(fallbackError);
        } catch (e, stackTrace) {
          if (e is AppException) rethrow;
          throw ErrorMapper.fromObject(e, stackTrace);
        }
      } else {
        throw _mapDioError(dioError);
      }
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }

    final dynamic rawData = response.data;
    final Map<String, dynamic> dataMap;
    if (rawData is Map<String, dynamic>) {
      dataMap = rawData;
    } else if (rawData is String) {
      try {
        dataMap = jsonDecode(rawData) as Map<String, dynamic>;
      } catch (_) {
        throw const UnexpectedException(
          message: 'Format respon dari server tidak valid.',
        );
      }
    } else {
      dataMap = <String, dynamic>{};
    }

    final success = dataMap['success'] as bool? ?? false;
    final userJson = dataMap['data'] as Map<String, dynamic>?;

    if (!success || userJson == null) {
      final errorMessage =
          dataMap['message']?.toString() ??
          dataMap['errors']?.toString() ??
          'Missing or malformed JWT';
      throw UnauthorizedException(
        message: errorMessage,
        statusCode: response.statusCode ?? 401,
      );
    }

    return UserModel.fromJson(userJson);
  }

  AppException _mapDioError(DioException dioError) {
    if (dioError.response?.statusCode == 401) {
      final dynamic rawData = dioError.response?.data;
      Map? dataMap;
      if (rawData is Map) {
        dataMap = rawData;
      } else if (rawData is String) {
        try {
          final decoded = jsonDecode(rawData);
          if (decoded is Map) dataMap = decoded;
        } catch (_) {}
      }

      String message = 'email atau password salah';
      if (dataMap != null) {
        if (dataMap['message'] != null &&
            dataMap['message'].toString().trim().isNotEmpty) {
          message = dataMap['message'].toString();
        } else if (dataMap['errors'] != null &&
            dataMap['errors'].toString().trim().isNotEmpty) {
          message = dataMap['errors'].toString();
        }
      }

      return UnauthorizedException(
        message: message,
        statusCode: 401,
        originalError: dioError,
      );
    }

    return ErrorMapper.fromDioException(dioError);
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
