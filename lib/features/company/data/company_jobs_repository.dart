import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../domain/company_jobs_repository.dart';
import '../domain/models/company_job.dart';

class DioCompanyJobsRepository implements CompanyJobsRepository {
  DioCompanyJobsRepository(this.dio);
  final Dio dio;

  Future<Map<String, dynamic>> _request({
    Map<String, dynamic>? data,
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = data == null
          ? await dio.get<dynamic>(
              '/api/mitra/jobs',
              queryParameters: {'page': page, 'size': size, 'status': 'aktif'},
            )
          : await dio.post<dynamic>('/api/mitra/jobs', data: data);
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

  CompanyJob _job(dynamic raw) {
    final json = raw as Map;
    return CompanyJob(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      workType: json['work_type'] as String,
      requiredSkills: List<String>.from(json['required_skills'] as List? ?? []),
      optionalSkills: List<String>.from(json['optional_skills'] as List? ?? []),
      company: json['company'] as String,
      status: json['status'] as String,
      sourceUrl: json['source_url'] as String? ?? '',
    );
  }

  @override
  Future<CompanyJobsPage> list({int page = 1, int size = 10}) async {
    try {
      final body = await _request(page: page, size: size);
      final paging = body['paging'] as Map;
      return CompanyJobsPage(
        (body['data'] as List).map(_job).toList(),
        (paging['page'] as num).toInt(),
        page < (paging['total_page'] as num).toInt(),
        (paging['total_item'] as num).toInt(),
      );
    } catch (error, stack) {
      throw ErrorMapper.fromObject(error, stack);
    }
  }

  @override
  Future<CompanyJob> create(CreateCompanyJob input) async {
    input.validate();
    try {
      final body = await _request(
        data: {
          'title': input.title,
          'category': input.category,
          'description': input.description,
          'location': input.location,
          'work_type': input.workType,
          'required_skills': input.requiredSkills,
          'optional_skills': input.optionalSkills,
          'source_url': input.sourceUrl,
          'status': 'aktif',
        },
      );
      return _job(body['data']);
    } catch (error, stack) {
      throw ErrorMapper.fromObject(error, stack);
    }
  }
}
