import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../providers/localization_provider.dart';
import '../screens/chat_consultant_screen.dart';
import '../utils/app_strings.dart';

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

  void _navigateToChatConsultant() {
    Navigator.pop(context);
  }

  void _confirmDeleteConversation(
    BuildContext context,
    String conversationId,
    dynamic strings,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(strings.deleteConversation),
          content: Text(strings.areYouSureDeleteConsultation),
          actions: <Widget>[
            TextButton(
              child: Text(strings.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(strings.delete),
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
    return Consumer2<ChatProvider, LocalizationProvider>(
      builder: (context, chatProvider, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              strings.yourConsultations,
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
              onPressed: _navigateToChatConsultant,
            ),
          ),
          body:
              chatProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : chatProvider.conversations.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: const Color(0xFFE07E02).withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          strings.noConversationsYet,
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
                            strings.startNewConsultationWith,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: chatProvider.conversations.reversed.length,
                    itemBuilder: (context, index) {
                      final conversation =
                          chatProvider.conversations.reversed.toList()[index];
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
                                title: Text(strings.confirm),
                                content: Text(
                                  strings.areYouSureDeleteConsultation,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: Text(strings.cancel.toUpperCase()),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: Text(strings.delete.toUpperCase()),
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
                              content: Text(strings.consultationDeleted),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE07E02),
                            child: Icon(
                              Icons.chat_rounded,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            conversation.topic,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            strings.tapToContinueConsultation,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed:
                                () => _confirmDeleteConversation(
                                  context,
                                  conversation.id,
                                  strings,
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
      },
    );
  }
}
