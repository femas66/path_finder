import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'fcm_background_handler.dart';
import 'notification_payload.dart';

/// Service untuk mengelola siklus hidup Firebase Cloud Messaging (FCM).
class FcmService {
  FcmService([this._messaging]);

  final FirebaseMessaging? _messaging;

  final _foregroundController =
      StreamController<NotificationPayload>.broadcast();
  final _messageOpenedAppController =
      StreamController<NotificationPayload>.broadcast();

  Stream<NotificationPayload> get onForegroundMessage =>
      _foregroundController.stream;
  Stream<NotificationPayload> get onMessageOpenedApp =>
      _messageOpenedAppController.stream;

  /// Stream saat token / registration ID perangkat diperbarui.
  Stream<String> get onTokenRefresh =>
      _messaging?.onRegistered ?? const Stream.empty();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Menginisialisasi listener notifikasi, permissions, dan background handler.
  Future<bool> initialize({
    void Function(NotificationPayload payload)? onNotificationTapped,
  }) async {
    if (_isInitialized) return true;
    if (_messaging == null) {
      debugPrint('FCM: FirebaseMessaging instance tidak tersedia.');
      return false;
    }

    try {
      // 1. Meminta izin notifikasi (wajib untuk iOS dan Android 13+)
      final settings = await requestPermission();
      final isAuthorized =
          settings?.authorizationStatus == AuthorizationStatus.authorized ||
              settings?.authorizationStatus == AuthorizationStatus.provisional;

      if (!isAuthorized) {
        debugPrint('FCM: Izin notifikasi tidak diberikan oleh pengguna.');
        return false;
      }

      // 2. Set opsi tampilan notifikasi saat aplikasi berada di foreground (iOS)
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Daftarkan background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 4. Listener notifikasi masuk saat aplikasi sedang dibuka (foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final payload = NotificationPayload.fromRemoteMessage(message);
        debugPrint(
          'FCM Foreground: [${payload.id}] ${payload.title} - ${payload.body}',
        );
        _foregroundController.add(payload);
      });

      // 5. Listener ketika notifikasi ditekan saat aplikasi berada di background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final payload = NotificationPayload.fromRemoteMessage(message);
        debugPrint('FCM Opened from background: [${payload.id}] ${payload.title}');
        _messageOpenedAppController.add(payload);
        onNotificationTapped?.call(payload);
      });

      // 6. Cek jika aplikasi dibuka dari kondisi mati (terminated) oleh notifikasi
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        final payload = NotificationPayload.fromRemoteMessage(initialMessage);
        debugPrint(
          'FCM Opened from terminated: [${payload.id}] ${payload.title}',
        );
        onNotificationTapped?.call(payload);
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('FCM Initialization error: $e');
      return false;
    }
  }

  /// Meminta izin notifikasi ke sistem operasi.
  Future<NotificationSettings?> requestPermission() async {
    if (_messaging == null) return null;
    try {
      return await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } catch (e) {
      debugPrint('FCM requestPermission error: $e');
      return null;
    }
  }

  /// Mendapatkan FCM registration token perangkat saat ini.
  Future<String?> getToken() async {
    if (_messaging == null) return null;
    try {
      await _messaging.register();
      // ignore: deprecated_member_use
      final token = await _messaging.getToken();
      debugPrint('FCM Registration Token: $token');
      return token;
    } catch (e) {
      debugPrint('FCM getToken error: $e');
      return null;
    }
  }

  /// Menghapus FCM registration token perangkat saat ini.
  Future<void> deleteToken() async {
    if (_messaging == null) return;
    try {
      await _messaging.unregister();
      // ignore: deprecated_member_use
      await _messaging.deleteToken();
      debugPrint('FCM Token berhasil dihapus.');
    } catch (e) {
      debugPrint('FCM deleteToken error: $e');
    }
  }

  /// Berlangganan topik tertentu (misal: "announcements", "jobs").
  Future<void> subscribeToTopic(String topic) async {
    if (_messaging == null) return;
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('FCM Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('FCM subscribeToTopic error ($topic): $e');
    }
  }

  /// Berhenti berlangganan dari topik tertentu.
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging == null) return;
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('FCM Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('FCM unsubscribeFromTopic error ($topic): $e');
    }
  }

  /// Membersihkan stream controller saat service di-dispose.
  void dispose() {
    _foregroundController.close();
    _messageOpenedAppController.close();
  }
}
