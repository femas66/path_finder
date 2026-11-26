class Env {
  Env._();

  static const String _overrideBaseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api-pathfinder.wandidev.my.id',
  );

  static String get baseUrl => _overrideBaseUrl;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
