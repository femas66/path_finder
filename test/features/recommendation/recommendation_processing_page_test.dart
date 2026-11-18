import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path_finder/features/recommendation/domain/entities/recommendation.dart';
import 'package:path_finder/features/recommendation/domain/recommendation_repository.dart';
import 'package:path_finder/features/recommendation/presentation/pages/recommendation_processing_page.dart';
import 'package:path_finder/features/recommendation/presentation/providers/recommendation_providers.dart';

/// Repository palsu yang tidak pernah selesai, sehingga halaman tetap berada
/// pada keadaan "sedang menganalisis" selama pengujian.
///
/// [finish] dipanggil di akhir setiap pengujian agar timer timeout pada
/// controller ikut berhenti (Flutter test gagal bila masih ada timer aktif).
class _PendingRepository implements RecommendationRepository {
  final Completer<Recommendation> _completer = Completer<Recommendation>();

  @override
  Future<Recommendation> generate({String? storyId, int? topK}) =>
      _completer.future;

  @override
  Future<Recommendation> latest() => _completer.future;

  void finish() {
    if (!_completer.isCompleted) {
      _completer.complete(
        const Recommendation(
          id: 'rec-1',
          studentId: 'user-1',
          storyId: 'story-1',
          generatedAt: null,
        ),
      );
    }
  }
}

Widget _buildRoutedApp(_PendingRepository repository) {
  final router = GoRouter(
    initialLocation: '/processing',
    routes: [
      GoRoute(
        path: '/processing',
        builder: (context, state) => const RecommendationProcessingPage(),
      ),
      GoRoute(
        path: '/story',
        builder: (context, state) =>
            const Scaffold(body: Text('halaman cerita')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      recommendationRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('RecommendationProcessingPage', () {
    testWidgets('meminta konfirmasi sebelum membatalkan', (tester) async {
      final repository = _PendingRepository();
      await tester.pumpWidget(_buildRoutedApp(repository));
      await tester.pump();

      // Batal dari dialog: proses tetap berjalan.
      await tester.ensureVisible(find.text('Batalkan'));
      await tester.tap(find.text('Batalkan'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Batalkan analisis?'), findsOneWidget);

      await tester.tap(find.text('Lanjut Menunggu'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Batalkan analisis?'), findsNothing);
      expect(find.text('halaman cerita'), findsNothing);

      // Konfirmasi: keluar dari halaman pemrosesan.
      await tester.ensureVisible(find.text('Batalkan'));
      await tester.tap(find.text('Batalkan'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Ya, Batalkan'));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('halaman cerita'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      repository.finish();
      await tester.pump();
    });

    testWidgets('tombol back sistem juga meminta konfirmasi', (tester) async {
      final repository = _PendingRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recommendationRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: RecommendationProcessingPage(),
          ),
        ),
      );
      await tester.pump();

      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Batalkan analisis?'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      repository.finish();
      await tester.pump();
    });
  });
}
