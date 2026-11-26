import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../utils/formatters.dart';

/// Price: LTR-isolated amount + ج.س unit (web Price.jsx parity). Never shows AED.
class PriceText extends StatelessWidget {
  final num value;
  final double size;
  final Color color;
  final FontWeight weight;
  const PriceText(
    this.value, {
    super.key,
    this.size = 20,
    this.color = WexColors.royal,
    this.weight = FontWeight.w800,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: size, color: color, fontWeight: weight,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Semantics(
      label: '${formatSdgAmount(value)} $sdgUnit',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(formatSdgAmount(value), style: style),
          ),
          const SizedBox(width: 4),
          Text(sdgUnit, style: style.copyWith(fontSize: size * 0.72, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
