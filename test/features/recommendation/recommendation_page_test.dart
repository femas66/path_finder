import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/features/recommendation/domain/entities/recommendation.dart';
import 'package:path_finder/features/recommendation/domain/recommendation_repository.dart';
import 'package:path_finder/features/recommendation/presentation/pages/recommendation_page.dart';
import 'package:path_finder/features/recommendation/presentation/providers/recommendation_providers.dart';

/// Repository palsu yang selalu mengembalikan hasil yang sudah disiapkan.
class _FakeRepository implements RecommendationRepository {
  _FakeRepository({this.result, this.error});

  final Recommendation? result;
  final Object? error;

  @override
  Future<Recommendation> generate({String? storyId, int? topK}) async {
    if (error != null) throw error!;
    return result!;
  }

  @override
  Future<Recommendation> latest() async {
    if (error != null) throw error!;
    return result!;
  }
}

Widget _buildPage(_FakeRepository repository) {
  return ProviderScope(
    overrides: [
      recommendationRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(home: RecommendationPage()),
  );
}

Recommendation _sampleRecommendation() {
  return const Recommendation(
    id: 'rec-1',
    studentId: 'user-1',
    storyId: 'story-1',
    generatedAt: null,
    status: 'ok',
    profile: RecommendationProfile(
      hardSkills: ['Go', 'PostgreSQL'],
      softSkills: ['Teamwork'],
      profileStatus: 'lengkap',
    ),
    items: [
      RecommendationItem(
        jobId: 'JOB-009',
        title: 'Backend Developer Intern',
        category: 'Backend Developer Intern',
        company: 'PT Qtera Mandiri',
        location: 'Jakarta Utara',
        workType: 'WFO',
        matchingScore: 90,
        readinessScore: 91,
        matchedSkills: ['Go', 'PostgreSQL'],
        missingSkills: ['Docker'],
        scoreStatus: 'ok',
        rank: 1,
      ),
      RecommendationItem(
        jobId: 'JOB-015',
        title: 'Frontend Developer Intern',
        category: 'Frontend Developer Intern',
        company: 'PT Telkom Indonesia',
        location: 'Bandung',
        workType: 'Hybrid',
        matchingScore: 45,
        readinessScore: 40,
        matchedSkills: ['Git'],
        missingSkills: ['React', 'TypeScript'],
        scoreStatus: 'ok',
        rank: 2,
      ),
    ],
  );
}

void main() {
  group('RecommendationPage', () {
    testWidgets('menampilkan lowongan beserta skor dan keahlian', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildPage(_FakeRepository(result: _sampleRecommendation())),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Rekomendasi untukmu'), findsOneWidget);
      expect(
        find.text('3 keahlian dikenali dari ceritamu'),
        findsOneWidget,
      );

      expect(find.text('Backend Developer Intern'), findsOneWidget);
      expect(find.text('Frontend Developer Intern'), findsOneWidget);

      // Skor kecocokan tampil apa adanya.
      expect(find.text('90'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);

      // Keahlian yang sudah cocok dan yang perlu dipelajari.
      // "Go" muncul dua kali: pada ringkasan profil dan pada kartu lowongan.
      expect(find.text('Go'), findsAtLeastNWidgets(1));
      expect(find.text('Docker'), findsOneWidget);
      expect(find.text('Perlu dipelajari'), findsNWidgets(2));

      // Kesiapan kerja.
      expect(find.text('Kesiapan kerja 91%'), findsOneWidget);

      expect(find.text('Belum ada rekomendasi'), findsNothing);
    });

    testWidgets('menampilkan panduan saat profil tanpa keahlian', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildPage(
          _FakeRepository(
            result: const Recommendation(
              id: 'rec-2',
              studentId: 'user-2',
              storyId: 'story-2',
              generatedAt: null,
              status: 'profil_tidak_lengkap',
              profile: RecommendationProfile(profileStatus: 'tanpa_skill'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Ceritamu belum menyebut keahlian'), findsOneWidget);
      expect(find.text('Perbaiki cerita'), findsOneWidget);
      expect(find.text('Belum ada keahlian yang dikenali'), findsOneWidget);
    });

    testWidgets('menampilkan ajakan saat belum pernah ada rekomendasi',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _buildPage(
          _FakeRepository(
            error: const NotFoundException(
              message: 'rekomendasi belum pernah dibuat',
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Belum ada rekomendasi'), findsOneWidget);
      expect(find.text('Tulis cerita diri'), findsOneWidget);
    });
  });
}
