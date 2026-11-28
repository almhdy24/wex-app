import '../../app/env.dart';

class HeroSlide {
  final int id;
  final String title;
  final String subtitle;
  final String? imagePath;
  final String? buttonLabel;
  final String? link;
  const HeroSlide(
      {required this.id,
      required this.title,
      required this.subtitle,
      this.imagePath,
      this.buttonLabel,
      this.link});
  String get imageUrl => Env.assetUrl(imagePath ?? '');
  factory HeroSlide.fromJson(Map<String, dynamic> j) => HeroSlide(
        id: (j['id'] ?? 0) as int,
        title: (j['title'] ?? '').toString(),
        subtitle: (j['subtitle'] ?? '').toString(),
        imagePath: j['image']?.toString(),
        buttonLabel: j['button_label']?.toString(),
        link: j['link']?.toString(),
      );
}

class HomeSection {
  final int id;
  final String key;
  final String title;
  final String source;
  final String? sourceValue;
  final int limit;
  const HomeSection(
      {required this.id,
      required this.key,
      required this.title,
      required this.source,
      this.sourceValue,
      this.limit = 10});
  factory HomeSection.fromJson(Map<String, dynamic> j) => HomeSection(
        id: (j['id'] ?? 0) as int,
        key: (j['key'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        source: (j['source'] ?? '').toString(),
        sourceValue: j['source_value']?.toString(),
        limit: ((j['limit'] ?? 10) as num).round(),
      );
}

class FaqItem {
  final int id;
  final String question;
  final String answer;
  const FaqItem(
      {required this.id, required this.question, required this.answer});
  factory FaqItem.fromJson(Map<String, dynamic> j) => FaqItem(
        id: (j['id'] ?? 0) as int,
        question: (j['question'] ?? '').toString(),
        answer: (j['answer'] ?? '').toString(),
      );
}

class ContentPage {
  final String slug;
  final String title;
  final String body;
  const ContentPage(
      {required this.slug, required this.title, required this.body});
  factory ContentPage.fromJson(Map<String, dynamic> j) => ContentPage(
        slug: (j['slug'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        body: (j['body'] ?? '').toString(),
      );
}
