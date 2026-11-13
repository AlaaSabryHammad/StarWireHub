import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/github_live_details.dart';
import '../models/github_repo.dart';
import '../providers/repo_provider.dart';
import '../services/arabic_summary_service.dart';
import '../services/github_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_badge.dart';

class RepoDetailsScreen extends StatefulWidget {
  final GithubRepo repo;

  const RepoDetailsScreen({super.key, required this.repo});

  @override
  State<RepoDetailsScreen> createState() => _RepoDetailsScreenState();
}

class _RepoDetailsScreenState extends State<RepoDetailsScreen>
    with SingleTickerProviderStateMixin {
  final ArabicSummaryService _summaryService = ArabicSummaryService();
  final GithubService _githubService = GithubService();

  late TabController _tabController;

  // الحالات والبيانات المحملة
  String? _arabicSummary;
  bool _isLoadingSummary = true;
  bool _showOriginalEnglish = false;

  GithubLiveDetails? _liveDetails;

  String? _readmeContent;
  bool _isLoadingReadme = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllProjectData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProjectData() async {
    // 1. تحميل الملخص العربي
    _summaryService.getArabicSummary(widget.repo).then((summary) {
      if (mounted) {
        setState(() {
          _arabicSummary = summary;
          _isLoadingSummary = false;
        });
      }
    });

    // 2. تحميل البيانات الحية من GitHub API
    _githubService.fetchLiveRepoDetails(widget.repo.repo).then((details) {
      if (mounted) {
        setState(() {
          _liveDetails = details;
        });
        // 3. تحميل ملف README بعد معرفة الفرع الرئيسي
        _githubService
            .fetchReadme(
              widget.repo.repo,
              defaultBranch: details?.defaultBranch ?? 'main',
            )
            .then((readme) {
          if (mounted) {
            setState(() {
              _readmeContent = readme;
              _isLoadingReadme = false;
            });
          }
        });
      }
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الرابط المطلوب')),
        );
      }
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatBytes(int kb) {
    if (kb >= 1024 * 1024) {
      return '${(kb / (1024 * 1024)).toStringAsFixed(1)} GB';
    } else if (kb >= 1024) {
      return '${(kb / 1024).toStringAsFixed(1)} MB';
    }
    return '$kb KB';
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repo;
    final langColor = AppTheme.getLanguageColor(repo.language);
    final provider = context.watch<RepoProvider>();
    final isBookmarked = provider.isBookmarked(repo.repo);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          repo.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isBookmarked ? AppTheme.accentAmber : AppTheme.textPrimary,
            ),
            onPressed: () => provider.toggleBookmark(repo.repo),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _copyToClipboard(
              repo.url,
              'تم نسخ رابط المستودع بنجاح 🚀',
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome_rounded, size: 18), text: 'نظرة عامة والملخص'),
            Tab(icon: Icon(Icons.description_rounded, size: 18), text: 'ملف README'),
            Tab(icon: Icon(Icons.terminal_rounded, size: 18), text: 'التشغيل والاستنساخ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // التبويب 1: النظرة العامة والملخص الذكي وتفاصيل GitHub
          _buildOverviewTab(context, langColor),

          // التبويب 2: استعراض ملف README.md الكامل
          _buildReadmeTab(),

          // التبويب 3: أوامر الاستنساخ السريع والتثبيت
          _buildInstallTab(),
        ],
      ),
    );
  }

  // التبويب الأول: النظرة العامة
  Widget _buildOverviewTab(BuildContext context, Color langColor) {
    final repo = widget.repo;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // كارت الرأسية مع صورة المالك من GitHub والإحصائيات الحية
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.lightBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المالك واسم المستودع
                Row(
                  children: [
                    if (_liveDetails?.avatarUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          _liveDetails!.avatarUrl!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
                        ),
                      )
                    else
                      _buildAvatarFallback(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            repo.owner,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            repo.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // شبكة الإحصائيات الحية (Stars, Forks, Watchers, Open Issues)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatBadge(
                      icon: Icons.star_rounded,
                      count: repo.stars,
                      iconColor: const Color(0xFFD97706),
                      backgroundColor: AppTheme.accentAmberSurface,
                      borderColor: const Color(0xFFFEF3C7),
                      textColor: const Color(0xFF92400E),
                      label: 'نجمة',
                    ),
                    StatBadge(
                      icon: Icons.fork_right_rounded,
                      count: repo.forks,
                      iconColor: AppTheme.accentCyan,
                      backgroundColor: const Color(0xFFF0F9FF),
                      borderColor: const Color(0xFFE0F2FE),
                      textColor: const Color(0xFF0369A1),
                      label: 'تفرع',
                    ),
                    if (_liveDetails != null) ...[
                      StatBadge(
                        icon: Icons.visibility_rounded,
                        count: _liveDetails!.watchers,
                        iconColor: AppTheme.accentPurple,
                        backgroundColor: AppTheme.accentPurpleSurface,
                        borderColor: const Color(0xFFDDD6FE),
                        textColor: AppTheme.accentPurple,
                        label: 'متابع',
                      ),
                      StatBadge(
                        icon: Icons.bug_report_rounded,
                        count: _liveDetails!.openIssues,
                        iconColor: AppTheme.accentRose,
                        backgroundColor: AppTheme.accentRoseSurface,
                        borderColor: const Color(0xFFFECDD3),
                        textColor: AppTheme.accentRose,
                        label: 'Issue',
                      ),
                    ],
                    if (repo.starsThisWeek > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: AppTheme.accentEmeraldSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up, size: 14, color: AppTheme.accentEmerald),
                            const SizedBox(width: 4),
                            Text(
                              '+${repo.starsThisWeek} نمو أسبوعي',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentEmerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // كارت الملخص الذكي باللغة العربية
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primarySurface,
                  const Color(0xFFF8FAFC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'ملخص فكرة المشروع (بالعربية)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showOriginalEnglish = !_showOriginalEnglish;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.translate_rounded,
                              size: 14,
                              color: _showOriginalEnglish
                                  ? AppTheme.accentPurple
                                  : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showOriginalEnglish ? 'العربية' : 'English',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _showOriginalEnglish
                                    ? AppTheme.accentPurple
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_isLoadingSummary)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'جاري تلخيص فكرة المشروع بالعربية...',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_showOriginalEnglish)
                  Text(
                    repo.description.isNotEmpty
                        ? repo.description
                        : (repo.line ?? 'No description provided.'),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppTheme.textPrimary,
                    ),
                  )
                else
                  Text(
                    _arabicSummary ?? 'لا يوجد ملخص متاح حالياً.',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.65,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // كارت بديل حر لـ (إن وجد)
          if (repo.alternativeTo.isNotEmpty) ...[
            const Text(
              'بديل مفتوح المصدر لـ:',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: repo.alternativeTo.map((alt) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurpleSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.accentPurple, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        alt,
                        style: const TextStyle(
                          color: AppTheme.accentPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
          ],

          // كارت بيانات GitHub الحية (حجم المستودع، الإصدار، الفروع، التواريخ)
          const Text(
            'بيانات المستودع المباشرة من GitHub',
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
                _buildLiveRow(
                  'اللغة الأساسية',
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: langColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        repo.language,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppTheme.lightBorder, height: 20),
                _buildLiveRow(
                  'الترخيص',
                  Text(
                    _liveDetails?.licenseName ?? repo.license,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentEmerald),
                  ),
                ),
                if (_liveDetails != null) ...[
                  const Divider(color: AppTheme.lightBorder, height: 20),
                  _buildLiveRow(
                    'حجم الكود',
                    Text(
                      _formatBytes(_liveDetails!.sizeKb),
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                  ),
                  const Divider(color: AppTheme.lightBorder, height: 20),
                  _buildLiveRow(
                    'الفرع الافتراضي',
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _liveDetails!.defaultBranch,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ),
                  ),
                  if (_liveDetails!.latestReleaseTag != null) ...[
                    const Divider(color: AppTheme.lightBorder, height: 20),
                    _buildLiveRow(
                      'أحدث إصدار (Release)',
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentEmeraldSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _liveDetails!.latestReleaseTag!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentEmerald),
                        ),
                      ),
                    ),
                  ],
                  if (_liveDetails!.createdAt != null) ...[
                    const Divider(color: AppTheme.lightBorder, height: 20),
                    _buildLiveRow(
                      'تاريخ الإنشاء',
                      Text(
                        DateFormat.yMMMd().format(_liveDetails!.createdAt!),
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                  if (_liveDetails!.updatedAt != null) ...[
                    const Divider(color: AppTheme.lightBorder, height: 20),
                    _buildLiveRow(
                      'آخر تحديث على GitHub',
                      Text(
                        DateFormat.yMMMd().format(_liveDetails!.updatedAt!),
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // روابط سريعة (GitHub & Homepage)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.open_in_browser_rounded),
                  label: const Text('فتح في GitHub', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _launchUrl(repo.url),
                ),
              ),
              if (repo.homepage != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.lightSurface,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppTheme.lightBorder, width: 1.2),
                    ),
                  ),
                  icon: const Icon(Icons.language_rounded, color: AppTheme.accentCyan),
                  onPressed: () => _launchUrl(repo.homepage!),
                ),
              ],
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // التبويب الثاني: استعراض ملف README.md الكامل
  Widget _buildReadmeTab() {
    if (_isLoadingReadme) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 16),
            Text(
              'جاري جلب ملف README.md مباشرة من GitHub...',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
            ),
          ],
        ),
      );
    }

    if (_readmeContent == null || _readmeContent!.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book_rounded, size: 56, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              const Text(
                'لم يتم العثور على ملف README.md في هذا المستودع',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('تصفح المستودع على GitHub'),
                onPressed: () => _launchUrl(widget.repo.url),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.lightBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Directionality(
          // نصوص الـ Readme الإنجليزية تكون LTR لتناسق القراءة
          textDirection: TextDirection.ltr,
          child: MarkdownBody(
            data: _readmeContent!,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF1E293B)),
              h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              code: const TextStyle(
                backgroundColor: Color(0xFFF1F5F9),
                fontFamily: 'monospace',
                fontSize: 12.5,
                color: Color(0xFF0F172A),
              ),
              codeblockDecoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              blockquoteDecoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: AppTheme.primary, width: 4),
                ),
              ),
            ),
            onTapLink: (text, href, title) {
              if (href != null && href.isNotEmpty) {
                _launchUrl(href);
              }
            },
          ),
        ),
      ),
    );
  }

  // التبويب الثالث: الاستنساخ والتشغيل السريع
  Widget _buildInstallTab() {
    final repo = widget.repo;
    final cloneCommand = 'git clone ${repo.url}.git';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أمر الاستنساخ عبر Git',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          _buildCodeBlock(cloneCommand, 'نسخ أمر الاستنساخ'),
          const SizedBox(height: 24),

          // أوامر التشغيل الشائعة حسب لغة المشروع
          const Text(
            'أوامر التشغيل السريعة (المقترحة)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          _buildLanguageCommands(repo.language),
          const SizedBox(height: 24),

          // كارت مساعدة للمطورين
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primary, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'يمكنك تصفح تبويب "ملف README" بالأعلى للحصول على تعليمات التثبيت الكاملة والمفصلة الخاصة بهذا المشروع.',
                    style: TextStyle(fontSize: 13, color: AppTheme.primary, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String code, String copyLabel) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                code,
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
            tooltip: copyLabel,
            onPressed: () => _copyToClipboard(code, 'تم نسخ الأمر بنجاح 📋'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCommands(String language) {
    switch (language.toLowerCase()) {
      case 'javascript':
      case 'typescript':
        return Column(
          children: [
            _buildCodeBlock('npm install\nnpm run dev', 'نسخ أوامر Node/NPM'),
          ],
        );
      case 'python':
        return Column(
          children: [
            _buildCodeBlock('pip install -r requirements.txt\npython main.py', 'نسخ أوامر Python'),
          ],
        );
      case 'rust':
        return Column(
          children: [
            _buildCodeBlock('cargo build --release\ncargo run', 'نسخ أوامر Rust'),
          ],
        );
      case 'dart':
      case 'flutter':
        return Column(
          children: [
            _buildCodeBlock('flutter pub get\nflutter run', 'نسخ أوامر Flutter'),
          ],
        );
      case 'go':
        return Column(
          children: [
            _buildCodeBlock('go mod tidy\ngo run .', 'نسخ أوامر Go'),
          ],
        );
      default:
        return _buildCodeBlock('cd ${widget.repo.name}\nls -la', 'نسخ أمر التصفح');
    }
  }

  Widget _buildAvatarFallback() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          widget.repo.owner.isNotEmpty ? widget.repo.owner[0].toUpperCase() : 'G',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLiveRow(String title, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5)),
        const SizedBox(width: 10),
        Flexible(child: value),
      ],
    );
  }
}
