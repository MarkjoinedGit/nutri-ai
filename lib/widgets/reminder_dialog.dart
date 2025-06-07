import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import '../providers/user_provider.dart';
import '../providers/localization_provider.dart';
import '../utils/reminder_utils.dart';
import '../utils/app_strings.dart';

class ReminderDialog extends StatefulWidget {
  final Reminder? reminder;

  const ReminderDialog({super.key, this.reminder});

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  static const Color customOrange = Color(0xFFE07E02);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  ReminderType _selectedType = ReminderType.other;
  RepeatType _selectedRepeat = RepeatType.none;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description ?? '';
      _selectedDateTime = ReminderUtils.parseReminderTime(
        widget.reminder!.time,
      );
      _selectedType = widget.reminder!.type;
      _selectedRepeat = widget.reminder!.repeat;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        return AlertDialog(
          title: Text(
            widget.reminder == null
                ? strings.createReminder
                : strings.editReminder,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitleField(),
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
                    const SizedBox(height: 16),
                    _buildTypeDropdown(),
                    const SizedBox(height: 16),
                    _buildDateTimeSelector(),
                    const SizedBox(height: 16),
                    _buildRepeatDropdown(),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: Text(strings.cancel),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: customOrange,
                foregroundColor: Colors.white,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Text(
                        widget.reminder == null
                            ? strings.create
                            : strings.update,
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleField() {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        return TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: strings.title,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return strings.pleaseEnterTitle;
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildDescriptionField() {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        return TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: strings.description,
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
        );
      },
    );
  }

  Widget _buildTypeDropdown() {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return DropdownButtonFormField<ReminderType>(
          value: _selectedType,
          decoration: InputDecoration(
            labelText: strings.reminderType,
            border: const OutlineInputBorder(),
          ),
          items:
              ReminderType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        ReminderUtils.getReminderTypeIcon(type),
                        color: ReminderUtils.getReminderTypeColor(type),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(ReminderUtils.getReminderTypeText(type, context)),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
        );
      },
    );
  }

  Widget _buildDateTimeSelector() {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        return ListTile(
          title: Text(strings.reminderTime),
          subtitle: Text(
            ReminderUtils.formatDateTime(_selectedDateTime),
            style: const TextStyle(color: customOrange),
          ),
          trailing: const Icon(Icons.access_time),
          onTap: _selectDateTime,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[400]!),
          ),
        );
      },
    );
  }

  Widget _buildRepeatDropdown() {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        return DropdownButtonFormField<RepeatType>(
          value: _selectedRepeat,
          decoration: InputDecoration(
            labelText: strings.repeat,
            border: const OutlineInputBorder(),
          ),
          items:
              RepeatType.values.map((repeat) {
                return DropdownMenuItem(
                  value: repeat,
                  child: Text(ReminderUtils.getRepeatText(repeat, context)),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRepeat = value!;
            });
          },
        );
      },
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: customOrange),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(primary: customOrange),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveReminder() async {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final reminderProvider = Provider.of<ReminderProvider>(
        context,
        listen: false,
      );

      if (userProvider.currentUser == null) {
        throw Exception(strings.userNotLoggedIn);
      }

      final reminder = Reminder(
        id: widget.reminder?.id ?? '',
        userId: userProvider.currentUser!.id,
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        time: _selectedDateTime.toIso8601String(),
        repeat: _selectedRepeat,
        type: _selectedType,
        status: widget.reminder?.status ?? ReminderStatus.active,
        createdAt: widget.reminder?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.reminder == null) {
        await reminderProvider.createReminder(reminder);
      } else {
        await reminderProvider.updateReminder(widget.reminder!.id, reminder);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.reminder == null
                  ? strings.reminderCreatedSuccessfully
                  : strings.reminderUpdatedSuccessfully,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.error}: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
