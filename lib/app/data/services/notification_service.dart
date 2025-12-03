import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
/// Local notification service
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation based on payload
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and navigate
      print('Notification tapped with payload: $payload');
    }
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.requestNotificationsPermission() ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  /// Show instant notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled',
      channelDescription: 'Scheduled notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Predefined notifications

  /// Daily challenge notification
  static Future<void> showDailyChallengeNotification() async {
    await showNotification(
      id: 1,
      title: '🎯 Daily Challenge Available!',
      body: 'Complete today\'s challenge to earn bonus rewards!',
      payload: 'daily_challenge',
    );
  }

  /// Streak reminder notification
  static Future<void> showStreakReminderNotification(int streakCount) async {
    await showNotification(
      id: 2,
      title: '🔥 Don\'t break your streak!',
      body: 'You\'re on a $streakCount day streak. Keep it going!',
      payload: 'streak_reminder',
    );
  }

  /// Achievement unlocked notification
  static Future<void> showAchievementUnlockedNotification({
    required String achievementTitle,
  }) async {
    await showNotification(
      id: 3,
      title: '🏆 Achievement Unlocked!',
      body: 'You earned: $achievementTitle',
      payload: 'achievement_unlocked',
    );
  }

  /// Quiz completed notification
  static Future<void> showQuizCompletedNotification({
    required String quizTitle,
    required int score,
  }) async {
    await showNotification(
      id: 4,
      title: '✅ Quiz Completed!',
      body: 'You scored $score% on $quizTitle',
      payload: 'quiz_completed',
    );
  }

  /// Course progress notification
  static Future<void> showCourseProgressNotification({
    required String courseTitle,
    required int progress,
  }) async {
    await showNotification(
      id: 5,
      title: '📚 Course Progress',
      body: 'You\'re $progress% through $courseTitle',
      payload: 'course_progress',
    );
  }
}

// Add this import at the top

