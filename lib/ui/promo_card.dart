import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_controller.dart';
import '../core/design/colors.g.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';
import '../core/format/dates.dart';
import '../data/models/promotion.dart';
import 'gradients.dart';

/// Banner height scales with the text scale (172 at 1.0, up to 1.4x) so large fonts never overflow.
double promoHeight(BuildContext context, [double base = 172]) =>
    base * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4);

/// Banner: 172px (2:1 at 360), radius 20, padding 20. Themes: ink | teal | sun | paper.
/// Layouts: text | image (scrim on the text side) | split (text 60% / image 40%).
class PromoCard extends ConsumerStatefulWidget {
  final Promotion promo;
  final VoidCallback onTap;
  final double height;
  const PromoCard({super.key, required this.promo, required this.onTap, this.height = 172});
  @override
  ConsumerState<PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends ConsumerState<PromoCard> {
  Timer? _tick;
  int _left = 0;

  @override
  void initState() {
    super.initState();
    final end = widget.promo.endsAt;
    if (widget.promo.showCountdown && end != null) {
      _left = ref.read(serverTimeApiProvider).serverTime.secondsUntil(end);
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _left = ref.read(serverTimeApiProvider).serverTime.secondsUntil(end));
        if (_left <= 0) _tick?.cancel();
      });
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  ({Color bg, Color fg, Color sub, Color ctaBg, Color ctaFg, Color badgeBg, Color badgeFg, bool border}) get _c =>
      switch (widget.promo.theme) {
        PromoTheme.ink => (
            bg: WexColors.ink900, fg: WexColors.surface, sub: WexColors.onInkMuted, ctaBg: WexColors.sun500,
            ctaFg: WexColors.ink900, badgeBg: WexColors.sun500, badgeFg: WexColors.ink900, border: false),
        PromoTheme.teal => (
            bg: WexColors.teal700, fg: WexColors.surface, sub: WexColors.teal100, ctaBg: WexColors.surface,
            ctaFg: WexColors.ink900, badgeBg: WexColors.sun500, badgeFg: WexColors.ink900, border: false),
        PromoTheme.sun => (
            bg: WexColors.sun500, fg: WexColors.ink900, sub: WexColors.ink800, ctaBg: WexColors.ink900,
            ctaFg: WexColors.surface, badgeBg: WexColors.ink800, badgeFg: WexColors.surface, border: false),
        PromoTheme.paper => (
            bg: WexColors.sunken, fg: WexColors.ink900, sub: WexColors.muted, ctaBg: WexColors.teal600,
            ctaFg: WexColors.surface, badgeBg: WexColors.sun500, badgeFg: WexColors.ink900, border: true),
      };

  @override
  Widget build(BuildContext context) {
    final p = widget.promo;
    final c = _c;
    final hasImage = p.imageUrl != null && p.layout != PromoLayout.text;
    final textFraction = p.layout == PromoLayout.split && hasImage ? 0.6 : 1.0;

    final text = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (p.badgeText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: c.badgeBg, borderRadius: BorderRadius.circular(Radii.tag)),
            child: Text(p.badgeText!, style: WexText.label.copyWith(color: c.badgeFg, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        if (p.badgeText != null) const SizedBox(height: 8),
        Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: WexText.titleL.copyWith(color: c.fg, height: 28 / 22)),
        if (p.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(p.subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: WexText.bodyS.copyWith(color: c.sub)),
        ],
        const Spacer(),
        Row(children: [
          if (p.ctaLabel != null)
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.ctaBg, borderRadius: BorderRadius.circular(Radii.control)),
              child: Text(p.ctaLabel!, style: WexText.body.copyWith(color: c.ctaFg, fontWeight: FontWeight.w600)),
            ),
          if (p.showCountdown && p.endsAt != null && _left > 0) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text('ينتهي بعد ${formatCountdown(Duration(seconds: _left), alwaysHours: true)}',
                    maxLines: 1,
                    style: WexText.label.copyWith(color: c.sub, fontFeatures: const [FontFeature.tabularFigures()])),
              ),
            ),
          ],
        ]),
      ]),
    );

    return Semantics(
      button: true,
      label: [p.title, if (p.subtitle != null) p.subtitle!].join('، '),
      child: Material(
        color: c.bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: c.border ? const BorderSide(color: WexColors.line) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: SizedBox(
            height: promoHeight(context, widget.height),
            child: Stack(children: [
              if (p.theme == PromoTheme.ink) const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: Gradients.hero))),
              if (hasImage && p.layout == PromoLayout.image) ...[
                Positioned.fill(
                  child: CachedNetworkImage(imageUrl: p.imageUrl!, fit: BoxFit.cover, memCacheWidth: 900, fadeInDuration: Motion.base),
                ),
                // Scrim only on the text side (solid, no gradient).
                PositionedDirectional(
                  top: 0, bottom: 0, start: 0,
                  child: FractionallySizedBox(widthFactor: 0.65, child: ColoredBox(color: WexColors.ink900.withValues(alpha: 0.4))),
                ),
              ],
              if (hasImage && p.layout == PromoLayout.split)
                PositionedDirectional(
                  top: 12, bottom: 12, end: 12,
                  child: FractionallySizedBox(
                    widthFactor: 0.34,
                    child: CachedNetworkImage(imageUrl: p.imageUrl!, fit: BoxFit.contain, memCacheWidth: 500, fadeInDuration: Motion.base),
                  ),
                ),
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: textFraction,
                  child: text,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// 72px compact promo row (cart_promo).
class PromoCompact extends StatelessWidget {
  final Promotion promo;
  final VoidCallback onTap;
  const PromoCompact({super.key, required this.promo, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final dark = promo.theme == PromoTheme.ink || promo.theme == PromoTheme.teal;
    final bg = switch (promo.theme) {
      PromoTheme.ink => WexColors.ink900,
      PromoTheme.teal => WexColors.teal700,
      PromoTheme.sun => WexColors.sun500,
      PromoTheme.paper => WexColors.sunken,
    };
    final fg = dark ? WexColors.surface : WexColors.ink900;
    return Semantics(
      button: true,
      label: promo.title,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.card),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(promo.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: WexText.body.copyWith(color: fg, fontWeight: FontWeight.w600)),
                  if (promo.subtitle != null)
                    Text(promo.subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: WexText.bodyS.copyWith(color: fg.withValues(alpha: 0.8))),
                ]),
              ),
              if (promo.ctaLabel != null) ...[
                const SizedBox(width: 12),
                Text(promo.ctaLabel!, style: WexText.body.copyWith(color: fg, fontWeight: FontWeight.w600)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
