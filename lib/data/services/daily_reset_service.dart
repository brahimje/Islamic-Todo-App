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

        // For daily recurring tasks that were completed, reset them
        if (task.recurringPattern == 'daily' && task.state == TaskState.completed) {
          // Check if the last reset was yesterday (task has already been reset today)
          final lastReset = task.lastResetDate;
          if (lastReset != null) {
            if (lastReset.year == now.year &&
                lastReset.month == now.month &&
                lastReset.day == now.day) {
              // Already reset today, skip
              continue;
            }
          }

          // Generate next occurrence
          try {
            final nextTask = task.generateNextOccurrence();
            newTasks.add(nextTask);
            await _tasksBox.put(nextTask.id, nextTask);

            // Update original task to reflect last reset date
            final updatedOriginal = task.copyWith(lastResetDate: now);
            await _tasksBox.put(task.id, updatedOriginal);
          } catch (e) {
            print('Error generating next occurrence for task ${task.id}: $e');
          }
        }

        // Reactivate skipped daily tasks that are today
        if (task.recurringPattern == 'daily' &&
            task.state == TaskState.skipped &&
            task.scheduledTime != null) {
          final lastReset = task.lastResetDate;
          if (lastReset == null ||
              lastReset.year != now.year ||
              lastReset.month != now.month ||
              lastReset.day != now.day) {
            final reactivated = task.copyWith(
              state: TaskState.active,
              lastResetDate: now,
            );
            await _tasksBox.put(task.id, reactivated);
          }
        }

        // For weekly/monthly, check if they're due again
        if ((task.recurringPattern == 'weekly' ||
                task.recurringPattern == 'monthly') &&
            task.state == TaskState.completed &&
            task.scheduledTime != null) {
          final scheduled = task.scheduledTime!;
          bool isDueAgain = false;

          if (task.recurringPattern == 'weekly') {
            // Check if it's the same day of the week and at least 7 days have passed
            final daysDiff = now.difference(DateTime(
                    scheduled.year, scheduled.month, scheduled.day))
                .inDays;
            isDueAgain = daysDiff >= 7 && scheduled.weekday == now.weekday;
          } else if (task.recurringPattern == 'monthly') {
            // Check if the day of month matches and at least 30 days have passed
            isDueAgain = scheduled.day == now.day &&
                now.difference(scheduled).inDays >= 30;
          }

          if (isDueAgain) {
            try {
              final nextTask = task.generateNextOccurrence();
              newTasks.add(nextTask);
              await _tasksBox.put(nextTask.id, nextTask);
            } catch (e) {
              print('Error generating next occurrence for task ${task.id}: $e');
            }
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
