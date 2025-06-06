import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../providers/notification_provider.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationProvider? _notificationProvider;

  void setNotificationProvider(NotificationProvider provider) {
    _notificationProvider = provider;
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final notificationId = response.id ?? 0;

    _notificationProvider?.markAsRead(notificationId);
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Channel for reminder notifications',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
      scheduledTime,
      tz.getLocation('Asia/Ho_Chi_Minh'),
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    _scheduleNotificationCallback(id, title, body, scheduledTime, payload);
  }

  Future<void> scheduleRepeatingReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required RepeatInterval repeatInterval,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Channel for reminder notifications',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
      scheduledTime,
      tz.getLocation('Asia/Ho_Chi_Minh'),
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _getDateTimeComponents(repeatInterval),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    _scheduleRepeatingNotificationCallback(
      id,
      title,
      body,
      scheduledTime,
      repeatInterval,
      payload,
    );
  }

  void _scheduleNotificationCallback(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
    String? payload,
  ) {
    final now = DateTime.now();
    final delay = scheduledTime.difference(now);

    if (delay.isNegative) return;

    Future.delayed(delay, () {
      _addToNotificationList(id, title, body, payload);
    });
  }

  void _scheduleRepeatingNotificationCallback(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
    RepeatInterval repeatInterval,
    String? payload,
  ) {
    _scheduleNotificationCallback(id, title, body, scheduledTime, payload);

    Duration repeatDuration;
    switch (repeatInterval) {
      case RepeatInterval.daily:
        repeatDuration = const Duration(days: 1);
        break;
      case RepeatInterval.weekly:
        repeatDuration = const Duration(days: 7);
        break;
      default:
        repeatDuration = const Duration(days: 1);
    }

    for (int i = 1; i <= 30; i++) {
      final nextTime = scheduledTime.add(repeatDuration * i);
      _scheduleNotificationCallback(id, title, body, nextTime, payload);
    }
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'general_channel',
          'General',
          channelDescription: 'Channel for general notifications',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    _addToNotificationList(id, title, body, payload);
  }

  void _addToNotificationList(
    int id,
    String title,
    String body,
    String? payload,
  ) {
    _notificationProvider?.addNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );
  }

  DateTimeComponents _getDateTimeComponents(RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.daily:
        return DateTimeComponents.time;
      case RepeatInterval.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      default:
        return DateTimeComponents.time;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
