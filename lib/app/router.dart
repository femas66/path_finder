import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/company/presentation/pages/company_dashboard_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';

abstract class AppRoutePaths {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String companyDashboard = '/company-dashboard';
  static const String story = '/story';
  static const String recommendation = '/recommendation';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutePaths.splash,
  routes: [
    GoRoute(
      path: AppRoutePaths.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutePaths.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutePaths.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutePaths.register,
      builder: (context, state) => const _RoutePlaceholderPage(
        title: 'Daftar Akun',
        path: AppRoutePaths.register,
      ),
    ),
    GoRoute(
      path: AppRoutePaths.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutePaths.dashboard,
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: AppRoutePaths.companyDashboard,
      builder: (context, state) => const CompanyDashboardPage(),
    ),
    GoRoute(
      path: AppRoutePaths.story,
      builder: (context, state) => const _RoutePlaceholderPage(
        title: 'Story Page',
        path: AppRoutePaths.story,
      ),
    ),
    GoRoute(
      path: AppRoutePaths.recommendation,
      builder: (context, state) => const _RoutePlaceholderPage(
        title: 'Recommendation Page',
        path: AppRoutePaths.recommendation,
      ),
    ),
  ],
);

class _RoutePlaceholderPage extends StatelessWidget {
  const _RoutePlaceholderPage({required this.title, required this.path});

  final String title;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Route: $path',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
