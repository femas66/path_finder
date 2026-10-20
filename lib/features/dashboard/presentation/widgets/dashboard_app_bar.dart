import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Simple, compact app bar for the Home (Beranda) tab.
/// Clean white surface with subtle bottom border, no heavy or unnecessary assets.
class DashboardHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardHomeAppBar({
    super.key,
    this.title = 'Halo, Mahasiswa 👋',
    this.subtitle = 'Siap temukan karir IT impianmu?',
  });

  final String title;
  final String subtitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.sen(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.sen(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFE2E8F0),
          height: 1,
        ),
      ),
    );
  }
}

/// Simple, compact app bar for dashboard sub-tabs (Lowongan, Lamaran, Profil).
class DashboardTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardTabAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 20,
      title: Text(
        title,
        style: GoogleFonts.sen(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: const Color(0xFF0F172A),
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFE2E8F0),
          height: 1,
        ),
      ),
    );
  }
}
