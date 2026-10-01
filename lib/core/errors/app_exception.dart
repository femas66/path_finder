sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  final String message;
  final int? statusCode;
  final Object? originalError;

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Sesi telah berakhir atau tidak memiliki izin akses.',
    super.statusCode = 401,
    super.originalError,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Data atau endpoint tidak ditemukan.',
    super.statusCode = 404,
    super.originalError,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode = 422,
    super.originalError,
  });
}

class UnexpectedException extends AppException {
  const UnexpectedException({
    super.message = 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.',
    super.statusCode,
    super.originalError,
  });
}
