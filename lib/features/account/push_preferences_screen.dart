import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('إشعارات التطبيق')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذّر التحميل', style: TextStyle(color: WexColors.textSecondary))),
        data: (p) => ListView(
          padding: const EdgeInsets.all(Sp.page),
          children: [
            _row('تحديثات الطلب', p.orderUpdates, (v) => toggle('order_updates', v)),
            _row('تأكيد الدفع', p.paymentUpdates, (v) => toggle('payment_updates', v)),
            _row('تنبيهات الأسعار', p.priceAlerts, (v) => toggle('price_alerts', v)),
            _row('العروض والإعلانات', p.announcements, (v) => toggle('announcements', v)),
            const SizedBox(height: Sp.x6),
            OutlinedButton.icon(
              onPressed: () async {
                await repo.sendTest();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال إشعار تجريبي')));
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('إرسال إشعار تجريبي'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, bool value, ValueChanged<bool> onChanged) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        value: value,
        activeThumbColor: WexColors.royal,
        onChanged: onChanged,
      );
}
