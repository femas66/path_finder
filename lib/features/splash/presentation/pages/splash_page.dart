import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../widgets/splash_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    this.autoNavigate = true,
    this.navigationDelay = const Duration(milliseconds: 2500),
  });

  final bool autoNavigate;
  final Duration navigationDelay;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    if (widget.autoNavigate) {
      _navigationTimer = Timer(widget.navigationDelay, () {
        if (mounted) {
          context.go(AppRoutePaths.onboarding);
        }
      });
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSkip() {
    if (widget.autoNavigate && mounted) {
      _navigationTimer?.cancel();
      context.go(AppRoutePaths.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onSkip,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Fullscreen Background Asset Image
            Image.asset('assets/splash/bg-asset.png', fit: BoxFit.cover),
            // Center: Logo with 1:1 Aspect Ratio, Title & Tagline
            SafeArea(
              child: Center(
                child: SplashLogo(
                  scaleAnimation: _scaleAnimation,
                  fadeAnimation: _fadeAnimation,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
