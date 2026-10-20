import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router.dart';
import '../widgets/application_status_card.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_bottom_navbar.dart';
import '../widgets/job_vacancy_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            onNavigateToJobs: () => _onTabSelected(1),
            onNavigateToApplications: () => _onTabSelected(2),
          ),
          const _JobsTab(),
          const _ApplicationsTab(),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: DashboardBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Beranda (Home)
// ---------------------------------------------------------------------------
class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.onNavigateToJobs,
    required this.onNavigateToApplications,
  });

  final VoidCallback onNavigateToJobs;
  final VoidCallback onNavigateToApplications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DashboardHomeAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner Story & AI Matching
          _buildStoryBanner(context),
          const SizedBox(height: 24),

          // Status Lamaran Ringkas
          _buildSectionHeader(
            title: 'Status Lamaran Terkini',
            actionText: 'Lihat Semua',
            onAction: onNavigateToApplications,
          ),
          const SizedBox(height: 12),
          ApplicationStatusCard(
            title: 'Backend Engineer Intern',
            company: 'PT Tokopedia',
            appliedDate: 'Dilamar 2 hari lalu',
            status: 'Seleksi Berkas',
            isCompact: true,
            onTap: onNavigateToApplications,
          ),
          const SizedBox(height: 24),

          // Rekomendasi Lowongan Matching
          _buildSectionHeader(
            title: 'Rekomendasi Lowongan Untukmu',
            actionText: 'Eksplorasi',
            onAction: onNavigateToJobs,
          ),
          const SizedBox(height: 12),
          JobVacancyCard(
            title: 'Frontend Developer Intern',
            company: 'PT Telkom Indonesia',
            location: 'Bandung',
            type: 'Hybrid',
            matchScore: 94,
            onApply: onNavigateToJobs,
          ),
          const SizedBox(height: 12),
          JobVacancyCard(
            title: 'Junior Mobile Flutter Engineer',
            company: 'Gojek Tech Academy',
            location: 'Jakarta',
            type: 'Onsite',
            matchScore: 88,
            onApply: onNavigateToJobs,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStoryBanner(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(AppRoutePaths.story),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2373F4).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'AI MATCHING',
                        style: GoogleFonts.sen(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: const Color(0xFF2373F4),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: Color(0xFF2373F4),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Ceritakan Dirimu untuk Rekomendasi Lowongan',
                  style: GoogleFonts.sen(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tulis pengalamanmu untuk menemukan posisi IT dengan kecocokan tertinggi.',
                  style: GoogleFonts.sen(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutePaths.story),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2373F4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mulai Cerita',
                          style: GoogleFonts.sen(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.sen(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF121223),
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText,
            style: GoogleFonts.sen(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2373F4),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Lowongan (Jobs / Melamar Lowongan & Matching)
// ---------------------------------------------------------------------------
class _JobsTab extends StatelessWidget {
  const _JobsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DashboardTabAppBar(
        title: 'Daftar Lowongan IT',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari posisi, keahlian, atau perusahaan...',
              hintStyle: GoogleFonts.sen(
                fontSize: 13,
                color: const Color(0xFFA0A5BA),
              ),
              prefixIcon:
                  const Icon(Icons.search_rounded, color: Color(0xFFA0A5BA)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua Lowongan', isSelected: true),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Rekomendasi Matching (AI)',
                  isHighlighted: true,
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Frontend'),
                const SizedBox(width: 8),
                _buildFilterChip('Backend'),
                const SizedBox(width: 8),
                _buildFilterChip('Data Science'),
                const SizedBox(width: 8),
                _buildFilterChip('DevOps'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Jobs List with JobVacancyCard
          JobVacancyCard(
            title: 'Frontend Developer Intern',
            company: 'PT Telkom Indonesia',
            location: 'Bandung',
            type: 'Magang',
            matchScore: 94,
            description:
                'Membantu pengembangan modul antarmuka aplikasi web dan mobile dengan Flutter & React.',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Melihat detail lowongan Frontend Developer Intern'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            onApply: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Lamaran terkirim untuk Frontend Developer Intern!'),
                  backgroundColor: Color(0xFF2373F4),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          JobVacancyCard(
            title: 'Junior Mobile Flutter Engineer',
            company: 'Gojek Tech Academy',
            location: 'Jakarta',
            type: 'Full-time',
            matchScore: 88,
            description:
                'Berkontribusi dalam arsitektur aplikasi mobile, state management Riverpod, dan integrasi REST API.',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Melihat detail lowongan Junior Mobile Flutter Engineer'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            onApply: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Lamaran terkirim untuk Junior Mobile Flutter Engineer!'),
                  backgroundColor: Color(0xFF2373F4),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          JobVacancyCard(
            title: 'Backend Node.js / Python Intern',
            company: 'Bukalapak',
            location: 'Remote',
            type: 'Magang',
            matchScore: 81,
            description:
                'Mengembangkan service endpoint microservice dan integrasi machine learning pipeline.',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Melihat detail lowongan Backend Node.js / Python Intern'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            onApply: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Lamaran terkirim untuk Backend Node.js / Python Intern!'),
                  backgroundColor: Color(0xFF2373F4),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          JobVacancyCard(
            title: 'UI/UX Product Design Apprentice',
            company: 'DANA Indonesia',
            location: 'Jakarta (Hybrid)',
            type: 'Magang',
            matchScore: 75,
            description:
                'Merancang user journey, wireframe, dan prototype antarmuka produk finansial digital.',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Melihat detail lowongan UI/UX Product Design Apprentice'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            onApply: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Lamaran terkirim untuk UI/UX Product Design Apprentice!'),
                  backgroundColor: Color(0xFF2373F4),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label, {
    bool isSelected = false,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF2373F4)
            : (isHighlighted ? const Color(0xFFECFDF5) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF2373F4)
              : (isHighlighted
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.sen(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected
              ? Colors.white
              : (isHighlighted
                  ? const Color(0xFF047857)
                  : const Color(0xFF475569)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3: Lamaran (Applications / Melihat Status Lamaran)
// ---------------------------------------------------------------------------
class _ApplicationsTab extends StatelessWidget {
  const _ApplicationsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DashboardTabAppBar(
        title: 'Status Lamaran',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ApplicationStatusCard(
            title: 'Backend Engineer Intern',
            company: 'PT Tokopedia',
            appliedDate: '17 Oktober 2026',
            status: 'Seleksi Berkas',
            note: 'Berkas lamaran sedang ditinjau oleh HR & Tech Lead.',
          ),
          SizedBox(height: 12),
          ApplicationStatusCard(
            title: 'Frontend Developer Intern',
            company: 'PT Telkom Indonesia',
            appliedDate: '15 Oktober 2026',
            status: 'Wawancara User',
            note:
                'Jadwal wawancara teknis: Kamis, 22 Okt 2026 via Google Meet.',
          ),
          SizedBox(height: 12),
          ApplicationStatusCard(
            title: 'Mobile App Developer Apprentice',
            company: 'Shopee Indonesia',
            appliedDate: '10 Oktober 2026',
            status: 'Diterima Magang',
            note: 'Selamat! Cek email untuk penawaran offering letter.',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 4: Profil (Profile)
// ---------------------------------------------------------------------------
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DashboardTabAppBar(
        title: 'Profil Mahasiswa',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      const Color(0xFF2373F4).withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: Color(0xFF2373F4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mahasiswa Pengguna',
                        style: GoogleFonts.sen(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Teknik Informatika • Semester 6',
                        style: GoogleFonts.sen(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Minat IT: Frontend & Mobile',
                          style: GoogleFonts.sen(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2373F4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Menu items
          _buildMenuTile(
            icon: Icons.history_edu_rounded,
            title: 'Riwayat Cerita & Analisis Minat',
            subtitle: 'Lihat kembali profil karir & kecocokan IT',
            onTap: () => context.go(AppRoutePaths.story),
          ),
          _buildMenuTile(
            icon: Icons.description_outlined,
            title: 'Curriculum Vitae (CV) & Portofolio',
            subtitle: 'Atur berkas untuk melamar lowongan',
            onTap: () {},
          ),
          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: 'Pengaturan Akun',
            subtitle: 'Ubah kata sandi dan preferensi',
            onTap: () {},
          ),
          const SizedBox(height: 16),

          // Logout Button
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutePaths.login),
            icon: const Icon(Icons.logout_rounded,
                color: Color(0xFFDC2626), size: 18),
            label: Text(
              'Keluar dari Akun',
              style: GoogleFonts.sen(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFDC2626),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFEE2E2)),
              backgroundColor: const Color(0xFFFEF2F2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2373F4), size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.sen(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          subtitle: Text(
            subtitle,
            style:
                GoogleFonts.sen(fontSize: 11, color: const Color(0xFF64748B)),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFA0A5BA),
            size: 20,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
