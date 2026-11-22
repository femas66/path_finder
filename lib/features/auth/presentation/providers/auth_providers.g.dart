// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authLocalSource)
final authLocalSourceProvider = AuthLocalSourceProvider._();

final class AuthLocalSourceProvider
    extends
        $FunctionalProvider<AuthLocalSource, AuthLocalSource, AuthLocalSource>
    with $Provider<AuthLocalSource> {
  AuthLocalSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLocalSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLocalSourceHash();

  @$internal
  @override
  $ProviderElement<AuthLocalSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthLocalSource create(Ref ref) {
    return authLocalSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthLocalSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthLocalSource>(value),
    );
  }
}

String _$authLocalSourceHash() => r'ea47a70b97092c1fda56c1a96deb6f575516b1b3';

@ProviderFor(authRemoteSource)
final authRemoteSourceProvider = AuthRemoteSourceProvider._();

final class AuthRemoteSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteSource,
          AuthRemoteSource,
          AuthRemoteSource
        >
    with $Provider<AuthRemoteSource> {
  AuthRemoteSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRemoteSource create(Ref ref) {
    return authRemoteSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteSource>(value),
    );
  }
}

String _$authRemoteSourceHash() => r'3474361a7f783a37bd0e1965c7e322bba5465bc8';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'61d9c25802b82036e8bb3c4db3ed7ecb050905b2';

@ProviderFor(authToken)
final authTokenProvider = AuthTokenProvider._();

final class AuthTokenProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  AuthTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authTokenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authTokenHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return authToken(ref);
  }
}

String _$authTokenHash() => r'49e4cac83834cdbac8ede26f2e47cfd0321a85cd';
