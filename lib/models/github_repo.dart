class GithubRepo {
  final String repo;
  final String? area;
  final String? subarea;
  final String category;
  final String? line;
  final String description;
  final int stars;
  final int forks;
  final String language;
  final String license;
  final List<String> topics;
  final String? pushedAt;
  final String? firstSeen;
  final int picks;
  final String url;
  final String? page;
  final String? homepage;
  final String? createdAt;
  final List<String> forms;
  final List<String> platforms;
  final List<String> tags;
  final List<String> alternativeTo;
  final int starsThisWeek;
  final bool trending;

  GithubRepo({
    required this.repo,
    this.area,
    this.subarea,
    required this.category,
    this.line,
    required this.description,
    required this.stars,
    required this.forks,
    required this.language,
    required this.license,
    required this.topics,
    this.pushedAt,
    this.firstSeen,
    required this.picks,
    required this.url,
    this.page,
    this.homepage,
    this.createdAt,
    required this.forms,
    required this.platforms,
    required this.tags,
    required this.alternativeTo,
    required this.starsThisWeek,
    required this.trending,
  });

  // استخراج اسم المستودع فقط واسم المالك
  String get owner => repo.contains('/') ? repo.split('/')[0] : '';
  String get name => repo.contains('/') ? repo.split('/')[1] : repo;

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      repo: json['repo'] as String? ?? 'Unknown',
      area: json['area'] as String?,
      subarea: json['subarea'] as String?,
      category: json['category'] as String? ?? 'General',
      line: json['line'] as String?,
      description: json['description'] as String? ?? '',
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      forks: (json['forks'] as num?)?.toInt() ?? 0,
      language: (json['language'] as String?)?.isNotEmpty == true
          ? json['language'] as String
          : 'Other',
      license: (json['license'] as String?)?.isNotEmpty == true
          ? json['license'] as String
          : 'None',
      topics: (json['topics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      pushedAt: json['pushedAt'] as String?,
      firstSeen: json['firstSeen'] as String?,
      picks: (json['picks'] as num?)?.toInt() ?? 1,
      url: json['url'] as String? ?? 'https://github.com/${json['repo']}',
      page: json['page'] as String?,
      homepage: (json['homepage'] as String?)?.isNotEmpty == true
          ? json['homepage'] as String
          : null,
      createdAt: json['createdAt'] as String?,
      forms: (json['forms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      platforms: (json['platforms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      alternativeTo: (json['alternativeTo'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      starsThisWeek: (json['starsThisWeek'] as num?)?.toInt() ?? 0,
      trending: json['trending'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'repo': repo,
      'area': area,
      'subarea': subarea,
      'category': category,
      'line': line,
      'description': description,
      'stars': stars,
      'forks': forks,
      'language': language,
      'license': license,
      'topics': topics,
      'pushedAt': pushedAt,
      'firstSeen': firstSeen,
      'picks': picks,
      'url': url,
      'page': page,
      'homepage': homepage,
      'createdAt': createdAt,
      'forms': forms,
      'platforms': platforms,
      'tags': tags,
      'alternativeTo': alternativeTo,
      'starsThisWeek': starsThisWeek,
      'trending': trending,
    };
  }
}

