import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/reminder_model.dart';
import './notification_service.dart';
import '../config/api_config.dart';

class ReminderService {
  static const String baseUrl = ApiConfig.baseUrl;
  final NotificationService _notificationService = NotificationService();

  Future<List<Reminder>> getRemindersByEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reminders/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Reminder.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reminders');
      }
    } catch (e) {
      throw Exception('Error fetching reminders: $e');
    }
  }

  Future<Reminder> createReminder(Reminder reminder) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reminders/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reminder.toJson()),
      );

      if (response.statusCode == 201) {
        final createdReminder = Reminder.fromJson(jsonDecode(response.body));

        // Lên lịch thông báo cục bộ
        await _scheduleLocalNotification(createdReminder);

        return createdReminder;
      } else {
        throw Exception('Failed to create reminder');
      }
    } catch (e) {
      throw Exception('Error creating reminder: $e');
    }
  }

  Future<Reminder> updateReminder(String id, Reminder reminder) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reminders/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reminder.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedReminder = Reminder.fromJson(jsonDecode(response.body));

        // Hủy thông báo cũ và tạo thông báo mới
        await _notificationService.cancelNotification(id.hashCode);
        if (updatedReminder.status == ReminderStatus.active) {
          await _scheduleLocalNotification(updatedReminder);
        }

        return updatedReminder;
      } else {
        throw Exception('Failed to update reminder');
      }
    } catch (e) {
      throw Exception('Error updating reminder: $e');
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/reminders/$id'));

      if (response.statusCode == 200) {
        // Hủy thông báo cục bộ
        await _notificationService.cancelNotification(id.hashCode);
      } else {
        throw Exception('Failed to delete reminder');
      }
    } catch (e) {
      throw Exception('Error deleting reminder: $e');
    }
  }

  Future<void> _scheduleLocalNotification(Reminder reminder) async {
    if (reminder.status != ReminderStatus.active) return;

    final scheduledTime = DateTime.parse(reminder.time);

    if (reminder.repeat == RepeatType.none) {
      // Thông báo một lần
      await _notificationService.scheduleReminder(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.description ?? 'Đã đến giờ nhắc nhở!',
        scheduledTime: scheduledTime,
        payload: reminder.id,
      );
    } else {
      // Thông báo lặp lại
      RepeatInterval interval;
      switch (reminder.repeat) {
        case RepeatType.daily:
          interval = RepeatInterval.daily;
          break;
        case RepeatType.weekly:
          interval = RepeatInterval.weekly;
          break;
        default:
          interval = RepeatInterval.daily;
      }

      await _notificationService.scheduleRepeatingReminder(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.description ?? 'Đã đến giờ nhắc nhở!',
        scheduledTime: scheduledTime,
        repeatInterval: interval,
        payload: reminder.id,
      );
    }
  }

  Future<void> syncRemindersWithNotifications(List<Reminder> reminders) async {
    // Hủy tất cả thông báo hiện tại
    await _notificationService.cancelAllNotifications();

    // Lên lịch lại cho các reminder active
    for (final reminder in reminders) {
      if (reminder.status == ReminderStatus.active) {
        await _scheduleLocalNotification(reminder);
      }
    }
  }
}
