import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/typography.dart';

/// Brand symbol drawn in code (64-unit squircle, white W polyline, sun dot).
class BrandSymbol extends StatelessWidget {
  final double size;
  const BrandSymbol({super.key, this.size = 28});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: _SymbolPainter()));
}

class _SymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 64;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(18 * k)),
      Paint()..color = WexColors.teal600,
    );
    final path = Path()
      ..moveTo(13 * k, 19 * k)
      ..lineTo(23 * k, 45 * k)
      ..lineTo(32 * k, 27 * k)
      ..lineTo(41 * k, 45 * k)
      ..lineTo(51 * k, 19 * k);
    canvas.drawPath(
      path,
      Paint()
        ..color = WexColors.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.4 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(Offset(51 * k, 19 * k), 5.4 * k, Paint()..color = WexColors.sun500);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Symbol + wordmark.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        const BrandSymbol(),
        const SizedBox(width: 8),
        Text('ويكس تكنولوجي', style: WexText.titleM.copyWith(fontWeight: FontWeight.w700)),
      ]);
}
