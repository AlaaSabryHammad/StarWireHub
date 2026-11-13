import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/github_live_details.dart';

class GithubService {
  static const Map<String, String> _headers = {
    'Accept': 'application/vnd.github.v3+json',
    'User-Agent': 'StarwireHub-App',
  };

  // جلب البيانات الحية المباشرة من GitHub API
  Future<GithubLiveDetails?> fetchLiveRepoDetails(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gh_details_$fullName';

    // فحص الكاش أولاً
    final cachedStr = prefs.getString(cacheKey);
    if (cachedStr != null) {
      try {
        final decoded = jsonDecode(cachedStr) as Map<String, dynamic>;
        return GithubLiveDetails.fromJson(decoded);
      } catch (_) {}
    }

    try {
      final repoUrl = Uri.parse('https://api.github.com/repos/$fullName');
      final releaseUrl = Uri.parse('https://api.github.com/repos/$fullName/releases/latest');

      final repoFuture = http.get(repoUrl, headers: _headers).timeout(const Duration(seconds: 8));
      final releaseFuture = http.get(releaseUrl, headers: _headers).timeout(const Duration(seconds: 5));

      final results = await Future.wait([repoFuture, releaseFuture]);
      final repoRes = results[0];
      final releaseRes = results[1];

      if (repoRes.statusCode == 200) {
        final repoJson = jsonDecode(utf8.decode(repoRes.bodyBytes)) as Map<String, dynamic>;
        Map<String, dynamic>? releaseJson;
        if (releaseRes.statusCode == 200) {
          try {
            releaseJson = jsonDecode(utf8.decode(releaseRes.bodyBytes)) as Map<String, dynamic>;
          } catch (_) {}
        }

        final details = GithubLiveDetails.fromJson(repoJson, releaseJson: releaseJson);
        // حفظ في الكاش
        await prefs.setString(cacheKey, repoRes.body);
        return details;
      }
    } catch (_) {}

    return null;
  }

  // جلب ملف README.md مباشرة
  Future<String?> fetchReadme(String fullName, {String defaultBranch = 'main'}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gh_readme_$fullName';

    final cachedReadme = prefs.getString(cacheKey);
    if (cachedReadme != null && cachedReadme.isNotEmpty) {
      return cachedReadme;
    }

    // المحاولة 1: raw.githubusercontent.com على الفرع الرئيسي (بدون أي Rate Limit)
    final branches = [defaultBranch, 'main', 'master'];
    for (final b in branches.toSet()) {
      try {
        final rawUrl = Uri.parse('https://raw.githubusercontent.com/$fullName/$b/README.md');
        final response = await http.get(rawUrl).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final content = utf8.decode(response.bodyBytes);
          if (content.trim().isNotEmpty) {
            await prefs.setString(cacheKey, content);
            return content;
          }
        }
      } catch (_) {}
    }

    // المحاولة 2: عبر GitHub API الرسمي للـ Readme
    try {
      final apiUrl = Uri.parse('https://api.github.com/repos/$fullName/readme');
      final response = await http.get(
        apiUrl,
        headers: {
          ..._headers,
          'Accept': 'application/vnd.github.raw',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final content = utf8.decode(response.bodyBytes);
        if (content.trim().isNotEmpty) {
          await prefs.setString(cacheKey, content);
          return content;
        }
      }
    } catch (_) {}

    return null;
  }
}

