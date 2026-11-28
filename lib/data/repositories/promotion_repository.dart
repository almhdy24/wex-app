import '../../core/network/api_client.dart';
import '../models/promotion.dart';

class PromotionRepository {
  final ApiClient api;
  PromotionRepository(this.api);

  Future<List<Promotion>> list(String placement) async {
    final env = await api.get('/promotions', query: {'placement': placement, 'platform': 'app'});
    return (env.data as List? ?? []).map((e) => Promotion.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  /// Fire-and-forget; failures are silent.
  Future<void> event(int id, String type) async {
    try {
      await api.post('/promotions/$id/events', body: {'type': type});
    } catch (_) {}
  }
}
