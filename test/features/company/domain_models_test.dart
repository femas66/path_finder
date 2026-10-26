import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/company/data/company_mock_data.dart';
import 'package:path_finder/features/company/domain/models/candidate_application.dart';
import 'package:path_finder/features/company/domain/models/job_posting.dart';

void main() {
  group('JobPosting Model', () {
    test('instantiates correctly and copyWith updates values', () {
      final job = JobPosting(
        id: 'job-1',
        title: 'Mobile Developer Intern',
        field: 'Software Engineering',
        quota: 3,
        executionPeriod: '1 Januari 2027 s.d. 31 Juli 2027',
        description: 'Membangun aplikasi mobile Flutter',
        facilities: 'Uang saku bulanan, sertifikat resmi, mentor 1-on-1',
        requiredSkills: 'Flutter, Dart, Git, REST API',
        companyName: 'PT Inovasi Teknologi Nusantara',
        location: 'Bandung (Hybrid)',
        applicantsCount: 5,
        isActive: true,
        createdAt: DateTime(2026, 10, 26),
      );

      expect(job.id, 'job-1');
      expect(job.title, 'Mobile Developer Intern');
      expect(job.quota, 3);
      expect(job.executionPeriod, '1 Januari 2027 s.d. 31 Juli 2027');
      expect(job.isActive, isTrue);

      final updated = job.copyWith(
        title: 'Senior Mobile Engineer Intern',
        quota: 5,
        applicantsCount: 6,
      );

      expect(updated.title, 'Senior Mobile Engineer Intern');
      expect(updated.quota, 5);
      expect(updated.applicantsCount, 6);
      expect(updated.id, job.id);
    });
  });

  group('CandidateApplication Model', () {
    test('instantiates correctly and copyWith updates status and notes', () {
      final candidate = CandidateApplication(
        id: 'cand-1',
        jobId: 'job-1',
        jobTitle: 'Mobile Developer Intern',
        candidateName: 'Aditya Pratama',
        university: 'Institut Teknologi Bandung',
        major: 'Teknik Informatika • Semester 6',
        appliedDate: '24 Oktober 2026',
        matchScore: 94,
        status: 'Diterima',
        notes: 'Portofolio Flutter sangat relevan.',
      );

      expect(candidate.id, 'cand-1');
      expect(candidate.candidateName, 'Aditya Pratama');
      expect(candidate.status, 'Diterima');
      expect(candidate.matchScore, 94);

      final updated = candidate.copyWith(
        status: 'Ditolak',
        notes: 'Kuota posisi sudah terpenuhi.',
      );

      expect(updated.status, 'Ditolak');
      expect(updated.notes, contains('Kuota posisi sudah terpenuhi.'));
      expect(updated.candidateName, 'Aditya Pratama');
    });
  });

  group('CompanyMockData', () {
    test('provides initial jobs and candidates dataset', () {
      final jobs = CompanyMockData.getInitialJobs();
      final candidates = CompanyMockData.getInitialCandidates();

      expect(jobs.isNotEmpty, isTrue);
      expect(candidates.isNotEmpty, isTrue);
      expect(jobs.first.title, isNotEmpty);
      expect(candidates.first.candidateName, isNotEmpty);
    });
  });
}
