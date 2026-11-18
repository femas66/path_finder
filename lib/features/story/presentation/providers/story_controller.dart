import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_finder/features/story/domain/entities/user_story.dart';
import 'story_providers.dart';

part 'story_controller.g.dart';

/// Menyimpan cerita diri terakhir yang berhasil dikirim ke backend.
///
/// `null` berarti pengguna belum mengirim cerita pada sesi ini.
///
/// `keepAlive` wajib: halaman memanggil controller lewat `ref.read`, tanpa
/// listener. Tanpa ini provider di-dispose saat request masih berjalan dan
/// `state = await ...` akan melempar error "Ref after dispose".
@Riverpod(keepAlive: true)
class StoryController extends _$StoryController {
  @override
  FutureOr<UserStory?> build() => null;

  /// Mengirim cerita dan mengembalikan hasilnya.
  ///
  /// Melempar `AppException` bila gagal, sehingga UI bisa menampilkan pesan
  /// dari [ErrorMapper].
  Future<UserStory?> submit(String content) async {
    state = const AsyncLoading();
    final repository = ref.read(storyRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return await repository.submitStory(content: content);
    });

    if (state.hasError) {
      throw state.error!;
    }

    return state.value;
  }

  void reset() {
    state = const AsyncData(null);
  }
}
