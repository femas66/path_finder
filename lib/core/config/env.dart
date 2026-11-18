import 'package:flutter/foundation.dart';

class Env {
  Env._();

  /// Nilai `BASE_URL` dari `--dart-define`, misalnya:
  /// `flutter run --dart-define=BASE_URL=http://192.168.1.10:3000`
  static const String _overrideBaseUrl = String.fromEnvironment('BASE_URL');

  /// Base URL backend Go (`path-finder-backend`).
  ///
  /// Android emulator tidak bisa menjangkau `127.0.0.1` milik komputer host;
  /// alamat khusus emulator untuk host adalah `10.0.2.2`. Untuk perangkat
  /// fisik, kirim alamat LAN komputer lewat `--dart-define=BASE_URL=...`.
  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://127.0.0.1:3000';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
