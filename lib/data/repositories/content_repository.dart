import '../../core/network/api_client.dart';
import '../models/content.dart';

class ContentRepository {
  final ApiClient api;
  ContentRepository(this.api);

  Future<List<HeroSlide>> heroSlides() async {
    final env = await api.get('/hero-slides');
    return (env.data as List? ?? []).map((e) => HeroSlide.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<HomeSection>> homeSections() async {
    final env = await api.get('/home-sections');
    return (env.data as List? ?? []).map((e) => HomeSection.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<FaqItem>> faq() async {
    final env = await api.get('/faq');
    return (env.data as List? ?? []).map((e) => FaqItem.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<ContentPage> page(String slug) async {
    final env = await api.get('/pages/$slug');
    return ContentPage.fromJson(Map<String, dynamic>.from(env.data as Map));
  }
}
