import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationHelper {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  static Future<void> scheduleMealReminders() async {
    final times = [
      const TimeOfDay(hour: 7,  minute: 0),   // Sarapan
      const TimeOfDay(hour: 12, minute: 0),   // Makan Siang
      const TimeOfDay(hour: 18, minute: 0),   // Makan Malam
    ];
    final messages = ['Sarapan yuk! 🌅', 'Waktunya makan siang! 🍱', 'Makan malam dulu! 🌙'];

    for (int i = 0; i < times.length; i++) {
      await _notificationsPlugin.zonedSchedule(
        i,
        '🍽️ FoodieFinder Reminder',
        messages[i],
        _nextInstance(times[i]),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminder', 'Meal Reminder',
            importance: Importance.high, priority: Priority.high,
          ),
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
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
