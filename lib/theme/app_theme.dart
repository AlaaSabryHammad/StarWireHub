import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Palette (الوضع النهاري الاحترافي)
  static const Color lightBg = Color(0xFFF8FAFC);          // خلفية نظيفة ومريحة للعين Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);     // بطاقات بيضاء ناصعة
  static const Color lightCardHover = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);      // حدود ناعمة ودقيقة Slate 200
  static const Color lightBorderStrong = Color(0xFFCBD5E1);

  // Text Colors (Light Mode)
  static const Color textPrimary = Color(0xFF0F172A);      // نص عالي التباين Slate 900
  static const Color textSecondary = Color(0xFF475569);    // نص فرعي Slate 600
  static const Color textMuted = Color(0xFF94A3B8);        // نص خافت Slate 400

  // Brand & Accent Colors
  static const Color primary = Color(0xFF4F46E5);          // Indigo احترافي
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primarySurface = Color(0xFFEEF2FF);   // خلفية باهتة للأزرار والشارات
  static const Color accentCyan = Color(0xFF0284C7);
  static const Color accentEmerald = Color(0xFF059669);
  static const Color accentEmeraldSurface = Color(0xFFECFDF5);
  static const Color accentAmber = Color(0xFFD97706);
  static const Color accentAmberSurface = Color(0xFFFFFBEB);
  static const Color accentRose = Color(0xFFE11D48);
  static const Color accentRoseSurface = Color(0xFFFFF1F2);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentPurpleSurface = Color(0xFFF5F3FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient trendingGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient alternativeGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ألوان لغات البرمجة بدقة وتناسق
  static Color getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return const Color(0xFF00A29C);
      case 'python':
        return const Color(0xFF2B5B84);
      case 'typescript':
        return const Color(0xFF2563EB);
      case 'javascript':
        return const Color(0xFFD97706);
      case 'rust':
        return const Color(0xFFB45309);
      case 'go':
        return const Color(0xFF0284C7);
      case 'c++':
      case 'cpp':
        return const Color(0xFFDB2777);
      case 'swift':
        return const Color(0xFFEA580C);
      case 'kotlin':
        return const Color(0xFF7C3AED);
      case 'java':
        return const Color(0xFFB45309);
      case 'vue':
        return const Color(0xFF059669);
      case 'html':
        return const Color(0xFFE11D48);
      case 'css':
        return const Color(0xFF4F46E5);
      case 'shell':
      case 'bash':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF64748B);
    }
  }

  // الثيم النهاري الأساسي مع تخصيص الخط العربي الأفضل
  static ThemeData get lightTheme => getTheme(fontKey: 'cairo');

  static ThemeData getTheme({String fontKey = 'cairo'}) {
    String? fontFamily;

    switch (fontKey.toLowerCase()) {
      case 'tajawal':
        fontFamily = GoogleFonts.tajawal().fontFamily;
        break;
      case 'almarai':
        fontFamily = GoogleFonts.almarai().fontFamily;
        break;
      case 'alexandria':
        fontFamily = GoogleFonts.alexandria().fontFamily;
        break;
      case 'cairo':
      default:
        fontFamily = GoogleFonts.cairo().fontFamily;
        break;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accentCyan,
        surface: lightSurface,
        onSurface: textPrimary,
      ),
      fontFamily: fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
      ),
    );
  }
}
