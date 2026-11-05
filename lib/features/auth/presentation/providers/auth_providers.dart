import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_finder/core/network/network_providers.dart';
import 'package:path_finder/features/auth/data/auth_local_source.dart';
import 'package:path_finder/features/auth/data/auth_remote_source.dart';
import 'package:path_finder/features/auth/data/auth_repository_impl.dart';
import 'package:path_finder/features/auth/domain/auth_repository.dart';

part 'auth_providers.g.dart';

@riverpod
AuthLocalSource authLocalSource(Ref ref) {
  return AuthLocalSource();
}

@riverpod
AuthRemoteSource authRemoteSource(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRemoteSource(dio);
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final remoteSource = ref.watch(authRemoteSourceProvider);
  final localSource = ref.watch(authLocalSourceProvider);
  return AuthRepositoryImpl(
    remoteSource: remoteSource,
    localSource: localSource,
  );
}

@riverpod
Future<String?> authToken(Ref ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getToken();
}
