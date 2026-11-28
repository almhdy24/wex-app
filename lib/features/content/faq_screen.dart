import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/design/typography.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/states.dart';

class FaqScreen extends ConsumerWidget {
  const FaqScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(faqProvider);
    return AppScaffold(
      appBar: const AppTopBar(title: 'الأسئلة الشائعة'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorState(onRetry: () => ref.invalidate(faqProvider)),
        data: (items) => ListView(
          padding: AppScaffold.listPadding(context, top: 4),
          children: [
            for (final f in items)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: WexColors.surface,
                  borderRadius: BorderRadius.circular(Radii.card),
                  border: Border.all(color: WexColors.line),
                ),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(f.question, style: WexText.body.copyWith(fontWeight: FontWeight.w600)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(f.answer, style: WexText.bodyS.copyWith(height: 1.8))],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
