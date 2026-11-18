// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Menyimpan cerita diri terakhir yang berhasil dikirim ke backend.
///
/// `null` berarti pengguna belum mengirim cerita pada sesi ini.
///
/// `keepAlive` wajib: halaman memanggil controller lewat `ref.read`, tanpa
/// listener. Tanpa ini provider di-dispose saat request masih berjalan dan
/// `state = await ...` akan melempar error "Ref after dispose".

@ProviderFor(StoryController)
final storyControllerProvider = StoryControllerProvider._();

/// Menyimpan cerita diri terakhir yang berhasil dikirim ke backend.
///
/// `null` berarti pengguna belum mengirim cerita pada sesi ini.
///
/// `keepAlive` wajib: halaman memanggil controller lewat `ref.read`, tanpa
/// listener. Tanpa ini provider di-dispose saat request masih berjalan dan
/// `state = await ...` akan melempar error "Ref after dispose".
final class StoryControllerProvider
    extends $AsyncNotifierProvider<StoryController, UserStory?> {
  /// Menyimpan cerita diri terakhir yang berhasil dikirim ke backend.
  ///
  /// `null` berarti pengguna belum mengirim cerita pada sesi ini.
  ///
  /// `keepAlive` wajib: halaman memanggil controller lewat `ref.read`, tanpa
  /// listener. Tanpa ini provider di-dispose saat request masih berjalan dan
  /// `state = await ...` akan melempar error "Ref after dispose".
  StoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storyControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storyControllerHash();

  @$internal
  @override
  StoryController create() => StoryController();
}

String _$storyControllerHash() => r'8534455854ef7e83ea9f926ac78616399a3dee4b';

/// Menyimpan cerita diri terakhir yang berhasil dikirim ke backend.
///
/// `null` berarti pengguna belum mengirim cerita pada sesi ini.
///
/// `keepAlive` wajib: halaman memanggil controller lewat `ref.read`, tanpa
/// listener. Tanpa ini provider di-dispose saat request masih berjalan dan
/// `state = await ...` akan melempar error "Ref after dispose".

abstract class _$StoryController extends $AsyncNotifier<UserStory?> {
  FutureOr<UserStory?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserStory?>, UserStory?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserStory?>, UserStory?>,
              AsyncValue<UserStory?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
