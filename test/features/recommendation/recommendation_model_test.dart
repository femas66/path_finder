import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/recommendation/data/models/recommendation_model.dart';

void main() {
  group('RecommendationModel', () {
    test('membaca response lengkap dari backend', () {
      final model = RecommendationModel.fromJson({
        'id': 'rec-1',
        'student_id': 'user-1',
        'story_id': 'story-1',
        'generated_at': '2026-11-18T07:31:58Z',
        'schema_version': '1.0',
        'model_version': 'ner:lexicon-rule-1.0.0;encoder:none;ranker:rule-1.0.0',
        'top_k': 3,
        'status': 'ok',
        'profile': {
          'hard_skills': ['Go', 'PostgreSQL'],
          'soft_skills': ['Teamwork'],
          'interests': <String>[],
          'profile_status': 'lengkap',
        },
        'items': [
          {
            'job_id': 'JOB-009',
            'title': 'Backend Developer Intern',
            'category': 'Backend Developer Intern',
            'company': 'PT Qtera Mandiri',
            'location': 'Jakarta Utara',
            'work_type': 'WFO',
            'source': 'Glints',
            'source_url': 'https://example.test/job',
            'matching_score': 90,
            'cosine_similarity': null,
            'readiness_score': 91,
            'matched_skills': ['Go', 'PostgreSQL'],
            'missing_skills': ['Docker'],
            'score_status': 'ok',
            'rank': 1,
          },
        ],
      });

      expect(model.status, 'ok');
      expect(model.topK, 3);
      expect(model.profile.hardSkills, ['Go', 'PostgreSQL']);
      expect(model.items, hasLength(1));

      final item = model.items.first;
      expect(item.jobId, 'JOB-009');
      expect(item.matchingScore, 90);
      expect(item.readinessScore, 91);
      expect(item.cosineSimilarity, isNull);
      expect(item.missingSkills, ['Docker']);
      expect(item.rank, 1);

      final entity = model.toEntity();
      expect(entity.studentId, 'user-1');
      expect(entity.generatedAt, isNotNull);
      expect(entity.isProfileIncomplete, isFalse);
      expect(entity.isEmpty, isFalse);
      expect(entity.items.first.hasScore, isTrue);
    });

    test('membaca response profil tanpa keahlian', () {
      final model = RecommendationModel.fromJson({
        'id': 'rec-2',
        'student_id': 'user-2',
        'story_id': 'story-2',
        'generated_at': '2026-11-18T08:00:00Z',
        'status': 'profil_tidak_lengkap',
        'top_k': 3,
        'profile': {
          'hard_skills': <String>[],
          'soft_skills': <String>[],
          'interests': <String>[],
          'profile_status': 'tanpa_skill',
        },
        'items': <Map<String, dynamic>>[],
      });

      final entity = model.toEntity();
      expect(entity.isProfileIncomplete, isTrue);
      expect(entity.isEmpty, isTrue);
      expect(entity.profile.hasSkills, isFalse);
    });

    test('tahan terhadap field yang hilang', () {
      final model = RecommendationModel.fromJson(<String, dynamic>{});

      expect(model.id, '');
      expect(model.status, 'ok');
      expect(model.items, isEmpty);
      expect(model.profile.hardSkills, isEmpty);
      expect(model.toEntity().generatedAt, isNull);
    });

    test('item tanpa skor tetap terbaca', () {
      final model = RecommendationModel.fromJson({
        'id': 'rec-3',
        'student_id': 'user-3',
        'story_id': 'story-3',
        'status': 'parsial',
        'items': [
          {
            'job_id': 'JOB-001',
            'title': 'Software Engineer Intern',
            'category': 'Software Engineer Intern',
            'matching_score': null,
            'readiness_score': null,
            'score_status': 'persyaratan_belum_tersedia',
            'matched_skills': <String>[],
            'missing_skills': <String>[],
          },
        ],
      });

      final item = model.toEntity().items.first;
      expect(item.hasScore, isFalse);
      expect(item.matchingScore, isNull);
      expect(item.readinessScore, isNull);
      expect(item.scoreStatus, 'persyaratan_belum_tersedia');
    });
  });
}
