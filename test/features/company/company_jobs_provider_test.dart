import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/auth/presentation/providers/auth_controller.dart';
import 'package:path_finder/features/company/domain/company_jobs_repository.dart';
import 'package:path_finder/features/company/domain/models/company_job.dart';
import 'package:path_finder/features/company/presentation/providers/applicants_provider.dart';
import 'package:path_finder/features/company/presentation/providers/company_jobs_provider.dart';

import 'candidates_tab_test.dart' show MitraAuth, FakeRepository;
import 'company_jobs_test_support.dart';

class CountingApplicants extends FakeRepository {
  int jobCalls = 0;
  @override
  Future<Map<String, String>> jobs() async {
    jobCalls++;
    return super.jobs();
  }
}

void main() {
  test(
    'create refreshes jobs and applicants selector; concurrent submit ignored',
    () async {
      final repo = FakeJobsRepository()
        ..pendingCreate = Completer<CompanyJob>();
      final applicants = CountingApplicants();
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(MitraAuth.new),
          companyJobsRepositoryProvider.overrideWithValue(repo),
          applicantsRepositoryProvider.overrideWithValue(applicants),
        ],
      );
      addTearDown(container.dispose);
      final jobsSub = container.listen(companyJobsProvider, (_, _) {});
      final filterSub = container.listen(applicantJobsProvider, (_, _) {});
      final createSub = container.listen(createJobProvider, (_, _) {});
      addTearDown(jobsSub.close);
      addTearDown(filterSub.close);
      addTearDown(createSub.close);
      await container.read(companyJobsProvider.future);
      await container.read(applicantJobsProvider.future);
      final input = CreateCompanyJob(
        title: 'Flutter Intern',
        category: jobCategories[2],
        description: 'Mengembangkan aplikasi mobile bersama tim.',
        location: 'Bandung',
        workType: 'Hybrid',
        requiredSkills: ['Flutter'],
      );
      final notifier = container.read(createJobProvider.notifier);
      final first = notifier.submit(input);
      expect(await notifier.submit(input), isNull);
      await Future<void>.delayed(Duration.zero);
      expect(repo.creates.length, 1);
      repo.pendingCreate!.complete(jobFixture());
      expect((await first)!.id, 'job-1');
      await container.read(companyJobsProvider.future);
      await container.read(applicantJobsProvider.future);
      expect(repo.listCalls, 2);
      expect(applicants.jobCalls, 2);
    },
  );

  test('refresh during pending page prevents stale page from replacing refreshed data', () async {
    final repo = FakeJobsRepository();
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(MitraAuth.new),
        companyJobsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(companyJobsProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(companyJobsProvider.future);
    final pending = Completer<CompanyJobsPage>();
    repo.pendingList = pending;
    final more = container.read(companyJobsProvider.notifier).loadMore();
    repo.pendingList = null;
    repo.empty = true;
    container.invalidate(companyJobsProvider);
    await container.read(companyJobsProvider.future);
    pending.complete(CompanyJobsPage([jobFixture('stale')], 2, false, 2));
    await more;
    expect(
      container.read(companyJobsProvider).requireValue.result.items,
      isEmpty,
    );
  });
}
