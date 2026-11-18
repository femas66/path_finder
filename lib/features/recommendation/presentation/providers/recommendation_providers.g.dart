// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recommendationRemoteSource)
final recommendationRemoteSourceProvider =
    RecommendationRemoteSourceProvider._();

final class RecommendationRemoteSourceProvider
    extends
        $FunctionalProvider<
          RecommendationRemoteSource,
          RecommendationRemoteSource,
          RecommendationRemoteSource
        >
    with $Provider<RecommendationRemoteSource> {
  RecommendationRemoteSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationRemoteSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationRemoteSourceHash();

  @$internal
  @override
  $ProviderElement<RecommendationRemoteSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecommendationRemoteSource create(Ref ref) {
    return recommendationRemoteSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecommendationRemoteSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecommendationRemoteSource>(value),
    );
  }
}

String _$recommendationRemoteSourceHash() =>
    r'e762e36f17f5caf64d2bb72ff5832baecca34241';

@ProviderFor(recommendationRepository)
final recommendationRepositoryProvider = RecommendationRepositoryProvider._();

final class RecommendationRepositoryProvider
    extends
        $FunctionalProvider<
          RecommendationRepository,
          RecommendationRepository,
          RecommendationRepository
        >
    with $Provider<RecommendationRepository> {
  RecommendationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecommendationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecommendationRepository create(Ref ref) {
    return recommendationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecommendationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecommendationRepository>(value),
    );
  }
}

String _$recommendationRepositoryHash() =>
    r'6b5ab3d177f7333282c2e3592357e56bfe6f636b';
