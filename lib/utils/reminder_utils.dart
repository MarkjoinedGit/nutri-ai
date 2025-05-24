import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class ReminderUtils {
  static DateTime parseReminderTime(String timeString) {
    try {
      if (timeString.contains('+') || timeString.contains('Z')) {
        final dateTime = DateTime.parse(timeString);
        return dateTime.toLocal();
      } else {
        return DateTime.parse(timeString);
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  static Color getReminderTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Colors.blue;
      case ReminderType.mainMeal:
        return Colors.green;
      case ReminderType.snack:
        return Colors.orange;
      case ReminderType.supplement:
        return Colors.purple;
      case ReminderType.other:
        return Colors.grey;
    }
  }

  static IconData getReminderTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return Icons.local_drink;
      case ReminderType.mainMeal:
        return Icons.restaurant;
      case ReminderType.snack:
        return Icons.cookie;
      case ReminderType.supplement:
        return Icons.medication;
      case ReminderType.other:
        return Icons.notifications;
    }
  }

  static String getReminderTypeText(ReminderType type) {
    switch (type) {
      case ReminderType.water:
        return 'Uống nước';
      case ReminderType.mainMeal:
        return 'Bữa chính';
      case ReminderType.snack:
        return 'Bữa phụ';
      case ReminderType.supplement:
        return 'Thực phẩm bổ sung';
      case ReminderType.other:
        return 'Khác';
    }
  }

  static String getRepeatText(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.daily:
        return 'Hàng ngày';
      case RepeatType.weekly:
        return 'Hàng tuần';
      case RepeatType.monthly:
        return 'Hàng tháng';
      case RepeatType.none:
        return 'Một lần';
    }
  }

  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
