import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationHelper {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    final canScheduleExact =
        await androidPlugin?.canScheduleExactNotifications();
    if (canScheduleExact == false) {
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  static Future<void> scheduleMealReminders() async {
    const channelId = 'meal_reminder_channel';
    const channelName = 'Meal Reminder';

    final times = [
      const TimeOfDay(hour: 7, minute: 0),
      const TimeOfDay(hour: 10, minute: 53),
      const TimeOfDay(hour: 19, minute: 20),
    ];
    final messages = [
      'Sarapan yuk!',
      'Waktunya makan siang!',
      'Makan malam dulu!'
    ];

    for (int i = 0; i < times.length; i++) {
      await _notificationsPlugin.zonedSchedule(
        i,
        'FoodieFinder Reminder',
        messages[i],
        _nextInstance(times[i]),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: 'Reminder for breakfast, lunch, and dinner',
            importance: Importance.max,
            priority: Priority.high,
            enableLights: true,
            ticker: 'ticker',
          ),
          iOS: DarwinNotificationDetails(), // ios ga perlu keknya teh yangg
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static tz.TZDateTime _nextInstance(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
