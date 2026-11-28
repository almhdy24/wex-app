import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/spacing.dart';
import '../core/design/typography.dart';

enum TagKind { neutral, sun, success, danger, teal }

/// Compact label. [dense] = 11px card tag; default = 28px tag used in a Wrap (identical heights).
class AppTag extends StatelessWidget {
  final String label;
  final TagKind kind;
  final bool dense;
  const AppTag(this.label, {super.key, this.kind = TagKind.neutral, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (kind) {
      TagKind.sun => (WexColors.sun50, WexColors.sun700, WexColors.sun100),
      TagKind.success => (WexColors.successBg, WexColors.successText, WexColors.successBg),
      TagKind.danger => (WexColors.dangerBg, WexColors.dangerText, WexColors.dangerBg),
      TagKind.teal => (WexColors.teal50, WexColors.teal700, WexColors.teal100),
      TagKind.neutral => (WexColors.surface, WexColors.ink900, WexColors.line),
    };
    return Container(
      // No `alignment`: it would stretch the tag to the full available width.
      constraints: BoxConstraints(minHeight: dense ? 22 : 28),
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.tag),
        border: Border.all(color: border),
      ),
      child: Text(label,
          maxLines: 1,
          softWrap: false,
          style: WexText.label.copyWith(color: fg, fontSize: dense ? 11 : 12, height: 16 / 12, fontWeight: FontWeight.w500)),
    );
  }
}

/// Order / payment status pill (semantic colours only).
enum StatusKind { pending, review, confirmed, done, bad, neutral }

class StatusPill extends StatelessWidget {
  final String label;
  final StatusKind kind;
  const StatusPill(this.label, {super.key, this.kind = StatusKind.neutral});
  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      StatusKind.pending => (WexColors.sun50, WexColors.sun700),
      StatusKind.review => (WexColors.teal50, WexColors.teal700),
      StatusKind.confirmed => (WexColors.teal50, WexColors.teal700),
      StatusKind.done => (WexColors.successBg, WexColors.successText),
      StatusKind.bad => (WexColors.dangerBg, WexColors.dangerText),
      StatusKind.neutral => (WexColors.sunken, WexColors.muted),
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.tag)),
      child: Text(label, maxLines: 1, softWrap: false, style: WexText.label.copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
