import 'package:hive/hive.dart';

part 'prayer.g.dart';

/// Represents a daily obligatory (Fard) prayer
@HiveType(typeId: 0)
class Prayer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime time;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final bool notificationEnabled;

  @HiveField(6)
  final int reminderMinutesBefore;

  @HiveField(7)
  final DateTime? completedAt;

  Prayer({
    required this.id,
    required this.name,
    required this.time,
    this.isCompleted = false,
    required this.date,
    this.notificationEnabled = true,
    this.reminderMinutesBefore = 10,
    this.completedAt,
  });

  /// Create a copy with updated fields
  Prayer copyWith({
    String? id,
    String? name,
    DateTime? time,
    bool? isCompleted,
    DateTime? date,
    bool? notificationEnabled,
    int? reminderMinutesBefore,
    DateTime? completedAt,
  }) {
    return Prayer(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Check if this prayer time has passed
  bool get hasPassed => DateTime.now().isAfter(time);

  /// Check if this is the next upcoming prayer
  bool get isUpcoming => !hasPassed && !isCompleted;

  @override
  String toString() => 'Prayer(name: $name, time: $time, completed: $isCompleted)';
}
