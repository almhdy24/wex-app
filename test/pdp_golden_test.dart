@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wex_app/app/providers.dart';
import 'package:wex_app/core/design/theme.dart';
import 'package:wex_app/data/models/product.dart';
import 'package:wex_app/data/models/shop.dart';
import 'package:wex_app/features/product/product_detail_screen.dart';

void main() {
  testWidgets('pdp preview', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    const detail = ProductDetail(
      id: 1, slug: 'thinkpad', type: 'laptop', name: 'Lenovo ThinkPad T480',
      condition: 'used_imported', priceSdg: 585000, stockStatus: StockStatus.inStock,
      description: 'جهاز مكتبي خفيف للأعمال اليومية، هيكل متين وبطارية مزدوجة تدوم طويلاً مع لوحة مفاتيح مريحة.',
      // NOTE: screen and GPU values are intentionally SWAPPED to test the fix.
      specs: {
        'المعالج': 'Intel Core i5-8250U', 'الرام': '16 قيقا', 'التخزين': '256 اس اسدي',
        'كرت الشاشة': '14 بوصة', 'الشاشة': 'Intel UHD Graphics 620', 'البطارية': 'مزدوجة',
      },
    );
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (c, s) => const ProductDetailScreen(slug: 'thinkpad'))]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        productDetailProvider('thinkpad').overrideWith((ref) async => detail),
        shopProvider.overrideWith((ref) async => const Shop(
          name: 'ويكس', address: 'الخرطوم', phone: '', whatsapp: '0912345678',
          workingHours: '', shopMapLink: '', lockHours: 4, appDiscountPercent: 3,
          ordersEnabled: true, ordersDisabledMessage: '', tickerEnabled: false)),
      ],
      child: MaterialApp.router(
        theme: buildWexTheme(), debugShowCheckedModeBanner: false, routerConfig: router,
        builder: (c, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(find.byType(ProductDetailScreen), matchesGoldenFile('goldens/pdp.png'));
  });
}
