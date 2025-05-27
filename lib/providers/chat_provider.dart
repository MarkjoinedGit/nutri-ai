import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import '../services/chatbot_service.dart';
import '../models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Conversation> _conversations = [];
  List<ChatMessage> _currentConversationMessages = [];
  String? _currentConversationId;
  String? _currentConversationTopic;
  User? _currentUser;
  bool _isLoading = false;

  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get messages => _currentConversationMessages;
  String? get currentConversationId => _currentConversationId;
  String? get currentConversationTopic => _currentConversationTopic;
  bool get isLoading => _isLoading;

  void setUser(User user) {
    _currentUser = user;
    loadConversations();
  }

  void startNewConversation() {
    _currentConversationId = null;
    _currentConversationTopic = null;
    _currentConversationMessages.clear();
    notifyListeners();
  }

  Future<void> loadConversations() async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await _apiService.getUserConversations(_currentUser!.id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectConversation(String conversationId) async {
    _currentConversationId = conversationId;

    // Tìm conversation để lấy topic
    final selectedConversation = _conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse:
          () => Conversation(
            id: conversationId,
            userId: _currentUser?.id ?? '',
            topic: 'Chat Consultation',
          ),
    );
    _currentConversationTopic = selectedConversation.topic;

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
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.deleteConversation(conversationId);

      if (success) {
        _conversations.removeWhere(
          (conversation) => conversation.id == conversationId,
        );

        if (_currentConversationId == conversationId) {
          _currentConversationId = null;
          _currentConversationTopic = null;
          _currentConversationMessages.clear();
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message) async {
    if (_currentUser == null) return;

    try {
      final String tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final userMessage = ChatMessage(
        id: tempId,
        conversationId: _currentConversationId ?? tempId,
        userChat: message,
        botChat: '',
        checkSearch: false,
        isTyping: true,
      );

      _currentConversationMessages.add(userMessage);
      notifyListeners();

      ChatMessage responseMessage;
      if (_currentConversationId != null) {
        responseMessage = await _apiService.sendMessage(
          conversationId: _currentConversationId!,
          userMessage: message,
        );
      } else {
        responseMessage = await _apiService.startNewConversation(
          userId: _currentUser!.id,
          userMessage: message,
        );

        _currentConversationId = responseMessage.conversationId;

        // Reload conversations để lấy topic mới từ server
        await _refreshConversationTopic(responseMessage.conversationId);
      }

      _currentConversationMessages = List.from(_currentConversationMessages);

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
      // Handle error - maybe update the temporary message to show an error state
    }
  }

  Future<void> _refreshConversationTopic(String conversationId) async {
    try {
      // Reload conversations để lấy topic mới
      _conversations = await _apiService.getUserConversations(_currentUser!.id);

      // Tìm conversation vừa tạo để lấy topic
      final newConversation = _conversations.firstWhere(
        (conv) => conv.id == conversationId,
        orElse:
            () => Conversation(
              id: conversationId,
              userId: _currentUser?.id ?? '',
              topic: 'New Conversation',
            ),
      );

      _currentConversationTopic = newConversation.topic;
      notifyListeners();
    } catch (e) {
      // Fallback nếu không thể lấy topic
      _currentConversationTopic = 'New Conversation';
      notifyListeners();
    }
  }
}
