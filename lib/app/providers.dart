import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_controller.dart';
import '../data/models/shop.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/me_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/push_repository.dart';

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


final ordersListProvider = FutureProvider.autoDispose((ref) => ref.read(orderRepositoryProvider).list());
final orderDetailProvider = FutureProvider.autoDispose.family(
    (ref, String number) => ref.read(orderRepositoryProvider).detail(number));


final meRepositoryProvider = Provider((ref) => MeRepository(ref.read(serverTimeApiProvider)));
final notificationRepositoryProvider =
    Provider((ref) => NotificationRepository(ref.read(serverTimeApiProvider)));
final notificationsProvider = FutureProvider.autoDispose((ref) => ref.read(notificationRepositoryProvider).list());
final unreadCountProvider = FutureProvider.autoDispose((ref) => ref.read(notificationRepositoryProvider).unreadCount());
final faqProvider = FutureProvider.autoDispose((ref) => ref.read(contentRepositoryProvider).faq());
final pageProvider = FutureProvider.autoDispose.family((ref, String slug) => ref.read(contentRepositoryProvider).page(slug));

final pushRepositoryProvider = Provider((ref) => PushRepository(ref.read(serverTimeApiProvider)));
