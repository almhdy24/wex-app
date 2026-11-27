import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/strings.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/wex_widgets.dart';

const _appVersion = '1.0.4';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final shop = ref.watch(shopProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text(Ar.myAccount)),
      body: ListView(
        padding: const EdgeInsets.all(Sp.page),
        children: [
          if (auth.isAuthenticated)
            WexCard(child: Row(children: [
              Container(width: 52, height: 52, alignment: Alignment.center,
                  decoration: const BoxDecoration(gradient: WexColors.gradBrand, shape: BoxShape.circle),
                  child: Text(auth.user!.name.isNotEmpty ? auth.user!.name.characters.first : 'و',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
              const SizedBox(width: Sp.x6),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(auth.user!.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 2),
                LtrText(auth.user!.email, style: const TextStyle(color: WexColors.textSecondary, fontSize: 13)),
              ])),
            ]))
          else
            WexCard(child: Column(children: [
              const Icon(Icons.account_circle_outlined, size: 44, color: WexColors.primary),
              const SizedBox(height: 10),
              const Text(Ar.signedOut, style: TextStyle(color: WexColors.textSecondary)),
              const SizedBox(height: 14),
              WexButton(Ar.signIn, onPressed: () => context.push('/login')),
            ])),
          const SizedBox(height: Sp.x7),

          _group(Ar.sectionOrders, [
            _item(Icons.receipt_long_rounded, Ar.sectionOrders, () => context.go('/orders')),
            _item(Icons.notifications_rounded, Ar.notifications, () => context.push('/notifications')),
            if (auth.isAuthenticated) _item(Icons.notifications_active_rounded, Ar.notifSettings, () => context.push('/push-preferences')),
          ]),
          const SizedBox(height: Sp.x6),
          _group(Ar.sectionSupport, [
            if (shop?.whatsapp.isNotEmpty ?? false)
              _item(Icons.chat_rounded, Ar.contactUs, () => openWhatsApp(shop!.whatsapp), tint: WexColors.success),
            _item(Icons.help_outline_rounded, Ar.faq, () => context.push('/faq')),
            _item(Icons.description_outlined, Ar.terms, () => context.push('/pages/terms')),
            _item(Icons.privacy_tip_outlined, Ar.privacy, () => context.push('/pages/privacy')),
            _item(Icons.assignment_return_outlined, Ar.returns, () => context.push('/pages/returns')),
          ]),
          if (auth.isAuthenticated) ...[
            const SizedBox(height: Sp.x6),
            WexCard(padding: EdgeInsets.zero, child: _item(Icons.logout_rounded, Ar.logout,
                () => ref.read(authControllerProvider.notifier).logout(), tint: WexColors.danger)),
          ],
          const SizedBox(height: Sp.x8),
          Center(child: Text('${Ar.appName} · الإصدار $_appVersion',
              style: const TextStyle(color: WexColors.disabled, fontSize: 12))),
          const SizedBox(height: Sp.x6),
        ],
      ),
    );
  }

  Widget _group(String title, List<Widget> items) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      children.add(items[i]);
      if (i < items.length - 1) children.add(const Divider(height: 1, indent: 54));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: WexColors.textSecondary))),
      WexCard(padding: EdgeInsets.zero, child: Column(children: children)),
    ]);
  }

  Widget _item(IconData icon, String label, VoidCallback onTap, {Color tint = WexColors.primary}) => ListTile(
        dense: true, visualDensity: const VisualDensity(vertical: -1),
        leading: Icon(icon, color: tint, size: 22),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600,
            color: tint == WexColors.danger ? WexColors.danger : WexColors.textPrimary)),
        trailing: const Icon(Icons.chevron_left_rounded, color: WexColors.disabled),
        onTap: onTap,
      );
}
