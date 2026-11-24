import 'models/company_job.dart';

abstract interface class CompanyJobsRepository {
  Future<CompanyJobsPage> list({int page = 1, int size = 10});
  Future<CompanyJob> create(CreateCompanyJob input);
}

class CompanyJobsPage {
  const CompanyJobsPage(this.items, this.page, this.hasMore, this.total);
  final List<CompanyJob> items;
  final int page;
  final bool hasMore;
  final int total;
}
