import 'hive_service.dart';
import 'ai_service.dart';
import 'user_service.dart';

class BlogService {
  static const String articlesKey = 'articles';

  static List<Map<String, dynamic>> getAllArticles() {
    final box = HiveService.blogBox;
    final data = box.get(articlesKey, defaultValue: []);
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  static Future<void> saveArticle(Map<String, dynamic> article) async {
    final box = HiveService.blogBox;
    final articles = getAllArticles();
    // On l'ajoute au début pour qu'il soit le plus récent
    articles.insert(0, article);
    await box.put(articlesKey, articles);
  }

  static Future<bool> shouldGenerateNewBlog() async {
    final articles = getAllArticles();
    if (articles.isEmpty) return true;

    final lastDate = DateTime.parse(articles.first['date']);
    final now = DateTime.now();

    // On génère un nouvel article si le dernier date de plus de 24h
    return now.difference(lastDate).inHours >= 24;
  }

  static Future<Map<String, dynamic>?> generateDailyBlog() async {
    try {
      final user = UserService.getUser();
      final blogData = await AIService.generateBlogContent(user);

      await saveArticle(blogData);
      return blogData;
    } catch (e) {
      print('Error in generateDailyBlog: $e');
      return null;
    }
  }
}
