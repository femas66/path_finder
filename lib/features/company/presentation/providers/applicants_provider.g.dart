// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applicants_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(applicantsRepository)
final applicantsRepositoryProvider = ApplicantsRepositoryProvider._();

final class ApplicantsRepositoryProvider
    extends
        $FunctionalProvider<
          CompanyApplicantsRepository,
          CompanyApplicantsRepository,
          CompanyApplicantsRepository
        >
    with $Provider<CompanyApplicantsRepository> {
  ApplicantsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicantsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicantsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CompanyApplicantsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CompanyApplicantsRepository create(Ref ref) {
    return applicantsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompanyApplicantsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompanyApplicantsRepository>(value),
    );
  }
}

String _$applicantsRepositoryHash() =>
    r'db2d93f0519e9d4d47a6c8c6d2c2eb02ed252f1f';

@ProviderFor(applicantJobs)
final applicantJobsProvider = ApplicantJobsProvider._();

final class ApplicantJobsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          FutureOr<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $FutureProvider<Map<String, String>> {
  ApplicantJobsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'applicantJobsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$applicantJobsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, String>> create(Ref ref) {
    return applicantJobs(ref);
  }
}

String _$applicantJobsHash() => r'3468a4ee6cf35c7d345ed6c876d9a5b1dfe7b536';

@ProviderFor(Applicants)
final applicantsProvider = ApplicantsFamily._();

final class ApplicantsProvider
    extends $AsyncNotifierProvider<Applicants, ApplicantsState> {
  ApplicantsProvider._({
    required ApplicantsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'applicantsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$applicantsHash();

  @override
  String toString() {
    return r'applicantsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Applicants create() => Applicants();

  @override
  bool operator ==(Object other) {
    return other is ApplicantsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$applicantsHash() => r'ccdc7c020c19d9d93719562f39e5e581664b05a7';

final class ApplicantsFamily extends $Family
    with
        $ClassFamilyOverride<
          Applicants,
          AsyncValue<ApplicantsState>,
          ApplicantsState,
          FutureOr<ApplicantsState>,
          String?
        > {
  ApplicantsFamily._()
    : super(
        retry: null,
        name: r'applicantsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ApplicantsProvider call(String? jobId) =>
      ApplicantsProvider._(argument: jobId, from: this);

  @override
  String toString() => r'applicantsProvider';
}

abstract class _$Applicants extends $AsyncNotifier<ApplicantsState> {
  late final _$args = ref.$arg as String?;
  String? get jobId => _$args;

  FutureOr<ApplicantsState> build(String? jobId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ApplicantsState>, ApplicantsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ApplicantsState>, ApplicantsState>,
              AsyncValue<ApplicantsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
