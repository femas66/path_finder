import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/env.dart';
import 'app_exception.dart';

class ErrorMapper {
  ErrorMapper._();

  static AppException fromObject(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return fromDioException(error);
    }

    return UnexpectedException(
      message: 'Terjadi kesalahan sistem: ${error.toString()}',
      originalError: error,
    );
  }

  /// Alamat backend yang sedang dipakai, ikut ditampilkan pada pesan error
  /// koneksi supaya penyebabnya bisa langsung dikenali (mis. masih mengarah ke
  /// `127.0.0.1` padahal jalan di emulator Android).
  static String get _target => Env.baseUrl;

  static AppException fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message:
              'Server tidak merespons (timeout) di $_target. '
              'Pastikan backend sudah berjalan, lalu coba lagi.',
          originalError: dioException,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message:
              'Tidak bisa terhubung ke backend di $_target. '
              'Jalankan backend (go run ./cmd/web) dan pastikan alamatnya benar.',
          originalError: dioException,
        );

      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final dynamic rawData = dioException.response?.data;
        Map? responseData;
        if (rawData is Map) {
          responseData = rawData;
        } else if (rawData is String) {
          try {
            final decoded = jsonDecode(rawData);
            if (decoded is Map) responseData = decoded;
          } catch (_) {}
        }

        String message = 'Terjadi kesalahan dari server.';
        if (responseData != null) {
          if (responseData['message'] != null &&
              responseData['message'].toString().trim().isNotEmpty) {
            message = responseData['message'].toString();
          } else if (responseData['errors'] != null &&
              responseData['errors'].toString().trim().isNotEmpty) {
            message = responseData['errors'].toString();
          } else if (responseData['detail'] != null &&
              responseData['detail'].toString().trim().isNotEmpty) {
            message = responseData['detail'].toString();
          } else if (responseData['error'] is Map &&
              responseData['error']['message'] != null) {
            message = responseData['error']['message'].toString();
          }
        }

        switch (statusCode) {
          case 400:
            return ValidationException(
              message: message,
              statusCode: statusCode,
              originalError: dioException,
            );
          case 401:
          case 403:
            return UnauthorizedException(
              message: message.isNotEmpty &&
                      message != 'Terjadi kesalahan dari server.'
                  ? message
                  : 'email atau password salah',
              statusCode: statusCode,
              originalError: dioException,
            );
          case 404:
            return NotFoundException(
              message: message,
              statusCode: statusCode,
              originalError: dioException,
            );
          case 422:
            return ValidationException(
              message: message,
              statusCode: statusCode,
              originalError: dioException,
            );
          case 500:
          case 502:
          case 503:
            return ServerException(
              message: 'Server sedang mengalami gangguan ($statusCode).',
              statusCode: statusCode,
              originalError: dioException,
            );
          default:
            return ServerException(
              message: message,
              statusCode: statusCode,
              originalError: dioException,
            );
        }

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Permintaan dibatalkan.',
          originalError: dioException,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Sertifikat keamanan tidak valid.',
          originalError: dioException,
        );

      case DioExceptionType.unknown:
      default:
        return UnexpectedException(
          message: dioException.message ?? 'Kesalahan jaringan tidak dikenal.',
          originalError: dioException,
        );
    }
  }
}
