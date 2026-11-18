import '../domain/models/job_vacancy.dart';

/// Data sementara (mock) lowongan magang/kerja untuk sisi mahasiswa.
class JobVacancyData {
  JobVacancyData._();

  static const List<JobVacancy> jobs = [
    JobVacancy(
      title: 'Frontend Developer Intern',
      company: 'PT Telkom Indonesia',
      location: 'Bandung',
      type: 'Magang',
      matchScore: 94,
      description:
          'Membantu pengembangan modul antarmuka aplikasi web dan mobile '
          'menggunakan Flutter dan React. Kamu akan terlibat langsung dalam '
          'implementasi komponen UI, integrasi API, serta kolaborasi dengan '
          'tim desain dan backend untuk menghadirkan produk digital yang '
          'bersih dan responsif.',
      requirements: [
        'Mahasiswa aktif semester 5–7 jurusan Teknik Informatika / Ilmu Komputer',
        'Memahami dasar HTML, CSS, dan JavaScript',
        'Terbiasa dengan React atau Flutter (nilai plus)',
        'Mampu bekerja dalam tim dan komunikatif',
      ],
      industryProfile:
          'PT Telkom Indonesia (Persero) Tbk adalah perusahaan telekomunikasi '
          'digital terbesar di Indonesia. Divisi digitalnya berfokus pada '
          'pengembangan platform, solusi enterprise, dan percepatan transformasi '
          'digital nasional di berbagai sektor industri.',
      facilities: [
        'Uang saku bulanan kompetitif',
        'Sertifikat magang resmi',
        'Mentoring 1-on-1 bersama engineer senior',
      ],
    ),
    JobVacancy(
      title: 'Junior Mobile Flutter Engineer',
      company: 'Gojek Tech Academy',
      location: 'Jakarta',
      type: 'Full-time',
      matchScore: 88,
      description:
          'Berkontribusi dalam arsitektur aplikasi mobile, state management '
          'Riverpod, dan integrasi REST API. Kamu akan membangun fitur baru, '
          'merawat kualitas kode, serta berkolaborasi dengan tim produk untuk '
          'menghadirkan pengalaman pengguna terbaik di ekosistem Gojek.',
      requirements: [
        'Menguasai Dart dan framework Flutter',
        'Memahami state management (Riverpod / Bloc)',
        'Pengalaman mengintegrasikan REST API',
        'Terbiasa menggunakan Git dan code review',
      ],
      industryProfile:
          'Gojek Tech Academy adalah program pengembangan talenta teknologi '
          'dari Gojek yang melatih engineer untuk membangun solusi on-demand '
          'multi-layanan di Asia Tenggara dengan standar engineering kelas dunia.',
      facilities: [
        'Kompensasi kompetitif',
        'Asuransi kesehatan',
        'Peluang menjadi karyawan tetap',
      ],
    ),
    JobVacancy(
      title: 'Backend Node.js / Python Intern',
      company: 'Bukalapak',
      location: 'Remote',
      type: 'Magang',
      matchScore: 81,
      description:
          'Mengembangkan service endpoint microservice dan integrasi machine '
          'learning pipeline. Kamu akan merancang API yang andal dan scalable, '
          'menulis unit test, serta memastikan performa layanan tetap optimal '
          'di bawah beban produksi.',
      requirements: [
        'Memahami Node.js atau Python',
        'Mengerti konsep REST API dan database (SQL / NoSQL)',
        'Familiar dengan arsitektur microservices (nilai plus)',
        'Memahami dasar Git dan CI/CD',
      ],
      industryProfile:
          'Bukalapak adalah perusahaan e-commerce teknologi Indonesia yang '
          'membangun ekosistem perdagangan digital untuk UMKM dan konsumen di '
          'seluruh Indonesia dengan jaringan teknologi yang luas dan teruji.',
      facilities: [
        'Remote penuh',
        'Uang saku bulanan',
        'Sertifikat magang resmi',
      ],
    ),
    JobVacancy(
      title: 'UI/UX Product Design Apprentice',
      company: 'DANA Indonesia',
      location: 'Jakarta (Hybrid)',
      type: 'Magang',
      matchScore: 75,
      description:
          'Merancang user journey, wireframe, dan prototype antarmuka produk '
          'finansial digital. Kamu akan bekerja berdampingan dengan tim produk '
          'untuk menyederhanakan alur pengguna dan membangun pengalaman yang '
          'mudah digunakan dan inklusif.',
      requirements: [
        'Mahasiswa DKV / Desain Produk / Informatika',
        'Mahir menggunakan Figma dan prinsip desain',
        'Memahami design system dan wireframing',
        'Memiliki portofolio desain',
      ],
      industryProfile:
          'DANA Indonesia adalah platform dompet digital yang berfokus pada '
          'layanan keuangan digital yang aman, cepat, dan inklusif bagi '
          'masyarakat Indonesia.',
      facilities: [
        'Uang saku bulanan',
        'Sistem kerja hybrid',
        'Bimbingan langsung Principal Designer',
      ],
    ),
  ];
}