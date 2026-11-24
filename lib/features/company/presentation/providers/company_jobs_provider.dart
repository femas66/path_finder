import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/company_jobs_repository.dart';
import '../../domain/company_jobs_repository.dart';
import '../../domain/models/company_job.dart';
import 'applicants_provider.dart';

part 'company_jobs_provider.g.dart';

@riverpod
CompanyJobsRepository companyJobsRepository(Ref ref) =>
    DioCompanyJobsRepository(ref.watch(dioClientProvider));

class CompanyJobsState {
  const CompanyJobsState(this.result, {this.loadingMore = false, this.error});
  final CompanyJobsPage result;
  final bool loadingMore;
  final Object? error;
}

@riverpod
class CompanyJobs extends _$CompanyJobs {
  int _generation = 0;

  @override
  Future<CompanyJobsState> build() async {
    _generation++;
    ref.onDispose(() => _generation++);
    await requireMitra(ref);
    return CompanyJobsState(
      await ref.watch(companyJobsRepositoryProvider).list(),
    );
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || current.loadingMore || !current.result.hasMore) {
      return;
    }
    final generation = _generation;
    state = AsyncData(CompanyJobsState(current.result, loadingMore: true));
    try {
      final next = await ref
          .read(companyJobsRepositoryProvider)
          .list(page: current.result.page + 1);
      if (!ref.mounted || generation != _generation) return;
      final merged = {
        for (final job in current.result.items) job.id: job,
        for (final job in next.items) job.id: job,
      };
      state = AsyncData(
        CompanyJobsState(
          CompanyJobsPage(
            merged.values.toList(),
            next.page,
            next.hasMore,
            next.total,
          ),
        ),
      );
    } catch (error) {
      if (ref.mounted && generation == _generation) {
        state = AsyncData(CompanyJobsState(current.result, error: error));
      }
    }
  }
}

@riverpod
class CreateJob extends _$CreateJob {
  @override
  AsyncValue<CompanyJob?> build() {
    ref.watch(authControllerProvider);
    return const AsyncData(null);
  }

  Future<CompanyJob?> submit(CreateCompanyJob input) async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    try {
      await requireMitra(ref);
      if (!ref.mounted) return null;
      final job = await ref.read(companyJobsRepositoryProvider).create(input);
      if (!ref.mounted) return null;
      ref.invalidate(companyJobsProvider);
      ref.invalidate(applicantJobsProvider);
      state = AsyncData(job);
      return job;
    } catch (error, stack) {
      if (ref.mounted) state = AsyncError(error, stack);
      return null;
    }
  }
}
