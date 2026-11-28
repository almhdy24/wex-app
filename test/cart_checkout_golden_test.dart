@Tags(['golden'])
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wex_app/app/providers.dart';
import 'package:wex_app/core/design/theme.dart';
import 'package:wex_app/data/models/catalog_meta.dart';
import 'package:wex_app/data/models/shop.dart';
import 'package:wex_app/features/cart/cart_screen.dart';
import 'package:wex_app/features/checkout/checkout_screen.dart';

const _shop = Shop(
    name: 'ويكس',
    address: 'أم درمان، الشهداء',
    phone: '0911000000',
    whatsapp: '0912345678',
    workingHours: 'يوميًا 9 ص - 9 م',
    shopMapLink: '',
    lockHours: 4,
    appDiscountPercent: 3,
    ordersEnabled: true,
    ordersDisabledMessage: '',
    tickerEnabled: false);

Future<void> _pump(WidgetTester t, Widget screen, String file) async {
  t.view.physicalSize = const Size(390 * 3, 844 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  SharedPreferences.setMockInitialValues({
    'wex_cart_items': jsonEncode([
      {
        'product_id': 1,
        'slug': 'a',
        'name': 'Lenovo ThinkPad T480',
        'price_sdg': 585000,
        'quantity': 2,
        'max_qty': 10
      },
      {
        'product_id': 2,
        'slug': 'b',
        'name': 'HP EliteBook 840 G5',
        'price_sdg': 520000,
        'quantity': 1,
        'max_qty': 2
      },
    ]),
  });
  final router =
      GoRouter(routes: [GoRoute(path: '/', builder: (c, s) => screen)]);
  await t.pumpWidget(ProviderScope(
    overrides: [
      shopProvider.overrideWith((ref) async => _shop),
      zonesProvider.overrideWith((ref) async =>
          [const ShippingZone(id: 1, name: 'الخرطوم', feeSdg: 5000)]),
    ],
    child: MaterialApp.router(
      theme: buildWexTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (c, child) => DefaultTextStyle.merge(
          style: const TextStyle(fontFamily: 'Tajawal'),
          child:
              Directionality(textDirection: TextDirection.rtl, child: child!)),
    ),
  ));
  await t.pump(const Duration(milliseconds: 600));
  await expectLater(find.byType(Scaffold).first, matchesGoldenFile(file));
}

void main() {
  testWidgets(
      'cart preview', (t) => _pump(t, const CartScreen(), 'goldens/cart.png'));
  testWidgets('checkout preview',
      (t) => _pump(t, const CheckoutScreen(), 'goldens/checkout.png'));
}
