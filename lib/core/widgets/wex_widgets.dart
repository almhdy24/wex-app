import '../../ui/gradients.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/colors.g.dart';
import '../design/spacing.dart';
import '../strings.dart';
import '../design/typography.dart';
import '../utils/launchers.dart';
import 'whatsapp_glyph.dart';

/// Card with hairline border + soft layered shadow.
class WexCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  const WexCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(Sp.x7),
      this.onTap,
      this.radius = 18});
  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: WexColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: WexColors.border),
        boxShadow: const [
          BoxShadow(
              color: WexColors.shadowSoft, blurRadius: 18, offset: Offset(0, 8))
        ],
      ),
      child: child,
    );
    if (onTap == null) return body;
    return InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(radius), child: body);
  }
}

/// Primary/secondary button with press-scale + haptic.
class WexButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool secondary;
  final Widget? icon;
  final bool expand;
  const WexButton(this.label,
      {super.key,
      this.onPressed,
      this.loading = false,
      this.secondary = false,
      this.icon,
      this.expand = true});
  @override
  State<WexButton> createState() => _WexButtonState();
}

class _WexButtonState extends State<WexButton> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final child = widget.loading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.4, color: Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 10)
                ],
                Flexible(
                    child: Text(widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: widget.secondary
                                ? WexColors.primary
                                : Colors.white))),
              ]);
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: () => setState(() => _down = false),
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.5,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: widget.expand ? double.infinity : null,
            height: 54,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: widget.secondary ? null : Gradients.hero,
              color: widget.secondary ? Colors.white : null,
              borderRadius: BorderRadius.circular(16),
              border:
                  widget.secondary ? Border.all(color: WexColors.border) : null,
              boxShadow: widget.secondary
                  ? null
                  : const [
                      BoxShadow(
                          color: Color(0x332E3BC4),
                          blurRadius: 16,
                          offset: Offset(0, 6))
                    ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class WexBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const WexBadge(this.text,
      {super.key, this.bg = WexColors.primary, this.fg = Colors.white});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(Radii.pill)),
        child: Text(text,
            style: TextStyle(
                color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

class WexChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  const WexChip(this.text, {super.key, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: WexColors.iceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: WexColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: WexColors.textSecondary),
            const SizedBox(width: 4)
          ],
          LtrText(text,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: WexColors.textPrimary)),
        ]),
      );
}

class WexSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;
  const WexSectionHeader(this.title,
      {super.key, this.onSeeAll, this.seeAllLabel = Ar.seeAll});
  @override
  Widget build(BuildContext context) => Row(children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: Text(seeAllLabel)),
      ]);
}

class WexEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final String? ctaLabel;
  final VoidCallback? onCta;
  const WexEmptyState(
      {super.key,
      required this.icon,
      required this.title,
      this.body,
      this.ctaLabel,
      this.onCta});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Sp.x9),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: WexColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle),
              child: Icon(icon, size: 38, color: WexColors.primary),
            ),
            const SizedBox(height: Sp.x7),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(body!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: WexColors.textSecondary, height: 1.6)),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: Sp.x7),
              WexButton(ctaLabel!, onPressed: onCta, expand: false),
            ],
          ]),
        ),
      );
}

/// English/Latin text rendered LTR but right-aligned inside RTL (product names).
class LtrText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  const LtrText(this.text, {super.key, this.style, this.maxLines});
  bool get _isLatin =>
      RegExp(r'^[\x00-\x7F\s\-_.,()/]+$').hasMatch(text.trim());
  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
        textDirection: _isLatin ? TextDirection.ltr : TextDirection.rtl,
        textAlign: _isLatin ? TextAlign.right : TextAlign.start,
        style: style,
      );
}


/// "Can't find it?" card → WhatsApp request. Shared by home, store and empty states.
class WexHelpCard extends StatelessWidget {
  final String whatsapp;
  const WexHelpCard({super.key, required this.whatsapp});
  @override
  Widget build(BuildContext context) {
    if (whatsapp.isEmpty) return const SizedBox.shrink();
    return WexCard(
      onTap: () => openWhatsApp(whatsapp, text: Ar.waLooking),
      child: Row(children: [
        Container(
          width: 46, height: 46, alignment: Alignment.center,
          decoration: BoxDecoration(color: WexColors.successBg, borderRadius: BorderRadius.circular(14)),
          child: const WhatsAppGlyph(size: 24, color: WexColors.success),
        ),
        const SizedBox(width: Sp.x6),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(Ar.notFoundTitle, style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 2),
          Text(Ar.notFoundBody, style: WexText.caption),
        ])),
        const Icon(Icons.arrow_back_rounded, color: WexColors.primary),
      ]),
    );
  }
}
