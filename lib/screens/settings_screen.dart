import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/repo_provider.dart';
import '../providers/theme_provider.dart';
import '../services/sync_notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepoProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text(
          'حول التطبيق والمزامنة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // كارت تعريفي بتطبيق StarWireHub
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primarySurface,
                  const Color(0xFFF5F3FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const AppLogo(size: 72, borderRadius: 20),
                const SizedBox(height: 14),
                const Text(
                  'StarWireHub',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: const Text(
                    'الإصدار 1.0.0 • مزامنة ساعية ذكية',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'تطبيق Flutter مصمم بعناية لاكتشاف ومتابعة أكثر مستودعات البرمجيات الحرة والأدوات البرمجية رواجاً ونمواً في مجتمع المطورين مع إشعارات ساعية مفصلة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // قسم نوع الخط العربي
          const Text(
            'نوع الخط العربي في التطبيق',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.lightBorder, width: 1.2),
                ),
                child: Column(
                  children: ThemeProvider.availableFonts.map((font) {
                    final isSelected = themeProvider.currentFont == font.key;
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          onTap: () => themeProvider.setFont(font.key),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primarySurface : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.font_download_rounded,
                              size: 20,
                              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                            ),
                          ),
                          title: Text(
                            font.nameArabic,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 15,
                              color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            font.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 22)
                              : const Icon(Icons.radio_button_unchecked_rounded, color: AppTheme.lightBorderStrong, size: 22),
                        ),
                        if (font != ThemeProvider.availableFonts.last)
                          const Divider(color: AppTheme.lightBorder, height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // قسم المزامنة الساعية والإشعارات
          const Text(
            'المزامنة الساعية والإشعارات التلقائية',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.lightBorder, width: 1.2),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'المزامنة الدورية (كل 60 دقيقة)',
                  subtitle: 'يفحص التطبيق المصدر آلياً كل ساعة لإشعارك بأي مشروع جديد أو ترقية بأعلى التفاصيل.',
                  iconColor: AppTheme.primary,
                  bgColor: AppTheme.primarySurface,
                ),
                const Divider(color: AppTheme.lightBorder, height: 24),
                // زر تجربة الإشعار الكبير والمفصل
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: AppTheme.primary, width: 1.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18, color: AppTheme.primary),
                    label: const Text(
                      'إرسال إشعار تجريبي فخم وكبير الآن 🔔',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                    onPressed: () async {
                      await SyncNotificationService().checkSyncAndNotify(isManualCheck: true);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('تم إرسال إشعار تفصيلي كبير إلى شريط الإشعارات لديك! 🚀'),
                            backgroundColor: AppTheme.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // قسم مصدر البيانات
          const Text(
            'مصدر البيانات والتحديثات',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.lightBorder, width: 1.2),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.sync_rounded,
                  title: 'دورة تحديث الفهرس الرسمي',
                  subtitle: 'يتم فهرسة مشاريع جديدة من منصات المطورين كل 48 ساعة على GitHub.',
                  iconColor: AppTheme.accentEmerald,
                  bgColor: AppTheme.accentEmeraldSurface,
                ),
                const Divider(color: AppTheme.lightBorder, height: 24),
                _buildInfoTile(
                  icon: Icons.speed_rounded,
                  title: 'خوارزمية الرواج (Velocity)',
                  subtitle: 'قياس سرعة نمو النجوم مقارنة بحجم وعمر المشروع لتسليط الضوء على المشاريع الواعدة.',
                  iconColor: AppTheme.accentAmber,
                  bgColor: AppTheme.accentAmberSurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // روابط مهمة
          const Text(
            'روابط ومجتمع المشروع',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          Material(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.lightBorder, width: 1.2),
              ),
              child: Column(
                children: [
                  ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    leading: const Icon(Icons.code_rounded, color: AppTheme.primary),
                    title: const Text('مستودع Starwire على GitHub', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('github.com/boffti/starwire', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                    onTap: () => _launchUrl('https://github.com/boffti/starwire'),
                  ),
                  const Divider(color: AppTheme.lightBorder, height: 1),
                  ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                    ),
                    leading: const Icon(Icons.web_rounded, color: AppTheme.accentCyan),
                    title: const Text('موقع Starwire الرسمي', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('starwire.foo', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                    onTap: () => _launchUrl('https://starwire.foo'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // زر إعادة تحميل الكاش وتحديث البيانات يدوياً
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightSurface,
              foregroundColor: AppTheme.textPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppTheme.lightBorder, width: 1.2),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
            label: const Text(
              'تحديث ومزامنة البيانات الفورية الآن',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              await provider.loadRepositories(forceRefresh: true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم تحديث البيانات بنجاح من GitHub!'),
                    backgroundColor: AppTheme.accentEmerald,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
