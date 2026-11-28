import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/strings.dart';
import '../../data/repositories/push_repository.dart';
import '../../firebase_options.dart';

/// Background/terminated message handler (must be a top-level function).
@pragma('vm:entry-point')
Future<void> firebaseBgHandler(RemoteMessage message) async {
  // No-op: the system tray shows the notification; tap handling is in the app.
}

/// Native push: Firebase init, token registration, 3 Android channels,
/// foreground display, and deep-link routing via [onOpen].
class PushService {
  final PushRepository repo;
  final void Function(Map<String, dynamic> data)? onOpen;
  PushService(this.repo, {this.onOpen});

  final _local = FlutterLocalNotificationsPlugin();
  String? _token;

  static const _channels = {
    'payments': Ar.chPayments,
    'orders': Ar.chOrders,
    'offers': Ar.chOffers,
  };

  Future<void> init() async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      debugPrint('Firebase init skipped: $e');
      return;
    }
    FirebaseMessaging.onBackgroundMessage(firebaseBgHandler);

    // Android 13+ runtime permission.
    await FirebaseMessaging.instance.requestPermission();

    // Local notification channels (match the backend FcmProvider routing).
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: (resp) {
        final payload = resp.payload;
        if (payload != null) _handlePayload(payload);
      },
    );
    final androidImpl = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    for (final entry in _channels.entries) {
      await androidImpl?.createNotificationChannel(
        AndroidNotificationChannel(entry.key, entry.value,
            importance: Importance.high),
      );
    }

    // Foreground messages → show a local notification.
    FirebaseMessaging.onMessage.listen(_showForeground);
    // App opened from a notification tap.
    FirebaseMessaging.onMessageOpenedApp
        .listen((m) => onOpen?.call(_stringMap(m.data)));
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) onOpen?.call(_stringMap(initial.data));

    // Register the device token.
    _token = await FirebaseMessaging.instance.getToken();
    if (_token != null) {
      try {
        await repo.registerFcmToken(_token!, deviceLabel: 'Android');
      } catch (_) {}
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
      _token = t;
      try {
        await repo.registerFcmToken(t, deviceLabel: 'Android');
      } catch (_) {}
    });
  }

  Future<void> _showForeground(RemoteMessage m) async {
    final n = m.notification;
    final channel = (m.data['type']?.toString() ?? '');
    final channelId = channel.contains('payment')
        ? 'payments'
        : channel.contains('offer') || channel.contains('announcement')
            ? 'offers'
            : 'orders';
    await _local.show(
      m.hashCode,
      n?.title ?? m.data['title']?.toString() ?? Ar.appName,
      n?.body ?? m.data['body']?.toString() ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(channelId, _channels[channelId]!,
            importance: Importance.high, priority: Priority.high),
      ),
      payload: _encode(m.data),
    );
  }

  void _handlePayload(String payload) {
    final map = <String, dynamic>{};
    for (final pair in payload.split('\u0001')) {
      final i = pair.indexOf('=');
      if (i > 0) map[pair.substring(0, i)] = pair.substring(i + 1);
    }
    onOpen?.call(map);
  }

  String _encode(Map<String, dynamic> data) =>
      data.entries.map((e) => '${e.key}=${e.value}').join('\u0001');

  Map<String, dynamic> _stringMap(Map<String, dynamic> d) =>
      d.map((k, v) => MapEntry(k, v?.toString() ?? ''));

  /// Re-register the current token (call after the user signs in).
  Future<void> registerCurrent() async {
    final t = _token;
    if (t == null) return;
    try {
      await repo.registerFcmToken(t, deviceLabel: 'Android');
    } catch (_) {}
  }

  Future<void> disable() async {
    if (_token != null) {
      try {
        await repo.unregister(_token!);
      } catch (_) {}
    }
  }
}
