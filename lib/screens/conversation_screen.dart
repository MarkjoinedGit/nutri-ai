import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../screens/chat_consultant_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentUser != null) {
        Provider.of<ChatProvider>(
          context,
          listen: false,
        ).setUser(userProvider.currentUser!);
      }
    });
  }

  // Navigate back to chat consultant screen
  void _navigateToChatConsultant() {
    // If we're viewing conversation history while already in a chat,
    // just return to that chat without creating a new screen
    Navigator.pop(context);
  }

  // Show confirmation dialog before deleting a conversation
  void _confirmDeleteConversation(BuildContext context, String conversationId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Conversation'),
          content: const Text(
            'Are you sure you want to delete this consultation?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Provider.of<ChatProvider>(
                  context,
                  listen: false,
                ).deleteConversation(conversationId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Consultations',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _navigateToChatConsultant,
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: const Color(0xFFE07E02).withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Conversations Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Start a new consultation with your NutriAI assistant',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final reversedConversations =
              chatProvider.conversations.reversed.toList();

          return ListView.builder(
            itemCount: reversedConversations.length,
            itemBuilder: (context, index) {
              final conversation = reversedConversations[index];
              return Dismissible(
                key: Key(conversation.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  bool? result = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text(
                          "Are you sure you want to delete this consultation?",
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("CANCEL"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text("DELETE"),
                          ),
                        ],
                      );
                    },
                  );
                  return result;
                },
                onDismissed: (direction) {
                  chatProvider.deleteConversation(conversation.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Consultation deleted'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE07E02),
                    child: Icon(Icons.chat_rounded, color: Colors.white),
                  ),
                  title: Text(
                    conversation.topic,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Tap to continue consultation',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed:
                        () => _confirmDeleteConversation(
                          context,
                          conversation.id,
                        ),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChangeNotifierProvider.value(
                              value: Provider.of<ChatProvider>(
                                context,
                                listen: false,
                              ),
                              child: ChatConsultantScreen(
                                conversationId: conversation.id,
                              ),
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE07E02),
        child: const Icon(Icons.add),
        onPressed: () {
          final chatProvider = Provider.of<ChatProvider>(
            context,
            listen: false,
          );
          chatProvider.startNewConversation();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChangeNotifierProvider.value(
                    value: chatProvider,
                    child: const ChatConsultantScreen(),
                  ),
            ),
          );
        },
      ),
    );
  }
}
