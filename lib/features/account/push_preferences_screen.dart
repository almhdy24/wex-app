import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/typography.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/buttons.dart';
import '../../ui/icons.dart';
import '../../ui/states.dart';

final pushPrefsProvider = FutureProvider.autoDispose((ref) => ref.read(pushRepositoryProvider).preferences());

class PushPreferencesScreen extends ConsumerWidget {
  const PushPreferencesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pushPrefsProvider);
    final repo = ref.read(pushRepositoryProvider);
    Future<void> toggle(String key, bool v) async {
      await repo.updatePreferences({key: v});
      ref.invalidate(pushPrefsProvider);
    }

    return AppScaffold(
      appBar: const AppTopBar(title: 'إعدادات الإشعارات'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorState(onRetry: () => ref.invalidate(pushPrefsProvider)),
        data: (p) => ListView(
          padding: AppScaffold.listPadding(context, top: 4),
          children: [
            _row('تحديثات الطلبات', p.orderUpdates, (v) => toggle('order_updates', v)),
            _row('تحديثات الدفع', p.paymentUpdates, (v) => toggle('payment_updates', v)),
            _row('تنبيهات الأسعار', p.priceAlerts, (v) => toggle('price_alerts', v)),
            _row('العروض والإعلانات', p.announcements, (v) => toggle('announcements', v)),
            const SizedBox(height: 16),
            SecondaryButton('إرسال إشعار تجريبي', icon: LucideIcons.send, onPressed: () async {
              await repo.sendTest();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال إشعار تجريبي')));
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, bool value, ValueChanged<bool> onChanged) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: WexText.body.copyWith(fontWeight: FontWeight.w500)),
        value: value,
        activeThumbColor: WexColors.teal600,
        onChanged: onChanged,
      );
}
