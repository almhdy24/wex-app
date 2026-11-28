import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/strings.dart';
import '../../core/utils/launchers.dart';
import '../../core/design/tones.dart';
import '../../core/design/typography.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/wex_kit.dart';
import '../../core/widgets/wex_widgets.dart';

const _appVersion = '1.0.7';

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
          // The one hero moment: user card on the brand gradient.
          if (auth.isAuthenticated)
            HeroCard(
                child: Row(children: [
              Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: Text(
                      auth.user!.name.isNotEmpty
                          ? auth.user!.name.characters.first
                          : 'و',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800))),
              const SizedBox(width: Sp.x6),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(auth.user!.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17)),
                    const SizedBox(height: 2),
                    LtrText(auth.user!.email,
                        style: const TextStyle(
                            color: WexColors.onDarkMuted, fontSize: 13)),
                  ])),
            ]))
          else
            SurfaceCard(
                soft: true,
                child: Column(children: [
                  const WexIllustration(IllustrationKind.box, size: 96),
                  const SizedBox(height: 8),
                  const Text(Ar.signedOut,
                      style: TextStyle(color: WexColors.textSecondary)),
                  const SizedBox(height: 14),
                  WexButton(Ar.signIn, onPressed: () => context.push('/login')),
                ])),
          if (shop?.whatsapp.isNotEmpty ?? false) ...[
            const SizedBox(height: Sp.x6),
            SurfaceCard(
              onTap: () => openWhatsApp(shop.whatsapp),
              child: Row(children: [
                const TintIcon(Icons.chat_rounded, tone: Tone.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(Ar.contactUs,
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        if (shop!.workingHours.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                                '${Ar.workingHoursLabel}: ${shop.workingHours}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: WexText.caption),
                          ),
                      ]),
                ),
                const StatusPill(Ar.whatsappLabel,
                    tone: Tone.success, dot: false),
              ]),
            ),
          ],
          const SizedBox(height: Sp.x7),
          _group(Ar.sectionOrders, [
            _item(Icons.receipt_long_rounded, Ar.sectionOrders,
                () => context.go('/orders')),
            _item(Icons.notifications_rounded, Ar.notifications,
                () => context.push('/notifications')),
            if (auth.isAuthenticated)
              _item(Icons.notifications_active_rounded, Ar.notifSettings,
                  () => context.push('/push-preferences')),
          ]),
          const SizedBox(height: Sp.x6),
          _group(Ar.sectionSupport, [
            _item(
                Icons.help_outline_rounded, Ar.faq, () => context.push('/faq')),
            _item(Icons.description_outlined, Ar.terms,
                () => context.push('/pages/terms')),
            _item(Icons.privacy_tip_outlined, Ar.privacy,
                () => context.push('/pages/privacy')),
            _item(Icons.assignment_return_outlined, Ar.returns,
                () => context.push('/pages/returns')),
          ]),
          if (auth.isAuthenticated) ...[
            const SizedBox(height: Sp.x6),
            SurfaceCard(
                padding: EdgeInsets.zero,
                child: Material(
                    type: MaterialType.transparency,
                    child: _item(
                        Icons.logout_rounded,
                        Ar.logout,
                        () =>
                            ref.read(authControllerProvider.notifier).logout(),
                        tint: WexColors.danger))),
          ],
          const SizedBox(height: Sp.x8),
          Center(
              child: Text(Ar.versionLine(_appVersion),
                  style: const TextStyle(
                      color: WexColors.disabled, fontSize: 12))),
          const SizedBox(height: Sp.x6),
        ],
      ),
    );
  }

  Widget _group(String title, List<Widget> items) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      children.add(items[i]);
      if (i < items.length - 1) {
        children.add(const Divider(height: 1, indent: 70));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: WexColors.textSecondary))),
      SurfaceCard(
          padding: EdgeInsets.zero,
          child: Material(
              type: MaterialType.transparency,
              child: Column(children: children))),
    ]);
  }

  Widget _item(IconData icon, String label, VoidCallback onTap,
          {Color tint = WexColors.primary}) =>
      ListTile(
        dense: false,
        contentPadding: const EdgeInsetsDirectional.only(start: 14, end: 8),
        leading: TintIcon(icon,
            size: 38,
            tone: tint == WexColors.danger
                ? Tone.danger
                : (tint == WexColors.success ? Tone.success : Tone.brand)),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: tint == WexColors.danger
                    ? WexColors.danger
                    : WexColors.textPrimary)),
        trailing:
            const Icon(Icons.chevron_left_rounded, color: WexColors.disabled),
        onTap: onTap,
      );
}
