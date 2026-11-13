class GithubLiveDetails {
  final String? avatarUrl;
  final int watchers;
  final int openIssues;
  final String defaultBranch;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? licenseName;
  final int sizeKb;
  final bool isArchived;
  final String? latestReleaseTag;
  final String? latestReleaseDate;

  GithubLiveDetails({
    this.avatarUrl,
    required this.watchers,
    required this.openIssues,
    required this.defaultBranch,
    this.createdAt,
    this.updatedAt,
    this.licenseName,
    required this.sizeKb,
    required this.isArchived,
    this.latestReleaseTag,
    this.latestReleaseDate,
  });

  factory GithubLiveDetails.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? releaseJson,
  }) {
    DateTime? parseDate(String? str) {
      if (str == null) return null;
      try {
        return DateTime.parse(str);
      } catch (_) {
        return null;
      }
    }

    return GithubLiveDetails(
      avatarUrl: json['owner'] != null ? json['owner']['avatar_url'] : null,
      watchers: (json['subscribers_count'] as num?)?.toInt() ??
          (json['watchers_count'] as num?)?.toInt() ??
          0,
      openIssues: (json['open_issues_count'] as num?)?.toInt() ?? 0,
      defaultBranch: json['default_branch'] as String? ?? 'main',
      createdAt: parseDate(json['created_at'] as String?),
      updatedAt: parseDate(json['updated_at'] as String?),
      licenseName: json['license'] != null ? json['license']['name'] as String? : null,
      sizeKb: (json['size'] as num?)?.toInt() ?? 0,
      isArchived: json['archived'] as bool? ?? false,
      latestReleaseTag: releaseJson != null ? releaseJson['tag_name'] as String? : null,
      latestReleaseDate: releaseJson != null ? releaseJson['published_at'] as String? : null,
    );
  }
}

