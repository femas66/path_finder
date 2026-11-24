import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/application_item.dart';
import '../../domain/models/mahasiswa_profile.dart';
import '../providers/dashboard_providers.dart';
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
class _HomeTab extends ConsumerWidget {
  const _HomeTab({
    required this.onNavigateToJobs,
    required this.onNavigateToApplications,
  });

  final VoidCallback onNavigateToJobs;
  final VoidCallback onNavigateToApplications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(myApplicationsProvider);
    final jobsAsync = ref.watch(jobsListProvider(const JobFilterParam(page: 1)));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DashboardHomeAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myApplicationsProvider);
          ref.invalidate(jobsListProvider);
          ref.invalidate(mahasiswaDashboardStatsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Banner Cerita Diri
            _buildStoryBanner(context),
            const SizedBox(height: 24),

            // Status Lamaran Terkini
            _buildSectionHeader(
              title: 'Status Lamaran Terkini',
              actionText: 'Lihat Semua',
              onAction: onNavigateToApplications,
            ),
            const SizedBox(height: 12),
            applicationsAsync.when(
              data: (apps) {
                if (apps.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Belum ada lamaran aktif. Jelajahi lowongan untuk melamar magang!',
                            style: GoogleFonts.sen(fontSize: 12, color: const Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final latest = apps.first;
                return ApplicationStatusCard(
                  title: latest.jobTitle,
                  company: latest.company,
                  appliedDate: latest.createdAt.toString().split(' ').first,
                  status: latest.displayStatus,
                  currentStep: latest.currentStep,
                  isCompact: true,
                  onTap: onNavigateToApplications,
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Gagal memuat status: $e', style: GoogleFonts.sen(fontSize: 12, color: const Color(0xFFDC2626))),
              ),
            ),
            const SizedBox(height: 24),

            // Lowongan Terbaru
            _buildSectionHeader(
              title: 'Lowongan IT Tersedia',
              actionText: 'Eksplorasi',
              onAction: onNavigateToJobs,
            ),
            const SizedBox(height: 12),
            jobsAsync.when(
              data: (jobs) {
                if (jobs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      'Belum ada lowongan dibuka saat ini.',
                      style: GoogleFonts.sen(fontSize: 13, color: const Color(0xFF64748B)),
                    ),
                  );
                }
                final displayJobs = jobs.take(3).toList();
                return Column(
                  children: displayJobs
                      .map(
                        (job) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: JobVacancyCard(
                            title: job.title,
                            company: job.company,
                            location: job.location,
                            type: job.type,
                            matchScore: job.matchScore,
                            onTap: () => context.push(AppRoutePaths.jobDetail, extra: job),
                            onApply: () => context.push(AppRoutePaths.jobDetail, extra: job),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Gagal memuat lowongan: $e', style: GoogleFonts.sen(fontSize: 12, color: const Color(0xFFDC2626))),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF2563EB)),
                          const SizedBox(width: 4),
                          Text(
                            'Cerita Diri & Refleksi',
                            style: GoogleFonts.sen(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tuliskan minat & pengalamanmu',
                  style: GoogleFonts.sen(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ceritakan ketertarikan karir teknologi untuk melengkapi profil magangmu.',
                  style: GoogleFonts.sen(fontSize: 12, color: const Color(0xFF64748B), height: 1.4),
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
// Tab 2: Lowongan (Jobs)
// ---------------------------------------------------------------------------
class _JobsTab extends ConsumerStatefulWidget {
  const _JobsTab();

  @override
  ConsumerState<_JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends ConsumerState<_JobsTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Teknologi',
    'Frontend',
    'Backend',
    'Mobile',
    'Data Science',
    'Desain',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = JobFilterParam(
      search: _searchCtrl.text.trim(),
      category: _selectedCategory,
    );
    final jobsAsync = ref.watch(jobsListProvider(filter));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DashboardTabAppBar(title: 'Daftar Lowongan IT'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(jobsListProvider(filter));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Search Bar
            TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari posisi, keahlian, atau perusahaan...',
                hintStyle: GoogleFonts.sen(fontSize: 13, color: const Color(0xFFA0A5BA)),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFA0A5BA)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
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

            // Filter Kategori
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2373F4) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2373F4) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.sen(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // List Lowongan
            jobsAsync.when(
              data: (jobs) {
                if (jobs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.work_off_outlined, size: 48, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada lowongan ditemukan',
                          style: GoogleFonts.sen(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: jobs
                      .map(
                        (job) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: JobVacancyCard(
                            title: job.title,
                            company: job.company,
                            location: job.location,
                            type: job.type,
                            matchScore: job.matchScore,
                            description: job.description,
                            onTap: () => context.push(AppRoutePaths.jobDetail, extra: job),
                            onApply: () => context.push(AppRoutePaths.jobDetail, extra: job),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('Gagal memuat lowongan: $err', style: GoogleFonts.sen(color: const Color(0xFFDC2626))),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(jobsListProvider(filter)),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3: Pelacakan Lamaran (Mahasiswa)
// ---------------------------------------------------------------------------
class _ApplicationsTab extends ConsumerStatefulWidget {
  const _ApplicationsTab();

  @override
  ConsumerState<_ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends ConsumerState<_ApplicationsTab> {
  String _selectedFilter = 'Semua';

  void _showDetailBottomSheet(BuildContext context, ApplicationItem item) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (item.status.toLowerCase().trim()) {
      case 'accepted':
        statusColor = const Color(0xFF059669);
        statusBg = const Color(0xFFECFDF5);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = const Color(0xFFDC2626);
        statusBg = const Color(0xFFFEE2E2);
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = const Color(0xFFD97706);
        statusBg = const Color(0xFFFEF3C7);
        statusIcon = Icons.schedule_rounded;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
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
                          item.jobTitle,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          item.displayStatus,
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
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    'Diajukan pada: ${item.createdAt.toString().split(' ').first}',
                    style: GoogleFonts.sen(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2373F4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.sen(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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
    final applicationsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DashboardTabAppBar(title: 'Status Lamaran'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myApplicationsProvider);
        },
        child: applicationsAsync.when(
          data: (allApplications) {
            final filtered = allApplications.where((app) {
              if (_selectedFilter == 'Semua') return true;
              if (_selectedFilter == 'Menunggu') {
                final s = app.status.toLowerCase();
                return s != 'accepted' && s != 'rejected';
              }
              if (_selectedFilter == 'Diterima') return app.status.toLowerCase() == 'accepted';
              if (_selectedFilter == 'Ditolak') return app.status.toLowerCase() == 'rejected';
              return true;
            }).toList();

            final waitingCount = allApplications.where((a) => a.status.toLowerCase() != 'accepted' && a.status.toLowerCase() != 'rejected').length;
            final acceptedCount = allApplications.where((a) => a.status.toLowerCase() == 'accepted').length;
            final rejectedCount = allApplications.where((a) => a.status.toLowerCase() == 'rejected').length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Menunggu',
                        count: waitingCount,
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                        isSelected: _selectedFilter == 'Menunggu',
                        onTap: () => setState(() => _selectedFilter = _selectedFilter == 'Menunggu' ? 'Semua' : 'Menunggu'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Diterima',
                        count: acceptedCount,
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF059669),
                        bgColor: const Color(0xFFECFDF5),
                        isSelected: _selectedFilter == 'Diterima',
                        onTap: () => setState(() => _selectedFilter = _selectedFilter == 'Diterima' ? 'Semua' : 'Diterima'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Ditolak',
                        count: rejectedCount,
                        icon: Icons.cancel_rounded,
                        color: const Color(0xFFDC2626),
                        bgColor: const Color(0xFFFEE2E2),
                        isSelected: _selectedFilter == 'Ditolak',
                        onTap: () => setState(() => _selectedFilter = _selectedFilter == 'Ditolak' ? 'Semua' : 'Ditolak'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Application List
                if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada lamaran dengan status "$_selectedFilter"',
                          style: GoogleFonts.sen(fontSize: 13, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                else
                  ...filtered.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ApplicationStatusCard(
                        title: item.jobTitle,
                        company: item.company,
                        appliedDate: item.createdAt.toString().split(' ').first,
                        status: item.displayStatus,
                        currentStep: item.currentStep,
                        onTap: () => _showDetailBottomSheet(context, item),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text('Gagal memuat lamaran: $err', style: GoogleFonts.sen(color: const Color(0xFFDC2626))),
          ),
        ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: GoogleFonts.sen(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 4: Profil Mahasiswa
// ---------------------------------------------------------------------------
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, MahasiswaProfile current) {
    final locCtrl = TextEditingController(text: current.location ?? '');
    final cvCtrl = TextEditingController(text: current.cv ?? '');
    final portCtrl = TextEditingController(text: current.portfolioUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Profil Mahasiswa', style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: 'Lokasi / Asal Kota', hintText: 'Contoh: Bandung'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cvCtrl,
                decoration: const InputDecoration(labelText: 'URL Link CV (Drive/Website)', hintText: 'https://...'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portCtrl,
                decoration: const InputDecoration(labelText: 'URL Link Portofolio', hintText: 'https://github.com/...'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final source = ref.read(mahasiswaRemoteSourceProvider);
                await source.updateProfile({
                  if (locCtrl.text.isNotEmpty) 'location': locCtrl.text.trim(),
                  if (cvCtrl.text.isNotEmpty) 'cv': cvCtrl.text.trim(),
                  if (portCtrl.text.isNotEmpty) 'portfolio_url': portCtrl.text.trim(),
                });
                ref.invalidate(mahasiswaProfileProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Color(0xFF059669)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal update: $e'), backgroundColor: const Color(0xFFDC2626)),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2373F4)),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(mahasiswaProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const DashboardTabAppBar(title: 'Profil Mahasiswa'),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(mahasiswaProfileProvider),
        child: profileAsync.when(
          data: (profile) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Card
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
                        backgroundColor: const Color(0xFF2373F4).withValues(alpha: 0.1),
                        child: Text(
                          profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'M',
                          style: GoogleFonts.sen(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2373F4)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: GoogleFonts.sen(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.email,
                              style: GoogleFonts.sen(fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                            if (profile.nim != null && profile.nim!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('NIM: ${profile.nim}', style: GoogleFonts.sen(fontSize: 11, color: const Color(0xFF64748B))),
                            ],
                            if (profile.location != null && profile.location!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Lokasi: ${profile.location}', style: GoogleFonts.sen(fontSize: 11, color: const Color(0xFF2373F4))),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF2373F4)),
                        onPressed: () => _showEditProfileDialog(context, ref, profile),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Detail Dokumen
                _buildMenuTile(
                  icon: Icons.description_outlined,
                  title: 'Curriculum Vitae (CV)',
                  subtitle: profile.cv != null && profile.cv!.isNotEmpty ? profile.cv! : 'Belum diunggah',
                  onTap: () => _showEditProfileDialog(context, ref, profile),
                ),
                _buildMenuTile(
                  icon: Icons.link_rounded,
                  title: 'Portofolio URL',
                  subtitle: profile.portfolioUrl != null && profile.portfolioUrl!.isNotEmpty ? profile.portfolioUrl! : 'Belum diisi',
                  onTap: () => _showEditProfileDialog(context, ref, profile),
                ),
                _buildMenuTile(
                  icon: Icons.history_edu_rounded,
                  title: 'Riwayat Cerita Reflektif',
                  subtitle: 'Tulis atau perbarui cerita minat karir',
                  onTap: () => context.go(AppRoutePaths.story),
                ),
                const SizedBox(height: 24),

                // Tombol Keluar Akun
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authLocalSourceProvider).clearSession();
                    if (context.mounted) {
                      context.go(AppRoutePaths.login);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
                  label: Text(
                    'Keluar dari Akun',
                    style: GoogleFonts.sen(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFEE2E2)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Gagal memuat profil: $e')),
        ),
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
          style: GoogleFonts.sen(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.sen(fontSize: 11, color: const Color(0xFF64748B)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFA0A5BA), size: 20),
        onTap: onTap,
      ),
    );
  }
}
