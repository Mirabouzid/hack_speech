class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String type;
  final int target;
  final int reward;
  final int progress;
  final bool completed;
  final DateTime startDate;
  final DateTime endDate;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    this.emoji = '🎯',
    this.type = 'weekly',
    required this.target,
    this.reward = 100,
    this.progress = 0,
    this.completed = false,
    required this.startDate,
    required this.endDate,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🎯',
      type: json['type'] ?? 'weekly',
      target: json['target'] ?? 0,
      reward: json['reward'] ?? 100,
      progress: json['progress'] ?? 0,
      completed: json['completed'] ?? false,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 7)),
    );
  }
}
