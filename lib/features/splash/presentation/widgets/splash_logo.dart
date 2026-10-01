import 'package:flutter/material.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    required this.scaleAnimation,
    required this.fadeAnimation,
  });

  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                    blurRadius: 32,
                    spreadRadius: 4,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.explore_rounded,
                  size: 58,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'PathFinder',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover Your IT Career Path',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
