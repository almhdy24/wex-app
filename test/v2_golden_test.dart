@Tags(['golden'])
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wex_app/app/providers.dart';
import 'package:wex_app/core/auth/auth_controller.dart';
import 'package:wex_app/core/design/theme.dart';
import 'package:wex_app/data/models/order.dart';
import 'package:wex_app/data/models/product.dart';
import 'package:wex_app/data/models/promotion.dart';
import 'package:wex_app/data/models/shop.dart';
import 'package:wex_app/data/models/user.dart';
import 'package:wex_app/features/account/account_screen.dart';
import 'package:wex_app/features/cart/cart_screen.dart';
import 'package:wex_app/features/orders/orders_screen.dart';
import 'package:wex_app/ui/product_card.dart';
import 'package:wex_app/ui/promo_card.dart';

const _shop = Shop(
    name: 'ويكس', address: 'أم درمان، الشهداء', phone: '0911000000', whatsapp: '0912345678',
    workingHours: 'يوميًا 9 ص - 9 م', shopMapLink: '', lockHours: 4, appDiscountPercent: 3,
    ordersEnabled: true, ordersDisabledMessage: '', tickerEnabled: false);

class _FakeAuth extends StateNotifier<AuthState> implements AuthController {
  _FakeAuth()
      : super(const AuthState(user: User(id: 1, name: 'محمد أحمد', email: 'm@example.com', role: 'customer'), bootstrapped: true));
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

final _orders = [
  OrderListItem(orderNumber: 'WEX-20261128-0042', status: OrderStatus.pendingPayment, statusLabel: 'بانتظار الدفع',
      paymentState: PaymentState.awaitingProof, totalSdg: 1170000, createdAt: DateTime.utc(2026, 11, 28, 13, 5),
      deliveryType: 'pickup', itemsCount: 2, linesCount: 2, firstItemName: 'Lenovo ThinkPad T480 Core i7 16GB 512GB SSD', secondsRemaining: 12300),
  OrderListItem(orderNumber: 'WEX-20261120-0031', status: OrderStatus.confirmed, statusLabel: 'مؤكد', paymentState: PaymentState.approved,
      totalSdg: 585000, createdAt: DateTime.utc(2026, 11, 20, 9, 40), deliveryType: 'delivery', itemsCount: 1, linesCount: 1, firstItemName: 'HP EliteBook 840 G5'),
  OrderListItem(orderNumber: 'WEX-20261015-0002', status: OrderStatus.expired, statusLabel: 'انتهت المهلة', paymentState: PaymentState.expired,
      totalSdg: 410000, createdAt: DateTime.utc(2026, 10, 15, 11, 0), deliveryType: 'pickup', itemsCount: 1, linesCount: 1, firstItemName: 'شاحن لابتوب أصلي 65 واط'),
];

const _p = [
  ProductListItem(id: 1, slug: 'a', type: 'laptop', name: 'HP BROPOOK 440 G7', condition: 'used_imported', priceSdg: 1474400,
      stockStatus: StockStatus.inStock, specChips: ['i5', '8GB', '256GB SSD'], compareAtSdg: 1632000),
  ProductListItem(id: 2, slug: 'b', type: 'laptop', name: 'Lenovo ThinkPad T480', condition: 'new', priceSdg: 585000,
      stockStatus: StockStatus.lowStock, specChips: ['i7', '16GB', '512GB SSD']),
];

Future<void> _pump(WidgetTester t, Widget screen, String file, {double h = 1000, double scale = 1.0}) async {
  t.view.physicalSize = Size(390 * 3, h * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  SharedPreferences.setMockInitialValues({
    'wex_cart_items': jsonEncode([
      {'product_id': 1, 'slug': 'a', 'name': 'HP BROPOOK 440 G7', 'price_sdg': 1474400, 'quantity': 2, 'max_qty': 10, 'condition': 'used_imported'},
      {'product_id': 2, 'slug': 'b', 'name': 'Lenovo ThinkPad T480', 'price_sdg': 585000, 'quantity': 1, 'max_qty': 2, 'condition': 'new'},
    ]),
  });
  final router = GoRouter(routes: [GoRoute(path: '/', builder: (c, s) => screen)]);
  await t.pumpWidget(ProviderScope(
    overrides: [
      shopProvider.overrideWith((ref) async => _shop),
      authControllerProvider.overrideWith((ref) => _FakeAuth()),
      ordersListProvider.overrideWith((ref) async => _orders),
      accessoriesProvider.overrideWith((ref) async => const []),
      promotionsProvider.overrideWith((ref, placement) async => const []),
    ],
    child: MaterialApp.router(
      theme: buildWexTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
        child: Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
    ),
  ));
  await t.pump(const Duration(milliseconds: 600));
  await t.pump(const Duration(milliseconds: 600));
  await expectLater(find.byType(Scaffold).first, matchesGoldenFile(file));
}

void main() {
  testWidgets('cart', (t) => _pump(t, const CartScreen(), 'goldens/v2_cart.png'));
  testWidgets('cart 1.3x', (t) => _pump(t, const CartScreen(), 'goldens/v2_cart_130.png', scale: 1.3));
  testWidgets('orders', (t) => _pump(t, const OrdersScreen(), 'goldens/v2_orders.png', h: 1100));
  testWidgets('account', (t) => _pump(t, const AccountScreen(), 'goldens/v2_account.png'));
  testWidgets('cards + promos', (t) async {
    await _pump(
      t,
      Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            ...productRows(_p, (p) => ProductCard(product: p, onTap: () {})),
            for (final th in PromoTheme.values) ...[
              PromoCard(
                promo: Promotion(id: th.index, placement: 'home_hero', title: 'لابتوب يناسب شغلك ودراستك',
                    subtitle: 'أجهزة مستوردة بأسعار واضحة، ونثبّت لك السعر بعد الطلب', badgeText: 'عرض محدود',
                    ctaLabel: 'تصفّح الحواسيب', theme: th),
                onTap: () {},
              ),
              const SizedBox(height: 12),
            ],
          ]),
        ),
      ),
      'goldens/v2_cards_promos.png',
      h: 1700,
    );
  });
}
