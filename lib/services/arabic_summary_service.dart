import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/github_repo.dart';

class ArabicSummaryService {
  static const String _cachePrefix = 'ar_summary_';

  // ترجمة نص إنجليزي إلى العربية باستخدام ترجمة سريعة ومجانية بدون مفاتيح
  Future<String> translateToArabic(String text) async {
    if (text.trim().isEmpty) return '';

    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=ar&dt=t&q=${Uri.encodeComponent(text)}',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 7));
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          final buffer = StringBuffer();
          for (final item in decoded[0]) {
            if (item is List && item.isNotEmpty && item[0] is String) {
              buffer.write(item[0]);
            }
          }
          final result = buffer.toString().trim();
          if (result.isNotEmpty) return result;
        }
      }
    } catch (_) {
      // في حال عدم توفر النت، سيتم الاعتماد على الشرح التوليدي المحلي
    }

    return '';
  }

  // توليد ملخص عربي شامل ومفهوم للمشروع مع حفظه محلياً
  Future<String> getArabicSummary(GithubRepo repo) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix${repo.repo}';

    final cached = prefs.getString(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // 1. ترجمة النبذة والوصف الأساسي
    final textToTranslate = repo.line != null && repo.line!.isNotEmpty
        ? repo.line!
        : repo.description;

    String translatedText = await translateToArabic(textToTranslate);

    // 2. صياغة ملخص سياقي عربي ذكي
    final summaryBuffer = StringBuffer();

    if (translatedText.isNotEmpty) {
      summaryBuffer.writeln(translatedText);
      summaryBuffer.writeln();
    } else {
      summaryBuffer.writeln(
        'مشروع مفتوح المصدر في تصنيف (${_translateCategory(repo.category)}) مبني بلغة ${repo.language}.',
      );
      summaryBuffer.writeln();
    }

    // إضافة سياق البدائل إن وجدت
    if (repo.alternativeTo.isNotEmpty) {
      final alts = repo.alternativeTo.join(' و ');
      summaryBuffer.writeln(
        '💡 الهدف الأساسي: يوفر هذا المشروع بديلاً مجانياً ومفتوح المصدر لتطبيق ($alts)، مما يتيح لك التحكم الكامل في بياناتك واستضافتها ذاتياً دون الحاجة لدفع اشتراكات تجارية.',
      );
      summaryBuffer.writeln();
    }

    // إضافة سياق الرواج إن كان تريند
    if (repo.starsThisWeek > 30) {
      summaryBuffer.writeln(
        '🔥 شعبية متصاعدة: حقق المشروع اهتماماً استثنائياً هذا الأسبوع بإضافة +${repo.starsThisWeek} نجمة جديدة على GitHub.',
      );
      summaryBuffer.writeln();
    }

    // إضافة تفاصيل المنصات إن وجدت
    if (repo.platforms.isNotEmpty) {
      summaryBuffer.writeln(
        '🖥️ الأنظمة المدعومة: يعمل على أنظمة (${repo.platforms.join('، ')}).',
      );
    }

    final finalSummary = summaryBuffer.toString().trim();

    // حفظ في الكاش لتصفحه لاحقاً بدون إنترنت
    if (finalSummary.isNotEmpty) {
      await prefs.setString(cacheKey, finalSummary);
    }

    return finalSummary;
  }

  String _translateCategory(String category) {
    switch (category.toLowerCase()) {
      case 'developer tools':
        return 'أدوات المطورين';
      case 'ai & machine learning':
      case 'ai':
        return 'الذكاء الاصطناعي وتعلم الآلة';
      case 'web & mobile':
        return 'تطوير الويب والهواتف';
      case 'databases':
        return 'قواعد البيانات';
      case 'cloud & ops':
      case 'devops':
        return 'السحابة والعمليات السحابية';
      case 'security':
        return 'الأمان وحماية البيانات';
      default:
        return category;
    }
  }
}

