import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/idempotency.dart';

class OrderRepository {
  final ApiClient api;
  OrderRepository(this.api);

  /// POST /orders — returns the created order's detail map (order_number etc.).
  Future<Map<String, dynamic>> create({
    required String orderType, // pickup | delivery
    required List<({int productId, int quantity})> items,
    required String contactPhone,
    int? shippingZoneId,
    String? deliveryAddress,
    String? customerNotes,
  }) async {
    final body = {
      'order_type': orderType,
      'contact_phone': contactPhone,
      'items': [for (final i in items) {'product_id': i.productId, 'quantity': i.quantity}],
      if (orderType == 'delivery') ...{
        'shipping_zone_id': shippingZoneId,
        'delivery_address': deliveryAddress,
      },
      if (customerNotes != null && customerNotes.isNotEmpty) 'customer_notes': customerNotes,
    };
    final env = await api.post('/orders',
        body: body, options: Options(headers: {'Idempotency-Key': idempotencyKeyFor(body)}));
    return Map<String, dynamic>.from(env.data as Map);
  }
}

