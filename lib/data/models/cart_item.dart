import '../../app/env.dart';
import 'product.dart';

class CartItem {
  final int productId;
  final String slug;
  final String name;
  final int priceSdg;
  final String? thumbPath;
  final int quantity;
  final int maxQty; // min(10, derived from stock status)

  const CartItem({
    required this.productId,
    required this.slug,
    required this.name,
    required this.priceSdg,
    this.thumbPath,
    this.quantity = 1,
    this.maxQty = 10,
  });

  String get thumbUrl => Env.assetUrl(thumbPath ?? '');
  int get lineTotal => priceSdg * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId, slug: slug, name: name, priceSdg: priceSdg,
        thumbPath: thumbPath, quantity: quantity ?? this.quantity, maxQty: maxQty,
      );

  Map<String, dynamic> toJson() => {
        'product_id': productId, 'slug': slug, 'name': name, 'price_sdg': priceSdg,
        'thumb': thumbPath, 'quantity': quantity, 'max_qty': maxQty,
      };

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        productId: (j['product_id'] ?? 0) as int,
        slug: (j['slug'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        priceSdg: ((j['price_sdg'] ?? 0) as num).round(),
        thumbPath: j['thumb']?.toString(),
        quantity: ((j['quantity'] ?? 1) as num).round().clamp(1, 10),
        maxQty: ((j['max_qty'] ?? 10) as num).round(),
      );

  factory CartItem.fromProduct(ProductDetail p, {int quantity = 1}) {
    final max = p.stockStatus == StockStatus.lowStock ? 2 : 10;
    return CartItem(
      productId: p.id, slug: p.slug, name: p.name, priceSdg: p.priceSdg,
      thumbPath: p.images.isNotEmpty ? (p.images.first.thumbPath ?? p.images.first.path) : null,
      quantity: quantity.clamp(1, max), maxQty: max,
    );
  }
}
