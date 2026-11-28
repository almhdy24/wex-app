import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/providers.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../core/utils/launchers.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/buttons.dart';
import '../../ui/icons.dart';

const _appVersion = '1.1.0';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final shop = ref.watch(shopProvider).valueOrNull;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final chevron = rtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight;

    return AppScaffold(
      appBar: const AppTopBar(title: 'حسابي', showBack: false),
      body: ListView(
        padding: AppScaffold.listPadding(context, top: 8),
        children: [
          if (auth.isAuthenticated)
            Row(children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: WexColors.ink900, shape: BoxShape.circle),
                child: Text(
                  auth.user!.name.isNotEmpty ? auth.user!.name.characters.first : 'و',
                  style: WexText.titleL.copyWith(color: WexColors.paper),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(auth.user!.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: WexText.titleM),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(auth.user!.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: WexText.bodyS),
                    ),
                  ),
                ]),
              ),
            ])
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WexColors.surface,
                borderRadius: BorderRadius.circular(Radii.card),
                border: Border.all(color: WexColors.line),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('أنت غير مسجّل', style: WexText.titleM),
                const SizedBox(height: 4),
                const Text('سجّل الدخول لمتابعة طلباتك وحفظ بياناتك.', style: WexText.bodyS),
                const SizedBox(height: 16),
                PrimaryButton('تسجيل الدخول', onPressed: () => context.push('/login')),
              ]),
            ),
          const SizedBox(height: 24),
          const _GroupTitle('طلباتي'),
          _Group(chevron: chevron, items: [
            (LucideIcons.receipt, 'طلباتي', () => context.go('/orders')),
            (LucideIcons.bell, 'الإشعارات', () => context.push('/notifications')),
            if (auth.isAuthenticated) (LucideIcons.bellRing, 'إعدادات الإشعارات', () => context.push('/push-preferences')),
          ]),
          const SizedBox(height: 24),
          const _GroupTitle('الدعم والسياسات'),
          _Group(chevron: chevron, items: [
            if (shop?.whatsapp.isNotEmpty ?? false) (LucideIcons.messageCircle, 'تواصل معنا عبر واتساب', () => openWhatsApp(shop!.whatsapp)),
            (LucideIcons.circleHelp, 'الأسئلة الشائعة', () => context.push('/faq')),
            (LucideIcons.fileText, 'الشروط والأحكام', () => context.push('/pages/terms')),
            (LucideIcons.shieldCheck, 'سياسة الخصوصية', () => context.push('/pages/privacy')),
            (LucideIcons.undo2, 'سياسة الاستلام والإرجاع', () => context.push('/pages/returns')),
          ]),
          if (auth.isAuthenticated) ...[
            const SizedBox(height: 24),
            _Group(chevron: null, danger: true, items: [
              (LucideIcons.logOut, 'تسجيل الخروج', () => ref.read(authControllerProvider.notifier).logout()),
            ]),
          ],
          const SizedBox(height: 24),
          Center(child: Text('ويكس تكنولوجي · الإصدار $_appVersion', style: WexText.label)),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  final String text;
  const _GroupTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: WexText.label),
      );
}

class _Group extends StatelessWidget {
  final List<(IconData, String, VoidCallback)> items;
  final IconData? chevron;
  final bool danger;
  const _Group({required this.items, required this.chevron, this.danger = false});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: WexColors.surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: WexColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: WexColors.surface,
          child: Column(children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(indent: 68),
              InkWell(
                onTap: items[i].$3,
                child: SizedBox(
                  height: 56,
                  child: Row(children: [
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: WexColors.sunken, shape: BoxShape.circle),
                      child: Icon(items[i].$1, size: 20, color: danger ? WexColors.danger : WexColors.ink900),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(items[i].$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WexText.body.copyWith(color: danger ? WexColors.danger : WexColors.ink900)),
                    ),
                    if (chevron != null) Icon(chevron, size: 20, color: WexColors.disabled),
                    const SizedBox(width: 12),
                  ]),
                ),
              ),
            ],
          ]),
        ),
      );
}
