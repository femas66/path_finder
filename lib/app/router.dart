import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/presentation/pages/splash_page.dart';

abstract class AppRoutePaths {
  static const String splash = '/splash';
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
  const _RoutePlaceholderPage({
    required this.title,
    required this.path,
  });

  final String title;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
