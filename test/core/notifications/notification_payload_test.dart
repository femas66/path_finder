import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_finder/core/notifications/notification_payload.dart';

void main() {
  group('NotificationPayload Unit Tests', () {
    test('creates NotificationPayload with explicit fields correctly', () {
      final now = DateTime.now();
      final payload = NotificationPayload(
        id: 'msg_001',
        title: 'Lowongan Baru!',
        body: 'PT Tech membuka lowongan Flutter Developer',
        data: const {'route': '/dashboard', 'job_id': '456'},
        sentTime: now,
        from: 'fcm_server',
      );

      expect(payload.id, equals('msg_001'));
      expect(payload.title, equals('Lowongan Baru!'));
      expect(payload.body, equals('PT Tech membuka lowongan Flutter Developer'));
      expect(payload.data['route'], equals('/dashboard'));
      expect(payload.data['job_id'], equals('456'));
      expect(payload.sentTime, equals(now));
      expect(payload.from, equals('fcm_server'));
    });

    test('fromRemoteMessage converts FCM RemoteMessage to NotificationPayload',
        () {
      final now = DateTime.now();
      final message = RemoteMessage(
        messageId: 'fcm_12345',
        notification: const RemoteNotification(
          title: 'Notifikasi Rekomendasi',
          body: 'Hasil analisis bidang IT Anda telah siap!',
        ),
        data: {'type': 'recommendation', 'score': '95'},
        sentTime: now,
        from: 'cloud_messaging',
      );

      final payload = NotificationPayload.fromRemoteMessage(message);

      expect(payload.id, equals('fcm_12345'));
      expect(payload.title, equals('Notifikasi Rekomendasi'));
      expect(payload.body, equals('Hasil analisis bidang IT Anda telah siap!'));
      expect(payload.data['type'], equals('recommendation'));
      expect(payload.data['score'], equals('95'));
      expect(payload.sentTime, equals(now));
      expect(payload.from, equals('cloud_messaging'));
    });

    test('fromRemoteMessage falls back to data map if notification title/body are null',
        () {
      final message = RemoteMessage(
        messageId: 'data_only_msg',
        data: {
          'title': 'Data Title',
          'body': 'Data Body Content',
        },
      );

      final payload = NotificationPayload.fromRemoteMessage(message);

      expect(payload.id, equals('data_only_msg'));
      expect(payload.title, equals('Data Title'));
      expect(payload.body, equals('Data Body Content'));
    });

    test('toMap serializes properly', () {
      final payload = NotificationPayload(
        id: '1',
        title: 'Title',
        body: 'Body',
        data: const {'key': 'value'},
      );

      final map = payload.toMap();

      expect(map['id'], equals('1'));
      expect(map['title'], equals('Title'));
      expect(map['body'], equals('Body'));
      expect(map['data'], equals({'key': 'value'}));
    });

    test('value equality check works as expected', () {
      final a = const NotificationPayload(id: '1', title: 'T', body: 'B');
      final b = const NotificationPayload(id: '1', title: 'T', body: 'B');
      final c = const NotificationPayload(id: '2', title: 'T', body: 'B');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
