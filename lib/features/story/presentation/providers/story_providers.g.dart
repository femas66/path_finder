// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storyRemoteSource)
final storyRemoteSourceProvider = StoryRemoteSourceProvider._();

final class StoryRemoteSourceProvider
    extends
        $FunctionalProvider<
          StoryRemoteSource,
          StoryRemoteSource,
          StoryRemoteSource
        >
    with $Provider<StoryRemoteSource> {
  StoryRemoteSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storyRemoteSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storyRemoteSourceHash();

  @$internal
  @override
  $ProviderElement<StoryRemoteSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StoryRemoteSource create(Ref ref) {
    return storyRemoteSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoryRemoteSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoryRemoteSource>(value),
    );
  }
}

String _$storyRemoteSourceHash() => r'b4e036fc6480c2230e00588f7a3da54b4bfff003';

@ProviderFor(storyRepository)
final storyRepositoryProvider = StoryRepositoryProvider._();

final class StoryRepositoryProvider
    extends
        $FunctionalProvider<StoryRepository, StoryRepository, StoryRepository>
    with $Provider<StoryRepository> {
  StoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storyRepositoryHash();

  @$internal
  @override
  $ProviderElement<StoryRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoryRepository create(Ref ref) {
    return storyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoryRepository>(value),
    );
  }
}

String _$storyRepositoryHash() => r'bd3bf669aa2f4e8c24be7991ba47bf8a18b9c491';
