import 'user_model.dart';

class DashboardStatsModel {
  final UserModel user;
  final int messagesAnalyzed;
  final int messagesImproved;
  final int badgesUnlocked;
  final int harmonyScore;
  final List<int> weeklyData;
  final List<CategoryStat> categoryStats;

  DashboardStatsModel({
    required this.user,
    required this.messagesAnalyzed,
    required this.messagesImproved,
    required this.badgesUnlocked,
    required this.harmonyScore,
    required this.weeklyData,
    required this.categoryStats,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return DashboardStatsModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      messagesAnalyzed: (stats['messagesAnalyzed'] as num?)?.toInt() ?? 0,
      messagesImproved: (stats['messagesImproved'] as num?)?.toInt() ?? 0,
      badgesUnlocked: (stats['badgesUnlocked'] as num?)?.toInt() ?? 0,
      harmonyScore: (stats['harmonyScore'] as num?)?.toInt() ?? 100,
      weeklyData: List<int>.from(
        (stats['weeklyData'] ?? [0, 0, 0, 0, 0, 0, 0]).map((e) => (e as num).toInt()),
      ),
      categoryStats: (stats['categoryStats'] as List<dynamic>?)
              ?.map((e) => CategoryStat.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CategoryStat {
  final String category;
  final int count;

  CategoryStat({required this.category, required this.count});

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      category: json['category'] ?? 'unknown',
      count: json['count'] ?? 0,
    );
  }
}
