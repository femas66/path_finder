import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../domain/models/candidate_application.dart';
import '../domain/models/company_profile.dart';
import '../domain/models/job_posting.dart';

class MitraRemoteSource {
  MitraRemoteSource(this._dio);

  final Dio _dio;

  String get _mitraBasePath {
    final baseUrl = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (baseUrl.endsWith('/api')) {
      return '/mitra';
    }
    return '/api/mitra';
  }

  /// Mengambil profil mitra / perusahaan saat ini (GET /api/mitra/profile).
  Future<CompanyProfile> getProfile() async {
    try {
      final response = await _dio.get('$_mitraBasePath/profile');
      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is Map) {
        final d = _asMap(rawData);
        return CompanyProfile(
          id: d['id']?.toString() ?? '',
          companyName: d['name']?.toString() ?? 'Mitra Perusahaan',
          industrySector: d['industry']?.toString() ?? 'Teknologi & Digital',
          city: d['location']?.toString() ?? 'Indonesia',
          officeAddress: d['location']?.toString() ?? '',
          description: d['description']?.toString() ?? '',
          website: d['portfolio_url']?.toString() ?? '',
          contactEmail: d['email']?.toString() ?? '',
          contactPhone: d['contact_phone']?.toString() ?? '',
          nib: d['nib']?.toString() ?? '1234567890123',
          npwp: d['npwp']?.toString() ?? '01.234.567.8-901.000',
          skKemenkumham: d['sk_kemenkumham']?.toString() ?? 'AHU-0012345.AH.01.01.2023',
        );
      }

      throw const UnexpectedException(message: 'Data profil mitra tidak ditemukan.');
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Memperbarui profil mitra / perusahaan (PUT /api/mitra/profile).
  Future<CompanyProfile> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put(
        '$_mitraBasePath/profile',
        data: updates,
      );
      final map = _asMap(response.data);
      if (map['success'] == true) {
        return await getProfile();
      }
      throw UnexpectedException(message: map['message']?.toString() ?? 'Gagal memperbarui profil');
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Mengambil daftar lowongan milik mitra sendiri (GET /api/mitra/jobs).
  Future<List<JobPosting>> getMyJobs() async {
    try {
      final response = await _dio.get('$_mitraBasePath/jobs');
      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is List) {
        return rawData.map((item) {
          final d = _asMap(item);
          final reqSkills = d['required_skills'];
          final reqStr = reqSkills is List ? reqSkills.join(', ') : (reqSkills?.toString() ?? '');
          final optSkills = d['optional_skills'];
          final optStr = optSkills is List ? optSkills.join(', ') : (optSkills?.toString() ?? '');

          return JobPosting(
            id: d['id']?.toString() ?? '',
            title: d['title']?.toString() ?? '',
            field: d['category']?.toString() ?? 'Umum',
            quota: 5,
            executionPeriod: d['work_type']?.toString() ?? 'Full-time',
            description: d['description']?.toString() ?? '',
            facilities: optStr,
            requiredSkills: reqStr,
            companyName: d['company']?.toString() ?? '',
            location: d['location']?.toString() ?? '',
            createdAt: d['created_at'] != null
                ? DateTime.tryParse(d['created_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
          );
        }).toList();
      }

      return const [];
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Membuat lowongan kerja baru (POST /api/mitra/jobs).
  Future<JobPosting> createJob({
    required String title,
    required String category,
    required String description,
    required String location,
    required String workType,
    required List<String> requiredSkills,
    List<String> optionalSkills = const [],
    String sourceUrl = '',
  }) async {
    try {
      final payload = {
        'title': title,
        'category': category,
        'description': description,
        'location': location,
        'work_type': workType,
        'required_skills': requiredSkills,
        'optional_skills': optionalSkills,
        'source_url': sourceUrl,
      };

      final response = await _dio.post('$_mitraBasePath/jobs', data: payload);
      final map = _asMap(response.data);
      final d = _asMap(map['data']);

      return JobPosting(
        id: d['id']?.toString() ?? '',
        title: d['title']?.toString() ?? title,
        field: d['category']?.toString() ?? category,
        quota: 5,
        executionPeriod: d['work_type']?.toString() ?? workType,
        description: d['description']?.toString() ?? description,
        facilities: optionalSkills.join(', '),
        requiredSkills: requiredSkills.join(', '),
        companyName: d['company']?.toString() ?? '',
        location: d['location']?.toString() ?? location,
        createdAt: DateTime.now(),
      );
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Memperbarui lowongan kerja (PUT /api/mitra/jobs/:id).
  Future<bool> updateJob(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('$_mitraBasePath/jobs/$id', data: data);
      final map = _asMap(response.data);
      return map['success'] == true;
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Menghapus lowongan kerja (DELETE /api/mitra/jobs/:id).
  Future<bool> deleteJob(String id) async {
    try {
      final response = await _dio.delete('$_mitraBasePath/jobs/$id');
      final map = _asMap(response.data);
      return map['success'] == true;
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Mengambil daftar kandidat pelamar yang masuk (GET /api/mitra/applications).
  Future<List<CandidateApplication>> getApplicants({String? jobId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (jobId != null && jobId.isNotEmpty) {
        queryParams['job_id'] = jobId;
      }

      final response = await _dio.get(
        '$_mitraBasePath/applications',
        queryParameters: queryParams,
      );

      final map = _asMap(response.data);
      final rawData = map['data'];

      if (rawData is List) {
        return rawData.map((item) {
          final d = _asMap(item);
          final mhs = _asMap(d['mahasiswa']);

          return CandidateApplication(
            id: d['id']?.toString() ?? '',
            jobId: d['job_id']?.toString() ?? '',
            jobTitle: d['job_title']?.toString() ?? 'Lowongan Magang',
            candidateName: mhs['name']?.toString() ?? 'Kandidat Mahasiswa',
            university: mhs['location']?.toString() ?? 'Perguruan Tinggi',
            major: mhs['nim'] != null ? 'NIM: ${mhs['nim']}' : 'Mahasiswa Aktif',
            appliedDate: d['created_at'] != null
                ? d['created_at'].toString().split('T').first
                : 'Baru saja',
            matchScore: 85,
            status: d['status']?.toString() ?? 'pending',
            notes: mhs['cv'] != null && mhs['cv'].toString().isNotEmpty
                ? 'CV: ${mhs['cv']}'
                : '',
          );
        }).toList();
      }

      return const [];
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  /// Memperbarui status lamaran kandidat: 'accepted' atau 'rejected' (PATCH /api/mitra/applications/:id/status).
  Future<bool> updateApplicationStatus(String applicationId, String status) async {
    try {
      final response = await _dio.patch(
        '$_mitraBasePath/applications/$applicationId/status',
        data: {'status': status},
      );

      final map = _asMap(response.data);
      return map['success'] == true;
    } on DioException catch (dioError) {
      throw ErrorMapper.fromDioException(dioError);
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ErrorMapper.fromObject(e, stackTrace);
    }
  }

  Map<String, dynamic> _asMap(dynamic rawData) {
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) return Map<String, dynamic>.from(rawData);
    if (rawData is String && rawData.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }
}
