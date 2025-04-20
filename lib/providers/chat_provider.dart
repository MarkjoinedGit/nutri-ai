import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Conversation> _conversations = [];
  List<ChatMessage> _currentConversationMessages = [];
  String? _currentConversationId;
  String? _userId;
  bool _isLoading = false;

  // Getters
  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get messages => _currentConversationMessages;
  String? get currentConversationId => _currentConversationId;
  bool get isLoading => _isLoading;

  // Set user ID
  void setUserId(String userId) {
    _userId = userId;
    loadConversations();
  }

  // Load user conversations
  Future<void> loadConversations() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await _apiService.getUserConversations(_userId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading conversations: $e');
    }
  }

  // Select a conversation
  Future<void> selectConversation(String conversationId) async {
    _currentConversationId = conversationId;
    _isLoading = true;
    notifyListeners();

    try {
      _currentConversationMessages = await _apiService.getConversationChats(
        conversationId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading chat messages: $e');
    }
  }

  // Send a message in current conversation
  // Send a message in current conversation
  Future<void> sendMessage(String message) async {
    if (_userId == null) return;

    try {
      // Create temporary user message to display immediately
      final String tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final userMessage = ChatMessage(
        id: tempId,
        conversationId: _currentConversationId ?? tempId,
        userChat: message,
        botChat: '', // Empty bot chat initially
        checkSearch: false,
        isTyping: true, // Indicate bot is typing
      );

      // Add message to current conversation immediately
      _currentConversationMessages.add(userMessage);
      notifyListeners();

      // Then send to API
      ChatMessage responseMessage;
      if (_currentConversationId != null) {
        // Add to existing conversation
        responseMessage = await _apiService.sendMessage(
          conversationId: _currentConversationId!,
          userMessage: message,
        );
      } else {
        // Start a new conversation
        responseMessage = await _apiService.startNewConversation(
          userId: _userId!,
          userMessage: message,
        );

        // Update current conversation ID
        _currentConversationId = responseMessage.conversationId;

        // Add the new conversation to our list
        Conversation newConversation = Conversation(
          id: responseMessage.conversationId,
          userId: _userId!,
          topic: "New Conversation", // Backend might set a different topic
        );
        _conversations.add(newConversation);
      }

      // Update the temporary message with the actual response
      final index = _currentConversationMessages.indexWhere(
        (msg) => msg.id == tempId,
      );
      if (index != -1) {
        _currentConversationMessages[index] = responseMessage;
      } else {
        _currentConversationMessages.add(responseMessage);
      }
      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
      // Handle error - maybe update the temporary message to show an error state
    }
  }
}
