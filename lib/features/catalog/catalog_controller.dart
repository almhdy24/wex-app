import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class CatalogState {
  final ProductQuery query;
  final List<ProductListItem> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;

  const CatalogState({
    required this.query,
    this.items = const [],
    this.loading = true,
    this.loadingMore = false,
    this.hasMore = false,
    this.error,
  });

  CatalogState copyWith({
    ProductQuery? query,
    List<ProductListItem>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) =>
      CatalogState(
        query: query ?? this.query,
        items: items ?? this.items,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        hasMore: hasMore ?? this.hasMore,
        error: clearError ? null : (error ?? this.error),
      );
}

class CatalogController extends StateNotifier<CatalogState> {
  final Ref _ref;
  int _reqId = 0;

  CatalogController(this._ref, ProductQuery initial)
      : super(CatalogState(query: initial)) {
    _load(reset: true);
  }

  ProductRepository get _repo => _ref.read(productRepositoryProvider);

  Future<void> _load({required bool reset}) async {
    final req = ++_reqId;
    final q = reset ? state.query.copyWith(page: 1) : state.query.copyWith(page: state.query.page + 1);
    state = reset
        ? state.copyWith(query: q, loading: true, clearError: true)
        : state.copyWith(query: q, loadingMore: true);
    try {
      final page = await _repo.list(q);
      if (req != _reqId) return; // stale
      state = state.copyWith(
        items: reset ? page.items : [...state.items, ...page.items],
        loading: false,
        loadingMore: false,
        hasMore: page.meta.hasMore,
        clearError: true,
      );
    } on ApiException catch (e) {
      if (req != _reqId) return;
      state = state.copyWith(loading: false, loadingMore: false, error: e.message);
    } catch (_) {
      if (req != _reqId) return;
      state = state.copyWith(loading: false, loadingMore: false, error: 'تعذّر تحميل المنتجات');
    }
  }

  void setSearch(String? search) {
    state = state.copyWith(query: state.query.copyWith(search: search ?? ''));
    _load(reset: true);
  }

  void setType(String? type) {
    state = CatalogState(query: ProductQuery(type: type, sort: state.query.sort, search: state.query.search));
    _load(reset: true);
  }

  void setSort(String? sort) {
    state = state.copyWith(query: state.query.copyWith(sort: sort));
    _load(reset: true);
  }

  void applyFilters({String? brand, String? condition, int? minPriceSdg, int? maxPriceSdg}) {
    state = state.copyWith(query: state.query.copyWith(
        brand: brand, condition: condition, minPriceSdg: minPriceSdg, maxPriceSdg: maxPriceSdg));
    _load(reset: true);
  }

  void clearFilters() {
    state = state.copyWith(query: state.query.copyWith(clearFilters: true));
    _load(reset: true);
  }

  void loadMore() {
    if (state.loadingMore || !state.hasMore || state.loading) return;
    _load(reset: false);
  }

  Future<void> refresh() => _load(reset: true);
}

final catalogControllerProvider =
    StateNotifierProvider.autoDispose.family<CatalogController, CatalogState, ProductQuery>(
  (ref, initial) => CatalogController(ref, initial),
);
