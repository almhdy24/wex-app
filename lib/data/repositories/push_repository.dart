import '../../core/network/api_client.dart';

/// Push preferences (7 booleans; customer sees the first four).
class PushPrefs {
  final bool orderUpdates, paymentUpdates, priceAlerts, announcements;
  const PushPrefs(
      {this.orderUpdates = true,
      this.paymentUpdates = true,
      this.priceAlerts = true,
      this.announcements = true});
  factory PushPrefs.fromJson(Map<String, dynamic> j) => PushPrefs(
        orderUpdates: j['order_updates'] != false,
        paymentUpdates: j['payment_updates'] != false,
        priceAlerts: j['price_alerts'] != false,
        announcements: j['announcements'] != false,
      );
}

class PushRepository {
  final ApiClient api;
  PushRepository(this.api);

  /// Register this device's FCM token (POST /push/subscriptions, provider fcm).
  Future<void> registerFcmToken(String token,
      {String? deviceLabel, String appVersion = '1.0.0'}) async {
    await api.post('/push/subscriptions', body: {
      'provider': 'fcm',
      'platform': 'android',
      'token': token,
      if (deviceLabel != null) 'device_label': deviceLabel,
      'locale': 'ar',
      'app_version': appVersion,
    });
  }

  Future<void> unregister(String token) async {
    await api.delete('/push/subscriptions', body: {'endpoint_or_token': token});
  }

  Future<PushPrefs> preferences() async {
    final env = await api.get('/push/preferences');
    return PushPrefs.fromJson(Map<String, dynamic>.from(env.data as Map));
  }

  Future<PushPrefs> updatePreferences(Map<String, bool> changes) async {
    final env = await api.request('PUT', '/push/preferences', body: changes);
    return PushPrefs.fromJson(Map<String, dynamic>.from(env.data as Map));
  }

  Future<void> sendTest() => api.post('/push/test', body: {'noop': true});
}
