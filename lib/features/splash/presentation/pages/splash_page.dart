import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_local_source.dart';
import '../../../auth/data/auth_remote_source.dart';
import '../../../auth/data/auth_repository_impl.dart';
import '../../../auth/domain/auth_repository.dart';
import '../widgets/splash_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    this.autoNavigate = true,
    this.navigationDelay = const Duration(milliseconds: 2500),
    this.authRepository,
    this.localSource,
    this.remoteSource,
  });

  final bool autoNavigate;
  final Duration navigationDelay;
  final AuthRepository? authRepository;
  final AuthLocalSource? localSource;
  final AuthRemoteSource? remoteSource;

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
      _navigationTimer = Timer(widget.navigationDelay, _navigateNext);
    }
  }

  AuthRepository _resolveRepository() {
    if (widget.authRepository != null) {
      return widget.authRepository!;
    }
    final local = widget.localSource ?? AuthLocalSource();
    final remote = widget.remoteSource ?? AuthRemoteSource(createDioClient());
    return AuthRepositoryImpl(remoteSource: remote, localSource: local);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    try {
      final repository = _resolveRepository();
      final user = await repository.validateCurrentSession();

      if (user != null && mounted) {
        if (user.isMitra) {
          context.go(AppRoutePaths.companyDashboard);
          return;
        } else {
          context.go(AppRoutePaths.dashboard);
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      context.go(AppRoutePaths.onboarding);
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
      _navigateNext();
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
