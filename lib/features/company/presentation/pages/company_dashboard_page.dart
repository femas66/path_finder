import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/company_profile.dart';
import '../../domain/models/job_posting.dart';
import '../providers/mitra_providers.dart';
import '../widgets/company_app_bar.dart';
import '../widgets/company_bottom_navbar.dart';
import '../widgets/tabs/candidates_tab.dart';
import '../widgets/tabs/company_home_tab.dart';
import '../widgets/tabs/company_profile_tab.dart';
import '../widgets/tabs/post_job_tab.dart';

class CompanyDashboardPage extends ConsumerStatefulWidget {
  const CompanyDashboardPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<CompanyDashboardPage> createState() => _CompanyDashboardPageState();
}

class _CompanyDashboardPageState extends ConsumerState<CompanyDashboardPage> {
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

  Future<void> _handleJobCreated(JobPosting newJob) async {
    try {
      final remoteSource = ref.read(mitraRemoteSourceProvider);

      final reqSkills = newJob.requiredSkills
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final optSkills = newJob.facilities
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await remoteSource.createJob(
        title: newJob.title,
        category: newJob.field.isNotEmpty ? newJob.field : 'Teknologi',
        description: newJob.description,
        location: newJob.location.isNotEmpty ? newJob.location : 'Indonesia',
        workType: newJob.executionPeriod.isNotEmpty ? newJob.executionPeriod : 'Full-time',
        requiredSkills: reqSkills.isNotEmpty ? reqSkills : ['Teknologi'],
        optionalSkills: optSkills,
      );

      ref.invalidate(mitraJobsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lowongan berhasil diposting ke server!'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _currentIndex = 0;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat lowongan: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleProfileUpdated(CompanyProfile updatedProfile) async {
    try {
      final remoteSource = ref.read(mitraRemoteSourceProvider);
      await remoteSource.updateProfile({
        'name': updatedProfile.companyName,
        'location': updatedProfile.city,
        if (updatedProfile.website.isNotEmpty) 'portfolio_url': updatedProfile.website,
      });

      ref.invalidate(mitraProfileProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil perusahaan berhasil diperbarui'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update profil: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleUpdateStatus(String candidateId, String newStatus) async {
    try {
      final remoteSource = ref.read(mitraRemoteSourceProvider);
      final apiStatus = newStatus.toLowerCase().contains('terima') ? 'accepted' : 'rejected';

      final success = await remoteSource.updateApplicationStatus(candidateId, apiStatus);

      if (success) {
        ref.invalidate(mitraApplicantsProvider(null));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pelamar berhasil diubah menjadi "$newStatus"'),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(mitraProfileProvider);
    final jobsAsync = ref.watch(mitraJobsProvider);
    final candidatesAsync = ref.watch(mitraApplicantsProvider(null));

    final profile = profileAsync.value;
    final companyName = profile?.companyName ?? 'Perusahaan Mitra';
    final jobs = jobsAsync.value ?? const [];
    final candidates = candidatesAsync.value ?? const [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CompanyAppBar(companyName: companyName),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CompanyHomeTab(
            jobs: jobs,
            candidates: candidates,
            onNavigateToPostJob: () => _onTabSelected(1),
            onNavigateToCandidates: () => _onTabSelected(2),
          ),
          PostJobTab(
            onJobCreated: _handleJobCreated,
          ),
          CandidatesTab(
            candidates: candidates,
            onUpdateStatus: _handleUpdateStatus,
          ),
          CompanyProfileTab(
            profile: profile,
            onProfileUpdated: _handleProfileUpdated,
          ),
        ],
      ),
      bottomNavigationBar: CompanyBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
