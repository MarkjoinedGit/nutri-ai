import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import '../providers/user_provider.dart';
import '../providers/localization_provider.dart';
import '../widgets/reminder_dialog.dart';
import '../utils/reminder_utils.dart';
import '../utils/app_strings.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  static const Color customOrange = Color(0xFFE07E02);
  late TabController _tabController;

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

  void _loadReminders() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    if (userProvider.currentUser != null) {
      reminderProvider.loadReminders(userProvider.currentUser!.email);
    }
  }

  List<Reminder> _getTodayReminders(List<Reminder> allReminders) {
    final today = DateTime.now();
    return allReminders.where((reminder) {
      final reminderTime = ReminderUtils.parseReminderTime(reminder.time);
      return reminderTime.year == today.year &&
          reminderTime.month == today.month &&
          reminderTime.day == today.day;
    }).toList();
  }

  List<Reminder> _sortRemindersByNewest(List<Reminder> reminders) {
    List<Reminder> sortedReminders = List.from(reminders);
    sortedReminders.sort((a, b) {
      final timeA = ReminderUtils.parseReminderTime(a.time);
      final timeB = ReminderUtils.parseReminderTime(b.time);
      return timeB.compareTo(timeA);
    });
    return sortedReminders;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReminderProvider, LocalizationProvider>(
      builder: (context, reminderProvider, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              strings.reminders,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.grey[200],
            iconTheme: const IconThemeData(color: Colors.black87),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: customOrange,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: customOrange,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.notifications_active),
                      text: strings.todayReminders,
                    ),
                    Tab(
                      icon: const Icon(Icons.list_alt),
                      text: strings.allReminders,
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Consumer<ReminderProvider>(
            builder: (context, reminderProvider, child) {
              if (reminderProvider.isLoading) {
                return _buildLoadingState();
              }

              if (reminderProvider.error != null) {
                return _buildErrorState(reminderProvider.error!);
              }

              final allReminders = _sortRemindersByNewest(
                reminderProvider.reminders,
              );
              final todayReminders = _sortRemindersByNewest(
                _getTodayReminders(allReminders),
              );

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildRemindersList(
                    todayReminders,
                    reminderProvider,
                    isToday: true,
                  ),
                  _buildRemindersList(
                    allReminders,
                    reminderProvider,
                    isToday: false,
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateReminderDialog(),
            backgroundColor: customOrange,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(
              strings.createReminder,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            elevation: 4,
            extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: customOrange),
              const SizedBox(height: 16),
              Text(
                strings.loadingReminders,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRemindersList(
    List<Reminder> reminders,
    ReminderProvider reminderProvider, {
    required bool isToday,
  }) {
    if (reminders.isEmpty) {
      return _buildEmptyState(isToday);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadReminders();
      },
      color: customOrange,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final reminder = reminders[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEnhancedReminderCard(
                    reminder,
                    reminderProvider,
                    isToday,
                  ),
                );
              }, childCount: reminders.length),
            ),
          ),
          // Thêm padding dưới cùng để tránh che khuất bởi FAB
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  Widget _buildEnhancedReminderCard(
    Reminder reminder,
    ReminderProvider reminderProvider,
    bool isToday,
  ) {
    final isActive = reminder.status == ReminderStatus.active;
    final reminderTime = ReminderUtils.parseReminderTime(reminder.time);
    final isPast = reminderTime.isBefore(DateTime.now());
    final isUpcoming = isToday && reminderTime.isAfter(DateTime.now());
    final strings = AppStrings.getStrings(
      Provider.of<LocalizationProvider>(context, listen: false).currentLanguage,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient:
            isUpcoming
                ? LinearGradient(
                  colors: [customOrange.withValues(alpha: 0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side:
              isUpcoming
                  ? BorderSide(
                    color: customOrange.withValues(alpha: 0.3),
                    width: 1,
                  )
                  : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ReminderUtils.getReminderTypeColor(
                        reminder.type,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ReminderUtils.getReminderTypeColor(
                          reminder.type,
                        ).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      ReminderUtils.getReminderTypeIcon(reminder.type),
                      color: ReminderUtils.getReminderTypeColor(reminder.type),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reminder.title,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isActive
                                          ? Colors.black87
                                          : Colors.grey[500],
                                  decoration:
                                      isPast && isActive
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                              ),
                            ),
                            if (isUpcoming)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: customOrange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  strings.upcomingReminders,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (reminder.description != null &&
                            reminder.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              reminder.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isActive
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isActive,
                    onChanged:
                        (_) =>
                            reminderProvider.toggleReminderStatus(reminder.id),
                    activeColor: customOrange,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: isPast ? Colors.red[400] : customOrange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${ReminderUtils.formatTime(reminderTime)} - ${ReminderUtils.formatDate(reminderTime)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isPast ? Colors.red[600] : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (reminder.repeat != RepeatType.none)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: customOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: customOrange.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.repeat, size: 12, color: customOrange),
                            const SizedBox(width: 4),
                            Text(
                              ReminderUtils.getRepeatText(
                                reminder.repeat,
                                context,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: customOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showEditReminderDialog(reminder),
                    style: TextButton.styleFrom(
                      foregroundColor: customOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text(
                      'Sửa',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed:
                        () => _showDeleteConfirmDialog(
                          reminder.id,
                          reminderProvider,
                        ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text(
                      'Xóa',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  strings.errorOccurred,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadReminders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    strings.tryAgain,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isToday) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: customOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isToday
                        ? Icons.today_outlined
                        : Icons.notifications_none_rounded,
                    size: 64,
                    color: customOrange,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isToday ? strings.noRemindersToday : strings.noReminders,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isToday
                      ? strings.noRemindersSetToday
                      : strings.createFirstReminder,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                if (!isToday) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateReminderDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(
                      strings.createReminder,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateReminderDialog() {
    showDialog(context: context, builder: (context) => const ReminderDialog());
  }

  void _showEditReminderDialog(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => ReminderDialog(reminder: reminder),
    );
  }

  void _showDeleteConfirmDialog(String reminderId, ReminderProvider provider) {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              strings.confirmDelete,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Text(strings.areYouSureDeleteReminder),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: Text(strings.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  navigator.pop();
                  try {
                    await provider.deleteReminder(reminderId);
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(strings.reminderDeletedSuccessfully),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('${strings.error} ${e.toString()}'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  strings.delete,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }
}
