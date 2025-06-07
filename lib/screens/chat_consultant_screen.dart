import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../providers/localization_provider.dart';
import '../widgets/chat_message_widget.dart';
import '../screens/conversation_screen.dart';
import '../utils/app_strings.dart';

class ChatConsultantScreen extends StatefulWidget {
  final String? conversationId;

  const ChatConsultantScreen({super.key, this.conversationId});

  @override
  State<ChatConsultantScreen> createState() => _ChatConsultantScreenState();
}

class _ChatConsultantScreenState extends State<ChatConsultantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const Color customOrange = Color(0xFFE07E02);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      if (userProvider.currentUser != null) {
        chatProvider.setUser(userProvider.currentUser!);

        if (widget.conversationId != null) {
          chatProvider.selectConversation(widget.conversationId!);
        }
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text;
      Provider.of<ChatProvider>(context, listen: false).sendMessage(message);
      _messageController.clear();

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _openConversationHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChangeNotifierProvider.value(
              value: Provider.of<ChatProvider>(context, listen: false),
              child: ConversationsScreen(),
            ),
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  String _getAppBarTitle(ChatProvider chatProvider, dynamic strings) {
    if (chatProvider.currentConversationTopic != null &&
        chatProvider.currentConversationTopic!.isNotEmpty &&
        chatProvider.currentConversationTopic != strings.newConversation) {
      return chatProvider.currentConversationTopic!;
    }

    if (chatProvider.currentConversationId != null) {
      return strings.chatConsultationInLIne;
    }

    return strings.chatConsultationInLIne;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, LocalizationProvider>(
      builder: (context, chatProvider, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _getAppBarTitle(chatProvider, strings),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: _navigateToDashboard,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.black87),
                tooltip: strings.viewConversationHistory,
                onPressed: _openConversationHistory,
              ),
              IconButton(
                icon: const Icon(Icons.add_comment, color: Colors.black87),
                tooltip: strings.startNewConversation,
                onPressed: () {
                  final chatProvider = Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  );
                  chatProvider.startNewConversation();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child:
                    chatProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : chatProvider.messages.isEmpty
                        ? _buildEmptyState(strings)
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: chatProvider.messages.length * 2,
                          itemBuilder: (context, index) {
                            final messageIndex = index ~/ 2;
                            final isUserMessage = index % 2 == 0;

                            final message = chatProvider.messages[messageIndex];

                            if (!isUserMessage &&
                                messageIndex >= chatProvider.messages.length) {
                              return const SizedBox.shrink();
                            }

                            final isTyping = !isUserMessage && message.isTyping;
                            final text =
                                isUserMessage
                                    ? message.userChat
                                    : message.botChat;

                            return ChatMessageWidget(
                              text: text,
                              isUser: isUserMessage,
                              isTyping: isTyping,
                            );
                          },
                        ),
              ),
              _buildMessageInput(strings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(dynamic strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: customOrange.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            strings.chatWithNutriAI,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              strings.askNutritionQuestions,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openConversationHistory,
            icon: const Icon(Icons.history),
            label: Text(strings.viewPreviousConsultations),
            style: ElevatedButton.styleFrom(
              backgroundColor: customOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(dynamic strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _messageController,
                maxLines: null, 
                minLines: 1, 
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: strings.typeYourQuestion,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: const BoxDecoration(
              color: customOrange,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
