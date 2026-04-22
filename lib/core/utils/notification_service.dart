import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart'; 
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required DateTime scheduledTime,
  }) async {
    await _plugin.zonedSchedule(
      id,
      'FlowTick Reminder',
      title,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'flowtick_tasks',
          'Task Reminders',
          channelDescription: 'Reminders for your FlowTick tasks',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF6C63FF),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}

