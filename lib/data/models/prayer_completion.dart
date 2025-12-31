import 'package:hive/hive.dart';

part 'prayer_completion.g.dart';

/// Tracks daily prayer completion for history and statistics
@HiveType(typeId: 9)
class PrayerCompletion extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int fajrCompleted; // 0=not, 1=completed, 2=missed

  @HiveField(3)
  final int dhuhrCompleted;

  @HiveField(4)
  final int asrCompleted;

  @HiveField(5)
  final int maghribCompleted;

  @HiveField(6)
  final int ishaCompleted;

  @HiveField(7)
  final List<String> nafilaCompleted; // List of nafila prayer IDs completed

  @HiveField(8)
  final DateTime? fajrCompletedAt;

  @HiveField(9)
  final DateTime? dhuhrCompletedAt;

  @HiveField(10)
  final DateTime? asrCompletedAt;

  @HiveField(11)
  final DateTime? maghribCompletedAt;

  @HiveField(12)
  final DateTime? ishaCompletedAt;

  PrayerCompletion({
    required this.id,
    required this.date,
    this.fajrCompleted = 0,
    this.dhuhrCompleted = 0,
    this.asrCompleted = 0,
    this.maghribCompleted = 0,
    this.ishaCompleted = 0,
    this.nafilaCompleted = const [],
    this.fajrCompletedAt,
    this.dhuhrCompletedAt,
    this.asrCompletedAt,
    this.maghribCompletedAt,
    this.ishaCompletedAt,
  });

  /// Get total fard prayers completed
  int get fardCompletedCount {
    int count = 0;
    if (fajrCompleted == 1) count++;
    if (dhuhrCompleted == 1) count++;
    if (asrCompleted == 1) count++;
    if (maghribCompleted == 1) count++;
    if (ishaCompleted == 1) count++;
    return count;
  }

  /// Get total prayers completed (fard + nafila)
  int get totalCompletedCount => fardCompletedCount + nafilaCompleted.length;

  /// Check if all fard prayers are completed
  bool get allFardCompleted => fardCompletedCount == 5;

  /// Get completion percentage for fard prayers
  double get fardCompletionPercentage => fardCompletedCount / 5 * 100;

  /// Create a copy with updated fields
  PrayerCompletion copyWith({
    String? id,
    DateTime? date,
    int? fajrCompleted,
    int? dhuhrCompleted,
    int? asrCompleted,
    int? maghribCompleted,
    int? ishaCompleted,
    List<String>? nafilaCompleted,
    DateTime? fajrCompletedAt,
    DateTime? dhuhrCompletedAt,
    DateTime? asrCompletedAt,
    DateTime? maghribCompletedAt,
    DateTime? ishaCompletedAt,
  }) {
    return PrayerCompletion(
      id: id ?? this.id,
      date: date ?? this.date,
      fajrCompleted: fajrCompleted ?? this.fajrCompleted,
      dhuhrCompleted: dhuhrCompleted ?? this.dhuhrCompleted,
      asrCompleted: asrCompleted ?? this.asrCompleted,
      maghribCompleted: maghribCompleted ?? this.maghribCompleted,
      ishaCompleted: ishaCompleted ?? this.ishaCompleted,
      nafilaCompleted: nafilaCompleted ?? this.nafilaCompleted,
      fajrCompletedAt: fajrCompletedAt ?? this.fajrCompletedAt,
      dhuhrCompletedAt: dhuhrCompletedAt ?? this.dhuhrCompletedAt,
      asrCompletedAt: asrCompletedAt ?? this.asrCompletedAt,
      maghribCompletedAt: maghribCompletedAt ?? this.maghribCompletedAt,
      ishaCompletedAt: ishaCompletedAt ?? this.ishaCompletedAt,
    );
  }

  @override
  String toString() =>
      'PrayerCompletion(date: $date, fard: $fardCompletedCount/5, nafila: ${nafilaCompleted.length})';
}
