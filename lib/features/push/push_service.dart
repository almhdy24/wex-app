import '../../data/repositories/push_repository.dart';

/// Native push entry point. The device token comes from FCM (firebase_messaging)
/// once Firebase is configured (google-services.json). Until then [registerToken]
/// is never called and the app builds fine. See docs/PUSH_SETUP.md.
class PushService {
  final PushRepository repo;
  PushService(this.repo);

  Future<void> registerToken(String fcmToken, {String? deviceLabel}) =>
      repo.registerFcmToken(fcmToken, deviceLabel: deviceLabel);

  Future<void> unregister(String fcmToken) => repo.unregister(fcmToken);
}
