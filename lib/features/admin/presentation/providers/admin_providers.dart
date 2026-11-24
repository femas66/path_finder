import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/admin_remote_source.dart';
import '../../data/models/admin_mahasiswa_model.dart';

final adminRemoteSourceProvider = Provider<AdminRemoteSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AdminRemoteSource(dio);
});

/// Provider data statistik dashboard admin (GET /api/admin/dashboard)
final adminDashboardStatsProvider = FutureProvider<AdminDashboardStats>((ref) async {
  final source = ref.watch(adminRemoteSourceProvider);
  return source.getDashboardStats();
});

/// Provider daftar seluruh mahasiswa di sistem admin (GET /api/admin/mahasiswa)
final adminMahasiswaListProvider = FutureProvider.family<List<AdminMahasiswaItem>, String>((ref, search) async {
  final source = ref.watch(adminRemoteSourceProvider);
  return source.listMahasiswa(search: search);
});
