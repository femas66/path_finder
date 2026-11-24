import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/application_remote_source.dart';
import '../../data/job_remote_source.dart';
import '../../data/mahasiswa_remote_source.dart';
import '../../domain/models/application_item.dart';
import '../../domain/models/job_vacancy.dart';
import '../../domain/models/mahasiswa_profile.dart';

final jobRemoteSourceProvider = Provider<JobRemoteSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return JobRemoteSource(dio);
});

final applicationRemoteSourceProvider = Provider<ApplicationRemoteSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ApplicationRemoteSource(dio);
});

final mahasiswaRemoteSourceProvider = Provider<MahasiswaRemoteSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return MahasiswaRemoteSource(dio);
});

/// Parameter filter lowongan
class JobFilterParam {
  const JobFilterParam({
    this.search = '',
    this.category = 'Semua',
    this.page = 1,
  });

  final String search;
  final String category;
  final int page;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobFilterParam &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          category == other.category &&
          page == other.page;

  @override
  int get hashCode => search.hashCode ^ category.hashCode ^ page.hashCode;
}

/// Provider daftar lowongan pekerjaan dari backend (GET /api/jobs)
final jobsListProvider = FutureProvider.family<List<JobVacancy>, JobFilterParam>((ref, filter) async {
  final source = ref.watch(jobRemoteSourceProvider);
  return source.getJobs(
    search: filter.search,
    category: filter.category,
    page: filter.page,
  );
});

/// Provider riwayat lamaran mahasiswa (GET /api/mahasiswa/applications)
final myApplicationsProvider = FutureProvider<List<ApplicationItem>>((ref) async {
  final source = ref.watch(applicationRemoteSourceProvider);
  return source.getMyApplications();
});

/// Provider data profil mahasiswa (GET /api/mahasiswa/profile)
final mahasiswaProfileProvider = FutureProvider<MahasiswaProfile>((ref) async {
  final source = ref.watch(mahasiswaRemoteSourceProvider);
  return source.getProfile();
});

/// Provider statistik dashboard mahasiswa (GET /api/mahasiswa/dashboard)
final mahasiswaDashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final source = ref.watch(mahasiswaRemoteSourceProvider);
  return source.getDashboard();
});
