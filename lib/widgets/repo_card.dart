import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/github_repo.dart';
import '../providers/repo_provider.dart';
import '../theme/app_theme.dart';
import 'stat_badge.dart';

class RepoCard extends StatelessWidget {
  final GithubRepo repo;
  final VoidCallback onTap;

  const RepoCard({
    super.key,
    required this.repo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final langColor = AppTheme.getLanguageColor(repo.language);
    final provider = context.watch<RepoProvider>();
    final isBookmarked = provider.isBookmarked(repo.repo);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppTheme.primary.withValues(alpha: 0.06),
          highlightColor: AppTheme.primary.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. رأس البطاقة: الأيقونة + اسم المشروع والتصنيف + زر المفضلة
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.12),
                            AppTheme.accentPurple.withValues(alpha: 0.18),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          repo.name.isNotEmpty
                              ? repo.name[0].toUpperCase()
                              : 'R',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // اسم المستودع والتصنيف
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            repo.repo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primarySurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              repo.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // زر الإشارة المرجعية (Bookmark)
                    InkWell(
                      onTap: () => provider.toggleBookmark(repo.repo),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isBookmarked
                              ? AppTheme.accentAmberSurface
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isBookmarked
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isBookmarked
                              ? AppTheme.accentAmber
                              : AppTheme.textMuted,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 2. وصف المشروع
                Text(
                  repo.line ?? repo.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),

                // 3. شارات البدائل والنمو الأسبوعي (إن وجدت)
                if (repo.alternativeTo.isNotEmpty || repo.starsThisWeek > 0) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      // شارة البدائل
                      ...repo.alternativeTo.map((alt) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurpleSurface,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: const Color(0xFFDDD6FE),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.swap_horiz_rounded,
                                size: 12,
                                color: AppTheme.accentPurple,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'بديل لـ $alt',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentPurple,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // شارة الرواج الأسبوعي
                      if (repo.starsThisWeek > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentEmeraldSurface,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: const Color(0xFFA7F3D0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.trending_up_rounded,
                                size: 12,
                                color: AppTheme.accentEmerald,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '+${repo.starsThisWeek} هذا الأسبوع',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentEmerald,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // خط فاصل ناعم
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // 4. تذييل البطاقة: محمي 100% من الـ Overflow باستخدام Wrap مرن
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // لغة البرمجة
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: langColor,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  repo.language,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // النجوم
                          StatBadge(
                            icon: Icons.star_rounded,
                            count: repo.stars,
                            iconColor: const Color(0xFFD97706),
                            backgroundColor: AppTheme.accentAmberSurface,
                            borderColor: const Color(0xFFFEF3C7),
                            textColor: const Color(0xFF92400E),
                          ),

                          // التفرعات
                          StatBadge(
                            icon: Icons.fork_right_rounded,
                            count: repo.forks,
                            iconColor: AppTheme.accentCyan,
                            backgroundColor: const Color(0xFFF0F9FF),
                            borderColor: const Color(0xFFE0F2FE),
                            textColor: const Color(0xFF0369A1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),

                    // سهم الانتقال
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppTheme.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 11,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
