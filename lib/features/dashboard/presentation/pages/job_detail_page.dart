import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/job_vacancy.dart';

/// Halaman detail sebuah lowongan magang/kerja (Detail Magang).
///
/// Menampilkan informasi lengkap lowongan: header (posisi, perusahaan, lokasi),
/// deskripsi posisi, syarat & kualifikasi, profil industri, serta tombol
/// pemicu pendaftaran di bagian bawah.
class JobDetailPage extends StatelessWidget {
  const JobDetailPage({super.key, required this.job});

  final JobVacancy job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Detail Magang',
          style: GoogleFonts.sen(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(job: job),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Deskripsi Posisi',
            child: Text(
              job.description,
              style: GoogleFonts.sen(
                fontSize: 13,
                color: const Color(0xFF334155),
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Syarat & Kualifikasi',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < job.requirements.length; i++) ...[
                  _RequirementRow(text: job.requirements[i]),
                  if (i < job.requirements.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Profil Industri',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.industryProfile,
                  style: GoogleFonts.sen(
                    fontSize: 13,
                    color: const Color(0xFF334155),
                    height: 1.55,
                  ),
                ),
                if (job.facilities.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Fasilitas',
                    style: GoogleFonts.sen(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < job.facilities.length; i++) ...[
                    _RequirementRow(text: job.facilities[i]),
                    if (i < job.facilities.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lamaran terkirim untuk ${job.title}!'),
                    backgroundColor: const Color(0xFF2373F4),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2373F4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lamar Sekarang',
                style: GoogleFonts.sen(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Satu baris syarat/kualifikasi dengan ikon centang.
class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF2373F4).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 12,
            color: Color(0xFF2373F4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.sen(
              fontSize: 13,
              color: const Color(0xFF334155),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Kartu putih pembungkus satu bagian informasi di halaman detail.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.sen(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Kartu header yang merangkum posisi, perusahaan, lokasi, dan kecocokan.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.job});

  final JobVacancy job;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF0F5FA), Color(0xFFE2EBF8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    job.initial,
                    style: GoogleFonts.sen(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2373F4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: GoogleFonts.sen(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.company,
                      style: GoogleFonts.sen(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
              if (job.matchScore != null) ...[
                const SizedBox(width: 8),
                _MatchBadge(score: job.matchScore!),
              ],
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                job.type != null ? '${job.location} • ${job.type}' : job.location,
                style: GoogleFonts.sen(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Badge persentase kecocokan.
class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.25)),
      ),
      child: Text(
        '$score% Match',
        style: GoogleFonts.sen(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF059669),
        ),
      ),
    );
  }
}