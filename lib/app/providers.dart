import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_controller.dart';
import '../data/models/shop.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/order_repository.dart';

final productRepositoryProvider =
    Provider((ref) => ProductRepository(ref.read(serverTimeApiProvider)));
final catalogRepositoryProvider =
    Provider((ref) => CatalogRepository(ref.read(serverTimeApiProvider)));
final contentRepositoryProvider =
    Provider((ref) => ContentRepository(ref.read(serverTimeApiProvider)));
final orderRepositoryProvider =
    Provider((ref) => OrderRepository(ref.read(serverTimeApiProvider)));
final zonesProvider = FutureProvider((ref) => ref.read(catalogRepositoryProvider).zones());

/// Shop profile (lock hours, discount %, orders_enabled, address...). Cached for the session.
final shopProvider = FutureProvider<Shop>((ref) async {
  return ref.read(catalogRepositoryProvider).shop();
});

final brandsProvider = FutureProvider((ref) => ref.read(catalogRepositoryProvider).brands());
final categoriesProvider = FutureProvider((ref) => ref.read(catalogRepositoryProvider).categories());
