import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/config/env.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/core/errors/error_mapper.dart';

void main() {
  group('ErrorMapper connection messages', () {
    DioException build(DioExceptionType type) {
      return DioException(
        requestOptions: RequestOptions(path: '/api/auth/register'),
        type: type,
      );
    }

    test('timeout mentions the backend address being used', () {
      final exception = ErrorMapper.fromDioException(
        build(DioExceptionType.connectionTimeout),
      );

      expect(exception, isA<NetworkException>());
      expect(exception.message, contains('timeout'));
      expect(exception.message, contains(Env.baseUrl));
      expect(exception.message, contains('Pastikan backend sudah berjalan'));
    });

    test('connection error mentions the backend address being used', () {
      final exception = ErrorMapper.fromDioException(
        build(DioExceptionType.connectionError),
      );

      expect(exception, isA<NetworkException>());
      expect(exception.message, contains(Env.baseUrl));
      expect(exception.message, contains('go run ./cmd/web'));
    });

    test('receive timeout is also reported as a server problem', () {
      final exception = ErrorMapper.fromDioException(
        build(DioExceptionType.receiveTimeout),
      );

      expect(exception, isA<NetworkException>());
      expect(exception.message, contains(Env.baseUrl));
    });

    test('server error message is read from the message field', () {
      final exception = ErrorMapper.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/auth/register'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/register'),
            statusCode: 409,
            data: const {
              'success': false,
              'message': 'email sudah terdaftar',
              'errors': 'email sudah terdaftar',
            },
          ),
        ),
      );

      expect(exception.message, equals('email sudah terdaftar'));
    });

    test('400 validation error keeps the backend message', () {
      final exception = ErrorMapper.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/stories'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/api/stories'),
            statusCode: 400,
            data: const {
              'success': false,
              'message': 'cerita minimal 50 karakter dan maksimal 2000 karakter',
            },
          ),
        ),
      );

      expect(exception, isA<ValidationException>());
      expect(exception.message, contains('minimal 50 karakter'));
    });
  });
}
