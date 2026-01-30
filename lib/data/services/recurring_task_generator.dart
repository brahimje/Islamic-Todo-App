import 'package:uuid/uuid.dart';
import '../models/task.dart';

/// Service for generating recurring tasks
class RecurringTaskGenerator {
  static const _uuid = Uuid();

  /// Generate recurring task instances for the next N days
  static List<Task> generateRecurringInstances(
    Task baseTask, {
    int daysAhead = 7,
    DateTime? startDate,
  }) {
    if (!baseTask.isRecurring || baseTask.recurringPattern == null) {
      return [];
    }

    final now = startDate ?? DateTime.now();
    final instances = <Task>[];

    // Check if recurring has expired
    if (baseTask.isRecurringExpired) {
      return [];
    }

    // Generate instances based on pattern
    for (int i = 1; i <= daysAhead; i++) {
      DateTime nextDate;

      switch (baseTask.recurringPattern) {
        case 'daily':
          nextDate = now.add(Duration(days: i));
          break;
        case 'weekly':
          // Generate for the same day of week
          int daysToAdd = 0;
          for (int j = 1; j <= daysAhead; j++) {
            final candidate = now.add(Duration(days: j));
            if (candidate.weekday == baseTask.scheduledTime?.weekday) {
              daysToAdd = j;
              break;
            }
          }
          nextDate = now.add(Duration(days: daysToAdd));
          break;
        case 'monthly':
          // Generate for the same day of month
          int month = now.month + (i - 1);
          int year = now.year;
          while (month > 12) {
            month -= 12;
            year++;
          }

          // Handle day overflow (e.g., Jan 31 + 1 month = Feb 28/29)
          int day = baseTask.scheduledTime?.day ?? now.day;
          final lastDay = DateTime(year, month + 1, 0).day;
          if (day > lastDay) {
            day = lastDay;
          }

          nextDate = DateTime(year, month, day,
              baseTask.scheduledTime?.hour ?? 9, baseTask.scheduledTime?.minute ?? 0);
          break;
        default:
          continue;
      }

      // Don't generate for dates in the past
      if (nextDate.isBefore(now)) {
        continue;
      }

      // Check if recurring end date has passed
      if (baseTask.recurringEndDate != null &&
          nextDate.isAfter(baseTask.recurringEndDate!)) {
        break;
      }

      // Create a new instance
      try {
        final instance = _createInstance(baseTask, nextDate);
        instances.add(instance);
      } catch (e) {
        print('Error creating recurring instance: $e');
        continue;
      }
    }

    return instances;
  }

  /// Create a single recurring task instance
  static Task _createInstance(Task baseTask, DateTime scheduledTime) {
    return Task(
      id: '${baseTask.id}_${_uuid.v4().substring(0, 8)}',
      title: baseTask.title,
      description: baseTask.description,
      scheduledTime: scheduledTime,
      deadline: baseTask.deadline != null
          ? _updateDateToNewDate(baseTask.deadline!, scheduledTime)
          : null,
      estimatedMinutes: baseTask.estimatedMinutes,
      isCompleted: false,
      createdAt: DateTime.now(),
      completedAt: null,
      priority: baseTask.priority,
      hasNotification: baseTask.hasNotification,
      category: baseTask.category,
      tags: List.from(baseTask.tags),
      reminderMinutesBefore: baseTask.reminderMinutesBefore,
      isRecurring: true, // Keep as recurring for reference
      recurringPattern: baseTask.recurringPattern,
      isReligious: baseTask.isReligious,
      prayerBlockId: baseTask.prayerBlockId,
      orderIndex: baseTask.orderIndex,
      state: TaskState.active,
      lastResetDate: DateTime.now(),
      archivedAt: null,
      recurringEndDate: baseTask.recurringEndDate,
    );
  }

  /// Update a date to match the time of a new date while keeping the day
  static DateTime _updateDateToNewDate(DateTime original, DateTime newDate) {
    return DateTime(newDate.year, newDate.month, newDate.day,
        original.hour, original.minute);
  }

  /// Build a recurring task from a template
  static Task createRecurringTemplate({
    required String title,
    required String pattern, // daily, weekly, monthly
    required DateTime scheduledTime,
    String? description,
    DateTime? deadline,
    int? estimatedMinutes,
    int priority = 1,
    bool hasNotification = true,
    String? category,
    List<String> tags = const [],
    int reminderMinutesBefore = 10,
    bool isReligious = false,
    String? prayerBlockId,
    int orderIndex = 0,
    DateTime? recurringEndDate,
  }) {
    return Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      scheduledTime: scheduledTime,
      deadline: deadline,
      estimatedMinutes: estimatedMinutes,
      isCompleted: false,
      createdAt: DateTime.now(),
      completedAt: null,
      priority: priority,
      hasNotification: hasNotification,
      category: category,
      tags: tags,
      reminderMinutesBefore: reminderMinutesBefore,
      isRecurring: true,
      recurringPattern: pattern,
      isReligious: isReligious,
      prayerBlockId: prayerBlockId,
      orderIndex: orderIndex,
      state: TaskState.active,
      lastResetDate: null,
      archivedAt: null,
      recurringEndDate: recurringEndDate,
    );
  }
}
