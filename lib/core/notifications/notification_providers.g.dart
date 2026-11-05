// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firebaseMessaging)
final firebaseMessagingProvider = FirebaseMessagingProvider._();

final class FirebaseMessagingProvider
    extends
        $FunctionalProvider<
          FirebaseMessaging?,
          FirebaseMessaging?,
          FirebaseMessaging?
        >
    with $Provider<FirebaseMessaging?> {
  FirebaseMessagingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseMessagingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseMessagingHash();

  @$internal
  @override
  $ProviderElement<FirebaseMessaging?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseMessaging? create(Ref ref) {
    return firebaseMessaging(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseMessaging? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseMessaging?>(value),
    );
  }
}

String _$firebaseMessagingHash() => r'f043c3a74f7d1128da61709cf999ee672f34eabc';

@ProviderFor(fcmService)
final fcmServiceProvider = FcmServiceProvider._();

final class FcmServiceProvider
    extends $FunctionalProvider<FcmService, FcmService, FcmService>
    with $Provider<FcmService> {
  FcmServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fcmServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fcmServiceHash();

  @$internal
  @override
  $ProviderElement<FcmService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FcmService create(Ref ref) {
    return fcmService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FcmService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FcmService>(value),
    );
  }
}

String _$fcmServiceHash() => r'444c34b82533e6699b8ebfd41f3fb7ab40be8ec4';

@ProviderFor(fcmToken)
final fcmTokenProvider = FcmTokenProvider._();

final class FcmTokenProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  FcmTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fcmTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fcmTokenHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return fcmToken(ref);
  }
}

String _$fcmTokenHash() => r'72ca3fbbddd36d321af189184edc2a5c59130d98';

@ProviderFor(foregroundNotificationStream)
final foregroundNotificationStreamProvider =
    ForegroundNotificationStreamProvider._();

final class ForegroundNotificationStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationPayload>,
          NotificationPayload,
          Stream<NotificationPayload>
        >
    with
        $FutureModifier<NotificationPayload>,
        $StreamProvider<NotificationPayload> {
  ForegroundNotificationStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foregroundNotificationStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foregroundNotificationStreamHash();

  @$internal
  @override
  $StreamProviderElement<NotificationPayload> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NotificationPayload> create(Ref ref) {
    return foregroundNotificationStream(ref);
  }
}

String _$foregroundNotificationStreamHash() =>
    r'39e991673ac93422c4dafb9a2f13052b5dbee945';
