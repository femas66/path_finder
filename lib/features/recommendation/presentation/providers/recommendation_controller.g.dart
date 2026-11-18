// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mengelola satu siklus analisis rekomendasi.
///
/// `keepAlive` wajib: halaman memanggil controller lewat `ref.read` tanpa
/// listener. Tanpa ini provider di-dispose saat request masih berjalan dan
/// `state = await ...` akan melempar error "Ref after dispose".

@ProviderFor(RecommendationController)
final recommendationControllerProvider = RecommendationControllerProvider._();

/// Mengelola satu siklus analisis rekomendasi.
///
/// `keepAlive` wajib: halaman memanggil controller lewat `ref.read` tanpa
/// listener. Tanpa ini provider di-dispose saat request masih berjalan dan
/// `state = await ...` akan melempar error "Ref after dispose".
final class RecommendationControllerProvider
    extends $AsyncNotifierProvider<RecommendationController, Recommendation?> {
  /// Mengelola satu siklus analisis rekomendasi.
  ///
  /// `keepAlive` wajib: halaman memanggil controller lewat `ref.read` tanpa
  /// listener. Tanpa ini provider di-dispose saat request masih berjalan dan
  /// `state = await ...` akan melempar error "Ref after dispose".
  RecommendationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationControllerHash();

  @$internal
  @override
  RecommendationController create() => RecommendationController();
}

String _$recommendationControllerHash() =>
    r'95fdc2e1dff7f9dfbbac1a1e67bb575bd554cf6e';

/// Mengelola satu siklus analisis rekomendasi.
///
/// `keepAlive` wajib: halaman memanggil controller lewat `ref.read` tanpa
/// listener. Tanpa ini provider di-dispose saat request masih berjalan dan
/// `state = await ...` akan melempar error "Ref after dispose".

abstract class _$RecommendationController
    extends $AsyncNotifier<Recommendation?> {
  FutureOr<Recommendation?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Recommendation?>, Recommendation?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Recommendation?>, Recommendation?>,
              AsyncValue<Recommendation?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
