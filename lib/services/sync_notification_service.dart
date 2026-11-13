import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/github_repo.dart';
import 'api_service.dart';

class SyncNotificationService {
  static final SyncNotificationService _instance = SyncNotificationService._internal();
  factory SyncNotificationService() => _instance;
  SyncNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  Timer? _hourlyTimer;
  bool _isInitialized = false;

  static const String _knownReposKey = 'starwire_known_repo_ids';
  static const String _channelId = 'starwire_repo_updates_channel';
  static const String _channelName = 'تحديثات المشاريع الجديدة';
  static const String _channelDesc = 'إشعارات تفصيلية عند اكتشاف مستودعات وبدائل مفتوحة المصدر جديدة';

  // تهيئة نظام الإشعارات
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        // عند الضغط على الإشعار
        if (kDebugMode) {
          print('Notification clicked with payload: ${response.payload}');
        }
      },
    );

    // طلب صلاحية الإشعارات لنظام أندرويد 13 فما فوق
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  // بدء المزامنة الدورية كل ساعة
  void startHourlySync() {
    _hourlyTimer?.cancel();

    // تشغيل فحص فوري بعد 10 ثوانٍ من تشغيل التطبيق
    Future.delayed(const Duration(seconds: 10), () {
      checkSyncAndNotify();
    });

    // تكرار الفحص تلقائياً كل ساعة
    _hourlyTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      checkSyncAndNotify();
    });
  }

  // إيقاف المزامنة
  void stopSync() {
    _hourlyTimer?.cancel();
  }

  // فحص المزامنة مع المصدر واكتشاف المشاريع الجديدة
  Future<void> checkSyncAndNotify({bool isManualCheck = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final knownRepos = (prefs.getStringList(_knownReposKey) ?? []).toSet();

      // جلب أحدث قائمة من GitHub مباشرة
      final currentRepos = await _apiService.fetchRepositories(forceRefresh: true);

      if (knownRepos.isEmpty) {
        // أول تشغيل للتطبيق: حفظ أسماء المشاريع الحالية كنقطة مرجعية
        final initialIds = currentRepos.map((r) => r.repo).toList();
        await prefs.setStringList(_knownReposKey, initialIds);

        if (isManualCheck && currentRepos.isNotEmpty) {
          // في حال الفحص اليدوي من الإعدادات، إرسال إشعار تجريبي فخم بأول مشروع صاعد
          await showBigRichNotification(currentRepos.first, isNewDiscovery: true);
        }
        return;
      }

      // البحث عن أي مستودع جديد لم يكن موجوداً من قبل
      final newRepos = currentRepos.where((r) => !knownRepos.contains(r.repo)).toList();

      if (newRepos.isNotEmpty) {
        // إظهار إشعار كبير ومفصل بالمشروع الجديد أو بالمشاريع المكتشفة
        if (newRepos.length == 1) {
          await showBigRichNotification(newRepos.first, isNewDiscovery: true);
        } else {
          await showMultiReposBigNotification(newRepos);
        }

        // تحديث قاعدة المعرفة
        final updatedIds = currentRepos.map((r) => r.repo).toList();
        await prefs.setStringList(_knownReposKey, updatedIds);
      } else if (isManualCheck) {
        // فحص يدوي ولم تظهر مستودعات جديدة: عرض أحدث مشروع صاعد كمعاينة
        final topTrending = List<GithubRepo>.from(currentRepos)
          ..sort((a, b) => b.starsThisWeek.compareTo(a.starsThisWeek));
        if (topTrending.isNotEmpty) {
          await showBigRichNotification(topTrending.first, isNewDiscovery: false);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during hourly sync: $e');
      }
    }
  }

  // عرض إشعار كبير وتفصيلي (BigTextStyle) لمشروع محدد
  Future<void> showBigRichNotification(GithubRepo repo, {bool isNewDiscovery = true}) async {
    await initialize();

    // صياغة نص تفصيلي كبير ومريح للقراءة
    final bigTextBuffer = StringBuffer();
    bigTextBuffer.writeln('🌟 المشروع: ${repo.repo}');
    bigTextBuffer.writeln('🏷️ التصنيف: ${repo.category} (${repo.language})');
    bigTextBuffer.writeln('⭐ التفاعل: ${repo.stars} نجمة • ${repo.forks} تفرع');

    if (repo.starsThisWeek > 0) {
      bigTextBuffer.writeln('🔥 معدل النمو: +${repo.starsThisWeek} نجمة جديدة هذا الأسبوع');
    }

    if (repo.alternativeTo.isNotEmpty) {
      bigTextBuffer.writeln('⚡ بديل حر لتطبيق: ${repo.alternativeTo.join("، ")}');
    }

    final desc = repo.line ?? repo.description;
    if (desc.isNotEmpty) {
      bigTextBuffer.writeln('📝 النبذة: $desc');
    }

    final bigTextStyle = BigTextStyleInformation(
      bigTextBuffer.toString(),
      contentTitle: isNewDiscovery
          ? '🚀 مستودع جديد مكتشف: ${repo.name}'
          : '🔥 الأكثر رواجاً الآن: ${repo.name}',
      summaryText: 'StarWireHub • تحديث كل ساعة',
    );

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigTextStyle,
      color: const Color(0xFF4F46E5),
      enableLights: true,
      enableVibration: true,
      showWhen: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: repo.repo.hashCode.abs() % 100000,
      title: isNewDiscovery ? '🚀 مستودع جديد: ${repo.name}' : '🔥 مشروع متصدر: ${repo.name}',
      body: desc.isNotEmpty ? desc : 'اكتشف تفاصيل هذا المشروع على StarWireHub',
      notificationDetails: notificationDetails,
      payload: repo.url,
    );
  }

  // عرض إشعار مجمع كبير عند اكتشاف عدة مشاريع جديدة دفعة واحدة
  Future<void> showMultiReposBigNotification(List<GithubRepo> newRepos) async {
    await initialize();

    final buffer = StringBuffer();
    buffer.writeln('تم اكتشاف ${newRepos.length} مستودعات جديدة صاعدة على GitHub:');
    buffer.writeln();

    for (int i = 0; i < newRepos.take(4).length; i++) {
      final r = newRepos[i];
      buffer.writeln('${i + 1}. ${r.name} (${r.language} • ${r.stars} ⭐)');
      if (r.alternativeTo.isNotEmpty) {
        buffer.writeln('   ↳ بديل لـ ${r.alternativeTo.first}');
      }
    }

    if (newRepos.length > 4) {
      buffer.writeln('... و ${newRepos.length - 4} مشاريع أخرى متاحة الآن داخل التطبيق.');
    }

    final bigTextStyle = BigTextStyleInformation(
      buffer.toString(),
      contentTitle: '✨ تم اكتشاف ${newRepos.length} مشاريع جديدة!',
      summaryText: 'StarWireHub • مزامنة ساعية',
    );

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigTextStyle,
      color: const Color(0xFF4F46E5),
      enableLights: true,
      enableVibration: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: '✨ ${newRepos.length} مشاريع جديدة متاحة الآن!',
      body: 'اضغط لتصفح المستودعات المكتشفة في StarWireHub',
      notificationDetails: notificationDetails,
    );
  }
}
