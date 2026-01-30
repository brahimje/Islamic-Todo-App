import 'package:hive/hive.dart';

part 'task.g.dart';

/// Priority levels for tasks
@HiveType(typeId: 6)
enum TaskPriority {
  @HiveField(0)
  low,

  @HiveField(1)
  medium,

  @HiveField(2)
  high,
}

/// Task state enum for lifecycle tracking
@HiveType(typeId: 10)
enum TaskState {
  @HiveField(0)
  active,

  @HiveField(1)
  completed,

  @HiveField(2)
  skipped,

  @HiveField(3)
  archived,

  @HiveField(4)
  overdue,
}

/// Represents a user task
@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime? scheduledTime;

  @HiveField(4)
  final DateTime? deadline;

  @HiveField(5)
  final int? estimatedMinutes;

  @HiveField(6)
  final bool isCompleted;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? completedAt;

  @HiveField(9)
  final int priority; // 0=low, 1=medium, 2=high

  @HiveField(10)
  final bool hasNotification;

  @HiveField(11)
  final String? category;

  @HiveField(12)
  final List<String> tags;

  @HiveField(13)
  final int reminderMinutesBefore;

  @HiveField(14)
  final bool isRecurring;

  @HiveField(15)
  final String? recurringPattern; // daily, weekly, monthly

  @HiveField(16)
  final bool isReligious; // Religious task (Quran, Dhikr, etc.) vs Normal

  @HiveField(17)
  final String? prayerBlockId; // Which prayer block this task belongs to

  @HiveField(18)
  final int orderIndex; // Order within the prayer block (for drag/drop reordering)

  @HiveField(19)
  final TaskState state; // Current state of the task

  @HiveField(20)
  final DateTime? archivedAt; // When the task was archived

  @HiveField(21)
  final DateTime? lastResetDate; // Last time this recurring task was reset

  @HiveField(22)
  final DateTime? recurringEndDate; // When recurring ends (optional)

  Task({
    required this.id,
    required this.title,
    this.description,
    this.scheduledTime,
    this.deadline,
    this.estimatedMinutes,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.priority = 1,
    this.hasNotification = false,
    this.category,
    this.tags = const [],
    this.reminderMinutesBefore = 10,
    this.isRecurring = false,
    this.recurringPattern,
    this.isReligious = false,
    this.prayerBlockId,
    this.orderIndex = 0,
    this.state = TaskState.active,
    this.archivedAt,
    this.lastResetDate,
    this.recurringEndDate,
  });

  /// Get priority as enum
  TaskPriority get priorityEnum => TaskPriority.values[priority];

  /// Check if task is scheduled for today
  bool get isScheduledForToday {
    if (scheduledTime == null) return false;
    final now = DateTime.now();
    return scheduledTime!.year == now.year &&
        scheduledTime!.month == now.month &&
        scheduledTime!.day == now.day;
  }

  /// Check if task is due today
  bool get isDueToday {
    if (deadline == null) return false;
    final now = DateTime.now();
    return deadline!.year == now.year &&
        deadline!.month == now.month &&
        deadline!.day == now.day;
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Check if task is due soon (within 24 hours)
  bool get isDueSoon {
    if (deadline == null || isCompleted) return false;
    final diff = deadline!.difference(DateTime.now());
    return diff.inHours <= 24 && diff.inHours > 0;
  }

  /// Get formatted estimated time
  String get formattedEstimatedTime {
    if (estimatedMinutes == null) return '';
    if (estimatedMinutes! >= 60) {
      final hours = estimatedMinutes! ~/ 60;
      final mins = estimatedMinutes! % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${estimatedMinutes}m';
  }

  /// Check if task is active (not archived, not completed today)
  bool get isActive => state == TaskState.active;

  /// Check if task should be visible in the UI (not archived)
  bool get isVisible => state != TaskState.archived;

  /// Check if task can be marked as recurring
  bool get canRecur => isRecurring && recurringPattern != null;

  /// Check if recurring task has expired
  bool get isRecurringExpired => 
    isRecurring && 
    recurringEndDate != null && 
    DateTime.now().isAfter(recurringEndDate!);

  /// Generate a new task for the next occurrence of a recurring task
  Task generateNextOccurrence() {
    if (!isRecurring || recurringPattern == null) {
      throw Exception('Cannot generate next occurrence for non-recurring task');
    }

    final now = DateTime.now();
    DateTime nextScheduledTime;

    switch (recurringPattern) {
      case 'daily':
        nextScheduledTime = DateTime(now.year, now.month, now.day + 1,
            scheduledTime?.hour ?? 9, scheduledTime?.minute ?? 0);
        break;
      case 'weekly':
        nextScheduledTime = now.add(const Duration(days: 7));
        nextScheduledTime = DateTime(nextScheduledTime.year, nextScheduledTime.month,
            nextScheduledTime.day, scheduledTime?.hour ?? 9, scheduledTime?.minute ?? 0);
        break;
      case 'monthly':
        nextScheduledTime = DateTime(now.year, now.month + 1, now.day,
            scheduledTime?.hour ?? 9, scheduledTime?.minute ?? 0);
        break;
      default:
        throw Exception('Unknown recurring pattern: $recurringPattern');
    }

    // Check if recurring has expired
    if (isRecurringExpired) {
      throw Exception('Recurring task has expired');
    }

    return copyWith(
      id: '${id}_${DateTime.now().millisecondsSinceEpoch}',
      scheduledTime: nextScheduledTime,
      isCompleted: false,
      completedAt: null,
      state: TaskState.active,
      lastResetDate: now,
    );
  }

  /// Create a copy with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    DateTime? deadline,
    int? estimatedMinutes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? priority,
    bool? hasNotification,
    String? category,
    List<String>? tags,
    int? reminderMinutesBefore,
    bool? isRecurring,
    String? recurringPattern,
    bool? isReligious,
    String? prayerBlockId,
    int? orderIndex,
    TaskState? state,
    DateTime? archivedAt,
    DateTime? lastResetDate,
    DateTime? recurringEndDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      deadline: deadline ?? this.deadline,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      hasNotification: hasNotification ?? this.hasNotification,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      isReligious: isReligious ?? this.isReligious,
      prayerBlockId: prayerBlockId ?? this.prayerBlockId,
      orderIndex: orderIndex ?? this.orderIndex,
      state: state ?? this.state,
      archivedAt: archivedAt ?? this.archivedAt,
      lastResetDate: lastResetDate ?? this.lastResetDate,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
    );
  }

  @override
  String toString() =>
      'Task(title: $title, completed: $isCompleted, priority: $priorityEnum)';
}
