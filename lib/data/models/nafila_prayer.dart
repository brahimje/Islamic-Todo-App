import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'nafila_prayer.g.dart';

/// Frequency options for Nafila prayers
@HiveType(typeId: 5)
enum NafilaFrequency {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  occasionally,

  @HiveField(3)
  asNeeded,
}

/// Represents a user's selected Nafila (voluntary) prayer
@HiveType(typeId: 1)
class NafilaPrayer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String prayerInfoId; // Reference to NafilaPrayerInfo

  @HiveField(2)
  final bool isEnabled;

  @HiveField(3)
  final int frequency; // 0=daily, 1=weekly, 2=occasionally, 3=asNeeded

  @HiveField(4)
  final int? preferredHour;

  @HiveField(5)
  final int? preferredMinute;

  @HiveField(6)
  final List<int> selectedDays; // 1=Monday, 7=Sunday

  @HiveField(7)
  final bool notificationEnabled;

  @HiveField(8)
  final int reminderMinutesBefore;

  @HiveField(9)
  final int customRakahCount;

  @HiveField(10)
  final DateTime? lastCompletedAt;

  @HiveField(11)
  final int streakCount;

  @HiveField(12)
  final int totalCompletions;

  NafilaPrayer({
    required this.id,
    required this.prayerInfoId,
    this.isEnabled = false,
    this.frequency = 0,
    this.preferredHour,
    this.preferredMinute,
    this.selectedDays = const [],
    this.notificationEnabled = false,
    this.reminderMinutesBefore = 10,
    this.customRakahCount = 2,
    this.lastCompletedAt,
    this.streakCount = 0,
    this.totalCompletions = 0,
  });

  /// Get frequency as enum
  NafilaFrequency get frequencyEnum => NafilaFrequency.values[frequency];

  /// Get preferred time as TimeOfDay
  TimeOfDay? get preferredTime {
    if (preferredHour != null && preferredMinute != null) {
      return TimeOfDay(hour: preferredHour!, minute: preferredMinute!);
    }
    return null;
  }

  /// Check if this prayer is scheduled for today
  bool get isScheduledForToday {
    if (!isEnabled) return false;
    if (frequencyEnum == NafilaFrequency.daily) return true;
    if (frequencyEnum == NafilaFrequency.weekly) {
      final today = DateTime.now().weekday;
      return selectedDays.contains(today);
    }
    return false;
  }

  /// Check if completed today
  bool get isCompletedToday {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    return lastCompletedAt!.year == now.year &&
        lastCompletedAt!.month == now.month &&
        lastCompletedAt!.day == now.day;
  }

  /// Create a copy with updated fields
  NafilaPrayer copyWith({
    String? id,
    String? prayerInfoId,
    bool? isEnabled,
    int? frequency,
    int? preferredHour,
    int? preferredMinute,
    List<int>? selectedDays,
    bool? notificationEnabled,
    int? reminderMinutesBefore,
    int? customRakahCount,
    DateTime? lastCompletedAt,
    int? streakCount,
    int? totalCompletions,
  }) {
    return NafilaPrayer(
      id: id ?? this.id,
      prayerInfoId: prayerInfoId ?? this.prayerInfoId,
      isEnabled: isEnabled ?? this.isEnabled,
      frequency: frequency ?? this.frequency,
      preferredHour: preferredHour ?? this.preferredHour,
      preferredMinute: preferredMinute ?? this.preferredMinute,
      selectedDays: selectedDays ?? this.selectedDays,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      customRakahCount: customRakahCount ?? this.customRakahCount,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      streakCount: streakCount ?? this.streakCount,
      totalCompletions: totalCompletions ?? this.totalCompletions,
    );
  }

  @override
  String toString() =>
      'NafilaPrayer(id: $prayerInfoId, enabled: $isEnabled, streak: $streakCount)';
}
