import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _reminderService = ReminderService();

  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Reminder> get activeReminders =>
      _reminders.where((r) => r.status == ReminderStatus.active).toList();

  Future<void> loadReminders(String userEmail) async {
    _setLoading(true);
    _error = null;

    try {
      _reminders = await _reminderService.getRemindersByEmail(userEmail);

      await _reminderService.syncRemindersWithNotifications(_reminders);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createReminder(Reminder reminder) async {
    _setLoading(true);
    _error = null;

    try {
      final createdReminder = await _reminderService.createReminder(reminder);
      _reminders.add(createdReminder);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateReminder(String id, Reminder reminder) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedReminder = await _reminderService.updateReminder(
        id,
        reminder,
      );
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index] = updatedReminder;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReminder(String id) async {
    _setLoading(true);
    _error = null;

    try {
      await _reminderService.deleteReminder(id);
      _reminders.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleReminderStatus(String id) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    final newStatus =
        reminder.status == ReminderStatus.active
            ? ReminderStatus.paused
            : ReminderStatus.active;

    final updatedReminder = reminder.copyWith(status: newStatus);
    await updateReminder(id, updatedReminder);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
