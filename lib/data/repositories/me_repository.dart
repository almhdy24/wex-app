import '../../core/network/api_client.dart';
import '../models/user.dart';

class MeRepository {
  final ApiClient api;
  MeRepository(this.api);

  Future<User> me() async {
    final env = await api.get('/me');
    return User.fromJson(Map<String, dynamic>.from(env.data as Map));
  }

  Future<User> update({String? name, String? phone}) async {
    final env = await api.patch('/me', body: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
    });
    return User.fromJson(Map<String, dynamic>.from(env.data as Map));
  }

  Future<User> setEmailNotifications(bool on) async {
    final env = await api.patch('/me/preferences', body: {'email_notifications': on});
    return User.fromJson(Map<String, dynamic>.from(env.data as Map));
  }
}
