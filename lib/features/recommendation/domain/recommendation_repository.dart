import 'entities/recommendation.dart';

abstract class RecommendationRepository {
  /// Meminta backend menganalisis cerita pengguna dan mengembalikan hasilnya.
  ///
  /// [storyId] kosong berarti memakai cerita terakhir milik pengguna.
  /// Melempar `AppException` bila request gagal.
  Future<Recommendation> generate({String? storyId, int? topK});

  /// Mengambil rekomendasi terakhir yang tersimpan di backend.
  Future<Recommendation> latest();
}
