import '../domain/models/candidate_application.dart';
import '../domain/models/job_posting.dart';

class CompanyMockData {
  CompanyMockData._();

  static List<JobPosting> getInitialJobs() {
    return [
      JobPosting(
        id: 'job-1',
        title: 'Mobile Flutter Engineer Intern',
        field: 'Software Engineering',
        quota: 3,
        executionPeriod: '1 Januari 2027 s.d. 31 Juli 2027',
        description:
            'Mengembangkan fitur aplikasi mobile PathFinder, mengimplementasikan Clean Architecture, dan integrasi API RESTful.',
        facilities:
            'Uang saku bulanan kompetitif, laptop kerja MacBook, sertifikat magang resmi, bimbingan mentor 1-on-1.',
        requiredSkills: 'Flutter, Dart, State Management (Riverpod), Git, REST API',
        companyName: 'PT Inovasi Teknologi Nusantara',
        location: 'Bandung (Hybrid)',
        applicantsCount: 8,
        isActive: true,
        createdAt: DateTime(2026, 10, 20),
      ),
      JobPosting(
        id: 'job-2',
        title: 'Frontend Web Developer Intern',
        field: 'Web Engineering',
        quota: 2,
        executionPeriod: '1 Februari 2027 s.d. 31 Juli 2027',
        description:
            'Membangun antarmuka portal web perusahaan dengan React/Next.js dan Tailwind CSS berstandar industri modern.',
        facilities:
            'Uang saku bulanan, sertifikat resmi industri, makan siang gratis, akses coworking space.',
        requiredSkills: 'React, TypeScript, Tailwind CSS, Responsive Design',
        companyName: 'PT Inovasi Teknologi Nusantara',
        location: 'Jakarta Selatan (Onsite)',
        applicantsCount: 5,
        isActive: true,
        createdAt: DateTime(2026, 10, 22),
      ),
      JobPosting(
        id: 'job-3',
        title: 'UI/UX Product Design Intern',
        field: 'Product & Design',
        quota: 2,
        executionPeriod: '1 Januari 2027 s.d. 30 Juni 2027',
        description:
            'Melakukan riset pengguna, wireframing, pembuatan prototype interaktif di Figma, dan usability testing.',
        facilities:
            'Uang saku bulanan, langganan Figma Pro, sertifikat resmi, bimbingan langsung Principal Designer.',
        requiredSkills: 'Figma, Design System, Wireframing, User Research',
        companyName: 'PT Inovasi Teknologi Nusantara',
        location: 'Bandung (Remote)',
        applicantsCount: 4,
        isActive: true,
        createdAt: DateTime(2026, 10, 24),
      ),
    ];
  }

  static List<CandidateApplication> getInitialCandidates() {
    return [
      const CandidateApplication(
        id: 'cand-1',
        jobId: 'job-1',
        jobTitle: 'Mobile Flutter Engineer Intern',
        candidateName: 'Aditya Pratama',
        university: 'Institut Teknologi Bandung',
        major: 'Teknik Informatika • Semester 6',
        appliedDate: '24 Oktober 2026',
        matchScore: 94,
        status: 'Diterima',
        notes: 'Portofolio Flutter sangat solid, aktif berkontribusi open source.',
      ),
      const CandidateApplication(
        id: 'cand-2',
        jobId: 'job-1',
        jobTitle: 'Mobile Flutter Engineer Intern',
        candidateName: 'Farhan Rizki',
        university: 'Universitas Indonesia',
        major: 'Ilmu Komputer • Semester 6',
        appliedDate: '23 Oktober 2026',
        matchScore: 89,
        status: 'Diterima',
        notes: 'Hasil tes teknis sangat memuaskan.',
      ),
      const CandidateApplication(
        id: 'cand-3',
        jobId: 'job-2',
        jobTitle: 'Frontend Web Developer Intern',
        candidateName: 'Siti Nurhaliza',
        university: 'Universitas Padjadjaran',
        major: 'Teknik Informatika • Semester 7',
        appliedDate: '25 Oktober 2026',
        matchScore: 91,
        status: 'Ditolak',
        notes: 'Kandidat telah menerima penawaran di perusahaan lain.',
      ),
      const CandidateApplication(
        id: 'cand-4',
        jobId: 'job-1',
        jobTitle: 'Mobile Flutter Engineer Intern',
        candidateName: 'Budi Santoso',
        university: 'Telkom University',
        major: 'Sistem Informasi • Semester 6',
        appliedDate: '21 Oktober 2026',
        matchScore: 84,
        status: 'Diterima',
        notes: 'Offering letter magang telah dikirimkan via email resmi.',
      ),
      const CandidateApplication(
        id: 'cand-5',
        jobId: 'job-3',
        jobTitle: 'UI/UX Product Design Intern',
        candidateName: 'Aulia Rahma',
        university: 'Institut Teknologi Bandung',
        major: 'Desain Komunikasi Visual • Semester 7',
        appliedDate: '20 Oktober 2026',
        matchScore: 78,
        status: 'Ditolak',
        notes: 'Kualifikasi belum sesuai dengan fokus design system saat ini.',
      ),
    ];
  }
}
