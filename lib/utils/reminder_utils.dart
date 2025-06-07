import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder_model.dart';
import '../providers/localization_provider.dart';
import './app_strings.dart';

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

  static String getReminderTypeText(ReminderType type, BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);
    switch (type) {
      case ReminderType.water:
        return strings.reminderTypeWater;
      case ReminderType.mainMeal:
        return strings.reminderTypeMainMeal;
      case ReminderType.snack:
        return strings.reminderTypeSnack;
      case ReminderType.supplement:
        return strings.reminderTypeSupplement;
      case ReminderType.other:
        return strings.reminderTypeOther;
    }
  }

  static String getRepeatText(RepeatType repeat, BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);
    switch (repeat) {
      case RepeatType.daily:
        return strings.repeatDaily;
      case RepeatType.weekly:
        return strings.repeatWeekly;
      case RepeatType.monthly:
        return strings.repeatMonthly;
      case RepeatType.none:
        return strings.repeatNone;
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
