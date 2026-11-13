import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/repo_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/sync_notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ضبط شريط الحالة وشريط التنقل السفلي للأجهزة المحمولة للوضع النهاري
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.lightSurface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // تهيئة نظام الإشعارات والمزامنة الساعية التلقائية
  final syncService = SyncNotificationService();
  await syncService.initialize();
  syncService.startHourlySync();

  runApp(const StarwireApp());
}

class StarwireApp extends StatelessWidget {
  const StarwireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RepoProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'StarWireHub',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            // دعم اللغة العربية والاتجاه من اليمين لليسار
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
