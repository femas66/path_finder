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
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1:1 Aspect Ratio Logo Mark - Solid, Flat, No Gradients/Glow
            SizedBox(
              width: 96,
              height: 96,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2373F4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF2373F4).withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.explore_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PathFinder',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Discover Your IT Career Path',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
