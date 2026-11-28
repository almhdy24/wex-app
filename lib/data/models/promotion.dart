import '../../app/env.dart';

enum PromoTheme { ink, teal, sun, paper }

enum PromoLayout { text, image, split }

enum PromoAction { product, category, filter, url, whatsapp, none }

PromoTheme _theme(String? s) => PromoTheme.values.firstWhere((e) => e.name == s, orElse: () => PromoTheme.ink);
PromoLayout _layout(String? s) => PromoLayout.values.firstWhere((e) => e.name == s, orElse: () => PromoLayout.text);
PromoAction _action(String? s) => PromoAction.values.firstWhere((e) => e.name == s, orElse: () => PromoAction.none);

class Promotion {
  final int id;
  final String placement;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final String? ctaLabel;
  final PromoAction actionType;
  final String? actionValue;
  final PromoLayout layout;
  final PromoTheme theme;
  final String? imageUrl;
  final String? imageAlt;
  final bool showCountdown;
  final DateTime? endsAt;

  const Promotion({
    required this.id,
    required this.placement,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.ctaLabel,
    this.actionType = PromoAction.none,
    this.actionValue,
    this.layout = PromoLayout.text,
    this.theme = PromoTheme.ink,
    this.imageUrl,
    this.imageAlt,
    this.showCountdown = false,
    this.endsAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> j) {
    String? s(String k) {
      final v = j[k]?.toString();
      return (v == null || v.isEmpty) ? null : v;
    }

    final img = s('image_url');
    return Promotion(
      id: ((j['id'] ?? 0) as num).round(),
      placement: (j['placement'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      subtitle: s('subtitle'),
      badgeText: s('badge_text'),
      ctaLabel: s('cta_label'),
      actionType: _action(j['action_type']?.toString()),
      actionValue: s('action_value'),
      layout: _layout(j['layout']?.toString()),
      theme: _theme(j['theme']?.toString()),
      imageUrl: img == null ? null : Env.assetUrl(img),
      imageAlt: s('image_alt'),
      showCountdown: j['show_countdown'] == true || j['show_countdown'] == 1,
      endsAt: DateTime.tryParse((j['ends_at'] ?? '').toString()),
    );
  }
}
