import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_providers.dart';
import 'dio_client.dart';

part 'network_providers.g.dart';

@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  return createDioClient(
    getToken: () async {
      try {
        final localSource = ref.read(authLocalSourceProvider);
        return await localSource.getToken();
      } catch (_) {
        return null;
      }
    },
  );
}
