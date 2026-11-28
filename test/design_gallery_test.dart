@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wex_app/core/design/colors.dart';
import 'package:wex_app/core/design/theme.dart';
import 'package:wex_app/core/widgets/price_text.dart';
import 'package:wex_app/core/widgets/product_card.dart';
import 'package:wex_app/data/models/product.dart';

ProductListItem _p(String name, int price, String cond, {bool oos = false}) =>
    ProductListItem(
        id: name.hashCode,
        slug: 's',
        type: 'laptop',
        name: name,
        condition: cond,
        priceSdg: price,
        stockStatus: oos ? StockStatus.outOfStock : StockStatus.inStock);

void main() {
  testWidgets('design gallery', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1500 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: buildWexTheme(),
      locale: const Locale('ar'),
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: DefaultTextStyle.merge(
          style: const TextStyle(
              fontFamily: 'Tajawal', color: WexColors.textPrimary),
          child: Scaffold(
            appBar: AppBar(title: const Text('المتجر')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // hero
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      gradient: WexColors.gradNavy,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('أجهزة لابتوب لأعمالك',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 8),
                        Text('أجهزة مستوردة بأسعار واضحة وتثبيت للسعر',
                            style: TextStyle(
                                color: WexColors.onDarkMuted, fontSize: 14)),
                      ]),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: FilledButton(
                          onPressed: () {}, child: const Text('تأكيد الطلب'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () {}, child: const Text('إضافة للسلة'))),
                ]),
                const SizedBox(height: 16),
                Wrap(spacing: 8, children: [
                  ChoiceChip(
                      label: const Text('الكل'),
                      selected: true,
                      onSelected: (_) {}),
                  ChoiceChip(
                      label: const Text('لابتوبات'),
                      selected: false,
                      onSelected: (_) {}),
                  ChoiceChip(
                      label: const Text('هواتف'),
                      selected: false,
                      onSelected: (_) {}),
                ]),
                const SizedBox(height: 16),
                const PriceText(1850000, size: 26),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.62,
                  children: [
                    ProductCard(
                        product:
                            _p('Dell Latitude 7490', 487500, 'used_imported'),
                        onTap: () {},
                        chips: const ['i5', '8GB', '256GB']),
                    ProductCard(
                        product: _p('MacBook Air M2', 1850000, 'new'),
                        onTap: () {},
                        chips: const ['M2', '16GB', '512GB']),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(Scaffold), matchesGoldenFile('goldens/gallery.png'));
  });
}
