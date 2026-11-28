import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';
import '../../core/design/typography.dart';
import '../../ui/app_scaffold.dart';
import '../../ui/app_top_bar.dart';
import '../../ui/states.dart';

/// Token-rendered server-side ({{lock_duration}} etc.). We just render paragraphs.
class ContentPageScreen extends ConsumerWidget {
  final String slug;
  const ContentPageScreen({super.key, required this.slug});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pageProvider(slug));
    return AppScaffold(
      appBar: AppTopBar(title: async.valueOrNull?.title ?? 'الصفحة'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorState(message: 'تعذّر تحميل الصفحة.', onRetry: () => ref.invalidate(pageProvider(slug))),
        data: (page) {
          final paras = page.body.split(RegExp(r'\n\s*\n')).where((p) => p.trim().isNotEmpty).toList();
          return ListView(
            padding: AppScaffold.listPadding(context, top: 4),
            children: [
              for (final p in paras)
                Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(p.trim(), style: WexText.body.copyWith(height: 1.9))),
            ],
          );
        },
      ),
    );
  }
}
