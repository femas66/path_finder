import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler untuk Firebase Cloud Messaging.
/// Wajib menggunakan `@pragma('vm:entry-point')` agar fungsi ini tidak
/// dieliminasi oleh tree-shaking kompiler AOT saat release mode.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Abaikan jika sudah diinisialisasi atau berjalan di lingkungan test
  }

  debugPrint(
    'FCM Background message: [${message.messageId}] ${message.notification?.title ?? message.data['title']}',
  );
}
