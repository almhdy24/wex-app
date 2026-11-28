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
import '../features/account/push_preferences_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/account/account_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/verify_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Shared-axis style push: short fade + slight slide from the inline end (RTL-aware).
/// Respects the OS "remove animations" setting.
CustomTransitionPage<void> _push(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondary, child) {
        if (MediaQuery.of(context).disableAnimations) return child;
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(-0.06, 0), end: Offset.zero)
                    .animate(curved),
            child: child,
          ),
        );
      },
    );

/// Bottom-sheet presentation: dimmed barrier, spring-in from the bottom.
CustomTransitionPage<void> _sheet(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      opaque: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondary, child) {
        if (MediaQuery.of(context).disableAnimations) return child;
        final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
              .animate(curved),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );

final appRouter = _build();

GoRouter _build() => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => WexScaffoldShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/', builder: (c, s) => const HomeScreen())
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/catalog',
                builder: (c, s) => CatalogScreen(
                  initialType: s.uri.queryParameters['type'],
                  initialSearch: s.uri.queryParameters['search'],
                  autofocusSearch: s.uri.queryParameters['focus'] == '1',
                ),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/orders', builder: (c, s) => const OrdersScreen())
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/account', builder: (c, s) => const AccountScreen())
            ]),
          ],
        ),
        GoRoute(
          path: '/products/:slug',
          parentNavigatorKey: _rootKey,
          pageBuilder: (c, s) =>
              _push(s, ProductDetailScreen(slug: s.pathParameters['slug']!)),
        ),
        GoRoute(
            path: '/cart',
            parentNavigatorKey: _rootKey,
            pageBuilder: (c, s) => _push(s, const CartScreen())),
        GoRoute(
            path: '/checkout',
            parentNavigatorKey: _rootKey,
            pageBuilder: (c, s) => _sheet(s, const CheckoutScreen())),
        GoRoute(
          path: '/orders/:number',
          parentNavigatorKey: _rootKey,
          pageBuilder: (c, s) => _push(
              s,
              OrderDetailScreen(
                orderNumber: s.pathParameters['number']!,
                justCreated:
                    (s.extra is Map && (s.extra as Map)['justCreated'] == true),
              )),
        ),
        GoRoute(
            path: '/notifications',
            parentNavigatorKey: _rootKey,
            pageBuilder: (c, s) => _push(s, const NotificationsScreen())),
        GoRoute(
            path: '/push-preferences',
            parentNavigatorKey: _rootKey,
            pageBuilder: (c, s) => _push(s, const PushPreferencesScreen())),
        GoRoute(
            path: '/faq',
            parentNavigatorKey: _rootKey,
            pageBuilder: (c, s) => _push(s, const FaqScreen())),
        GoRoute(
          path: '/pages/:slug',
          parentNavigatorKey: _rootKey,
          pageBuilder: (c, s) =>
              _push(s, ContentPageScreen(slug: s.pathParameters['slug']!)),
        ),
        GoRoute(
            path: '/login',
            parentNavigatorKey: _rootKey,
            pageBuilder: (c, s) => _push(s, const LoginScreen())),
        GoRoute(
          path: '/verify',
          parentNavigatorKey: _rootKey,
          pageBuilder: (c, s) => _push(
              s, VerifyScreen(email: s.uri.queryParameters['email'] ?? '')),
        ),
      ],
    );
