import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/github_repo.dart';

class ApiService {
  static const String dataUrl =
      'https://raw.githubusercontent.com/boffti/starwire/main/data/repos.json';
  static const String cacheKey = 'cached_starwire_repos';
  static const String lastFetchKey = 'cached_starwire_last_fetch';
  static const String bookmarksKey = 'starwire_bookmarks';

  // جلب المستودعات مع دعم الـ Cache التلقائي في حال انقطاع النت
  Future<List<GithubRepo>> fetchRepositories({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedJson);
          // إذا كان الكاش متوفراً نبدأ بتقديمه فوراً ثم نحدث في الخلفية إن لزم
          _refreshCacheInBackground();
          return decoded.map((e) => GithubRepo.fromJson(e)).toList();
        } catch (_) {}
      }
    }

    try {
      final response = await http
          .get(Uri.parse(dataUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
        // حفظ الكاش
        await prefs.setString(cacheKey, response.body);
        await prefs.setString(lastFetchKey, DateTime.now().toIso8601String());
        return decoded.map((e) => GithubRepo.fromJson(e)).toList();
      } else {
        throw Exception('رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      // محاولة استرجاع الكاش القديم عند انقطاع الاتصال
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        return decoded.map((e) => GithubRepo.fromJson(e)).toList();
      }
      throw Exception('تعذر تحميل البيانات، يرجى التحقق من اتصال الإنترنت: $e');
    }
  }

  void _refreshCacheInBackground() async {
    try {
      final response = await http
          .get(Uri.parse(dataUrl))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, response.body);
        await prefs.setString(lastFetchKey, DateTime.now().toIso8601String());
      }
    } catch (_) {}
  }

  // إدارة المفضلة (Bookmarks)
  Future<List<String>> getBookmarkedRepoIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(bookmarksKey) ?? [];
  }

  Future<void> toggleBookmark(String repoFullName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(bookmarksKey) ?? [];
    if (current.contains(repoFullName)) {
      current.remove(repoFullName);
    } else {
      current.add(repoFullName);
    }
    await prefs.setStringList(bookmarksKey, current);
  }
}

