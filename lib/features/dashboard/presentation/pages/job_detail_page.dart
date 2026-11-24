import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/job_vacancy.dart';
import '../providers/dashboard_providers.dart';

/// Halaman detail sebuah lowongan magang/kerja (Detail Magang).
///
/// Menampilkan informasi lengkap lowongan: header (posisi, perusahaan, lokasi),
/// deskripsi posisi, syarat & kualifikasi, profil industri, serta tombol
/// pemicu pendaftaran di bagian bawah yang memanggil API riil backend.
class JobDetailPage extends ConsumerStatefulWidget {
  const JobDetailPage({super.key, required this.job});

  final JobVacancy job;

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  bool _isLoading = false;

  Future<void> _handleApply() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Lamar Lowongan Ini?',
          style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          'Anda akan mendaftar untuk posisi ${widget.job.title} di ${widget.job.company}. Pastikan profil dan CV Anda sudah diperbarui.',
          style: GoogleFonts.sen(fontSize: 14, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.sen(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2373F4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Ya, Lamar',
              style: GoogleFonts.sen(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final remoteSource = ref.read(jobRemoteSourceProvider);
      final success = await remoteSource.applyJob(widget.job.id);

      if (!mounted) return;

      if (success) {
        ref.invalidate(myApplicationsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lamaran berhasil dikirim untuk ${widget.job.title}!'),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengirim lamaran. Silakan coba lagi.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

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
              job.description.isNotEmpty
                  ? job.description
                  : 'Tidak ada deskripsi rinci untuk posisi ini.',
              style: GoogleFonts.sen(
                fontSize: 13,
                color: const Color(0xFF334155),
                height: 1.55,
              ),
            ),
          ),
          if (job.requirements.isNotEmpty) ...[
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
          ],
          if (job.facilities.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Keahlian / Fasilitas Tambahan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < job.facilities.length; i++) ...[
                    _RequirementRow(
                      text: job.facilities[i],
                      icon: Icons.star_border_rounded,
                      iconColor: const Color(0xFFD97706),
                    ),
                    if (i < job.facilities.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Profil Industri',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.industryProfile.isNotEmpty
                      ? job.industryProfile
                      : job.company,
                  style: GoogleFonts.sen(
                    fontSize: 13,
                    color: const Color(0xFF334155),
                    height: 1.55,
                  ),
                ),
                if (job.sourceUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.link_rounded, size: 16, color: Color(0xFF2373F4)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          job.sourceUrl,
                          style: GoogleFonts.sen(
                            fontSize: 12,
                            color: const Color(0xFF2373F4),
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleApply,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2373F4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
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
  const _RequirementRow({
    required this.text,
    this.icon = Icons.check_circle_outline_rounded,
    this.iconColor = const Color(0xFF2373F4),
  });

  final String text;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.sen(
              fontSize: 13,
              color: const Color(0xFF334155),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Kontainer putih ber-border untuk mengelompokkan satu bagian informasi.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.sen(
              fontSize: 14,
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

/// Header detail lowongan: avatar perusahaan, posisi, nama perusahaan,
/// lokasi, jenis kerja, dan skor kecocokan (jika ada).
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.job});

  final JobVacancy job;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  color: const Color(0xFF2373F4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  job.initial,
                  style: GoogleFonts.sen(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2373F4),
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.company,
                      style: GoogleFonts.sen(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoBadge(
                icon: Icons.location_on_outlined,
                label: job.location,
              ),
              if (job.type != null && job.type!.isNotEmpty)
                _InfoBadge(
                  icon: Icons.work_outline_rounded,
                  label: job.type!,
                ),
              if (job.category.isNotEmpty)
                _InfoBadge(
                  icon: Icons.category_outlined,
                  label: job.category,
                ),
              if (job.matchScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${job.matchScore}% Cocok',
                        style: GoogleFonts.sen(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Badge kecil untuk lokasi / tipe pekerjaan dengan ikon dan teks.
class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.sen(
              fontSize: 11,
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
