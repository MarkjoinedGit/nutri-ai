import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../utils/reminder_utils.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  static const Color customOrange = Color(0xFFE07E02);

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = reminder.status == ReminderStatus.active;
    final reminderTime = ReminderUtils.parseReminderTime(reminder.time);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ReminderUtils.getReminderTypeColor(
                      reminder.type,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    ReminderUtils.getReminderTypeIcon(reminder.type),
                    color: ReminderUtils.getReminderTypeColor(reminder.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.black87 : Colors.grey[500],
                        ),
                      ),
                      if (reminder.description != null)
                        Text(
                          reminder.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isActive ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (_) => onToggleStatus(),
                  activeColor: customOrange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${ReminderUtils.formatTime(reminderTime)} - ${ReminderUtils.formatDate(reminderTime)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                if (reminder.repeat != RepeatType.none)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: customOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ReminderUtils.getRepeatText(reminder.repeat, context),
                      style: const TextStyle(
                        fontSize: 12,
                        color: customOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: customOrange,
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Chỉnh sửa'),
                ),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Xóa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
