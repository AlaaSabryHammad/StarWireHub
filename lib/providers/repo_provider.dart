import 'package:flutter/material.dart';
import '../models/github_repo.dart';
import '../services/api_service.dart';

enum SortOption {
  trendingVelocity, // الأكثر نمواً هذا الأسبوع
  mostStars,        // الأكثر نجوماً
  mostForks,        // الأكثر تفرعاً
  newest,           // الأحدث
}

class RepoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<GithubRepo> _allRepos = [];
  Set<String> _bookmarkedRepoNames = {};
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedLanguage = 'All';
  SortOption _currentSort = SortOption.trendingVelocity;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedLanguage => _selectedLanguage;
  SortOption get currentSort => _currentSort;
  Set<String> get bookmarkedRepoNames => _bookmarkedRepoNames;

  // قائمة الفئات المتاحة
  List<String> get categories {
    final cats = _allRepos.map((r) => r.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  // قائمة اللغات المتاحة
  List<String> get languages {
    final langs = _allRepos.map((r) => r.language).toSet().toList();
    langs.removeWhere((l) => l.isEmpty || l == 'Other');
    langs.sort();
    return ['All', ...langs];
  }

  // المشاريع المتصدرة هذا الأسبوع (Hero Trending)
  List<GithubRepo> get topTrendingThisWeek {
    final trending = List<GithubRepo>.from(_allRepos);
    trending.sort((a, b) => b.starsThisWeek.compareTo(a.starsThisWeek));
    return trending.take(8).toList();
  }

  // مشاريع البدائل مفتوحة المصدر (Open Source Alternatives)
  List<GithubRepo> get alternativeRepos {
    return _allRepos.where((r) => r.alternativeTo.isNotEmpty).toList();
  }

  // المستودعات المفضلة
  List<GithubRepo> get bookmarkedRepos {
    return _allRepos
        .where((r) => _bookmarkedRepoNames.contains(r.repo))
        .toList();
  }

  // المستودعات المفلترة المعروضة للمستخدم
  List<GithubRepo> get filteredRepos {
    return _allRepos.where((repo) {
      // 1. فلتر البحث
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = repo.repo.toLowerCase().contains(query);
        final matchDesc = repo.description.toLowerCase().contains(query);
        final matchLine = repo.line?.toLowerCase().contains(query) ?? false;
        final matchTags = repo.tags.any((t) => t.toLowerCase().contains(query));
        final matchAlt = repo.alternativeTo.any((a) => a.toLowerCase().contains(query));
        if (!matchName && !matchDesc && !matchLine && !matchTags && !matchAlt) {
          return false;
        }
      }

      // 2. فلتر الفئة
      if (_selectedCategory != 'All' && repo.category != _selectedCategory) {
        return false;
      }

      // 3. فلتر لغة البرمجة
      if (_selectedLanguage != 'All' && repo.language != _selectedLanguage) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_currentSort) {
          case SortOption.trendingVelocity:
            return b.starsThisWeek.compareTo(a.starsThisWeek);
          case SortOption.mostStars:
            return b.stars.compareTo(a.stars);
          case SortOption.mostForks:
            return b.forks.compareTo(a.forks);
          case SortOption.newest:
            final aDate = a.firstSeen ?? a.createdAt ?? '';
            final bDate = b.firstSeen ?? b.createdAt ?? '';
            return bDate.compareTo(aDate);
        }
      });
  }

  // التهيئة وتحميل البيانات
  Future<void> init() async {
    await loadBookmarks();
    await loadRepositories();
  }

  Future<void> loadRepositories({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allRepos = await _apiService.fetchRepositories(forceRefresh: forceRefresh);
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> loadBookmarks() async {
    final list = await _apiService.getBookmarkedRepoIds();
    _bookmarkedRepoNames = list.toSet();
    notifyListeners();
  }

  Future<void> toggleBookmark(String repoName) async {
    await _apiService.toggleBookmark(repoName);
    if (_bookmarkedRepoNames.contains(repoName)) {
      _bookmarkedRepoNames.remove(repoName);
    } else {
      _bookmarkedRepoNames.add(repoName);
    }
    notifyListeners();
  }

  bool isBookmarked(String repoName) {
    return _bookmarkedRepoNames.contains(repoName);
  }

  // تعيين الفلاتر
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void setSortOption(SortOption sort) {
    _currentSort = sort;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _selectedLanguage = 'All';
    _currentSort = SortOption.trendingVelocity;
    notifyListeners();
  }
}

