import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/applicants_repository.dart';
import '../../domain/models/candidate_application.dart';

part 'applicants_provider.g.dart';

@riverpod
CompanyApplicantsRepository applicantsRepository(Ref ref) =>
    ApplicantsRepository(ref.watch(dioClientProvider));

Future<void> requireMitra(Ref ref) async {
  final session = await ref.watch(authControllerProvider.future);
  if (session == null || !session.user.isMitra) {
    throw const UnauthorizedException();
  }
}

@riverpod
Future<Map<String, String>> applicantJobs(Ref ref) async {
  await requireMitra(ref);
  return ref.watch(applicantsRepositoryProvider).jobs();
}

class ApplicantsState {
  const ApplicantsState(
    this.items,
    this.page,
    this.hasMore, {
    this.loadingMore = false,
    this.busy = const {},
    this.error,
  });
  final List<CandidateApplication> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final Set<String> busy;
  final Object? error;
}

@riverpod
class Applicants extends _$Applicants {
  @override
  Future<ApplicantsState> build(String? jobId) async {
    await requireMitra(ref);
    final result = await ref
        .watch(applicantsRepositoryProvider)
        .list(jobId: jobId);
    return ApplicantsState(result.items, result.page, result.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null ||
        current.loadingMore ||
        current.busy.isNotEmpty ||
        !current.hasMore) {
      return;
    }
    state = AsyncData(
      ApplicantsState(
        current.items,
        current.page,
        current.hasMore,
        loadingMore: true,
      ),
    );
    try {
      final result = await ref
          .read(applicantsRepositoryProvider)
          .list(jobId: jobId, page: current.page + 1);
      if (!ref.mounted) return;
      final merged = {
        for (final item in current.items) item.id: item,
        for (final item in result.items) item.id: item,
      };
      state = AsyncData(
        ApplicantsState(merged.values.toList(), result.page, result.hasMore),
      );
    } catch (error) {
      if (ref.mounted) {
        state = AsyncData(
          ApplicantsState(
            current.items,
            current.page,
            current.hasMore,
            error: error,
          ),
        );
      }
    }
  }

  Future<void> decide(String id, String status) async {
    final current = state.asData?.value;
    if (current == null || current.loadingMore || current.busy.isNotEmpty) {
      return;
    }
    final item = current.items.where((item) => item.id == id).firstOrNull;
    if (item == null ||
        !item.canDecide ||
        !['accepted', 'rejected'].contains(status)) {
      return;
    }
    state = AsyncData(
      ApplicantsState(current.items, current.page, current.hasMore, busy: {id}),
    );
    try {
      await ref.read(applicantsRepositoryProvider).decide(id, status);
      if (!ref.mounted) return;
      state = AsyncData(
        ApplicantsState(
          current.items
              .map(
                (item) => item.id == id ? item.copyWith(status: status) : item,
              )
              .toList(),
          current.page,
          current.hasMore,
        ),
      );
    } catch (error) {
      if (ref.mounted) {
        state = AsyncData(
          ApplicantsState(
            current.items,
            current.page,
            current.hasMore,
            error: error,
          ),
        );
      }
    }
  }
}
