import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/notifications/fcm_service.dart';
import 'package:path_finder/core/notifications/notification_payload.dart';
import 'package:path_finder/core/notifications/notification_providers.dart';

void main() {
  group('FcmService & Notification Providers Tests', () {
    test('FcmService operates gracefully when messaging instance is null (test/offline)',
        () async {
      final service = FcmService();

      expect(service.isInitialized, isFalse);
      expect(await service.getToken(), isNull);
      expect(await service.requestPermission(), isNull);

      final initResult = await service.initialize();
      expect(initResult, isFalse);

      await service.deleteToken();
      await service.subscribeToTopic('test_topic');
      await service.unsubscribeFromTopic('test_topic');

      service.dispose();
    });

    test('Riverpod notification providers initialize and dispose cleanly',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final messaging = container.read(firebaseMessagingProvider);
      // In unit test environment without native Firebase bindings, returns null gracefully
      expect(messaging, isNull);

      final service = container.read(fcmServiceProvider);
      expect(service, isNotNull);
      expect(service.isInitialized, isFalse);

      final token = await container.read(fcmTokenProvider.future);
      expect(token, isNull);

      final asyncValue = container.read(foregroundNotificationStreamProvider);
      expect(asyncValue, isA<AsyncValue<NotificationPayload>>());
      expect(service.onForegroundMessage, isA<Stream<NotificationPayload>>());
    });
  });
}
