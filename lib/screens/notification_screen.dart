import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/localization_provider.dart';
import '../utils/app_strings.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const Color customOrange = Color(0xFFE07E02);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              strings.notifications,
              style: const TextStyle(
                color: customOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: Colors.black87),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  if (notificationProvider.unreadCount > 0) {
                    return TextButton(
                      onPressed: () {
                        notificationProvider.markAllAsRead();
                      },
                      child: Text(
                        strings.markAllRead,
                        style: const TextStyle(color: customOrange),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  final notificationProvider =
                      Provider.of<NotificationProvider>(context, listen: false);
                  if (value == 'clear_all') {
                    _showClearAllDialog(context, notificationProvider, strings);
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            const Icon(Icons.clear_all, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(strings.clearAll),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          body: Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        strings.noNotificationsYet,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: notificationProvider.notifications.length,
                itemBuilder: (context, index) {
                  final notification =
                      notificationProvider.notifications[index];
                  return _buildNotificationItem(
                    context,
                    notification,
                    notificationProvider,
                    strings,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationItem notification,
    NotificationProvider provider,
    dynamic strings,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: notification.isRead ? Colors.white : Colors.orange.shade50,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                notification.isRead
                    ? Colors.grey.shade300
                    : customOrange.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications,
            color: notification.isRead ? Colors.grey : customOrange,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(notification.timestamp, strings),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'mark_read' && !notification.isRead) {
              provider.markAsRead(notification.id);
            } else if (value == 'delete') {
              provider.removeNotification(notification.id);
            }
          },
          itemBuilder:
              (BuildContext context) => [
                if (!notification.isRead)
                  PopupMenuItem<String>(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        const Icon(Icons.mark_email_read, size: 18),
                        const SizedBox(width: 8),
                        Text(strings.markAsRead),
                      ],
                    ),
                  ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        strings.delete,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp, dynamic strings) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return strings.justNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${strings.minutesAgo}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${strings.hoursAgo}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${strings.daysAgo}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showClearAllDialog(
    BuildContext context,
    NotificationProvider provider,
    dynamic strings,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(strings.clearAllNotifications),
          content: Text(strings.clearAllConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.cancel),
            ),
            TextButton(
              onPressed: () {
                provider.clearAllNotifications();
                Navigator.of(context).pop();
              },
              child: Text(
                strings.clearAll,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
