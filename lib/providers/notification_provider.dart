import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? payload;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.payload,
  });

  NotificationItem copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? payload,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      payload: payload ?? this.payload,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'payload': payload,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      isRead: json['isRead'] ?? false,
      payload: json['payload'],
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  static const String _storageKey = 'notifications_storage';
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initialize() async {
    await _loadNotificationsFromStorage();
  }

  Future<void> _loadNotificationsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_storageKey);

      if (notificationsJson != null) {
        final List<dynamic> decodedList = json.decode(notificationsJson);
        _notifications.clear();
        _notifications.addAll(
          decodedList.map((item) => NotificationItem.fromJson(item)).toList(),
        );

        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading notifications from storage: $e');
    }
  }

  Future<void> _saveNotificationsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String notificationsJson = json.encode(
        _notifications.map((notification) => notification.toJson()).toList(),
      );
      await prefs.setString(_storageKey, notificationsJson);
    } catch (e) {
      print('Error saving notifications to storage: $e');
    }
  }

  Future<void> addNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final existingIndex = _notifications.indexWhere((n) => n.id == id);
    if (existingIndex != -1) {
      return;
    }

    final notification = NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      payload: payload,
    );

    _notifications.insert(0, notification);
    notifyListeners();

    await _saveNotificationsToStorage();
  }

  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();

      await _saveNotificationsToStorage();
    }
  }

  Future<void> markAllAsRead() async {
    bool hasChanges = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
      await _saveNotificationsToStorage();
    }
  }

  Future<void> removeNotification(int id) async {
    final initialLength = _notifications.length;
    _notifications.removeWhere((n) => n.id == id);

    if (_notifications.length != initialLength) {
      notifyListeners();
      await _saveNotificationsToStorage();
    }
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    notifyListeners();

    await _saveNotificationsToStorage();
  }

  Future<void> cleanOldNotifications({int maxAge = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: maxAge));
    final initialLength = _notifications.length;

    _notifications.removeWhere(
      (notification) => notification.timestamp.isBefore(cutoffDate),
    );

    if (_notifications.length != initialLength) {
      notifyListeners();
      await _saveNotificationsToStorage();
    }
  }
}
