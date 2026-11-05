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
        isAutoDispose: true,
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

String _$authLocalSourceHash() => r'c3709867adcf1c6567c1eca54384a39b76c490a9';

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
        isAutoDispose: true,
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

String _$authRemoteSourceHash() => r'72e392006fd5a75ef1dc6c790f68959e4096707b';

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
        isAutoDispose: true,
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

String _$authRepositoryHash() => r'b416eadfb74db0c88c21660e6010df8f7a8b2348';

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
        isAutoDispose: true,
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

String _$authTokenHash() => r'7c00ac296dd6d5c58de33ffba2c6342ed7dc84cd';
