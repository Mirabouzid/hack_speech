class BadgeModel {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String category;
  final bool unlocked;
  final DateTime? unlockedAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    this.category = 'detection',
    this.unlocked = false,
    this.unlockedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '🏅',
      description: json['description'] ?? '',
      category: json['category'] ?? 'detection',
      unlocked: json['unlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }

  String? get unlockedDate {
    if (unlockedAt == null) return null;
    return '${unlockedAt!.day}/${unlockedAt!.month}/${unlockedAt!.year}';
  }
}
