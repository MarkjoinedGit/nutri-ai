import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class ReminderListItem extends StatelessWidget {
  final Reminder reminder;
  final Function(String?, ReminderStatus) onStatusChanged;
  final Function(String?) onDelete;
  final Function(Reminder) onEdit;

  const ReminderListItem({
    super.key,
    required this.reminder,
    required this.onStatusChanged,
    required this.onDelete,
    required this.onEdit,
  });

  static const Color customOrange = Color(0xFFE07E02);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = reminder.status == ReminderStatus.completed;
    final bool isPaused = reminder.status == ReminderStatus.paused;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.green.shade200 : 
                 isPaused ? Colors.grey.shade300 : 
                 Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onEdit(reminder),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          reminder.getTypeIcon(),
                          color: customOrange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reminder.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusIndicator(context),
                ],
              ),
              if (reminder.description != null && reminder.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 36),
                  child: Text(
                    reminder.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCompleted ? Colors.grey : Colors.black54,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 36),
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        reminder.getTimeFormatted(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.repeat, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        reminder.getRepeatText(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      onEdit(reminder);
                    },
                    child: Text(
                      'Chỉnh sửa',
                      style: TextStyle(color: customOrange),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text('Bạn có chắc muốn xóa nhắc nhở này?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onDelete(reminder.id);
                              },
                              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return PopupMenuButton<ReminderStatus>(
      onSelected: (ReminderStatus status) {
        onStatusChanged(reminder.id, status);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: ReminderStatus.active,
          child: Row(
            children: [
              Icon(Icons.play_arrow, color: Colors.green),
              SizedBox(width: 8),
              Text('Kích hoạt'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: ReminderStatus.paused,
          child: Row(
            children: [
              Icon(Icons.pause, color: Colors.amber),
              SizedBox(width: 8),
              Text('Tạm dừng'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: ReminderStatus.completed,
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Hoàn thành'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(),
              size: 16,
              color: _getStatusColor(),
            ),
            const SizedBox(width: 4),
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (reminder.status) {
      case ReminderStatus.active:
        return Icons.notifications_active;
      case ReminderStatus.paused:
        return Icons.pause;
      case ReminderStatus.completed:
        return Icons.check_circle;
    }
  }

  String _getStatusText() {
    switch (reminder.status) {
      case ReminderStatus.active:
        return 'Kích hoạt';
      case ReminderStatus.paused:
        return 'Tạm dừng';
      case ReminderStatus.completed:
        return 'Hoàn thành';
    }
  }

  Color _getStatusColor() {
    switch (reminder.status) {
      case ReminderStatus.active:
        return customOrange;
      case ReminderStatus.paused:
        return Colors.amber;
      case ReminderStatus.completed:
        return Colors.green;
    }
  }
}