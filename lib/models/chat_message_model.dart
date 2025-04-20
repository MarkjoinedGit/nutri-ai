class ChatMessage {
  final String id;
  final String conversationId;
  final String userChat;
  final String botChat;
  final bool checkSearch;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.userChat,
    required this.botChat,
    required this.checkSearch,
    this.isTyping = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'],
      conversationId: json['conversation'],
      userChat: json['userchat'],
      botChat: json['botchat'],
      checkSearch: json['checksearch'] ?? false,
      isTyping: false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversation': conversationId,
      'userchat': userChat,
      'botchat': botChat,
      'checksearch': checkSearch,
    };
  }
}