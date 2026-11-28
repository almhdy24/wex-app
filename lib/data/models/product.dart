import '../../app/env.dart';
import '../../core/strings.dart';

enum StockStatus { inStock, lowStock, outOfStock, unknown }

StockStatus _stock(String? s) => switch (s) {
      'in_stock' => StockStatus.inStock,
      'low_stock' => StockStatus.lowStock,
      'out_of_stock' => StockStatus.outOfStock,
      _ => StockStatus.unknown,
    };

/// Catalog list item (PublicProductPresenter::presentListItem).
class ProductListItem {
  final int id;
  final String slug;
  final String type; // laptop | phone | accessory
  final String name;
  final String? shortDescription;
  final String condition; // new | used_imported
  final int priceSdg;
  final StockStatus stockStatus;
  final bool isFeatured;
  final String? thumbPath;
  final String? imagePath;

  const ProductListItem({
    required this.id,
    required this.slug,
    required this.type,
    required this.name,
    this.shortDescription,
    required this.condition,
    required this.priceSdg,
    required this.stockStatus,
    this.isFeatured = false,
    this.thumbPath,
    this.imagePath,
  });

  String get thumbUrl => Env.assetUrl(thumbPath ?? imagePath ?? '');
  bool get isOutOfStock => stockStatus == StockStatus.outOfStock;

  factory ProductListItem.fromJson(Map<String, dynamic> j) {
    final img =
        (j['image'] is Map) ? Map<String, dynamic>.from(j['image']) : const {};
    return ProductListItem(
      id: (j['id'] ?? 0) as int,
      slug: (j['slug'] ?? '').toString(),
      type: (j['type'] ?? 'laptop').toString(),
      name: (j['name'] ?? '').toString(),
      shortDescription: j['short_description']?.toString(),
      condition: (j['condition'] ?? '').toString(),
      priceSdg: ((j['price_sdg'] ?? 0) as num).round(),
      stockStatus: _stock(j['stock_status']?.toString()),
      isFeatured: j['is_featured'] == true,
      thumbPath: (j['thumb_url'] ?? img['thumb_path'])?.toString(),
      imagePath: (j['primary_image'] ?? img['path'])?.toString(),
    );
  }
}

class ProductImage {
  final int id;
  final String path;
  final String? thumbPath;
  final bool isPrimary;
  const ProductImage(
      {required this.id,
      required this.path,
      this.thumbPath,
      this.isPrimary = false});

  String get url => Env.assetUrl(path);
  String get thumbUrl => Env.assetUrl(thumbPath ?? path);

  factory ProductImage.fromJson(Map<String, dynamic> j) => ProductImage(
        id: (j['id'] ?? 0) as int,
        path: (j['path'] ?? '').toString(),
        thumbPath: j['thumb_path']?.toString(),
        isPrimary: j['is_primary'] == true,
      );
}

/// Product detail (PublicProductPresenter::presentDetail).
class ProductDetail {
  final int id;
  final String slug;
  final String type;
  final String name;
  final String? shortDescription;
  final String? description;
  final String condition;
  final int priceSdg;
  final StockStatus stockStatus;
  final String? warrantyText;
  final Map<String, String> specs;
  final bool isFeatured;
  final String? categoryName;
  final int? categoryId;
  final String? brandName;
  final List<ProductImage> images;
  final List<ProductListItem> accessories;

  const ProductDetail({
    required this.id,
    required this.slug,
    required this.type,
    required this.name,
    this.shortDescription,
    this.description,
    required this.condition,
    required this.priceSdg,
    required this.stockStatus,
    this.warrantyText,
    this.specs = const {},
    this.isFeatured = false,
    this.categoryName,
    this.categoryId,
    this.brandName,
    this.images = const [],
    this.accessories = const [],
  });

  bool get isOutOfStock => stockStatus == StockStatus.outOfStock;

  factory ProductDetail.fromJson(Map<String, dynamic> j) {
    final cat = (j['category'] is Map)
        ? Map<String, dynamic>.from(j['category'])
        : null;
    final brand =
        (j['brand'] is Map) ? Map<String, dynamic>.from(j['brand']) : null;
    final specsRaw = j['specs'];
    final specs = <String, String>{};
    if (specsRaw is Map) {
      specsRaw.forEach((k, v) => specs[k.toString()] = v.toString());
    }
    return ProductDetail(
      id: (j['id'] ?? 0) as int,
      slug: (j['slug'] ?? '').toString(),
      type: (j['type'] ?? 'laptop').toString(),
      name: (j['name'] ?? '').toString(),
      shortDescription: j['short_description']?.toString(),
      description: j['description']?.toString(),
      condition: (j['condition'] ?? '').toString(),
      priceSdg: ((j['price_sdg'] ?? 0) as num).round(),
      stockStatus: _stock(j['stock_status']?.toString()),
      warrantyText: j['warranty_text']?.toString(),
      specs: specs,
      isFeatured: j['is_featured'] == true,
      categoryName: cat?['name_ar']?.toString(),
      categoryId: cat?['id'] as int?,
      brandName: brand?['name']?.toString(),
      images: (j['images'] as List? ?? [])
          .map((e) => ProductImage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      accessories: (j['accessories'] as List? ?? [])
          .map((e) => ProductListItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// Condition label (web getConditionLabel parity; unknown → empty).
String conditionLabel(String condition) => switch (condition) {
      'new' => Ar.condNew,
      'used_imported' => Ar.condUsed,
      'open_box' => Ar.condOpenBox,
      'refurbished' => Ar.condRefurb,
      _ => '',
    };
