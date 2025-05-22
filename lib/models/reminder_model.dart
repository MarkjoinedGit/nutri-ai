import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

enum RepeatType { none, daily, weekly, monthly }

extension RepeatTypeExtension on RepeatType {
  String get value {
    switch (this) {
      case RepeatType.none:
        return 'none';
      case RepeatType.daily:
        return 'daily';
      case RepeatType.weekly:
        return 'weekly';
      case RepeatType.monthly:
        return 'monthly';
    }
  }

  static RepeatType fromString(String value) {
    switch (value) {
      case 'daily':
        return RepeatType.daily;
      case 'weekly':
        return RepeatType.weekly;
      case 'monthly':
        return RepeatType.monthly;
      default:
        return RepeatType.none;
    }
  }
}

enum ReminderType { water, mainMeal, snack, supplement, other }

extension ReminderTypeExtension on ReminderType {
  String get value {
    switch (this) {
      case ReminderType.water:
        return 'water';
      case ReminderType.mainMeal:
        return 'main_meal';
      case ReminderType.snack:
        return 'snack';
      case ReminderType.supplement:
        return 'supplement';
      case ReminderType.other:
        return 'other';
    }
  }

  static ReminderType fromString(String value) {
    switch (value) {
      case 'water':
        return ReminderType.water;
      case 'main_meal':
        return ReminderType.mainMeal;
      case 'snack':
        return ReminderType.snack;
      case 'supplement':
        return ReminderType.supplement;
      default:
        return ReminderType.other;
    }
  }
}

enum ReminderStatus { active, paused, completed }

extension ReminderStatusExtension on ReminderStatus {
  String get value {
    switch (this) {
      case ReminderStatus.active:
        return 'active';
      case ReminderStatus.paused:
        return 'paused';
      case ReminderStatus.completed:
        return 'completed';
    }
  }

  static ReminderStatus fromString(String value) {
    switch (value) {
      case 'active':
        return ReminderStatus.active;
      case 'paused':
        return ReminderStatus.paused;
      case 'completed':
        return ReminderStatus.completed;
      default:
        return ReminderStatus.active;
    }
  }
}

class Reminder {
  final String? id;
  final String userId;
  final String title;
  final String? description;
  final DateTime time;
  final RepeatType repeat;
  final ReminderType type;
  final ReminderStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reminder({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.time,
    this.repeat = RepeatType.none,
    this.type = ReminderType.other,
    this.status = ReminderStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      // GỬI THỜI GIAN THEO ĐỊNH DẠNG LOCAL (KHÔNG CHUYỂN SANG UTC)
      'time': time.toIso8601String(), // Bỏ .toUtc()
      'repeat': repeat.value,
      'type': type.value,
      'status': status.value,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['_id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      // PARSE THỜI GIAN VỚI XỬ LÝ TIMEZONE CHÍNH XÁC
      time: _parseDateTime(map['time']),
      repeat: RepeatTypeExtension.fromString(map['repeat']),
      type: ReminderTypeExtension.fromString(map['type']),
      status: ReminderStatusExtension.fromString(map['status']),
      createdAt: map['createdAt'] != null ? _parseDateTime(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? _parseDateTime(map['updatedAt']) : null,
    );
  }

  // Helper method để parse datetime với timezone
  static DateTime _parseDateTime(String dateTimeString) {
    try {
      // Nếu có timezone info (+07:00), parse và convert về local time
      if (dateTimeString.contains('+') || dateTimeString.contains('Z')) {
        final utcDateTime = DateTime.parse(dateTimeString);
        return utcDateTime.toLocal();
      } else {
        // Nếu không có timezone info, treat as local time
        return DateTime.parse(dateTimeString);
      }
    } catch (e) {
      // Fallback: parse as is
      return DateTime.parse(dateTimeString);
    }
  }

  String getTimeFormatted() {
    return DateFormat('HH:mm').format(time);
  }

  String getDateFormatted() {
    return DateFormat('dd/MM/yyyy').format(time);
  }

  String getRepeatText() {
    switch (repeat) {
      case RepeatType.none:
        return 'Không lặp lại';
      case RepeatType.daily:
        return 'Hàng ngày';
      case RepeatType.weekly:
        return 'Hàng tuần';
      case RepeatType.monthly:
        return 'Hàng tháng';
    }
  }

  String getTypeText() {
    switch (type) {
      case ReminderType.water:
        return 'Uống nước';
      case ReminderType.mainMeal:
        return 'Bữa chính';
      case ReminderType.snack:
        return 'Ăn nhẹ';
      case ReminderType.supplement:
        return 'Thực phẩm bổ sung';
      case ReminderType.other:
        return 'Khác';
    }
  }

  IconData getTypeIcon() {
    switch (type) {
      case ReminderType.water:
        return Icons.water_drop_outlined;
      case ReminderType.mainMeal:
        return Icons.restaurant_outlined;
      case ReminderType.snack:
        return Icons.cake_outlined;
      case ReminderType.supplement:
        return Icons.medication_outlined;
      case ReminderType.other:
        return Icons.notifications_outlined;
    }
  }
}