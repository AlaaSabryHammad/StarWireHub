import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class FontOption {
  final String key;
  final String nameArabic;
  final String description;

  const FontOption({
    required this.key,
    required this.nameArabic,
    required this.description,
  });
}

class ThemeProvider extends ChangeNotifier {
  static const String _fontKeyPref = 'starwire_app_font_family';

  // الخط الافتراضي الفخم هو كايرو
  String _currentFont = 'cairo';

  static const List<FontOption> availableFonts = [
    FontOption(
      key: 'cairo',
      nameArabic: 'كايرو (Cairo)',
      description: 'الخط الأحدث والأكثر تميزاً في التطبيقات التقنية بتصميم هندسي فخم',
    ),
    FontOption(
      key: 'tajawal',
      nameArabic: 'تجوّل (Tajawal)',
      description: 'خط ناعم وعصري ذو انسيابية عالية مصمم خصيصاً لواجهات المستخدم',
    ),
    FontOption(
      key: 'almarai',
      nameArabic: 'المراعي (Almarai)',
      description: 'خط عربي رصين ومريح للعين يمنح القراءة وضوحاً فائقاً',
    ),
    FontOption(
      key: 'alexandria',
      nameArabic: 'الإسكندرية (Alexandria)',
      description: 'خط ذو طابع تقني حديث وأشكال هندسية فريدة للمطورين',
    ),
  ];

  String get currentFont => _currentFont;

  ThemeData get themeData => AppTheme.getTheme(fontKey: _currentFont);

  ThemeProvider() {
    _loadFontPreference();
  }

  Future<void> _loadFontPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFont = prefs.getString(_fontKeyPref);
      if (savedFont != null && savedFont.isNotEmpty && _isValidFont(savedFont)) {
        _currentFont = savedFont;
        notifyListeners();
      }
    } catch (_) {}
  }

  bool _isValidFont(String font) {
    return availableFonts.any((f) => f.key == font);
  }

  Future<void> setFont(String fontKey) async {
    if (_currentFont == fontKey) return;
    _currentFont = fontKey;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fontKeyPref, fontKey);
    } catch (_) {}
  }
}

