import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authed = ref.watch(authControllerProvider).isAuthenticated;
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: Center(
        child: Text(authed ? 'لا توجد طلبات بعد — M3' : 'سجّل الدخول لعرض طلباتك',
            style: const TextStyle(color: WexColors.textSecondary)),
      ),
    );
  }
}
