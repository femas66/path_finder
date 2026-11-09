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
            status: 'Menunggu',
            currentStep: 2,
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
// Tab 3: Pelacakan Lamaran (Mahasiswa) - List riwayat lamaran & indikator status
// ---------------------------------------------------------------------------
class _ApplicationItem {
  const _ApplicationItem({
    required this.title,
    required this.company,
    required this.appliedDate,
    required this.status,
    required this.note,
    this.currentStep,
  });

  final String title;
  final String company;
  final String appliedDate;
  final String status;
  final String note;
  final int? currentStep;
}

class _ApplicationsTab extends StatefulWidget {
  const _ApplicationsTab();

  @override
  State<_ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<_ApplicationsTab> {
  String _selectedFilter = 'Semua';

  static const List<_ApplicationItem> _allApplications = [
    _ApplicationItem(
      title: 'Backend Engineer Intern',
      company: 'PT Tokopedia',
      appliedDate: '17 Oktober 2026',
      status: 'Menunggu',
      note: 'Tahap Seleksi Berkas sedang ditinjau oleh HR & Tech Lead.',
      currentStep: 2,
    ),
    _ApplicationItem(
      title: 'Mobile App Developer Apprentice',
      company: 'Shopee Indonesia',
      appliedDate: '10 Oktober 2026',
      status: 'Diterima',
      note:
          'Selamat! Kamu dinyatakan lolos. Cek email untuk penawaran offering letter.',
      currentStep: 4,
    ),
    _ApplicationItem(
      title: 'UI/UX Designer Intern',
      company: 'Bukalapak',
      appliedDate: '05 Oktober 2026',
      status: 'Ditolak',
      note:
          'Terima kasih atas minatmu. Saat ini kualifikasi belum sesuai kebutuhan tim.',
      currentStep: 1,
    ),
    _ApplicationItem(
      title: 'Frontend Developer Intern',
      company: 'PT Telkom Indonesia',
      appliedDate: '15 Oktober 2026',
      status: 'Menunggu',
      note: 'Menunggu konfirmasi jadwal wawancara teknis via Google Meet.',
      currentStep: 3,
    ),
  ];

  List<_ApplicationItem> get _filteredApplications {
    if (_selectedFilter == 'Semua') return _allApplications;
    return _allApplications
        .where(
            (app) => app.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  int _countByStatus(String status) {
    return _allApplications
        .where((app) => app.status.toLowerCase() == status.toLowerCase())
        .length;
  }

  void _showDetailBottomSheet(BuildContext context, _ApplicationItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final lower = item.status.toLowerCase();
        final Color statusColor = lower.contains('terima')
            ? const Color(0xFF059669)
            : (lower.contains('tolak')
                ? const Color(0xFFDC2626)
                : const Color(0xFFD97706));
        final Color statusBg = lower.contains('terima')
            ? const Color(0xFFECFDF5)
            : (lower.contains('tolak')
                ? const Color(0xFFFEE2E2)
                : const Color(0xFFFEF3C7));
        final IconData statusIcon = lower.contains('terima')
            ? Icons.check_circle_rounded
            : (lower.contains('tolak')
                ? Icons.cancel_rounded
                : Icons.schedule_rounded);

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.sen(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.company,
                          style: GoogleFonts.sen(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          item.status,
                          style: GoogleFonts.sen(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Text(
                'Catatan Status',
                style: GoogleFonts.sen(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  item.note,
                  style: GoogleFonts.sen(
                    fontSize: 13,
                    color: const Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tanggal Lamaran: ${item.appliedDate}',
                    style: GoogleFonts.sen(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2373F4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.sen(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredApplications;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DashboardTabAppBar(
        title: 'Status Lamaran',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Pelacakan Lamaran Ringkas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Lamaran',
                style: GoogleFonts.sen(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                '${_allApplications.length} Total Lamaran',
                style: GoogleFonts.sen(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Summary Cards (Menunggu, Diterima, Ditolak)
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Menunggu',
                  count: _countByStatus('Menunggu'),
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFEF3C7),
                  isSelected: _selectedFilter == 'Menunggu',
                  onTap: () {
                    setState(() {
                      _selectedFilter =
                          _selectedFilter == 'Menunggu' ? 'Semua' : 'Menunggu';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Diterima',
                  count: _countByStatus('Diterima'),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                  isSelected: _selectedFilter == 'Diterima',
                  onTap: () {
                    setState(() {
                      _selectedFilter =
                          _selectedFilter == 'Diterima' ? 'Semua' : 'Diterima';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Ditolak',
                  count: _countByStatus('Ditolak'),
                  icon: Icons.cancel_rounded,
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEE2E2),
                  isSelected: _selectedFilter == 'Ditolak',
                  onTap: () {
                    setState(() {
                      _selectedFilter =
                          _selectedFilter == 'Ditolak' ? 'Semua' : 'Ditolak';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  count: _allApplications.length,
                  isSelected: _selectedFilter == 'Semua',
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Semua';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Menunggu',
                  count: _countByStatus('Menunggu'),
                  isSelected: _selectedFilter == 'Menunggu',
                  activeColor: const Color(0xFFD97706),
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Menunggu';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Diterima',
                  count: _countByStatus('Diterima'),
                  isSelected: _selectedFilter == 'Diterima',
                  activeColor: const Color(0xFF059669),
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Diterima';
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Ditolak',
                  count: _countByStatus('Ditolak'),
                  isSelected: _selectedFilter == 'Ditolak',
                  activeColor: const Color(0xFFDC2626),
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Ditolak';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Application Cards List
          if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ApplicationStatusCard(
                  title: item.title,
                  company: item.company,
                  appliedDate: item.appliedDate,
                  status: item.status,
                  note: item.note,
                  currentStep: item.currentStep,
                  onTap: () => _showDetailBottomSheet(context, item),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? bgColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: GoogleFonts.sen(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: GoogleFonts.sen(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = const Color(0xFF2373F4),
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.sen(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.sen(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.inbox_rounded,
            size: 48,
            color: Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada lamaran dengan status "$_selectedFilter"',
            textAlign: TextAlign.center,
            style: GoogleFonts.sen(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
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
