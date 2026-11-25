import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/recommendation/domain/entities/recommendation.dart';
import 'package:path_finder/features/recommendation/presentation/widgets/recommendation_card.dart';

RecommendationItem _item({
  int? matchingScore = 94,
  int? readinessScore,
  List<String> matchedSkills = const [],
  List<String> missingSkills = const [],
  int? rank,
}) {
  return RecommendationItem(
    jobId: 'JOB-001',
    title: 'Backend Developer Intern',
    category: 'Backend',
    company: 'PT Qtera Mandiri',
    location: 'Jakarta Utara',
    workType: 'WFO',
    matchingScore: matchingScore,
    readinessScore: readinessScore,
    matchedSkills: matchedSkills,
    missingSkills: missingSkills,
    scoreStatus: 'ok',
    rank: rank,
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}

void main() {
  group('RecommendationCard', () {
    testWidgets('menampilkan badge persentase, posisi, divisi, perusahaan, lokasi',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap(RecommendationCard(item: _item(rank: 1))));

      expect(find.text('94%'), findsOneWidget);
      expect(find.text('cocok'), findsOneWidget);
      expect(find.text('Backend Developer Intern'), findsOneWidget);
      expect(find.text('Backend'), findsOneWidget);
      expect(find.text('PT Qtera Mandiri'), findsOneWidget);
      expect(find.text('Jakarta Utara • WFO'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('memakai tanda hubung saat skor kecocokan belum tersedia',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(RecommendationCard(item: _item(matchingScore: null))),
      );

      expect(find.text('—'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
      expect(find.text('cocok'), findsOneWidget);
    });

    testWidgets('menampilkan keahlian cocok, keahlian yang perlu dipelajari, '
        'dan kesiapan kerja', (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(
          RecommendationCard(
            item: _item(
              readinessScore: 91,
              matchedSkills: const ['Go', 'PostgreSQL'],
              missingSkills: const ['Docker'],
            ),
          ),
        ),
      );

      expect(find.text('Go'), findsOneWidget);
      expect(find.text('PostgreSQL'), findsOneWidget);
      expect(find.text('Perlu dipelajari'), findsOneWidget);
      expect(find.text('Docker'), findsOneWidget);
      expect(find.text('Kesiapan kerja 91%'), findsOneWidget);
    });

    testWidgets('meneruskan tap kartu ke callback', (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var taps = 0;
      await tester.pumpWidget(
        _wrap(RecommendationCard(item: _item(), onTap: () => taps++)),
      );

      await tester.tap(find.byType(RecommendationCard));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });
  });
}
