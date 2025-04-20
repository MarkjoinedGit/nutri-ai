class Conversation {
  final String id;
  final String userId;
  final String topic;

  Conversation({
    required this.id,
    required this.userId,
    required this.topic,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'],
      userId: json['user'],
      topic: json['topic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'topic': topic,
    };
  }
}