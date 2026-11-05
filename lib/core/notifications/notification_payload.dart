import 'package:firebase_messaging/firebase_messaging.dart';

/// Representasi data notifikasi FCM terstruktur.
class NotificationPayload {
  const NotificationPayload({
    this.id,
    this.title,
    this.body,
    this.data = const {},
    this.sentTime,
    this.from,
  });

  final String? id;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final DateTime? sentTime;
  final String? from;

  /// Factory untuk mengonversi [RemoteMessage] dari FCM ke [NotificationPayload].
  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayload(
      id: message.messageId,
      title: message.notification?.title ?? message.data['title']?.toString(),
      body: message.notification?.body ?? message.data['body']?.toString(),
      data: Map<String, dynamic>.unmodifiable(message.data),
      sentTime: message.sentTime,
      from: message.from,
    );
  }

  /// Mengonversi payload menjadi Map serializable.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'sentTime': sentTime?.toIso8601String(),
      'from': from,
    };
  }

  @override
  String toString() =>
      'NotificationPayload(id: $id, title: $title, body: $body, data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPayload &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ body.hashCode;
}
