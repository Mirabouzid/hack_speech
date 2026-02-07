class LeaderboardEntryModel {
  final int rank;
  final String id;
  final String name;
  final String? avatar;
  final int points;
  final int level;

  LeaderboardEntryModel({
    required this.rank,
    required this.id,
    required this.name,
    this.avatar,
    required this.points,
    required this.level,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] ?? 0,
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      points: json['points'] ?? 0,
      level: json['level'] ?? 1,
    );
  }
}
