import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/errors/app_exception.dart';
import 'package:path_finder/features/company/data/company_jobs_repository.dart';
import 'package:path_finder/features/company/domain/models/company_job.dart';

CreateCompanyJob input({
  String title = ' Flutter Intern ',
  String category = 'Mobile Developer Intern',
  String description = 'Mengembangkan aplikasi mobile bersama tim.',
  String location = 'Bandung',
  String workType = 'Hybrid',
  List<String> skills = const [' Flutter ', 'Dart'],
  List<String> optional = const [],
  String url = '',
}) => CreateCompanyJob(
  title: title,
  category: category,
  description: description,
  location: location,
  workType: workType,
  requiredSkills: skills,
  optionalSkills: optional,
  sourceUrl: url,
);
final jsonJob = {
  'id': 'server-id',
  'title': 'Flutter Intern',
  'category': jobCategories[2],
  'description': 'Mengembangkan aplikasi mobile bersama tim.',
  'location': 'Bandung',
  'work_type': 'Hybrid',
  'required_skills': ['Flutter', 'Dart'],
  'optional_skills': ['Git'],
  'company': 'Server Company',
  'status': 'aktif',
  'source_url': '',
};

void main() {
  test(
    'GET active owned jobs exact query and paging; POST exact trimmed payload',
    () async {
      final dio = Dio();
      final requests = <RequestOptions>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (r, h) {
            requests.add(r);
            h.resolve(
              Response(
                requestOptions: r,
                data: {
                  'success': true,
                  'data': r.method == 'POST' ? jsonJob : [jsonJob],
                  'paging': {
                    'page': 2,
                    'size': 10,
                    'total_page': 3,
                    'total_item': 21,
                  },
                },
              ),
            );
          },
        ),
      );
      final repo = DioCompanyJobsRepository(dio);
      final page = await repo.list(page: 2);
      expect(requests.single.path, '/api/mitra/jobs');
      expect(requests.single.queryParameters, {
        'page': 2,
        'size': 10,
        'status': 'aktif',
      });
      expect(page.page, 2);
      expect(page.hasMore, true);
      expect(page.total, 21);
      expect(page.items.single.optionalSkills, ['Git']);
      final job = await repo.create(input());
      expect(job.id, 'server-id');
      expect(job.company, 'Server Company');
      expect(requests.last.method, 'POST');
      expect(requests.last.data, {
        'title': 'Flutter Intern',
        'category': jobCategories[2],
        'description': 'Mengembangkan aplikasi mobile bersama tim.',
        'location': 'Bandung',
        'work_type': 'Hybrid',
        'required_skills': ['Flutter', 'Dart'],
        'optional_skills': [],
        'source_url': '',
        'status': 'aktif',
      });
    },
  );
  test('validation matches backend limits before network request', () async {
    final invalid = [
      input(title: 'ab'),
      input(title: 'x' * 151),
      input(category: 'Data & AI'),
      input(description: 'x' * 19),
      input(description: 'x' * 10001),
      input(location: ' '),
      input(location: 'x' * 256),
      input(workType: ''),
      input(workType: 'x' * 51),
      input(skills: []),
      input(skills: [' ']),
      input(skills: ['x' * 101]),
      input(skills: List.filled(51, 'Dart')),
      input(optional: ['']),
      input(optional: List.filled(51, 'Git')),
      input(url: 'javascript:alert(1)'),
      input(url: 'https://'),
      input(url: 'https://example.com/${'x' * 1000}'),
    ];
    final repo = DioCompanyJobsRepository(Dio());
    for (final value in invalid) {
      await expectLater(
        repo.create(value),
        throwsA(isA<ValidationException>()),
      );
    }
    expect(
      () => input(
        title: 'abc',
        description: 'x' * 20,
        workType: 'Custom backend text',
        url: 'http://example.com',
      ).validate(),
      returnsNormally,
    );
    expect(jobCategories.length, 8);
  });
  test('empty last page; backend message, malformed response, transport errors mapped', () async {
    final dio = Dio();
    var mode = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (r, h) {
          if (mode == 3) {
            h.reject(
              DioException(
                requestOptions: r,
                type: DioExceptionType.connectionTimeout,
              ),
            );
            return;
          }
          if (mode == 4) {
            h.reject(
              DioException(
                requestOptions: r,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: r,
                  statusCode: 403,
                  data: {'message': 'Forbidden jobs'},
                ),
              ),
            );
            return;
          }
          h.resolve(
            Response(
              requestOptions: r,
              data: mode == 0
                  ? {
                      'success': true,
                      'data': [],
                      'paging': {'page': 1, 'total_page': 0, 'total_item': 0},
                    }
                  : mode == 1
                  ? {'success': false, 'message': 'Tidak dapat menyimpan'}
                  : {'success': true, 'data': 'invalid'},
            ),
          );
        },
      ),
    );
    final repo = DioCompanyJobsRepository(dio);
    final page = await repo.list();
    expect(page.items, isEmpty);
    expect(page.hasMore, false);
    mode = 1;
    await expectLater(
      repo.create(input()),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'message',
          'Tidak dapat menyimpan',
        ),
      ),
    );
    mode = 2;
    await expectLater(repo.list(), throwsA(isA<AppException>()));
    mode = 3;
    await expectLater(repo.list(), throwsA(isA<NetworkException>()));
    mode = 4;
    await expectLater(
      repo.list(),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'message',
          'Forbidden jobs',
        ),
      ),
    );
  });
}
