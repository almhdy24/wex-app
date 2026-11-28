import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';

/// Solid teal primary (52px). The label keeps its width while [loading] (no layout jump).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final bool sun; // promo CTA only
  const PrimaryButton(this.label, {super.key, this.onPressed, this.icon, this.loading = false, this.expand = true, this.sun = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final fg = sun ? WexColors.ink900 : WexColors.surface;
    final content = Stack(alignment: Alignment.center, children: [
      Opacity(
        opacity: loading ? 0 : 1,
        child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 20, color: enabled ? fg : WexColors.disabled), const SizedBox(width: 8)],
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      ),
      if (loading)
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: fg)),
    ]);
    final style = sun
        ? FilledButton.styleFrom(backgroundColor: WexColors.sun500, foregroundColor: WexColors.ink900)
        : null;
    return SizedBox(
      width: expand ? double.infinity : null,
      height: 52,
      child: FilledButton(onPressed: enabled ? onPressed : null, style: style, child: content),
    );
  }
}

/// 1px line border, ink text (52px, or 44px when [compact]).
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;
  final bool expand;
  const SecondaryButton(this.label, {super.key, this.onPressed, this.icon, this.compact = false, this.expand = true});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: expand ? double.infinity : null,
        height: compact ? 44 : 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(minimumSize: Size(0, compact ? 44 : 52), padding: const EdgeInsets.symmetric(horizontal: 12)),
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 20, color: WexColors.ink900), const SizedBox(width: 8)],
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: WexText.body.copyWith(fontWeight: FontWeight.w600))),
          ]),
        ),
      );
}

/// Square icon-only button (44px default) with a line border.
class IconSquareButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;
  const IconSquareButton({super.key, required this.icon, required this.semanticLabel, this.onPressed, this.size = 44, this.iconColor});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semanticLabel,
        child: SizedBox(
          width: size,
          height: size,
          child: Material(
            color: WexColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.control),
              side: const BorderSide(color: WexColors.line),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.control),
              onTap: onPressed,
              child: Icon(icon, size: 22, color: iconColor ?? WexColors.ink900),
            ),
          ),
        ),
      );
}
