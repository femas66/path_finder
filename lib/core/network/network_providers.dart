import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dio_client.dart';

part 'network_providers.g.dart';

@riverpod
Dio dioClient(Ref ref) {
  return createDioClient();
}
