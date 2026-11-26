import 'package:flutter/material.dart';
import '../../core/design/colors.dart';

/// Stub — full order detail (countdown, bank accounts, proof upload, timeline) in M3.
class OrderDetailScreen extends StatelessWidget {
  final String orderNumber;
  const OrderDetailScreen({super.key, required this.orderNumber});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle, color: WexColors.success, size: 48),
            const SizedBox(height: 12),
            Text('تم إنشاء الطلب\n$orderNumber', textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('تفاصيل الدفع والتتبّع — M3', style: TextStyle(color: WexColors.textSecondary)),
          ]),
        ),
      );
}
