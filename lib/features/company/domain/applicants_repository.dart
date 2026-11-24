import 'models/candidate_application.dart';

class ApplicantsPage {
  const ApplicantsPage(this.items, this.page, this.hasMore);
  final List<CandidateApplication> items;
  final int page;
  final bool hasMore;
}

abstract interface class CompanyApplicantsRepository {
  Future<ApplicantsPage> list({String? jobId, int page = 1, int size = 10});
  Future<void> decide(String id, String status);
  Future<Map<String, String>> jobs();
}
