import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/repo_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/app_logo.dart';
import 'alternatives_screen.dart';
import 'bookmarks_screen.dart';
import 'explore_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ExploreScreen(),
    AlternativesScreen(),
    BookmarksScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepoProvider>();
    final bookmarksCount = provider.bookmarkedRepoNames.length;
    final isTablet = Responsive.isTablet(context);

    if (isTablet) {
      // تصميم التابلت والشاشات العريضة (قائمة جانبية فخمة + مساحة العمل)
      return Scaffold(
        backgroundColor: AppTheme.lightBg,
        body: Row(
          children: [
            // القائمة الجانبية (Sidebar)
            _buildTabletSidebar(context, bookmarksCount),

            // خط فاصل أنيق بين القائمة والمحتوى
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppTheme.lightBorder,
            ),

            // محتوى الشاشة المعروضة
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    // تصميم الهواتف الذكية العادية (شريط تنقل سفلي)
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.lightSurface,
          border: Border(
            top: BorderSide(color: AppTheme.lightBorder, width: 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x080F172A),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: AppTheme.lightSurface,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'استكشاف',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_outlined),
              activeIcon: Icon(Icons.swap_horiz_rounded),
              label: 'البدائل',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: bookmarksCount > 0,
                label: Text('$bookmarksCount'),
                backgroundColor: AppTheme.accentAmber,
                textColor: Colors.white,
                child: const Icon(Icons.bookmark_border_rounded),
              ),
              activeIcon: Badge(
                isLabelVisible: bookmarksCount > 0,
                label: Text('$bookmarksCount'),
                backgroundColor: AppTheme.accentAmber,
                textColor: Colors.white,
                child: const Icon(Icons.bookmark_rounded),
              ),
              label: 'المفضلة',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.info_outline_rounded),
              activeIcon: Icon(Icons.info_rounded),
              label: 'حول',
            ),
          ],
        ),
      ),
    );
  }

  // بناء القائمة الجانبية الاحترافية للتابلت
  Widget _buildTabletSidebar(BuildContext context, int bookmarksCount) {
    return Container(
      width: 250,
      color: AppTheme.lightSurface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس القائمة الجانبية (الشعار + الاسم)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    const AppLogo(size: 42, borderRadius: 12),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'StarWireHub',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'نسخة التابلت • متجاوبة',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // عناصر القائمة الجانبية
              _buildSidebarItem(
                index: 0,
                title: 'استكشاف المشاريع',
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
              ),
              const SizedBox(height: 6),
              _buildSidebarItem(
                index: 1,
                title: 'البدائل الحرة',
                icon: Icons.swap_horiz_outlined,
                activeIcon: Icons.swap_horiz_rounded,
              ),
              const SizedBox(height: 6),
              _buildSidebarItem(
                index: 2,
                title: 'المفضلة',
                icon: Icons.bookmark_border_rounded,
                activeIcon: Icons.bookmark_rounded,
                badgeCount: bookmarksCount,
              ),
              const SizedBox(height: 6),
              _buildSidebarItem(
                index: 3,
                title: 'حول التطبيق',
                icon: Icons.info_outline_rounded,
                activeIcon: Icons.info_rounded,
              ),

              const Spacer(),

              // كارت معلومات وتحديث بالأسفل
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sync_rounded,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مزامنة سريعة',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            'تحديث آلي كل 48 ساعة',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required String title,
    required IconData icon,
    required IconData activeIcon,
    int? badgeCount,
  }) {
    final isSelected = _currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primarySurface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFC7D2FE) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
