import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/reminder_form_dialog.dart';
import '../widgets/reminder_list_item.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with SingleTickerProviderStateMixin {
  static const Color customOrange = Color(0xFFE07E02);
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  ReminderType? _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.currentUser != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<ReminderProvider>(
          context,
          listen: false,
        ).loadUserReminders(userProvider.currentUser!.id);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải nhắc nhở: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder:
          (context) => ReminderFormDialog(
            onSave: (reminder) async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final reminderProvider = Provider.of<ReminderProvider>(
                context,
                listen: false,
              );

              navigator.pop();

              final result = await reminderProvider.createReminder(reminder);

              if (!mounted) return;

              if (result != null) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Tạo nhắc nhở thành công')),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Lỗi tạo nhắc nhở: ${reminderProvider.error}',
                    ),
                  ),
                );
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Vui lòng đăng nhập để sử dụng tính năng này'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.notifications_active_outlined,
              color: customOrange,
            ),
            const SizedBox(width: 8),
            const Text(
              'Nhắc nhở',
              style: TextStyle(
                color: customOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: customOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: customOrange,
          tabs: const [Tab(text: 'Lịch'), Tab(text: 'Tất cả')],
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: customOrange),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildCalendarTab(reminderProvider),
                  _buildAllRemindersTab(reminderProvider),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: customOrange,
        onPressed: _showAddReminderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarTab(ReminderProvider reminderProvider) {
    final remindersForSelectedDate = reminderProvider.getRemindersByDate(
      _selectedDate,
    );

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _selectedDate,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDate, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDate = selectedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: customOrange,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xFFF5E6D0),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: Colors.black),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
        ),
        const Divider(),
        Expanded(
          child:
              remindersForSelectedDate.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có nhắc nhở cho ngày ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: remindersForSelectedDate.length,
                    itemBuilder: (context, index) {
                      return ReminderListItem(
                        reminder: remindersForSelectedDate[index],
                        onStatusChanged: (id, status) {
                          reminderProvider.updateReminderStatus(id!, status);
                        },
                        onDelete: (id) async {
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );

                          final success = await reminderProvider.deleteReminder(
                            id!,
                          );

                          if (!mounted) return;

                          if (success) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Xóa nhắc nhở thành công'),
                              ),
                            );
                          } else {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Lỗi xóa nhắc nhở: ${reminderProvider.error}',
                                ),
                              ),
                            );
                          }
                        },
                        onEdit: (reminder) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => ReminderFormDialog(
                                  reminder: reminder,
                                  onSave: (updatedReminder) async {
                                    final navigator = Navigator.of(context);
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);

                                    navigator.pop();

                                    final success = await reminderProvider
                                        .updateReminder(
                                          reminder.id!,
                                          updatedReminder,
                                        );

                                    if (!mounted) return;

                                    if (success) {
                                      scaffoldMessenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Cập nhật nhắc nhở thành công',
                                          ),
                                        ),
                                      );
                                    } else {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Lỗi cập nhật nhắc nhở: ${reminderProvider.error}',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                          );
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildAllRemindersTab(ReminderProvider reminderProvider) {
    final allReminders = reminderProvider.getFilteredReminders(
      type: _selectedType,
    );

    return Column(
      children: [
        _buildTypeFilters(),
        Expanded(
          child:
              allReminders.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedType == null
                              ? 'Không có nhắc nhở nào'
                              : 'Không có nhắc nhở loại ${_selectedType!.toString().toLowerCase()}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allReminders.length,
                    itemBuilder: (context, index) {
                      return ReminderListItem(
                        reminder: allReminders[index],
                        onStatusChanged: (id, status) {
                          reminderProvider.updateReminderStatus(id!, status);
                        },
                        onDelete: (id) async {
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );

                          final success = await reminderProvider.deleteReminder(
                            id!,
                          );

                          if (!mounted) return;

                          if (success) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Xóa nhắc nhở thành công'),
                              ),
                            );
                          } else {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Lỗi xóa nhắc nhở: ${reminderProvider.error}',
                                ),
                              ),
                            );
                          }
                        },
                        onEdit: (reminder) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => ReminderFormDialog(
                                  reminder: reminder,
                                  onSave: (updatedReminder) async {
                                    final navigator = Navigator.of(context);
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);

                                    navigator.pop();

                                    final success = await reminderProvider
                                        .updateReminder(
                                          reminder.id!,
                                          updatedReminder,
                                        );

                                    if (!mounted) return;

                                    if (success) {
                                      scaffoldMessenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Cập nhật nhắc nhở thành công',
                                          ),
                                        ),
                                      );
                                    } else {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Lỗi cập nhật nhắc nhở: ${reminderProvider.error}',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                          );
                        },
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildTypeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          _buildFilterChip(
            label: 'Tất cả',
            icon: Icons.all_inclusive,
            selected: _selectedType == null,
            onSelected: (_) {
              setState(() {
                _selectedType = null;
              });
            },
          ),
          _buildFilterChip(
            label: 'Nước',
            icon: Icons.water_drop_outlined,
            selected: _selectedType == ReminderType.water,
            onSelected: (_) {
              setState(() {
                _selectedType = ReminderType.water;
              });
            },
          ),
          _buildFilterChip(
            label: 'Bữa chính',
            icon: Icons.restaurant_outlined,
            selected: _selectedType == ReminderType.mainMeal,
            onSelected: (_) {
              setState(() {
                _selectedType = ReminderType.mainMeal;
              });
            },
          ),
          _buildFilterChip(
            label: 'Ăn nhẹ',
            icon: Icons.cake_outlined,
            selected: _selectedType == ReminderType.snack,
            onSelected: (_) {
              setState(() {
                _selectedType = ReminderType.snack;
              });
            },
          ),
          _buildFilterChip(
            label: 'Thực phẩm bổ sung',
            icon: Icons.medication_outlined,
            selected: _selectedType == ReminderType.supplement,
            onSelected: (_) {
              setState(() {
                _selectedType = ReminderType.supplement;
              });
            },
          ),
          _buildFilterChip(
            label: 'Khác',
            icon: Icons.notifications_outlined,
            selected: _selectedType == ReminderType.other,
            onSelected: (_) {
              setState(() {
                _selectedType = ReminderType.other;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        avatar: Icon(icon, size: 18),
        selected: selected,
        selectedColor: customOrange.withValues(alpha: 0.2),
        checkmarkColor: customOrange,
        labelStyle: TextStyle(
          color: selected ? customOrange : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: onSelected,
      ),
    );
  }
}
