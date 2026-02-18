import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';

/// Helper class to diagnose and fix notification issues
class NotificationHelper {
  final NotificationService _notificationService;

  NotificationHelper(this._notificationService);

  /// Check all notification-related permissions and settings
  Future<NotificationStatus> checkNotificationStatus() async {
    final issues = <String>[];
    final suggestions = <String>[];

    // Initialize notification service
    try {
      await _notificationService.initialize();
    } catch (e) {
      issues.add('Failed to initialize notification service: $e');
      suggestions.add('Restart the app and try again');
    }

    // Check basic notification permission
    final notificationsEnabled = await _notificationService.areNotificationsEnabled();
    if (!notificationsEnabled) {
      issues.add('Notification permission not granted');
      suggestions.add('Enable notifications in app settings');
    }

    if (Platform.isAndroid) {
      // Check exact alarm permission (Android 12+)
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (!exactAlarmStatus.isGranted) {
        issues.add('Exact alarm permission not granted (required for Android 12+)');
        suggestions.add('Grant "Alarms & reminders" permission in app settings');
      }

      // Check battery optimization
      final batteryOptStatus = await Permission.ignoreBatteryOptimizations.status;
      if (!batteryOptStatus.isGranted) {
        issues.add('App is subject to battery optimization');
        suggestions.add('Disable battery optimization for this app to ensure reliable notifications');
      }

      // Check for pending notifications
      final pending = await _notificationService.getPendingNotifications();
      if (pending.isEmpty) {
        issues.add('No pending notifications scheduled');
        suggestions.add('Schedule at least one notification to test');
      }
    }

    return NotificationStatus(
      isFullyConfigured: issues.isEmpty,
      issues: issues,
      suggestions: suggestions,
    );
  }

  /// Request all necessary permissions
  Future<bool> requestAllPermissions() async {
    try {
      // Request notification permissions
      final notificationGranted = await _notificationService.requestPermissions();
      if (!notificationGranted) {
        return false;
      }

      // Request battery optimization exemption
      if (Platform.isAndroid) {
        await _notificationService.requestBatteryOptimizationExemption();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Test notification by showing one immediately
  Future<void> testNotification() async {
    await _notificationService.showImmediateNotification(
      title: 'Test Notification',
      body: 'If you see this, notifications are working!',
      type: NotificationType.normalTask,
    );
  }
}

/// Status of notification configuration
class NotificationStatus {
  final bool isFullyConfigured;
  final List<String> issues;
  final List<String> suggestions;

  NotificationStatus({
    required this.isFullyConfigured,
    required this.issues,
    required this.suggestions,
  });

  String get summary {
    if (isFullyConfigured) {
      return 'All notification settings are properly configured';
    } else {
      return '${issues.length} issue(s) found with notification setup';
    }
  }
}
