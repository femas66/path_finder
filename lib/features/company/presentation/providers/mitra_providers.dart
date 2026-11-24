import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/mitra_remote_source.dart';
import '../../domain/models/candidate_application.dart';
import '../../domain/models/company_profile.dart';
import '../../domain/models/job_posting.dart';

final mitraRemoteSourceProvider = Provider<MitraRemoteSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return MitraRemoteSource(dio);
});

/// Provider profil mitra saat ini (GET /api/mitra/profile)
final mitraProfileProvider = FutureProvider<CompanyProfile>((ref) async {
  final source = ref.watch(mitraRemoteSourceProvider);
  return source.getProfile();
});

/// Provider daftar lowongan milik mitra sendiri (GET /api/mitra/jobs)
final mitraJobsProvider = FutureProvider<List<JobPosting>>((ref) async {
  final source = ref.watch(mitraRemoteSourceProvider);
  return source.getMyJobs();
});

/// Provider daftar kandidat pelamar mitra (GET /api/mitra/applications)
final mitraApplicantsProvider = FutureProvider.family<List<CandidateApplication>, String?>((ref, jobId) async {
  final source = ref.watch(mitraRemoteSourceProvider);
  return source.getApplicants(jobId: jobId);
});
