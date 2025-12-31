import 'package:hive/hive.dart';

part 'user_settings.g.dart';

/// Calculation methods for prayer times
@HiveType(typeId: 8)
enum CalculationMethod {
  @HiveField(0)
  muslimWorldLeague,

  @HiveField(1)
  egyptian,

  @HiveField(2)
  karachi,

  @HiveField(3)
  ummAlQura,

  @HiveField(4)
  dubai,

  @HiveField(5)
  qatar,

  @HiveField(6)
  kuwait,

  @HiveField(7)
  moonsightingCommittee,

  @HiveField(8)
  singapore,

  @HiveField(9)
  northAmerica,

  @HiveField(10)
  other,
}

/// Represents user settings and preferences
@HiveType(typeId: 4)
class UserSettings extends HiveObject {
  @HiveField(0)
  final String? locationName;

  @HiveField(1)
  final double? latitude;

  @HiveField(2)
  final double? longitude;

  @HiveField(3)
  final int calculationMethod; // See CalculationMethod enum

  @HiveField(4)
  final bool notificationsEnabled;

  @HiveField(5)
  final int defaultReminderMinutes;

  @HiveField(6)
  final bool showNafilaReminders;

  @HiveField(7)
  final bool showTaskReminders;

  @HiveField(8)
  final String language;

  @HiveField(9)
  final int? dailyReviewHour;

  @HiveField(10)
  final int? dailyReviewMinute;

  @HiveField(11)
  final bool isOnboardingComplete;

  @HiveField(12)
  final bool useSilentNotifications;

  @HiveField(13)
  final int madhab; // 0=Shafi, 1=Hanafi (affects Asr calculation)

  @HiveField(14)
  final bool use24HourFormat;

  @HiveField(15)
  final bool showCompletedTasks;

  @HiveField(16)
  final bool autoArchiveCompletedTasks;

  @HiveField(17)
  final int weekStartDay; // 1=Monday, 7=Sunday

  // Adhkar Reminder Settings
  @HiveField(18)
  final bool showMorningAdhkarReminder;

  @HiveField(19)
  final bool showEveningAdhkarReminder;

  @HiveField(20)
  final bool showAfterPrayerAdhkarReminder;

  @HiveField(21)
  final bool showSleepAdhkarReminder;

  @HiveField(22)
  final int morningAdhkarHour; // Hour to remind for morning adhkar

  @HiveField(23)
  final int eveningAdhkarHour; // Hour to remind for evening adhkar

  UserSettings({
    this.locationName,
    this.latitude,
    this.longitude,
    this.calculationMethod = 0,
    this.notificationsEnabled = true,
    this.defaultReminderMinutes = 10,
    this.showNafilaReminders = true,
    this.showTaskReminders = true,
    this.language = 'en',
    this.dailyReviewHour,
    this.dailyReviewMinute,
    this.isOnboardingComplete = false,
    this.useSilentNotifications = false,
    this.madhab = 0,
    this.use24HourFormat = true,
    this.showCompletedTasks = true,
    this.autoArchiveCompletedTasks = false,
    this.weekStartDay = 1,
    this.showMorningAdhkarReminder = true,
    this.showEveningAdhkarReminder = true,
    this.showAfterPrayerAdhkarReminder = false,
    this.showSleepAdhkarReminder = false,
    this.morningAdhkarHour = 6, // Default 6 AM
    this.eveningAdhkarHour = 17, // Default 5 PM
  });

  /// Get calculation method as enum
  CalculationMethod get calculationMethodEnum =>
      CalculationMethod.values[calculationMethod];

  /// Check if location is set
  bool get hasLocation => latitude != null && longitude != null;

  /// Create a copy with updated fields
  UserSettings copyWith({
    String? locationName,
    double? latitude,
    double? longitude,
    int? calculationMethod,
    bool? notificationsEnabled,
    int? defaultReminderMinutes,
    bool? showNafilaReminders,
    bool? showTaskReminders,
    String? language,
    int? dailyReviewHour,
    int? dailyReviewMinute,
    bool? isOnboardingComplete,
    bool? useSilentNotifications,
    int? madhab,
    bool? use24HourFormat,
    bool? showCompletedTasks,
    bool? autoArchiveCompletedTasks,
    int? weekStartDay,
    bool? showMorningAdhkarReminder,
    bool? showEveningAdhkarReminder,
    bool? showAfterPrayerAdhkarReminder,
    bool? showSleepAdhkarReminder,
    int? morningAdhkarHour,
    int? eveningAdhkarHour,
  }) {
    return UserSettings(
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
      showNafilaReminders: showNafilaReminders ?? this.showNafilaReminders,
      showTaskReminders: showTaskReminders ?? this.showTaskReminders,
      language: language ?? this.language,
      dailyReviewHour: dailyReviewHour ?? this.dailyReviewHour,
      dailyReviewMinute: dailyReviewMinute ?? this.dailyReviewMinute,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      useSilentNotifications:
          useSilentNotifications ?? this.useSilentNotifications,
      madhab: madhab ?? this.madhab,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      autoArchiveCompletedTasks:
          autoArchiveCompletedTasks ?? this.autoArchiveCompletedTasks,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      showMorningAdhkarReminder:
          showMorningAdhkarReminder ?? this.showMorningAdhkarReminder,
      showEveningAdhkarReminder:
          showEveningAdhkarReminder ?? this.showEveningAdhkarReminder,
      showAfterPrayerAdhkarReminder:
          showAfterPrayerAdhkarReminder ?? this.showAfterPrayerAdhkarReminder,
      showSleepAdhkarReminder:
          showSleepAdhkarReminder ?? this.showSleepAdhkarReminder,
      morningAdhkarHour: morningAdhkarHour ?? this.morningAdhkarHour,
      eveningAdhkarHour: eveningAdhkarHour ?? this.eveningAdhkarHour,
    );
  }

  /// Create default settings
  factory UserSettings.defaults() {
    return UserSettings(
      calculationMethod: 0,
      notificationsEnabled: true,
      defaultReminderMinutes: 10,
      showNafilaReminders: true,
      showTaskReminders: true,
      language: 'en',
      isOnboardingComplete: false,
      madhab: 0,
      use24HourFormat: true,
      showCompletedTasks: true,
      autoArchiveCompletedTasks: false,
      weekStartDay: 1,
      showMorningAdhkarReminder: true,
      showEveningAdhkarReminder: true,
      showAfterPrayerAdhkarReminder: false,
      showSleepAdhkarReminder: false,
      morningAdhkarHour: 6,
      eveningAdhkarHour: 17,
    );
  }

  @override
  String toString() =>
      'UserSettings(location: $locationName, method: $calculationMethodEnum)';
}
