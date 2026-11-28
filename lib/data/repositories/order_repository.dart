import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/idempotency.dart';
import '../models/order.dart';

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
      'items': [
        for (final i in items)
          {'product_id': i.productId, 'quantity': i.quantity}
      ],
      if (orderType == 'delivery') ...{
        'shipping_zone_id': shippingZoneId,
        'delivery_address': deliveryAddress,
      },
      if (customerNotes != null && customerNotes.isNotEmpty)
        'customer_notes': customerNotes,
    };
    final env = await api.post('/orders',
        body: body,
        options:
            Options(headers: {'Idempotency-Key': idempotencyKeyFor(body)}));
    return Map<String, dynamic>.from(env.data as Map);
  }

  Future<List<OrderListItem>> list() async {
    final env = await api.get('/orders');
    return (env.data as List? ?? [])
        .map((e) => OrderListItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<OrderDetail> detail(String number) async {
    final env = await api.get('/orders/$number');
    return OrderDetail.fromJson(Map<String, dynamic>.from(env.data as Map));
  }

  Future<OrderDetail> cancel(String number, {String? reason}) async {
    final env = await api.post('/orders/$number/cancel',
        body: {if (reason != null) 'reason': reason, 'noop': true});
    return OrderDetail.fromJson(Map<String, dynamic>.from(env.data as Map));
  }

  Future<Map<String, dynamic>> reorder(String number) async {
    final env = await api.post('/orders/$number/reorder', body: {'noop': true});
    return Map<String, dynamic>.from(env.data as Map);
  }

  /// Upload a receipt image (field name must be `proof_image`).
  Future<void> uploadProof(String number, String filePath,
      {String? senderName, String? reference}) async {
    final form = FormData.fromMap({
      'proof_image':
          await MultipartFile.fromFile(filePath, filename: 'proof.jpg'),
      if (senderName != null && senderName.isNotEmpty)
        'sender_name': senderName,
      if (reference != null && reference.isNotEmpty)
        'reference_number': reference,
    });
    await api.post('/orders/$number/payment-proof', body: form);
  }

  /// Authenticated proof image bytes (private, no-store).
  Future<List<int>> proofImageBytes(String url) async {
    final resp = await api.dio.get<List<int>>(url,
        options: Options(responseType: ResponseType.bytes));
    return resp.data ?? const [];
  }
}
