import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/wex_scaffold_shell.dart';
import '../features/home/home_screen.dart';
import '../features/catalog/catalog_screen.dart';
import '../features/product/product_detail_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/content/faq_screen.dart';
import '../features/content/content_page_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/account/account_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/verify_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildRouter() => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => WexScaffoldShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/', builder: (c, s) => const HomeScreen())]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/catalog',
                builder: (c, s) => CatalogScreen(
                  initialType: s.uri.queryParameters['type'],
                  initialSearch: s.uri.queryParameters['search'],
                ),
              ),
            ]),
            StatefulShellBranch(routes: [GoRoute(path: '/orders', builder: (c, s) => const OrdersScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/account', builder: (c, s) => const AccountScreen())]),
          ],
        ),
        GoRoute(
          path: '/products/:slug',
          parentNavigatorKey: _rootKey,
          builder: (c, s) => ProductDetailScreen(slug: s.pathParameters['slug']!),
        ),
        GoRoute(path: '/cart', parentNavigatorKey: _rootKey, builder: (c, s) => const CartScreen()),
        GoRoute(path: '/checkout', parentNavigatorKey: _rootKey, builder: (c, s) => const CheckoutScreen()),
        GoRoute(
          path: '/orders/:number',
          parentNavigatorKey: _rootKey,
          builder: (c, s) => OrderDetailScreen(orderNumber: s.pathParameters['number']!),
        ),
        GoRoute(path: '/notifications', parentNavigatorKey: _rootKey, builder: (c, s) => const NotificationsScreen()),
        GoRoute(path: '/faq', parentNavigatorKey: _rootKey, builder: (c, s) => const FaqScreen()),
        GoRoute(
          path: '/pages/:slug',
          parentNavigatorKey: _rootKey,
          builder: (c, s) => ContentPageScreen(slug: s.pathParameters['slug']!),
        ),
        GoRoute(path: '/login', parentNavigatorKey: _rootKey, builder: (c, s) => const LoginScreen()),
        GoRoute(
          path: '/verify',
          parentNavigatorKey: _rootKey,
          builder: (c, s) => VerifyScreen(email: s.uri.queryParameters['email'] ?? ''),
        ),
      ],
    );
