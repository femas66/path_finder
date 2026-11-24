import 'package:flutter/material.dart';

import '../../data/company_mock_data.dart';
import '../../domain/models/candidate_application.dart';
import '../../domain/models/company_profile.dart';
import '../../domain/models/job_posting.dart';
import '../widgets/company_app_bar.dart';
import '../widgets/company_bottom_navbar.dart';
import '../widgets/tabs/candidates_tab.dart';
import '../widgets/tabs/company_home_tab.dart';
import '../widgets/tabs/company_profile_tab.dart';
import '../widgets/tabs/post_job_tab.dart';

class CompanyDashboardPage extends StatefulWidget {
  const CompanyDashboardPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<CompanyDashboardPage> createState() => _CompanyDashboardPageState();
}

class _CompanyDashboardPageState extends State<CompanyDashboardPage> {
  late int _currentIndex;
  late List<JobPosting> _jobs;
  late List<CandidateApplication> _candidates;
  late CompanyProfile _companyProfile;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _jobs = List.from(CompanyMockData.getInitialJobs());
    _candidates = List.from(CompanyMockData.getInitialCandidates());
    _companyProfile = CompanyMockData.getInitialCompanyProfile();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleJobCreated(JobPosting newJob) {
    setState(() {
      _jobs.insert(
        0,
        newJob.copyWith(companyName: _companyProfile.companyName),
      );
      // Switch back to Home / Ringkasan tab to view the newly posted job
      _currentIndex = 0;
    });
  }

  void _handleProfileUpdated(CompanyProfile updatedProfile) {
    setState(() {
      _companyProfile = updatedProfile;
      _jobs = _jobs
          .map((job) => job.copyWith(companyName: updatedProfile.companyName))
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil perusahaan berhasil diperbarui'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CompanyAppBar(companyName: _companyProfile.companyName),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          CompanyHomeTab(
            jobs: _jobs,
            candidates: _candidates,
            onNavigateToPostJob: () => _onTabSelected(1),
            onNavigateToCandidates: () => _onTabSelected(2),
          ),
          PostJobTab(onJobCreated: _handleJobCreated),
          const CandidatesTab(),
          CompanyProfileTab(
            profile: _companyProfile,
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
