import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(Sp.page),
        children: [
          if (auth.isAuthenticated) ...[
            _card(Row(children: [
              const CircleAvatar(radius: 26, backgroundColor: WexColors.ice,
                  child: Icon(Icons.person, color: WexColors.royal)),
              const SizedBox(width: Sp.x6),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(auth.user!.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Text(auth.user!.email, style: const TextStyle(color: WexColors.textSecondary, fontSize: 13)),
              ])),
            ])),
            const SizedBox(height: Sp.x6),
          ] else ...[
            _card(Column(children: [
              const Text('سجّل الدخول للطلب والمتابعة', style: TextStyle(color: WexColors.textSecondary)),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: () => context.push('/login'), child: const Text('تسجيل الدخول'))),
            ])),
            const SizedBox(height: Sp.x6),
          ],
          _tile(Icons.notifications_outlined, 'الإشعارات', () => context.push('/notifications')),
          if (auth.isAuthenticated)
            _tile(Icons.notifications_active_outlined, 'إعدادات الإشعارات', () => context.push('/push-preferences')),
          _tile(Icons.help_outline, 'الأسئلة الشائعة', () => context.push('/faq')),
          _tile(Icons.description_outlined, 'الشروط والأحكام', () => context.push('/pages/terms')),
          _tile(Icons.privacy_tip_outlined, 'سياسة الخصوصية', () => context.push('/pages/privacy')),
          _tile(Icons.assignment_return_outlined, 'سياسة الاستلام والإرجاع', () => context.push('/pages/returns')),
          if (auth.isAuthenticated) ...[
            const SizedBox(height: Sp.x6),
            _card(ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: WexColors.danger),
              title: const Text('تسجيل الخروج', style: TextStyle(color: WexColors.danger, fontWeight: FontWeight.w700)),
              onTap: () => ref.read(authControllerProvider.notifier).logout(),
            )),
          ],
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: Sp.x3),
        child: _card(ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: WexColors.royal),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_left, color: WexColors.disabled),
          onTap: onTap,
        )),
      );

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.all(Sp.x6),
        decoration: BoxDecoration(
          color: WexColors.white,
          borderRadius: BorderRadius.circular(Radii.card),
          boxShadow: const [BoxShadow(color: Color(0x0F061A55), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: child,
      );
}
