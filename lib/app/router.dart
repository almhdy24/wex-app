import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/wex_scaffold_shell.dart';
import '../features/home/home_screen.dart';
import '../features/catalog/catalog_screen.dart';
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
            StatefulShellBranch(routes: [GoRoute(path: '/catalog', builder: (c, s) => const CatalogScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/orders', builder: (c, s) => const OrdersScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/account', builder: (c, s) => const AccountScreen())]),
          ],
        ),
        GoRoute(path: '/login', parentNavigatorKey: _rootKey, builder: (c, s) => const LoginScreen()),
        GoRoute(
          path: '/verify',
          parentNavigatorKey: _rootKey,
          builder: (c, s) => VerifyScreen(email: s.uri.queryParameters['email'] ?? ''),
        ),
      ],
    );
