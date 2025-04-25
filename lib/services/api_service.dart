import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/chat_message_model.dart';
import '../../models/conversation_model.dart';
import '../config/api_config.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  
  // Thêm headers mặc định với UTF-8 encoding
  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json; charset=UTF-8',
  };

  // Get conversations for a user
  Future<List<Conversation>> getUserConversations(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/user/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      // Sử dụng utf8.decode để đảm bảo xử lý đúng tiếng Việt
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Conversation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load conversations: ${response.statusCode}');
    }
  }

  // Get chat messages for a conversation
  Future<List<ChatMessage>> getConversationChats(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats/conv/$conversationId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      // Sử dụng utf8.decode để đảm bảo xử lý đúng tiếng Việt
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
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
      headers: _headers,
      body: json.encode({
        'conversation': conversationId,
        'userchat': userMessage,
      }),
    );

    if (response.statusCode == 201) {
      // Sử dụng utf8.decode để đảm bảo xử lý đúng tiếng Việt
      return ChatMessage.fromJson(json.decode(utf8.decode(response.bodyBytes)));
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
      headers: _headers,
      body: json.encode({
        'user': userId,
        'userchat': userMessage,
      }),
    );

    if (response.statusCode == 201) {
      // Sử dụng utf8.decode để đảm bảo xử lý đúng tiếng Việt
      return ChatMessage.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to start conversation: ${response.statusCode}');
    }
  }
}