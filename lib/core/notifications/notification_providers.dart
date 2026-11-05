import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'fcm_service.dart';
import 'notification_payload.dart';

part 'notification_providers.g.dart';

@riverpod
FirebaseMessaging? firebaseMessaging(Ref ref) {
  try {
    return FirebaseMessaging.instance;
  } catch (_) {
    return null;
  }
}

@riverpod
FcmService fcmService(Ref ref) {
  final messaging = ref.watch(firebaseMessagingProvider);
  final service = FcmService(messaging);
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
Future<String?> fcmToken(Ref ref) async {
  final service = ref.watch(fcmServiceProvider);
  return service.getToken();
}

@riverpod
Stream<NotificationPayload> foregroundNotificationStream(Ref ref) {
  final service = ref.watch(fcmServiceProvider);
  return service.onForegroundMessage;
}
