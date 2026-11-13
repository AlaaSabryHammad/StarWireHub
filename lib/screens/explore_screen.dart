import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/repo_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/app_logo.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/repo_card.dart';
import '../widgets/trending_slider.dart';
import 'repo_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepoProvider>();
    final isTablet = Responsive.isTablet(context);
    final gridColumns = Responsive.getGridCrossAxisCount(context);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 34, borderRadius: 10),
            const SizedBox(width: 10),
            const Text(
              'StarWireHub',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.textSecondary,
            ),
            tooltip: 'تحديث البيانات',
            onPressed: () => provider.loadRepositories(forceRefresh: true),
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune_rounded, color: AppTheme.textSecondary),
                if (provider.selectedCategory != 'All' ||
                    provider.selectedLanguage != 'All' ||
                    provider.currentSort != SortOption.trendingVelocity)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'تصفية وترتيب',
            onPressed: () => FilterSheet.show(context),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : provider.errorMessage != null
          ? _buildErrorView(provider)
          : RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.lightSurface,
              onRefresh: () => provider.loadRepositories(forceRefresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // 1. شريط البحث والفلاتر السريعة
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(provider),
                          const SizedBox(height: 12),
                          _buildCategoryChips(provider),
                          if (provider.selectedCategory != 'All' ||
                              provider.selectedLanguage != 'All') ...[
                            const SizedBox(height: 10),
                            _buildActiveFiltersBadge(provider),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // 2. سلايدر المشاريع الأكثر رواجاً (يختفي عند البحث)
                  if (provider.searchQuery.isEmpty &&
                      provider.selectedCategory == 'All')
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TrendingSlider(
                          repos: provider.topTrendingThisWeek,
                          onRepoTap: (repo) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RepoDetailsScreen(repo: repo),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // 3. عنوان قائمة المشاريع وعددها
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.searchQuery.isNotEmpty
                                ? 'نتائج البحث (${provider.filteredRepos.length})'
                                : 'أحدث المشاريع المكتشفة (${provider.filteredRepos.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primarySurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getSortLabel(provider.currentSort),
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. عرض المشاريع المتجاوب (Grid في التابلت، و List في الهاتف)
                  if (provider.filteredRepos.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 56,
                                color: AppTheme.textMuted,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'لا توجد مشاريع مطابقة لخيارات البحث',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (isTablet)
                    // عرض شبكي متعدد الأعمدة للتابلت
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridColumns,
                          mainAxisExtent: 295,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final repo = provider.filteredRepos[index];
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
                        }, childCount: provider.filteredRepos.length),
                      ),
                    )
                  else
                    // عرض قائمة فردية للهواتف العادية
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final repo = provider.filteredRepos[index];
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
                      }, childCount: provider.filteredRepos.length),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBar(RepoProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14.5),
        decoration: InputDecoration(
          hintText: 'ابحث عن أداة، مكتبة، أو بديل مفتوح المصدر...',
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textMuted,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        onChanged: (val) => provider.setSearchQuery(val),
      ),
    );
  }

  Widget _buildCategoryChips(RepoProvider provider) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: provider.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = provider.categories[index];
          final isSelected = provider.selectedCategory == cat;
          return ChoiceChip(
            label: Text(cat == 'All' ? 'الكل' : cat),
            selected: isSelected,
            selectedColor: AppTheme.primary,
            backgroundColor: AppTheme.lightSurface,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppTheme.primary : AppTheme.lightBorder,
                width: 1,
              ),
            ),
            onSelected: (selected) {
              if (selected) {
                provider.setCategory(cat);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildActiveFiltersBadge(RepoProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_rounded,
            size: 14,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'فلاتر مفعلة: ${provider.selectedCategory != 'All' ? provider.selectedCategory : ''} ${provider.selectedLanguage != 'All' ? '(${provider.selectedLanguage})' : ''}',
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => provider.resetFilters(),
            child: const Text(
              'مسح الكل',
              style: TextStyle(
                color: AppTheme.accentRose,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(RepoProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: AppTheme.accentRose,
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ في تحميل المستودعات',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              onPressed: () => provider.loadRepositories(forceRefresh: true),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.trendingVelocity:
        return 'الأسرع نمواً 🔥';
      case SortOption.mostStars:
        return 'الأعلى نجوماً ⭐';
      case SortOption.mostForks:
        return 'الأكثر تفرعاً 🍴';
      case SortOption.newest:
        return 'الأحدث ⏱️';
    }
  }
}
