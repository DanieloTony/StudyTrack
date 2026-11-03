
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/study_task.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      var timezoneName = timezoneInfo.identifier.trim();

      // Support older India timezone identifiers and fall back safely if the
      // environment returns an unexpected value.
      if (timezoneName == 'Asia/Calcutta') {
        timezoneName = 'Asia/Kolkata';
      }

      if (timezoneName.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(timezoneName));
      } else {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      windows: WindowsInitializationSettings(
        appName: 'StudyTrack',
        appUserModelId: 'com.example.studytrack',
        guid: '7d4b6b7a-1a2b-4c3d-9e8f-123456789abc',
      ),
    );

    await _plugin.initialize(settings: settings);

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  int _notificationId(String taskId) {
    var hash = 0;

    for (final unit in taskId.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return hash == 0 ? 1 : hash;
  }

  /// Displays an immediate notification for testing.
  Future<void> showTestNotification() async {
    await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'studytrack_test',
        'StudyTrack test notifications',
        channelDescription: 'Test notifications from StudyTrack.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      windows: WindowsNotificationDetails(),
    );

    await _plugin.show(
      id: 999,
      title: 'StudyTrack is working!',
      body: 'Your notification test was successful.',
      notificationDetails: details,
    );
  }

  Future<void> syncTaskReminders(List<StudyTask> tasks) async {
    await initialize();

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.windows) {
      return;
    }

    await _plugin.cancelAll();

    final now = DateTime.now();

    for (final task in tasks) {
      if (task.isCompleted || task.deadline == null) continue;

      final reminderMinutes = task.reminderMinutesBefore;

      if (reminderMinutes <= 0) continue;

      final reminderTime = task.deadline!.subtract(
        Duration(minutes: reminderMinutes),
      );

      if (!reminderTime.isAfter(now)) continue;

      final scheduledDate = tz.TZDateTime.from(
        reminderTime,
        tz.local,
      );

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _plugin.zonedSchedule(
          id: _notificationId(task.id),
          title: 'StudyTrack reminder',
          body: 'Your task "${task.title}" is coming up.',
          scheduledDate: scheduledDate,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'study_task_reminders',
              'Study task reminders',
              channelDescription:
                  'Reminders for upcoming study deadlines.',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode:
              AndroidScheduleMode.inexactAllowWhileIdle,
          payload: task.id,
        );
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
  await _plugin.zonedSchedule(
    id: _notificationId(task.id),
    title: 'StudyTrack reminder',
    body: 'Your task "${task.title}" is coming up.',
    scheduledDate: scheduledDate,
    notificationDetails: const NotificationDetails(
      windows: WindowsNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    payload: task.id,
  );
}
    }
  }
}
