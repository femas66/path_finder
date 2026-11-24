import 'dart:async';

import 'package:path_finder/features/company/domain/company_jobs_repository.dart';
import 'package:path_finder/features/company/domain/models/company_job.dart';

CompanyJob jobFixture([String id = 'job-1']) => CompanyJob(
  id: id,
  title: 'Flutter Intern $id',
  category: jobCategories[2],
  description: 'Mengembangkan aplikasi Flutter bersama tim.',
  location: 'Bandung',
  workType: 'Hybrid',
  requiredSkills: ['Flutter', 'Dart'],
  optionalSkills: ['Git'],
  company: 'Mitra',
  status: 'aktif',
  sourceUrl: '',
);

class FakeJobsRepository implements CompanyJobsRepository {
  bool fail = false;
  bool empty = false;
  int listCalls = 0;
  final creates = <CreateCompanyJob>[];
  Completer<CompanyJob>? pendingCreate;
  Completer<CompanyJobsPage>? pendingList;
  @override
  Future<CompanyJobsPage> list({int page = 1, int size = 10}) async {
    listCalls++;
    if (pendingList != null) return pendingList!.future;
    if (fail) throw StateError('offline');
    return CompanyJobsPage(
      empty ? [] : [jobFixture('job-$page')],
      page,
      !empty && page == 1,
      empty ? 0 : 2,
    );
  }

  @override
  Future<CompanyJob> create(CreateCompanyJob input) async {
    input.validate();
    creates.add(input);
    if (pendingCreate != null) return pendingCreate!.future;
    if (fail) throw StateError('offline');
    return jobFixture();
  }
}
