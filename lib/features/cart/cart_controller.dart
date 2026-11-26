import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';

const _kCartKey = 'wex_cart_items';

class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super(const []) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCartKey);
      if (raw == null) return;
      final list = (jsonDecode(raw) as List)
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      state = list;
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCartKey, jsonEncode(state.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  int get totalItems => state.fold(0, (s, i) => s + i.quantity);
  int get subtotalSdg => state.fold(0, (s, i) => s + i.lineTotal);

  void addProduct(ProductDetail p, {int quantity = 1}) {
    final idx = state.indexWhere((e) => e.productId == p.id);
    if (idx == -1) {
      state = [...state, CartItem.fromProduct(p, quantity: quantity)];
    } else {
      final item = state[idx];
      final q = (item.quantity + quantity).clamp(1, item.maxQty);
      state = [...state]..[idx] = item.copyWith(quantity: q);
    }
    _persist();
  }

  void setQuantity(int productId, int quantity) {
    final idx = state.indexWhere((e) => e.productId == productId);
    if (idx == -1) return;
    final item = state[idx];
    final q = quantity.clamp(1, item.maxQty);
    state = [...state]..[idx] = item.copyWith(quantity: q);
    _persist();
  }

  void remove(int productId) {
    state = state.where((e) => e.productId != productId).toList();
    _persist();
  }

  void restore(CartItem item, int index) {
    final list = [...state];
    list.insert(index.clamp(0, list.length), item);
    state = list;
    _persist();
  }

  void clear() {
    state = const [];
    _persist();
  }
}

final cartControllerProvider =
    StateNotifierProvider<CartController, List<CartItem>>((ref) => CartController());
