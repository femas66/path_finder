import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/network/network_providers.dart';
import 'package:path_finder/features/company/data/applicants_repository.dart';
import 'package:path_finder/features/company/data/company_jobs_repository.dart';
import 'package:path_finder/features/company/presentation/providers/applicants_provider.dart';
import 'package:path_finder/features/company/presentation/providers/company_jobs_provider.dart';

void main() {
  test(
    'production defaults use shared authenticated Dio, never local stores',
    () {
      final dio = Dio();
      final container = ProviderContainer(
        overrides: [dioClientProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);
      addTearDown(dio.close);
      final applicants = container.read(applicantsRepositoryProvider);
      final jobs = container.read(companyJobsRepositoryProvider);
      expect(applicants, isA<ApplicantsRepository>());
      expect(jobs, isA<DioCompanyJobsRepository>());
      expect((applicants as ApplicantsRepository).dio, same(dio));
      expect((jobs as DioCompanyJobsRepository).dio, same(dio));
    },
  );
}
