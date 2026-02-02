import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS settings: Request permission when initializing
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'school_app_channel',
          'School App Notifications',
          channelDescription: 'Notifications for classes and study sessions',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // -----------------------------------------------------------------------------
  // SCHEDULE NOTIFICATIONS
  // -----------------------------------------------------------------------------

  /// Schedules a notification [minutesBefore] the [scheduledDate].
  /// [id] should be unique (e.g. hash of class details + day).
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Ensure we are scheduling in the future.
      if (scheduledDate.isBefore(DateTime.now())) return;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'school_app_channel',
            'School App Notifications',
            channelDescription: 'Notifications for classes and study sessions',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // -----------------------------------------------------------------------------
  // SPECIFIC TRIGGERS
  // -----------------------------------------------------------------------------

  /// Schedule a notification 30 minutes before a class.
  Future<void> scheduleClassNotification({
    required String courseName,
    required String location,
    required DateTime classDateTime,
  }) async {
    final scheduledTime = classDateTime.subtract(const Duration(minutes: 30));
    final id = classDateTime.millisecondsSinceEpoch ~/ 1000; 

    await scheduleNotification(
      id: id,
      title: 'Upcoming Class: $courseName',
      body: 'Class starts in 30 minutes at $location.',
      scheduledDate: scheduledTime,
    );
  }
  
  /// Schedule a notification 15 minutes before a study session.
  Future<void> scheduleStudySessionNotification({
    required String topic,
    required DateTime sessionDateTime,
  }) async {
    final scheduledTime = sessionDateTime.subtract(const Duration(minutes: 15));
    final id = (sessionDateTime.millisecondsSinceEpoch ~/ 1000) + 1; // Offset ID

    await scheduleNotification(
      id: id,
      title: 'Study Session Reminder',
      body: 'Time to study "$topic" in 15 minutes!',
      scheduledDate: scheduledTime,
    );
  }
}
