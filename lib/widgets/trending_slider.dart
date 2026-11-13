import 'package:flutter/material.dart';

import '../models/github_repo.dart';
import '../theme/app_theme.dart';
import 'stat_badge.dart';

class TrendingSlider extends StatelessWidget {
  final List<GithubRepo> repos;
  final Function(GithubRepo) onRepoTap;

  const TrendingSlider({
    super.key,
    required this.repos,
    required this.onRepoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (repos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppTheme.trendingGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'الأسرع نمواً هذا الأسبوع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmberSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Text(
                  'Trending 🔥',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentAmber,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 172,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: repos.length,
            itemBuilder: (context, index) {
              final repo = repos[index];
              return _TrendingCard(repo: repo, onTap: () => onRepoTap(repo));
            },
          ),
        ),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final GithubRepo repo;
  final VoidCallback onTap;

  const _TrendingCard({required this.repo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final langColor = AppTheme.getLanguageColor(repo.language);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.lightBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // السطر العلوي: اسم المشروع وزيادة النجوم
            Row(
              children: [
                Expanded(
                  child: Text(
                    repo.repo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentEmeraldSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        size: 11,
                        color: AppTheme.accentEmerald,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '+${repo.starsThisWeek}',
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
            const SizedBox(height: 6),

            // السطر المختصر
            Expanded(
              child: Text(
                repo.line ?? repo.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // السطر السفلي: النجوم + لغة البرمجة
            Row(
              children: [
                StatBadge(
                  icon: Icons.star_rounded,
                  count: repo.stars,
                  iconColor: const Color(0xFFD97706),
                  backgroundColor: AppTheme.accentAmberSurface,
                  borderColor: const Color(0xFFFEF3C7),
                  textColor: const Color(0xFF92400E),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
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
    );
  }
}
