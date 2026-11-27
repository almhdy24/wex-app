@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wex_app/core/design/theme.dart';
import 'package:wex_app/features/auth/login_screen.dart';

void main() {
  testWidgets('login preview', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (c, s) => const LoginScreen())]);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(
        theme: buildWexTheme(),
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        builder: (c, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
    ));
    await tester.pumpAndSettle();
    await expectLater(find.byType(LoginScreen), matchesGoldenFile('goldens/login.png'));
  });
}
