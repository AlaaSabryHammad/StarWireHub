import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/repo_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/repo_card.dart';
import 'repo_details_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepoProvider>();
    final bookmarks = provider.bookmarkedRepos;
    final isTablet = Responsive.isTablet(context);
    final gridColumns = Responsive.getGridCrossAxisCount(context);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.accentAmberSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Icon(Icons.bookmark_rounded, color: AppTheme.accentAmber, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'المفضلة (${bookmarks.length})',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: bookmarks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: AppTheme.lightSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.lightBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        size: 56,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'لا توجد مشاريع مفضلة بعد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اضغط على أيقونة الإشارة المرجعية بجانب أي مشروع لحفظه والرجوع إليه بسهولة بدون إنترنت.',
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
            )
          : isTablet
              ? GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridColumns,
                    mainAxisExtent: 295,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final repo = bookmarks[index];
                    return RepoCard(
                      repo: repo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RepoDetailsScreen(repo: repo),
                          ),
                        );
                      },
                    );
                  },
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final repo = bookmarks[index];
                    return RepoCard(
                      repo: repo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RepoDetailsScreen(repo: repo),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
