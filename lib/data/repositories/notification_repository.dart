import '../../core/network/api_client.dart';
import '../models/app_notification.dart';

class NotificationRepository {
  final ApiClient api;
  NotificationRepository(this.api);

  Future<List<AppNotification>> list() async {
    final env = await api.get('/notifications');
    return (env.data as List? ?? [])
        .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<int> unreadCount() async {
    final env = await api.get('/notifications/unread-count');
    final d = env.data;
    return (d is Map ? (d['unread_count'] ?? 0) : 0) as int;
  }

  Future<void> markRead(int id) => api.patch('/notifications/$id/read', body: {'noop': true});
  Future<void> markAllRead() => api.post('/notifications/mark-all-read', body: {'noop': true});
}
