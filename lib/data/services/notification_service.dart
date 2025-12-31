import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../core/router/app_router.dart';

/// Notification type for different categories
enum NotificationType {
  prayer,      // Adhan / Salat reminders
  adhkar,      // Morning/Evening Adhkar
  religiousTask, // Quran reading, Dhikr, Islamic study
  normalTask,  // Regular tasks
}

/// Service for managing local notifications for prayer times, adhkar, and tasks
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION CHANNELS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Prayer/Adhan channel - High importance with sound
  static const String _prayerChannelId = 'prayer_reminders';
  static const String _prayerChannelName = 'Prayer Time (Adhan)';
  static const String _prayerChannelDescription =
      'Reminders for the five daily prayers';

  /// Adhkar channel - Important spiritual reminders
  static const String _adhkarChannelId = 'adhkar_reminders';
  static const String _adhkarChannelName = 'Daily Adhkar';
  static const String _adhkarChannelDescription =
      'Morning and evening remembrance reminders';

  /// Religious tasks channel - Quran, Dhikr, Islamic activities
  static const String _religiousTaskChannelId = 'religious_task_reminders';
  static const String _religiousTaskChannelName = 'Religious Activities';
  static const String _religiousTaskChannelDescription =
      'Reminders for Quran, Dhikr, and other Islamic tasks';

  /// Normal tasks channel - Regular day-to-day tasks
  static const String _taskChannelId = 'task_reminders';
  static const String _taskChannelName = 'Task Reminders';
  static const String _taskChannelDescription = 'Reminders for scheduled tasks';

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION IDS
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const int _fajrNotificationId = 1;
  static const int _dhuhrNotificationId = 2;
  static const int _asrNotificationId = 3;
  static const int _maghribNotificationId = 4;
  static const int _ishaNotificationId = 5;
  static const int _adhkarMorningId = 10;
  static const int _adhkarEveningId = 11;
  static const int _adhkarAfterPrayerId = 12;
  static const int _adhkarSleepId = 13;
  static const int _religiousTaskBaseId = 500;
  static const int _taskBaseNotificationId = 1000;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    // macOS initialization settings
    const macOSSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macOSSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _isInitialized = true;
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Prayer channel - High importance for Adhan
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _prayerChannelId,
          _prayerChannelName,
          description: _prayerChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Adhkar channel - High importance for daily remembrance
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _adhkarChannelId,
          _adhkarChannelName,
          description: _adhkarChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

      // Religious tasks channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _religiousTaskChannelId,
          _religiousTaskChannelName,
          description: _religiousTaskChannelDescription,
          importance: Importance.high,
          playSound: true,
        ),
      );

      // Normal task channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _taskChannelId,
          _taskChannelName,
          description: _taskChannelDescription,
          importance: Importance.defaultImportance,
          playSound: true,
        ),
      );
    }
  }

  /// Handle notification tap - navigate to appropriate screen
  void _onNotificationTapped(NotificationResponse response) {
    
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    
    // Get the navigator context
    final navigatorState = rootNavigatorKey.currentState;
    if (navigatorState == null) {
      return;
    }
    
    // Parse payload and navigate
    if (payload.startsWith('prayer:')) {
      // Prayer notification → Home screen
      AppRouter.router.go(AppRoutes.home);
    } else if (payload.startsWith('adhkar:')) {
      // Adhkar notification → Daily Adhkar (Challenges) screen
      AppRouter.router.go(AppRoutes.challenges);
    } else if (payload.startsWith('religious_task:') || payload.startsWith('task:')) {
      // Task notification → Home screen
      AppRouter.router.go(AppRoutes.home);
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } else if (Platform.isMacOS) {
      final macPlugin = _notifications.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      final granted = await macPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    } else if (Platform.isMacOS) {
      // On macOS, check if permission was granted
      final macPlugin = _notifications.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      final settings = await macPlugin?.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    // iOS - assume enabled if we got here
    return true;
  }

  /// Schedule prayer notification
  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    required int minutesBefore,
  }) async {
    if (!_isInitialized) await initialize();

    final notificationTime = prayerTime.subtract(Duration(minutes: minutesBefore));
    
    // Don't schedule if time has passed
    if (notificationTime.isBefore(DateTime.now())) return;

    final notificationId = _getPrayerNotificationId(prayerName);
    final scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);

    // Format the prayer time for display
    final hour = prayerTime.hour;
    final minute = prayerTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeStr = '$displayHour:$minute $period';

    // User-friendly notification content
    final title = '$prayerName Prayer';
    final body = minutesBefore > 0
        ? '$prayerName at $timeStr - Prepare for salah'
        : 'Time for $prayerName prayer';

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _prayerChannelId,
          _prayerChannelName,
          channelDescription: _prayerChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
      payload: 'prayer:$prayerName',
    );

  }

  /// Schedule all prayer notifications for a day
  Future<void> scheduleDailyPrayerNotifications({
    required DateTime fajr,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    required int minutesBefore,
  }) async {
    // Cancel existing prayer notifications first
    await cancelAllPrayerNotifications();

    final prayers = {
      'Fajr': fajr,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };

    for (final entry in prayers.entries) {
      await schedulePrayerNotification(
        prayerName: entry.key,
        prayerTime: entry.value,
        minutesBefore: minutesBefore,
      );
    }
  }

  /// Schedule a task reminder notification
  /// Differentiates between religious and normal tasks
  Future<void> scheduleTaskNotification({
    required String taskId,
    required String taskTitle,
    required DateTime scheduledTime,
    required int minutesBefore,
    bool isReligious = false,
    String? category,
  }) async {
    if (!_isInitialized) await initialize();

    final notificationTime =
        scheduledTime.subtract(Duration(minutes: minutesBefore));

    // Don't schedule if time has passed
    if (notificationTime.isBefore(DateTime.now())) return;

    final tzScheduledTime = tz.TZDateTime.from(notificationTime, tz.local);

    // Choose notification style based on task type
    if (isReligious) {
      await _scheduleReligiousTaskNotification(
        taskId: taskId,
        taskTitle: taskTitle,
        scheduledTime: tzScheduledTime,
        minutesBefore: minutesBefore,
        category: category,
      );
    } else {
      await _scheduleNormalTaskNotification(
        taskId: taskId,
        taskTitle: taskTitle,
        scheduledTime: tzScheduledTime,
        minutesBefore: minutesBefore,
        category: category,
      );
    }
  }

  /// Schedule a religious task notification (Quran, Dhikr, Islamic study, etc.)
  Future<void> _scheduleReligiousTaskNotification({
    required String taskId,
    required String taskTitle,
    required tz.TZDateTime scheduledTime,
    required int minutesBefore,
    String? category,
  }) async {
    final notificationId = _religiousTaskBaseId + taskId.hashCode.abs() % 400;

    // Clean title for religious task
    final categoryLabel = _getReligiousLabel(category);
    final title = categoryLabel.isNotEmpty ? '$categoryLabel: $taskTitle' : taskTitle;
    final body = minutesBefore > 0
        ? 'Starting in $minutesBefore min - Barakallahu fik'
        : 'Time for your spiritual practice';

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _religiousTaskChannelId,
          _religiousTaskChannelName,
          channelDescription: _religiousTaskChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
      payload: 'religious_task:$taskId',
    );

  }

  /// Schedule a normal task notification
  Future<void> _scheduleNormalTaskNotification({
    required String taskId,
    required String taskTitle,
    required tz.TZDateTime scheduledTime,
    required int minutesBefore,
    String? category,
  }) async {
    final notificationId = _taskBaseNotificationId + taskId.hashCode.abs() % 10000;

    final title = taskTitle;
    final body = minutesBefore > 0
        ? 'Starts in $minutesBefore minutes'
        : 'Time to start this task';

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _taskChannelId,
          _taskChannelName,
          channelDescription: _taskChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
      payload: 'task:$taskId',
    );

  }

  /// Get clean label for religious task category
  String _getReligiousLabel(String? category) {
    if (category == null) return '';
    
    switch (category.toLowerCase()) {
      case 'quran':
        return 'Quran';
      case 'dhikr':
        return 'Dhikr';
      case 'dua':
        return 'Dua';
      case 'sunnah':
        return 'Sunnah';
      case 'islamic study':
        return 'Study';
      case 'charity':
        return 'Sadaqah';
      default:
        return '';
    }
  }

  /// Schedule Adhkar reminder notification
  Future<void> scheduleAdhkarNotification({
    required String adhkarType, // sabah, masa, salat, nawm
    required DateTime scheduledTime,
  }) async {
    if (!_isInitialized) await initialize();

    // Don't schedule if time has passed
    if (scheduledTime.isBefore(DateTime.now())) return;

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    
    final (notificationId, title, body) = _getAdhkarContent(adhkarType);

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      tzScheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _adhkarChannelId,
          _adhkarChannelName,
          channelDescription: _adhkarChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
      payload: 'adhkar:$adhkarType',
    );

  }

  /// Get Adhkar notification content based on type
  (int, String, String) _getAdhkarContent(String adhkarType) {
    switch (adhkarType.toLowerCase()) {
      case 'sabah':
        return (
          _adhkarMorningId,
          'Morning Adhkar',
          'Start your day with remembrance of Allah',
        );
      case 'masa':
        return (
          _adhkarEveningId,
          'Evening Adhkar',
          'End your day with evening remembrance',
        );
      case 'salat':
        return (
          _adhkarAfterPrayerId,
          'Post-Prayer Adhkar',
          'Complete your prayer with dhikr',
        );
      case 'nawm':
        return (
          _adhkarSleepId,
          'Sleep Adhkar',
          'Recite before sleep for protection',
        );
      default:
        return (
          _adhkarMorningId + adhkarType.hashCode.abs() % 100,
          'Adhkar Reminder',
          'Time for your daily remembrance',
        );
    }
  }

  /// Cancel a specific task notification
  Future<void> cancelTaskNotification(String taskId, {bool isReligious = false}) async {
    final notificationId = isReligious
        ? _religiousTaskBaseId + taskId.hashCode.abs() % 400
        : _taskBaseNotificationId + taskId.hashCode.abs() % 10000;
    await _notifications.cancel(notificationId);
  }

  /// Cancel all prayer notifications
  Future<void> cancelAllPrayerNotifications() async {
    await _notifications.cancel(_fajrNotificationId);
    await _notifications.cancel(_dhuhrNotificationId);
    await _notifications.cancel(_asrNotificationId);
    await _notifications.cancel(_maghribNotificationId);
    await _notifications.cancel(_ishaNotificationId);
  }

  /// Cancel all adhkar notifications
  Future<void> cancelAllAdhkarNotifications() async {
    await _notifications.cancel(_adhkarMorningId);
    await _notifications.cancel(_adhkarEveningId);
    await _notifications.cancel(_adhkarAfterPrayerId);
    await _notifications.cancel(_adhkarSleepId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Get notification ID for a prayer
  int _getPrayerNotificationId(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return _fajrNotificationId;
      case 'dhuhr':
        return _dhuhrNotificationId;
      case 'asr':
        return _asrNotificationId;
      case 'maghrib':
        return _maghribNotificationId;
      case 'isha':
        return _ishaNotificationId;
      default:
        return prayerName.hashCode.abs() % 1000;
    }
  }

  /// Show an immediate notification with type-based styling
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.normalTask,
  }) async {
    if (!_isInitialized) await initialize();

    // Select channel and styling based on notification type
    final (channelId, channelName, channelDesc, importance) = switch (type) {
      NotificationType.prayer => (
          _prayerChannelId,
          _prayerChannelName,
          _prayerChannelDescription,
          Importance.high,
        ),
      NotificationType.adhkar => (
          _adhkarChannelId,
          _adhkarChannelName,
          _adhkarChannelDescription,
          Importance.high,
        ),
      NotificationType.religiousTask => (
          _religiousTaskChannelId,
          _religiousTaskChannelName,
          _religiousTaskChannelDescription,
          Importance.high,
        ),
      NotificationType.normalTask => (
          _taskChannelId,
          _taskChannelName,
          _taskChannelDescription,
          Importance.defaultImportance,
        ),
    };

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: importance,
          priority: importance == Importance.high ? Priority.high : Priority.defaultPriority,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
