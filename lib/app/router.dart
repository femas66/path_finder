import 'package:go_router/go_router.dart';

import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/company/presentation/pages/company_dashboard_page.dart';
import '../features/dashboard/domain/models/job_vacancy.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/dashboard/presentation/pages/job_detail_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/recommendation/presentation/pages/recommendation_page.dart';
import '../features/recommendation/presentation/pages/recommendation_processing_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/story/presentation/pages/story_page.dart';

abstract class AppRoutePaths {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String companyDashboard = '/company-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String jobDetail = '/job-detail';
  static const String story = '/story';
  static const String recommendation = '/recommendation';
  static const String recommendationProcessing = '/recommendation/processing';
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
      builder: (context, state) => const RegisterPage(),
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
      path: AppRoutePaths.adminDashboard,
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: AppRoutePaths.jobDetail,
      builder: (context, state) => JobDetailPage(job: state.extra as JobVacancy),
    ),
    GoRoute(
      path: AppRoutePaths.story,
      builder: (context, state) => const StoryPage(),
    ),
    GoRoute(
      path: AppRoutePaths.recommendation,
      builder: (context, state) => const RecommendationPage(),
      routes: [
        GoRoute(
          path: 'processing',
          builder: (context, state) => RecommendationProcessingPage(
            storyId: state.uri.queryParameters['story_id'],
          ),
        ),
      ],
    ),
  ],
);

