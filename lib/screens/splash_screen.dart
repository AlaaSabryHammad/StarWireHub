import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/repo_provider.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  String _loadingMessage = 'جارٍ تشغيل محرك الاكتشاف...';

  @override
  void initState() {
    super.initState();

    // 1. متحكم نبض الأيقونة وحلقات الإشعاع
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2. متحكم شريط التقدم السلس (Progress Bar)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    )..addListener(() {
        final val = _progressAnimation.value;
        if (val < 0.35) {
          if (_loadingMessage != 'جارٍ تشغيل محرك الاكتشاف...') {
            setState(() => _loadingMessage = 'جارٍ تشغيل محرك الاكتشاف...');
          }
        } else if (val < 0.75) {
          if (_loadingMessage != 'مزامنة أحدث المشاريع والبدائل الرائجة...') {
            setState(() => _loadingMessage = 'مزامنة أحدث المشاريع والبدائل الرائجة...');
          }
        } else {
          if (_loadingMessage != 'أهلاً بك! جاهز للاستكشاف 🚀') {
            setState(() => _loadingMessage = 'أهلاً بك! جاهز للاستكشاف 🚀');
          }
        }
      });

    // بدء تحميل البيانات في الخلفية وبدء الأنيميشن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepoProvider>().init();
      _progressController.forward().then((_) {
        _navigateToHome();
      });
    });
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. خلفية ذات تدرج شعاعي خافت وناعم
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.9,
                  colors: [
                    Color(0xFFEEF2FF),
                    Color(0xFFF8FAFC),
                  ],
                ),
              ),
            ),
          ),

          // 2. المحتوى المركزي
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // الأيقونة وشعاع النبض المحيط
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // حلقة التوهج الخارجية الأولى
                            Container(
                              width: 170 * _scaleAnimation.value,
                              height: 170 * _scaleAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primary.withValues(alpha: 0.08),
                              ),
                            ),
                            // حلقة التوهج الثانية
                            Container(
                              width: 140 * _scaleAnimation.value,
                              height: 140 * _scaleAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.accentPurple.withValues(alpha: 0.12),
                              ),
                            ),
                            // حاوية الأيقونة الرئيسية
                            Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withValues(alpha: 0.35),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.asset(
                                    'assets/icon/app_icon.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // اسم التطبيق مع تدرج لوني فخم
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF312E81), Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'StarWireHub',
                        style: GoogleFonts.cairo(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // الوصف والتاغ لاين بالعربية
                    Text(
                      'بوابتك الذكية لاكتشاف مستودعات GitHub الرائجة والبدائل الحرة',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // وسوم المزايا الثلاث
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildFeaturePill('🔥 رواج أسبوعي', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                        _buildFeaturePill('⚡ بدائل مفتوحة', AppTheme.accentPurple, AppTheme.accentPurpleSurface),
                        _buildFeaturePill('✨ ملخصات عربية', AppTheme.primary, AppTheme.primarySurface),
                      ],
                    ),

                    const Spacer(flex: 3),

                    // شريط التحميل والنسبة المئوية
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Column(
                          children: [
                            // النص التوضيحي للحالة
                            Text(
                              _loadingMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // شريط التقدم بتدرج خطي جذاب
                            Container(
                              height: 6,
                              width: 220,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 220 * _progressAnimation.value,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // رقم الإصدار والحقوق
                    const Text(
                      'الإصدار 1.0.0 • تصميم عصري وفائق السرعة',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
