import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardNavItem {
  const DashboardNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class DashboardBottomNavbar extends StatelessWidget {
  const DashboardBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<DashboardNavItem> items = [
    DashboardNavItem(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    DashboardNavItem(
      label: 'Lowongan',
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
    ),
    DashboardNavItem(
      label: 'Lamaran',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
    ),
    DashboardNavItem(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: const Color(0xFF2373F4).withValues(alpha: 0.1),
                  highlightColor: Colors.transparent,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            key: ValueKey<bool>(isSelected),
                            size: 24,
                            color: isSelected
                                ? const Color(0xFF2373F4)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.sen(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF2373F4)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
