import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/typography.dart';
import 'buttons.dart';
import 'icons.dart';

/// 48px line icon + two lines of text + one action. No illustrations.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState({super.key, this.icon = LucideIcons.packageOpen, required this.title, this.body, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(icon, size: 48, color: WexColors.muted),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: WexText.titleM),
            if (body != null) ...[
              const SizedBox(height: 4),
              Text(body!, textAlign: TextAlign.center, style: WexText.bodyS),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(actionLabel!, onPressed: onAction, expand: false),
            ],
          ]),
        ),
      );
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorState({super.key, this.message = 'تعذّر التحميل. تحقّق من الاتصال وحاول مرة أخرى.', required this.onRetry});
  @override
  Widget build(BuildContext context) => EmptyState(
        icon: LucideIcons.wifiOff,
        title: message,
        actionLabel: 'إعادة المحاولة',
        onAction: onRetry,
      );
}
