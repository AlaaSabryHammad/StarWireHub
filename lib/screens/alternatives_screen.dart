import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/repo_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/repo_card.dart';
import 'repo_details_screen.dart';

class AlternativesScreen extends StatefulWidget {
  const AlternativesScreen({super.key});

  @override
  State<AlternativesScreen> createState() => _AlternativesScreenState();
}

class _AlternativesScreenState extends State<AlternativesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedAlternativeTag = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepoProvider>();
    final allAlternatives = provider.alternativeRepos;
    final isTablet = Responsive.isTablet(context);
    final gridColumns = Responsive.getGridCrossAxisCount(context);

    // استخراج جميع الأدوات التي لها بدائل لتوليد Chips
    final toolsSet = <String>{};
    for (final r in allAlternatives) {
      toolsSet.addAll(r.alternativeTo);
    }
    final toolsList = ['All', ...toolsSet.toList()..sort()];

    // فلترة المشاريع
    final filtered = allAlternatives.where((repo) {
      if (_selectedAlternativeTag != 'All' &&
          !repo.alternativeTo.contains(_selectedAlternativeTag)) {
        return false;
      }
      if (_searchController.text.isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        final matchAlt = repo.alternativeTo.any((a) => a.toLowerCase().contains(q));
        final matchRepo = repo.repo.toLowerCase().contains(q);
        final matchDesc = repo.description.toLowerCase().contains(q);
        if (!matchAlt && !matchRepo && !matchDesc) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppTheme.alternativeGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPurple.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'البدائل الحرة',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // لوحة معلومات ترحيبية
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentPurpleSurface,
                    const Color(0xFFFAF5FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFDDD6FE), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPurple.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_open_rounded, color: AppTheme.accentPurple, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'حرر بياناتك مع البرمجيات الحرة',
                        style: TextStyle(
                          color: AppTheme.accentPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'اكتشف بدائل مفتوحة المصدر وقابلة للاستضافة الذاتية (Self-hosted) لأشهر الأدوات التجارية مثل Notion, Figma, Slack وغيرها.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // شريط البحث الخاص بالبدائل
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                    hintText: 'ابحث باسم التطبيق التجاري (مثل: Notion, Figma)...',
                    hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textMuted),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
            ),
          ),

          // شريط الـ Chips السريع للأدوات التجارية
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: toolsList.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tool = toolsList[index];
                    final isSelected = _selectedAlternativeTag == tool;
                    return ChoiceChip(
                      label: Text(tool == 'All' ? 'جميع البدائل' : 'بدائل $tool'),
                      selected: isSelected,
                      selectedColor: AppTheme.accentPurple,
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
                          color: isSelected ? AppTheme.accentPurple : AppTheme.lightBorder,
                          width: 1,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedAlternativeTag = tool;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // عدد النتائج
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'تم العثور على (${filtered.length}) مشروع بديل',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // قائمة المشاريع المتجاوبة
          if (filtered.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 54, color: AppTheme.textMuted),
                      SizedBox(height: 12),
                      Text(
                        'لا توجد مشاريع بديلة مطابقة لبحثك',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (isTablet)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  mainAxisExtent: 295,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final repo = filtered[index];
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
                  childCount: filtered.length,
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final repo = filtered[index];
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
                childCount: filtered.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
