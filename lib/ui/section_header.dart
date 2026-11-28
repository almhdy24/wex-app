import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/typography.dart';

/// Section title with an optional "عرض الكل" link.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader(this.title, {super.key, this.onSeeAll});
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: WexText.titleM)),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text('عرض الكل', style: WexText.body.copyWith(color: WexColors.teal600, fontWeight: FontWeight.w500)),
            ),
          ),
      ]);
}

/// Label (muted) over value, used for key/value rows.
class InfoRow extends StatelessWidget {
  final String label;
  final Widget value;
  const InfoRow({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(label, style: WexText.bodyS)),
          const SizedBox(width: 12),
          Flexible(child: value),
        ]),
      );
}
