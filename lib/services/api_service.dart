import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/chat_message_model.dart';
import '../../models/conversation_model.dart';

class ApiService {
  final String baseUrl = 'https://zep.hcmute.fit/7800'; // Replace with your actual API base URL

  // Get conversations for a user
  Future<List<Conversation>> getUserConversations(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/user/$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Conversation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load conversations: ${response.statusCode}');
    }
  }

  // Get chat messages for a conversation
  Future<List<ChatMessage>> getConversationChats(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats/conv/$conversationId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => ChatMessage.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load chats: ${response.statusCode}');
    }
  }

  // Send a message to an existing conversation
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String userMessage,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'conversation': conversationId,
        'userchat': userMessage,
      }),
    );

    if (response.statusCode == 201) {
      return ChatMessage.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  // Start a new conversation
  Future<ChatMessage> startNewConversation({
    required String userId,
    required String userMessage,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chats/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user': userId,
        'userchat': userMessage,
      }),
    );

    if (response.statusCode == 201) {
      return ChatMessage.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to start conversation: ${response.statusCode}');
    }
  }
}