import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../domain/models/candidate_application.dart';
import '../domain/applicants_repository.dart';
export '../domain/applicants_repository.dart';

class ApplicantsRepository implements CompanyApplicantsRepository {
  ApplicantsRepository(this.dio);
  final Dio dio;

  Future<Map<String, dynamic>> _request(
    String path, {
    Map<String, dynamic>? query,
    String? status,
  }) async {
    try {
      final response = status == null
          ? await dio.get<dynamic>(path, queryParameters: query)
          : await dio.patch<dynamic>(path, data: {'status': status});
      final body = Map<String, dynamic>.from(response.data as Map);
      if (body['success'] != true) {
        throw ServerException(
          message: body['message'] as String? ?? 'Permintaan gagal',
        );
      }
      return body;
    } catch (error, stack) {
      throw ErrorMapper.fromObject(error, stack);
    }
  }

  @override
  Future<ApplicantsPage> list({
    String? jobId,
    int page = 1,
    int size = 10,
  }) async {
    final body = await _request(
      '/api/mitra/applications',
      query: {'job_id': ?jobId, 'page': page, 'size': size},
    );
    final items = (body['data'] as List? ?? []).map((raw) {
      final json = raw as Map;
      final student = json['mahasiswa'] as Map? ?? {};
      final job = json['job'] as Map? ?? {};
      return CandidateApplication(
        id: json['id'] as String,
        jobId: json['job_id'] as String? ?? job['id'] as String? ?? '',
        jobTitle: job['title'] as String? ?? '',
        candidateName: student['name'] as String? ?? 'Mahasiswa',
        email: student['email'] as String? ?? '',
        cvUrl: student['cv'] as String?,
        university: '',
        major: '',
        matchScore: 0,
        appliedDate: json['created_at'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );
    }).toList();
    final paging = body['paging'] as Map?;
    return ApplicantsPage(
      items,
      page,
      paging != null
          ? page < (paging['total_page'] as num).toInt()
          : items.length == size,
    );
  }

  @override
  Future<void> decide(String id, String status) async {
    if (!['accepted', 'rejected'].contains(status)) {
      throw const ValidationException(message: 'Status tidak valid');
    }
    await _request(
      '/api/mitra/applications/${Uri.encodeComponent(id)}/status',
      status: status,
    );
  }

  @override
  Future<Map<String, String>> jobs() async {
    final jobs = <String, String>{};
    var page = 1;
    while (true) {
      final body = await _request(
        '/api/mitra/jobs',
        query: {'page': page, 'size': 100},
      );
      final rows = body['data'] as List? ?? [];
      for (final row in rows) {
        jobs[row['id'] as String] = row['title'] as String;
      }
      final paging = body['paging'] as Map?;
      if (paging != null
          ? page >= (paging['total_page'] as num).toInt()
          : rows.length < 100) {
        break;
      }
      page++;
    }
    return jobs;
  }
}
