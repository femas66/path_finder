import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/models/candidate_application.dart';
import '../../../domain/models/job_posting.dart';
import '../cards/company_job_card.dart';

class CompanyHomeTab extends StatelessWidget {
  const CompanyHomeTab({
    super.key,
    required this.jobs,
    required this.candidates,
    required this.onNavigateToPostJob,
    required this.onNavigateToCandidates,
  });

  final List<JobPosting> jobs;
  final List<CandidateApplication> candidates;
  final VoidCallback onNavigateToPostJob;
  final VoidCallback onNavigateToCandidates;

  @override
  Widget build(BuildContext context) {
    final activeJobs = jobs.where((j) => j.isActive).length;
    final totalApplicants = candidates.length;
    final interviewCount =
        candidates.where((c) => c.status == 'Wawancara').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          // Banner Quick Action: Posting Lowongan
          _buildQuickActionBanner(context),
          const SizedBox(height: 20),

          // Statistik Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  label: 'Lowongan Aktif',
                  value: '$activeJobs',
                  icon: Icons.work_outline_rounded,
                  iconColor: const Color(0xFF2373F4),
                  bgColor: const Color(0xFF2373F4).withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  label: 'Total Pelamar',
                  value: '$totalApplicants',
                  icon: Icons.people_outline_rounded,
                  iconColor: const Color(0xFF10B981),
                  bgColor: const Color(0xFF10B981).withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  label: 'Wawancara',
                  value: '$interviewCount',
                  icon: Icons.contact_phone_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Header Section: Lowongan yang Dibuka
          _buildSectionHeader(
            title: 'Lowongan Magang Anda',
            actionText: 'Buat Baru',
            onAction: onNavigateToPostJob,
          ),
          const SizedBox(height: 12),

          if (jobs.isEmpty)
            _buildEmptyState(
              icon: Icons.work_off_outlined,
              message: 'Belum ada lowongan yang diposting.',
              buttonText: 'Posting Sekarang',
              onButtonPressed: onNavigateToPostJob,
            )
          else
            ...jobs.map((job) => CompanyJobCard(
                  job: job,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Detail lowongan: ${job.title}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                )),

          const SizedBox(height: 20),

          // Header Section: Kandidat Masuk Terkini
          _buildSectionHeader(
            title: 'Kandidat Masuk Terkini',
            actionText: 'Lihat Semua',
            onAction: onNavigateToCandidates,
          ),
          const SizedBox(height: 12),

          if (candidates.isEmpty)
            _buildEmptyState(
              icon: Icons.person_search_outlined,
              message: 'Belum ada kandidat yang melamar.',
            )
          else
            ...candidates.take(2).map((cand) => _buildQuickCandidateTile(cand)),
        ],
      ),
    );
  }

  Widget _buildQuickActionBanner(BuildContext context) {
    return Container(
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
                    'REKRUTMEN MAGANG',
                    style: GoogleFonts.sen(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: const Color(0xFF2373F4),
                    ),
                  ),
                ),
                const Icon(
                  Icons.stars_rounded,
                  size: 18,
                  color: Color(0xFF2373F4),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Butuh Talenta Mahasiswa Terbaik?',
              style: GoogleFonts.sen(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Posting posisi magang baru dengan kualifikasi spesifik untuk dicocokkan otomatis oleh sistem PathFinder.',
              style: GoogleFonts.sen(
                fontSize: 12,
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onNavigateToPostJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2373F4),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Posting Lowongan Baru',
                    style: GoogleFonts.sen(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.sen(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.sen(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        InkWell(
          onTap: onAction,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              actionText,
              style: GoogleFonts.sen(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2373F4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCandidateTile(CandidateApplication cand) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF2373F4).withValues(alpha: 0.1),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF2373F4),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cand.candidateName,
                  style: GoogleFonts.sen(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  cand.jobTitle,
                  style: GoogleFonts.sen(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FA),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              cand.status,
              style: GoogleFonts.sen(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2373F4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFFA0A5BA)),
            const SizedBox(height: 10),
            Text(
              message,
              style: GoogleFonts.sen(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onButtonPressed,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2373F4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.sen(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2373F4),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
