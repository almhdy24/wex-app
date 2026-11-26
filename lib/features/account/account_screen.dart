import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: auth.isAuthenticated
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('مرحبًا ${auth.user!.name}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                    child: const Text('تسجيل الخروج'),
                  ),
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('لم تسجّل الدخول بعد',
                      style: TextStyle(color: WexColors.textSecondary)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('تسجيل الدخول'),
                  ),
                ]),
        ),
      ),
    );
  }
}
