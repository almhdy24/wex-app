class Category {
  final int id;
  final String nameAr;
  final String slug;
  const Category({required this.id, required this.nameAr, required this.slug});
  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: (j['id'] ?? 0) as int,
        nameAr: (j['name_ar'] ?? '').toString(),
        slug: (j['slug'] ?? '').toString(),
      );
}

class Brand {
  final int id;
  final String name;
  final String slug;
  const Brand({required this.id, required this.name, required this.slug});
  factory Brand.fromJson(Map<String, dynamic> j) => Brand(
        id: (j['id'] ?? 0) as int,
        name: (j['name'] ?? '').toString(),
        slug: (j['slug'] ?? '').toString(),
      );
}

class ShippingZone {
  final int id;
  final String name;
  final int feeSdg;
  const ShippingZone(
      {required this.id, required this.name, required this.feeSdg});
  factory ShippingZone.fromJson(Map<String, dynamic> j) => ShippingZone(
        id: (j['id'] ?? 0) as int,
        name: (j['zone_name'] ?? j['name'] ?? '').toString(),
        feeSdg: ((j['delivery_fee_sdg'] ?? j['fee_sdg'] ?? 0) as num).round(),
      );
}
