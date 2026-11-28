import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';
import '../models/product.dart';

class ProductQuery {
  final String? search;
  final String? type; // laptop|phone|accessory
  final String? category; // id or slug
  final String? brand;
  final String? condition; // new|used_imported
  final int? minPriceSdg;
  final int? maxPriceSdg;
  final bool? featured;
  final bool? inStock;
  final bool? dealsOnly;
  final String? sort; // price_asc|price_desc|newest
  final int page;
  final int perPage;

  const ProductQuery({
    this.search,
    this.type,
    this.category,
    this.brand,
    this.condition,
    this.minPriceSdg,
    this.maxPriceSdg,
    this.featured,
    this.inStock,
    this.dealsOnly,
    this.sort,
    this.page = 1,
    this.perPage = 12,
  });

  Map<String, dynamic> toParams() => {
        if (search != null && search!.isNotEmpty) 'q': search,
        if (type != null) 'type': type,
        if (category != null) 'category': category,
        if (brand != null) 'brand': brand,
        if (condition != null) 'condition': condition,
        if (minPriceSdg != null) 'min_price_sdg': minPriceSdg,
        if (maxPriceSdg != null) 'max_price_sdg': maxPriceSdg,
        if (featured != null) 'featured': featured! ? 1 : 0,
        if (inStock != null) 'in_stock': inStock! ? 1 : 0,
        if (dealsOnly == true) 'deal': 1,
        if (sort != null) 'sort': sort,
        'page': page,
        'per_page': perPage,
      };

  ProductQuery copyWith({
    String? search,
    String? type,
    String? category,
    String? brand,
    String? condition,
    int? minPriceSdg,
    int? maxPriceSdg,
    String? sort,
    int? page,
    bool clearFilters = false,
  }) =>
      ProductQuery(
        search: search ?? this.search,
        type: clearFilters ? null : (type ?? this.type),
        category: clearFilters ? null : (category ?? this.category),
        brand: clearFilters ? null : (brand ?? this.brand),
        condition: clearFilters ? null : (condition ?? this.condition),
        minPriceSdg: clearFilters ? null : (minPriceSdg ?? this.minPriceSdg),
        maxPriceSdg: clearFilters ? null : (maxPriceSdg ?? this.maxPriceSdg),
        featured: featured,
        inStock: inStock,
        dealsOnly: dealsOnly,
        sort: sort ?? this.sort,
        page: page ?? this.page,
        perPage: perPage,
      );
}

class ProductPage {
  final List<ProductListItem> items;
  final PageMeta meta;
  const ProductPage(this.items, this.meta);
}

class ProductRepository {
  final ApiClient api;
  ProductRepository(this.api);

  Future<ProductPage> list(ProductQuery q) async {
    final env = await api.get('/products', query: q.toParams());
    final items = (env.data as List? ?? [])
        .map((e) => ProductListItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return ProductPage(items, PageMeta.fromJson(env.meta));
  }

  Future<ProductDetail> detail(String slug) async {
    final env = await api.get('/products/$slug');
    return ProductDetail.fromJson(Map<String, dynamic>.from(env.data as Map));
  }
}
