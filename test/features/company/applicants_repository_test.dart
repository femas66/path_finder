import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/features/company/data/applicants_repository.dart';
import 'package:path_finder/core/errors/app_exception.dart';

void main() {
  test('nested applicant, actual CV, paging and PATCH contract', () async {
    final dio = Dio();
    final requests = <RequestOptions>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          requests.add(request);
          handler.resolve(
            Response(
              requestOptions: request,
              statusCode: 200,
              data: {
                'success': true,
                'data': request.method == 'PATCH'
                    ? null
                    : [
                        {
                          'id': 'app-1',
                          'job_id': 'job-1',
                          'status': 'pending',
                          'mahasiswa': {
                            'name': 'Student',
                            'email': 'student@example.com',
                            'cv': 'https://files.example.com/private.pdf',
                          },
                          'job': {'id': 'job-1', 'title': 'Engineer'},
                        },
                      ],
                'paging': {'page': 2, 'total_page': 3},
              },
            ),
          );
        },
      ),
    );
    final repo = ApplicantsRepository(dio);
    final page = await repo.list(jobId: 'job-1', page: 2);
    expect(page.items.single.cvUrl, 'https://files.example.com/private.pdf');
    expect(page.items.single.canDecide, isTrue);
    expect(page.hasMore, isTrue);
    expect(requests.first.queryParameters, {
      'job_id': 'job-1',
      'page': 2,
      'size': 10,
    });
    await repo.decide('app-1', 'accepted');
    expect(requests.last.method, 'PATCH');
    expect(requests.last.path, '/api/mitra/applications/app-1/status');
    expect(requests.last.data, {'status': 'accepted'});
    await expectLater(
      repo.decide('app-1', 'pending'),
      throwsA(isA<ValidationException>()),
    );
  });

  test('backend errors preserved', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) => handler.resolve(
          Response(
            requestOptions: request,
            statusCode: 200,
            data: {'success': false, 'message': 'Already decided'},
          ),
        ),
      ),
    );
    await expectLater(
      ApplicantsRepository(dio).decide('id', 'rejected'),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'Already decided',
        ),
      ),
    );
  });
}
