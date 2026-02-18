import 'package:hive/hive.dart';
import '../models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing daily task resets
class DailyResetService {
  static const String _lastResetDateKey = 'last_daily_reset_date';

  final Box<Task> _tasksBox;

  DailyResetService(this._tasksBox);

  /// Get the date of the last daily reset
  Future<DateTime?> _getLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastResetDateKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Set the date of the last daily reset
  Future<void> _setLastResetDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastResetDateKey, date.millisecondsSinceEpoch);
  }

  /// Check if a reset is needed (hasn't been run today)
  Future<bool> _shouldReset() async {
    final lastReset = await _getLastResetDate();
    if (lastReset == null) return true;

    final now = DateTime.now();
    return lastReset.year != now.year ||
        lastReset.month != now.month ||
        lastReset.day != now.day;
  }

  /// Perform daily reset of recurring tasks
  Future<List<Task>> performDailyReset() async {
    final shouldReset = await _shouldReset();
    if (!shouldReset) {
      return [];
    }

    final now = DateTime.now();
    final newTasks = <Task>[];

    try {
      final allTasks = _tasksBox.values.toList();

      for (final task in allTasks) {
        if (!task.isRecurring || task.recurringPattern == null) {
          continue;
        }

        // Check if task is expired
        if (task.isRecurringExpired) {
          continue;
        }

        // Skip if not active (e.g., archived tasks)
        if (task.state != TaskState.active && 
            task.state != TaskState.completed && 
            task.state != TaskState.skipped) {
          continue;
        }

        final scheduledTime = task.scheduledTime;
        if (scheduledTime == null) continue;

        // Determine if we should generate next occurrence
        bool shouldGenerateNext = false;
        final lastReset = task.lastResetDate;

        switch (task.recurringPattern) {
          case 'daily':
            // Generate next occurrence if:
            // 1. Task was completed yesterday or earlier
            // 2. Task was skipped yesterday or earlier
            // 3. It's a new day and we haven't reset yet
            if (task.state == TaskState.completed || task.state == TaskState.skipped) {
              if (lastReset == null) {
                shouldGenerateNext = true;
              } else {
                // Check if last reset was before today
                shouldGenerateNext = lastReset.year != now.year ||
                    lastReset.month != now.month ||
                    lastReset.day != now.day;
              }
            }
            break;

          case 'weekly':
            // Generate if it's the same weekday and at least 7 days have passed
            if (task.state == TaskState.completed || task.state == TaskState.skipped) {
              if (scheduledTime.weekday == now.weekday) {
                if (lastReset == null) {
                  // First time - check if original scheduled date was at least 7 days ago
                  final daysSinceScheduled = now.difference(
                    DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day)
                  ).inDays;
                  shouldGenerateNext = daysSinceScheduled >= 7;
                } else {
                  // Check if at least 7 days since last reset
                  final daysSinceReset = now.difference(
                    DateTime(lastReset.year, lastReset.month, lastReset.day)
                  ).inDays;
                  shouldGenerateNext = daysSinceReset >= 7;
                }
              }
            }
            break;

          case 'monthly':
            // Generate if it's the same day of month and at least 28 days have passed
            if (task.state == TaskState.completed || task.state == TaskState.skipped) {
              if (scheduledTime.day == now.day) {
                if (lastReset == null) {
                  // First time - check if original scheduled date was at least 28 days ago
                  final daysSinceScheduled = now.difference(
                    DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day)
                  ).inDays;
                  shouldGenerateNext = daysSinceScheduled >= 28;
                } else {
                  // Check if at least 28 days since last reset
                  final daysSinceReset = now.difference(
                    DateTime(lastReset.year, lastReset.month, lastReset.day)
                  ).inDays;
                  shouldGenerateNext = daysSinceReset >= 28;
                }
              }
            }
            break;
        }

        // Generate next occurrence if needed
        if (shouldGenerateNext) {
          try {
            final nextTask = task.generateNextOccurrence();
            newTasks.add(nextTask);
            await _tasksBox.put(nextTask.id, nextTask);

            // Update original task to mark it as reset
            final updatedOriginal = task.copyWith(
              lastResetDate: now,
            );
            await _tasksBox.put(task.id, updatedOriginal);
          } catch (e) {
            print('Error generating next occurrence for task ${task.id}: $e');
          }
        }
      }

      // Update last reset date
      await _setLastResetDate(now);

      return newTasks;
    } catch (e) {
      print('Error performing daily reset: $e');
      return [];
    }
  }

  /// Archive old completed tasks (older than specified days)
  Future<int> archiveOldCompletedTasks({int daysOld = 7}) async {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: daysOld));
    int archivedCount = 0;

    try {
      final allTasks = _tasksBox.values.toList();

      for (final task in allTasks) {
        if (task.state == TaskState.completed &&
            task.completedAt != null &&
            task.completedAt!.isBefore(cutoffDate)) {
          final archived = task.copyWith(
            state: TaskState.archived,
            archivedAt: now,
          );
          await _tasksBox.put(task.id, archived);
          archivedCount++;
        }
      }

      return archivedCount;
    } catch (e) {
      print('Error archiving old completed tasks: $e');
      return 0;
    }
  }

  /// Clean up expired recurring tasks
  Future<int> cleanupExpiredRecurringTasks() async {
    final now = DateTime.now();
    int cleanedCount = 0;

    try {
      final allTasks = _tasksBox.values.toList();

      for (final task in allTasks) {
        if (task.isRecurringExpired && task.state != TaskState.archived) {
          final archived = task.copyWith(
            state: TaskState.archived,
            archivedAt: now,
          );
          await _tasksBox.put(task.id, archived);
          cleanedCount++;
        }
      }

      return cleanedCount;
    } catch (e) {
      print('Error cleaning up expired recurring tasks: $e');
      return 0;
    }
  }
}
