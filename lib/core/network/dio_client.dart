import 'package:dio/dio.dart';
import '../config/env.dart';

Dio createDioClient() {
  final options = BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: Env.connectTimeout,
    receiveTimeout: Env.receiveTimeout,
    sendTimeout: Env.sendTimeout,
    headers: const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options);

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ),
  );

  return dio;
}
