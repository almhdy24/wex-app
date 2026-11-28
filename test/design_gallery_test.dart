@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wex_app/core/design/colors.dart';
import 'package:wex_app/core/design/theme.dart';
import 'package:wex_app/core/strings.dart';
import 'package:wex_app/core/widgets/product_card.dart';
import 'package:wex_app/core/widgets/wex_widgets.dart';
import 'package:wex_app/data/models/product.dart';

ProductListItem _p(String name, int price, String cond, Map<String, String> specs,
        {bool oos = false}) =>
    ProductListItem(
      id: name.hashCode, slug: 's', type: 'laptop', name: name, condition: cond,
      priceSdg: price, stockStatus: oos ? StockStatus.outOfStock : StockStatus.inStock, specs: specs);

void main() {
  testWidgets('store grid gallery', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final items = [
      _p('HP BROPOOK 440 G7', 877500, 'used_imported',
          {'المعالج': 'Core i5-10210U', 'الرام': '8 قيقا', 'التخزين': '256 اس اسدي'}),
      _p('MacBook Air M2', 1850000, 'new', {'المعالج': 'Apple M2', 'الرام': '16 GB', 'التخزين': '512GB SSD'}),
      _p('شنطة ظهر لابتوب مقاومة للماء 15.6', 32500, 'new', const {}),
      _p('LENOVO THINKPAD T480', 585000, 'used_imported', {'المعالج': 'i5-8250U', 'الرام': '16GB', 'التخزين': '256GB SSD'}, oos: true),
    ];
    const width = 390.0;
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: buildWexTheme(), debugShowCheckedModeBanner: false,
        home: DefaultTextStyle.merge(
          style: const TextStyle(fontFamily: 'Tajawal', color: WexColors.textPrimary),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(title: const Text(Ar.navStore)),
              body: CustomScrollView(slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(child: Row(children: [
                    Text(Ar.results(14), style: const TextStyle(color: WexColors.textSecondary, fontSize: 13)),
                  ])),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: productGridDelegate(width),
                    delegate: SliverChildBuilderDelegate(
                        (c, i) => ProductCard(product: items[i], onTap: () {}), childCount: items.length),
                  ),
                ),
                const SliverToBoxAdapter(child: Padding(
                    padding: EdgeInsets.all(16), child: WexHelpCard(whatsapp: '0912345678'))),
              ]),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/gallery.png'));
  });
}
