class DetectionModel {
  final String id;
  final String userId;
  final String originalText;
  final bool isHateSpeech;
  final double confidence;
  final String? category;
  final String? reformulatedText;
  final DateTime createdAt;

  DetectionModel({
    required this.id,
    required this.userId,
    required this.originalText,
    required this.isHateSpeech,
    required this.confidence,
    this.category,
    this.reformulatedText,
    required this.createdAt,
  });

  factory DetectionModel.fromJson(Map<String, dynamic> json) {
    return DetectionModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      originalText: json['originalText'] ?? '',
      isHateSpeech: json['isHateSpeech'] ?? false,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      category: json['category'],
      reformulatedText: json['reformulatedText'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'originalText': originalText,
      'isHateSpeech': isHateSpeech,
      'confidence': confidence,
      'category': category,
      'reformulatedText': reformulatedText,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
