import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/repo_provider.dart';
import '../theme/app_theme.dart';

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepoProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.lightSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView(
            controller: scrollController,
            children: [
              // مقبض السحب العلوي
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.lightBorderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // العنوان وأزرار التحكم
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تصفية وترتيب المشاريع',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.resetFilters();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'إعادة ضبط',
                      style: TextStyle(
                        color: AppTheme.accentRose,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. الترتيب حسب
              const Text(
                'الترتيب حسب:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSortChip(
                    context,
                    label: 'الأسرع نمواً 🔥',
                    option: SortOption.trendingVelocity,
                    current: provider.currentSort,
                  ),
                  _buildSortChip(
                    context,
                    label: 'الأكثر نجوماً ⭐',
                    option: SortOption.mostStars,
                    current: provider.currentSort,
                  ),
                  _buildSortChip(
                    context,
                    label: 'الأكثر تفرعاً 🍴',
                    option: SortOption.mostForks,
                    current: provider.currentSort,
                  ),
                  _buildSortChip(
                    context,
                    label: 'الأحدث ⏱️',
                    option: SortOption.newest,
                    current: provider.currentSort,
                  ),
                ],
              ),
              const Divider(color: AppTheme.lightBorder, height: 32),

              // 2. لغات البرمجة
              const Text(
                'لغة البرمجة:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.languages.map((lang) {
                  final isSelected = provider.selectedLanguage == lang;
                  return ChoiceChip(
                    label: Text(lang == 'All' ? 'جميع اللغات' : lang),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : AppTheme.lightBorder,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        provider.setLanguage(lang);
                      }
                    },
                  );
                }).toList(),
              ),
              const Divider(color: AppTheme.lightBorder, height: 32),

              // 3. الفئات
              const Text(
                'التصنيف / الفئة:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.categories.map((cat) {
                  final isSelected = provider.selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat == 'All' ? 'جميع الفئات' : cat),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primary : AppTheme.lightBorder,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        provider.setCategory(cat);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // زر التطبيق
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'عرض النتائج',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortChip(
    BuildContext context, {
    required String label,
    required SortOption option,
    required SortOption current,
  }) {
    final isSelected = option == current;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primary,
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textSecondary,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.lightBorder,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          context.read<RepoProvider>().setSortOption(option);
        }
      },
    );
  }
}
