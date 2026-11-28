import 'package:flutter/material.dart';
import '../design/colors.dart';

/// Original, code-drawn illustrations (simple shapes in brand colours).
enum IllustrationKind { box, cart, search }

class WexIllustration extends StatelessWidget {
  final IllustrationKind kind;
  final double size;
  const WexIllustration(this.kind, {super.key, this.size = 132});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _IllustrationPainter(kind)),
      );
}

class _IllustrationPainter extends CustomPainter {
  final IllustrationKind kind;
  _IllustrationPainter(this.kind);

  @override
  void paint(Canvas c, Size s) {
    final w = s.width;
    final tint = Paint()..color = WexColors.primaryTint;
    final brand = Paint()..color = WexColors.primary;
    final violet = Paint()..color = WexColors.violet;
    final white = Paint()..color = Colors.white;
    // Soft backdrop blob + sparkles
    c.drawCircle(Offset(w / 2, w / 2), w * 0.46, tint);
    c.drawCircle(Offset(w * 0.16, w * 0.22), w * 0.035, violet);
    c.drawCircle(Offset(w * 0.86, w * 0.3), w * 0.025, brand);
    c.drawCircle(Offset(w * 0.8, w * 0.8), w * 0.04, tint);

    switch (kind) {
      case IllustrationKind.box:
        final body = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.26, w * 0.44, w * 0.48, w * 0.30),
            Radius.circular(w * 0.05));
        c.drawRRect(body, brand);
        final lid = RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.22, w * 0.34, w * 0.56, w * 0.13),
            Radius.circular(w * 0.04));
        c.drawRRect(lid, violet);
        c.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(w * 0.44, w * 0.52, w * 0.12, w * 0.035),
                Radius.circular(w * 0.02)),
            white..color = Colors.white.withValues(alpha: 0.85));
      case IllustrationKind.cart:
        final path = Path()
          ..moveTo(w * 0.24, w * 0.34)
          ..lineTo(w * 0.34, w * 0.34)
          ..lineTo(w * 0.40, w * 0.62)
          ..lineTo(w * 0.72, w * 0.62)
          ..lineTo(w * 0.78, w * 0.42)
          ..lineTo(w * 0.36, w * 0.42);
        c.drawPath(
            path,
            Paint()
              ..color = WexColors.primary
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.045
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round);
        c.drawCircle(Offset(w * 0.45, w * 0.73), w * 0.04, violet);
        c.drawCircle(Offset(w * 0.67, w * 0.73), w * 0.04, violet);
      case IllustrationKind.search:
        c.drawCircle(
            Offset(w * 0.46, w * 0.46),
            w * 0.17,
            Paint()
              ..color = WexColors.primary
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.05);
        c.drawLine(
            Offset(w * 0.58, w * 0.58),
            Offset(w * 0.74, w * 0.74),
            Paint()
              ..color = WexColors.violet
              ..strokeWidth = w * 0.06
              ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_IllustrationPainter old) => old.kind != kind;
}

/// Calm empty / status state: illustration, one warm line, one CTA.
class IllustratedEmpty extends StatelessWidget {
  final IllustrationKind kind;
  final String title;
  final String? body;
  final String? ctaLabel;
  final VoidCallback? onCta;
  const IllustratedEmpty(
      {super.key,
      this.kind = IllustrationKind.box,
      required this.title,
      this.body,
      this.ctaLabel,
      this.onCta});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            WexIllustration(kind),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(body!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      color: WexColors.textSecondary,
                      height: 1.6)),
            ],
            if (ctaLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onCta, child: Text(ctaLabel!)),
            ],
          ]),
        ),
      );
}

/// Animated check: circle scales in, then the tick draws.
class AnimatedCheck extends StatelessWidget {
  final double size;
  final Color color;
  const AnimatedCheck(
      {super.key, this.size = 72, this.color = WexColors.success});
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return CustomPaint(
          size: Size.square(size), painter: _CheckPainter(1, color));
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (_, t, __) => CustomPaint(
          size: Size.square(size), painter: _CheckPainter(t, color)),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double t;
  final Color color;
  _CheckPainter(this.t, this.color);
  @override
  void paint(Canvas c, Size s) {
    final w = s.width;
    final circleT = (t / 0.5).clamp(0.0, 1.0);
    c.drawCircle(
        Offset(w / 2, w / 2),
        w / 2 * Curves.elasticOut.transform(circleT).clamp(0.0, 1.1),
        Paint()..color = color);
    final tickT = ((t - 0.45) / 0.55).clamp(0.0, 1.0);
    if (tickT <= 0) return;
    final p = Path()
      ..moveTo(w * 0.28, w * 0.52)
      ..lineTo(w * 0.44, w * 0.67)
      ..lineTo(w * 0.73, w * 0.36);
    final m = p.computeMetrics().first;
    c.drawPath(
        m.extractPath(0, m.length * tickT),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.09
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_CheckPainter o) => o.t != t || o.color != color;
}
