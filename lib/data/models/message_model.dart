class MessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
