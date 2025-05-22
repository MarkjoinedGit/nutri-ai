import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _reminderService = ReminderService();
  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserReminders(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      final reminders = await _reminderService.getUserReminders(userId);
      _reminders = reminders;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Reminder?> createReminder(Reminder reminder) async {
    _setLoading(true);
    _error = null;

    try {
      final createdReminder = await _reminderService.createReminder(reminder);
      _reminders.add(createdReminder);
      notifyListeners();
      return createdReminder;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateReminder(String id, Reminder reminder) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedReminder = await _reminderService.updateReminder(id, reminder);
      
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index] = updatedReminder;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteReminder(String id) async {
    _setLoading(true);
    _error = null;

    try {
      await _reminderService.deleteReminder(id);
      
      _reminders.removeWhere((reminder) => reminder.id == id);
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateReminderStatus(String id, ReminderStatus status) async {
    _error = null;

    try {
      await _reminderService.updateReminderStatus(id, status);
      
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        final updatedReminder = Reminder(
          id: _reminders[index].id,
          userId: _reminders[index].userId,
          title: _reminders[index].title,
          description: _reminders[index].description,
          time: _reminders[index].time,
          repeat: _reminders[index].repeat,
          type: _reminders[index].type,
          status: status,
          createdAt: _reminders[index].createdAt,
          updatedAt: DateTime.now(),
        );
        
        _reminders[index] = updatedReminder;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  List<Reminder> getFilteredReminders({ReminderType? type, ReminderStatus? status}) {
    return _reminders.where((reminder) {
      bool matchesType = type == null || reminder.type == type;
      bool matchesStatus = status == null || reminder.status == status;
      return matchesType && matchesStatus;
    }).toList();
  }

  List<Reminder> getRemindersByDate(DateTime date) {
    return _reminders.where((reminder) {
      final reminderDate = DateTime(
        reminder.time.year,
        reminder.time.month,
        reminder.time.day,
      );
      
      final targetDate = DateTime(
        date.year,
        date.month,
        date.day,
      );
      
      // Kiểm tra trùng ngày
      if (reminderDate == targetDate) {
        return true;
      }
      
      // Kiểm tra lặp lại hàng ngày
      if (reminder.repeat == RepeatType.daily) {
        final createdDate = reminder.createdAt ?? DateTime.now();
        if (date.isAfter(createdDate) || date == createdDate) {
          return true;
        }
      }
      
      // Kiểm tra lặp lại hàng tuần
      if (reminder.repeat == RepeatType.weekly) {
        final createdDate = reminder.createdAt ?? DateTime.now();
        if ((date.isAfter(createdDate) || date == createdDate) && 
            reminderDate.weekday == targetDate.weekday) {
          return true;
        }
      }
      
      // Kiểm tra lặp lại hàng tháng
      if (reminder.repeat == RepeatType.monthly) {
        final createdDate = reminder.createdAt ?? DateTime.now();
        if ((date.isAfter(createdDate) || date == createdDate) && 
            reminderDate.day == targetDate.day) {
          return true;
        }
      }
      
      return false;
    }).toList();
  }
}