import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/reminder_model.dart';
import '../providers/user_provider.dart';

class ReminderFormDialog extends StatefulWidget {
  final Reminder? reminder;
  final Function(Reminder) onSave;

  const ReminderFormDialog({
    super.key,
    this.reminder,
    required this.onSave,
  });

  @override
  State<ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<ReminderFormDialog> {
  static const Color customOrange = Color(0xFFE07E02);
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedTime;
  late RepeatType _repeatType;
  late ReminderType _reminderType;

  @override
  void initState() {
    super.initState();
    
    _titleController = TextEditingController(text: widget.reminder?.title ?? '');
    _descriptionController = TextEditingController(text: widget.reminder?.description ?? '');
    _selectedTime = widget.reminder?.time ?? DateTime.now();
    _repeatType = widget.reminder?.repeat ?? RepeatType.none;
    _reminderType = widget.reminder?.type ?? ReminderType.other;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = TimeOfDay.fromDateTime(_selectedTime);
    
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: customOrange,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = _selectedTime;
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: customOrange,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isEditing = widget.reminder != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Chỉnh sửa nhắc nhở' : 'Tạo nhắc nhở mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'Nhập tiêu đề nhắc nhở',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  hintText: 'Nhập mô tả chi tiết',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedTime),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Thời gian',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    DateFormat('HH:mm').format(_selectedTime),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RepeatType>(
                decoration: const InputDecoration(
                  labelText: 'Lặp lại',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.repeat),
                ),
                value: _repeatType,
                items: RepeatType.values.map((RepeatType type) {
                  return DropdownMenuItem<RepeatType>(
                    value: type,
                    child: Text(_getRepeatTypeText(type)),
                  );
                }).toList(),
                onChanged: (RepeatType? value) {
                  if (value != null) {
                    setState(() {
                      _repeatType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReminderType>(
                decoration: const InputDecoration(
                  labelText: 'Loại nhắc nhở',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _reminderType,
                items: ReminderType.values.map((ReminderType type) {
                  return DropdownMenuItem<ReminderType>(
                    value: type,
                    child: Text(_getReminderTypeText(type)),
                  );
                }).toList(),
                onChanged: (ReminderType? value) {
                  if (value != null) {
                    setState(() {
                      _reminderType = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: customOrange,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final userId = userProvider.currentUser!.id;
              
              final reminder = Reminder(
                id: widget.reminder?.id,
                userId: userId,
                title: _titleController.text,
                description: _descriptionController.text.isEmpty 
                          ? null 
                          : _descriptionController.text,
                time: _selectedTime,
                repeat: _repeatType,
                type: _reminderType,
                status: widget.reminder?.status ?? ReminderStatus.active,
                createdAt: widget.reminder?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );
              
              widget.onSave(reminder);
            }
          },
          child: Text(isEditing ? 'Cập nhật' : 'Tạo'),
        ),
      ],
    );
  }

  String _getRepeatTypeText(RepeatType type) {
    switch (type) {
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

  String _getReminderTypeText(ReminderType type) {
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
}