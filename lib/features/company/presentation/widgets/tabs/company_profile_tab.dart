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
                  backgroundColor:
                      const Color(0xFF2373F4).withValues(alpha: 0.1),
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
            onTap: () {},
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.badge_outlined,
            title: 'Manajemen Akun HR & Rekruter',
            subtitle: 'Kelola akses rekan tim penilai lamaran',
            onTap: () {},
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.handshake_outlined,
            title: 'Kerjasama Perguruan Tinggi (MoU)',
            subtitle: 'Daftar kampus mitra magang bersertifikat',
            onTap: () {},
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.notifications_none_rounded,
            title: 'Preferensi Notifikasi Pelamar',
            subtitle: 'Atur email alert saat kandidat baru melamar',
            onTap: () {},
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
