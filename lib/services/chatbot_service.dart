import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/chat_message_model.dart';
import '../../models/conversation_model.dart';
import '../config/api_config.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  
  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json; charset=UTF-8',
  };

  Future<List<Conversation>> getUserConversations(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/user/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Conversation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load conversations: ${response.statusCode}');
    }
  }

  Future<List<ChatMessage>> getConversationChats(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats/conv/$conversationId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => ChatMessage.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load chats: ${response.statusCode}');
    }
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String userMessage,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chats/create'),
      headers: _headers,
      body: json.encode({
        'conversation': conversationId,
        'userchat': userMessage,
      }),
    );

    if (response.statusCode == 201) {
      return ChatMessage.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

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
      return ChatMessage.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to start conversation: ${response.statusCode}');
    }
  }
  
  Future<bool> deleteConversation(String conversationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/conversations/$conversationId'),
      headers: _headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete conversation: ${response.statusCode}');
    }
  }
}