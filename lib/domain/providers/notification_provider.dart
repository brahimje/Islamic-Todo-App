import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/notification_service.dart';
import 'prayer_provider.dart';
import 'settings_provider.dart';

/// Provider for notification service instance
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider that initializes and manages notification scheduling
final notificationManagerProvider = FutureProvider<void>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  final settings = ref.watch(settingsProvider);
  final prayerTimes = ref.watch(prayerTimesProvider);
  
  // Initialize notifications
  await notificationService.initialize();
  
  // Check if notifications are enabled in settings
  if (!settings.notificationsEnabled) {
    await notificationService.cancelAllPrayerNotifications();
    return;
  }
  
  // Request permissions if needed
  final hasPermission = await notificationService.areNotificationsEnabled();
  if (!hasPermission) {
    final granted = await notificationService.requestPermissions();
    if (!granted) {
      return;
    }
  }
  
  // Schedule prayer notifications based on current prayer times
  await notificationService.scheduleDailyPrayerNotifications(
    fajr: prayerTimes.fajr,
    dhuhr: prayerTimes.dhuhr,
    asr: prayerTimes.asr,
    maghrib: prayerTimes.maghrib,
    isha: prayerTimes.isha,
    minutesBefore: settings.defaultReminderMinutes,
  );
});

/// Schedule notifications manually (called after settings change)
Future<void> scheduleNotificationsFromSettings(WidgetRef ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  final settings = ref.read(settingsProvider);
  final prayerTimes = ref.read(prayerTimesProvider);
  
  if (!settings.notificationsEnabled) {
    await notificationService.cancelAllPrayerNotifications();
    return;
  }
  
  await notificationService.scheduleDailyPrayerNotifications(
    fajr: prayerTimes.fajr,
    dhuhr: prayerTimes.dhuhr,
    asr: prayerTimes.asr,
    maghrib: prayerTimes.maghrib,
    isha: prayerTimes.isha,
    minutesBefore: settings.defaultReminderMinutes,
  );
}

/// Provider to check if notification permission is granted
final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  await notificationService.initialize();
  return await notificationService.areNotificationsEnabled();
});

/// Provider to get pending notifications count
final pendingNotificationsProvider = FutureProvider<int>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  final pending = await notificationService.getPendingNotifications();
  return pending.length;
});
