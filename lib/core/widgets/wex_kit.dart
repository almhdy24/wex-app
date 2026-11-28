import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/spacing.dart';
import '../design/tones.dart';

/// 44dp icon square, radius 14, filled with the tone's tint.
class TintIcon extends StatelessWidget {
  final IconData icon;
  final Tone tone;
  final double size;
  const TintIcon(this.icon,
      {super.key, this.tone = Tone.brand, this.size = 44});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: tone.bg, borderRadius: BorderRadius.circular(Radii.icon)),
        child: Icon(icon, size: size * 0.5, color: tone.fg),
      );
}

/// Status pill (height 28) with an optional leading dot.
class StatusPill extends StatelessWidget {
  final String label;
  final Tone tone;
  final bool dot;
  const StatusPill(this.label,
      {super.key, this.tone = Tone.neutral, this.dot = true});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: tone.bg, borderRadius: BorderRadius.circular(Radii.pill)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot) ...[
            Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: tone.fg, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                  color: tone.fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.1)),
        ]),
      );
}

/// Small count chip; the number cross-fades/scale-bumps when it changes.
class CountChip extends StatelessWidget {
  final int count;
  final bool selected;
  const CountChip(this.count, {super.key, this.selected = false});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 22),
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              selected ? Colors.white.withValues(alpha: 0.22) : Tone.neutral.bg,
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Text('$count',
              key: ValueKey(count),
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : WexColors.textSecondary)),
        ),
      );
}

/// Filter chip (height 40): tint when idle, brand fill when selected, with a live count.
class CountFilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;
  const CountFilterChip(
      {super.key,
      required this.label,
      this.count,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? WexColors.primary : WexColors.white,
            border: Border.all(
                color: selected ? WexColors.primary : WexColors.border),
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : WexColors.textPrimary)),
            if (count != null) ...[
              const SizedBox(width: 8),
              CountChip(count!, selected: selected),
            ],
          ]),
        ),
      );
}

/// The one "hero moment" of a screen: brand gradient with soft decorative circles (8% white).
class HeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? radius;
  const HeroCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(20),
      this.radius});
  @override
  Widget build(BuildContext context) {
    final r = radius ?? BorderRadius.circular(Radii.card24);
    return Container(
      decoration: BoxDecoration(
        gradient: WexColors.gradBrand,
        borderRadius: r,
        boxShadow: const [
          BoxShadow(
              color: Color(0x333E4EE8), blurRadius: 24, offset: Offset(0, 10))
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(children: [
          PositionedDirectional(top: -40, end: -30, child: _circle(140)),
          PositionedDirectional(bottom: -50, start: -20, child: _circle(110)),
          Padding(padding: padding, child: child),
        ]),
      ),
    );
  }

  Widget _circle(double d) => IgnorePointer(
        child: Container(
            width: d,
            height: d,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08))),
      );
}

/// Calm 1px-bordered card (radius 24); pass [soft] for the single hero/primary card shadow.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool soft;
  final Color? color;
  const SurfaceCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.onTap,
      this.soft = false,
      this.color});
  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? WexColors.white,
        borderRadius: BorderRadius.circular(Radii.card24),
        border: Border.all(color: WexColors.border),
        boxShadow: soft
            ? const [
                BoxShadow(
                    color: WexColors.shadowSoft,
                    blurRadius: 20,
                    offset: Offset(0, 8))
              ]
            : null,
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.card24),
          child: box),
    );
  }
}
