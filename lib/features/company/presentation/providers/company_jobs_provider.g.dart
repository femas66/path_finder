// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_jobs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(companyJobsRepository)
final companyJobsRepositoryProvider = CompanyJobsRepositoryProvider._();

final class CompanyJobsRepositoryProvider
    extends
        $FunctionalProvider<
          CompanyJobsRepository,
          CompanyJobsRepository,
          CompanyJobsRepository
        >
    with $Provider<CompanyJobsRepository> {
  CompanyJobsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companyJobsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companyJobsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CompanyJobsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CompanyJobsRepository create(Ref ref) {
    return companyJobsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompanyJobsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompanyJobsRepository>(value),
    );
  }
}

String _$companyJobsRepositoryHash() =>
    r'3f3e141750bf9e0e89375e2b121f185bb06b8ab9';

@ProviderFor(CompanyJobs)
final companyJobsProvider = CompanyJobsProvider._();

final class CompanyJobsProvider
    extends $AsyncNotifierProvider<CompanyJobs, CompanyJobsState> {
  CompanyJobsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companyJobsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companyJobsHash();

  @$internal
  @override
  CompanyJobs create() => CompanyJobs();
}

String _$companyJobsHash() => r'301ae6bdb23563c7335e7d2a312d48e435156346';

abstract class _$CompanyJobs extends $AsyncNotifier<CompanyJobsState> {
  FutureOr<CompanyJobsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CompanyJobsState>, CompanyJobsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CompanyJobsState>, CompanyJobsState>,
              AsyncValue<CompanyJobsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CreateJob)
final createJobProvider = CreateJobProvider._();

final class CreateJobProvider
    extends $NotifierProvider<CreateJob, AsyncValue<CompanyJob?>> {
  CreateJobProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createJobProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createJobHash();

  @$internal
  @override
  CreateJob create() => CreateJob();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<CompanyJob?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<CompanyJob?>>(value),
    );
  }
}

String _$createJobHash() => r'8bd806ad1a998fa969c2567e68b9ab0836ce3b36';

abstract class _$CreateJob extends $Notifier<AsyncValue<CompanyJob?>> {
  AsyncValue<CompanyJob?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CompanyJob?>, AsyncValue<CompanyJob?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CompanyJob?>, AsyncValue<CompanyJob?>>,
              AsyncValue<CompanyJob?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
