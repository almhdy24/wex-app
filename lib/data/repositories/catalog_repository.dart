import '../../core/network/api_client.dart';
import '../models/catalog_meta.dart';
import '../models/shop.dart';

class CatalogRepository {
  final ApiClient api;
  CatalogRepository(this.api);

  Future<List<Category>> categories() async {
    final env = await api.get('/categories');
    return (env.data as List? ?? [])
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Brand>> brands() async {
    final env = await api.get('/brands');
    return (env.data as List? ?? [])
        .map((e) => Brand.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<ShippingZone>> zones() async {
    final env = await api.get('/shipping-zones');
    return (env.data as List? ?? [])
        .map((e) => ShippingZone.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Shop> shop() async {
    final env = await api.get('/shop');
    return Shop.fromJson(Map<String, dynamic>.from(env.data as Map));
  }
}
