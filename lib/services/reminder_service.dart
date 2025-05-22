import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reminder_model.dart';
import '../config/api_config.dart';

class ReminderService {
  final String _baseUrl = ApiConfig.baseUrl;
  
  Future<Reminder> createReminder(Reminder reminder) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reminders/create'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(reminder.toMap()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Reminder.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create reminder: ${response.body}');
    }
  }

  Future<List<Reminder>> getUserReminders(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/reminders/user/$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) => Reminder.fromMap(data)).toList();
    } else {
      throw Exception('Failed to load reminders: ${response.body}');
    }
  }

  Future<Reminder> updateReminder(String id, Reminder reminder) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/reminders/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(reminder.toMap()),
    );

    if (response.statusCode == 200) {
      return Reminder.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update reminder: ${response.body}');
    }
  }

  Future<void> deleteReminder(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/reminders/$id'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete reminder: ${response.body}');
    }
  }

  Future<void> updateReminderStatus(String id, ReminderStatus status) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/reminders/$id/status'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': status.value,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update reminder status: ${response.body}');
    }
  }
}