import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:path_finder/app/router.dart';

class CompanyProfileTab extends StatelessWidget {
  const CompanyProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Profil Perusahaan Card
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF2373F4)
                      .withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.business_rounded,
                    size: 34,
                    color: Color(0xFF2373F4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Perusahaan',
                        style: GoogleFonts.sen(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PT Inovasi Teknologi Nusantara',
                        style: GoogleFonts.sen(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Software House & Digital Solution • Bandung',
                        style: GoogleFonts.sen(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF10B981)),
                        ),
                        child: Text(
                          'Mitra Industri Terverifikasi',
                          style: GoogleFonts.sen(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu Items
          _buildMenuTile(
            context: context,
            icon: Icons.domain_outlined,
            title: 'Detail Legalitas & Profil Perusahaan',
            subtitle: 'NPWP, NIB, dan deskripsi profil perusahaan',
            onTap: () => _showLegalityModal(context),
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.notifications_none_rounded,
            title: 'Preferensi Notifikasi Pelamar',
            subtitle: 'Atur email alert saat kandidat baru melamar',
            onTap: () => _showNotificationPreferencesModal(context),
          ),

          const SizedBox(height: 20),

          // Logout Button
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutePaths.login),
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFDC2626),
              size: 18,
            ),
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

  void _showLegalityModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Legalitas & Profil Industri',
                  style: GoogleFonts.sen(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dokumen verifikasi resmi mitra program magang PathFinder',
                  style: GoogleFonts.sen(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 14),
                _buildInfoRow('Nama Entitas', 'PT Inovasi Teknologi Nusantara'),
                _buildInfoRow('NIB (Berusaha)', '1234000987654'),
                _buildInfoRow('NPWP Perusahaan', '01.234.567.8-428.000'),
                _buildInfoRow(
                  'SK Kemenkumham',
                  'AHU-0012345.AH.01.01.TAHUN 2022',
                ),
                _buildInfoRow(
                  'Status Verifikasi',
                  'Terverifikasi Kemendikbudristek',
                ),
                _buildInfoRow(
                  'Alamat Kantor',
                  'Gedung Cyber 2 Lt. 12, Jakarta Selatan',
                ),
                _buildInfoRow('Situs Web', 'https://inovasiteknologi.co.id'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2373F4),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationPreferencesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Preferensi Notifikasi',
                  style: GoogleFonts.sen(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF2373F4),
                  ),
                  title: const Text('Email Lamaran Baru'),
                  subtitle: const Text(
                    'Terima notifikasi instan saat ada mahasiswa melamar',
                  ),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF059669),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.stars_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                  title: const Text('Kandidat Match Tinggi (>90%)'),
                  subtitle: const Text(
                    'Prioritas notifikasi saat ada kandidat bintang',
                  ),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF059669),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2373F4),
                    ),
                    child: const Text('Simpan & Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.sen(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.sen(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
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
            style: GoogleFonts.sen(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
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
