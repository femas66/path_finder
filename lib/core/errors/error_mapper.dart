import 'package:dio/dio.dart';
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

  static AppException fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Koneksi ke server timeout. Silakan periksa jaringan Anda.',
          originalError: dioException,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Gagal terhubung ke backend. Pastikan server Python aktif.',
          originalError: dioException,
        );

      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final responseData = dioException.response?.data;

        String message = 'Terjadi kesalahan dari server.';
        if (responseData is Map) {
          if (responseData['detail'] != null) {
            message = responseData['detail'].toString();
          } else if (responseData['message'] != null) {
            message = responseData['message'].toString();
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
              message: message,
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
