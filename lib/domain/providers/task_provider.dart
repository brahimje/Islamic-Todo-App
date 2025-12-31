import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_todo_app/data/models/task.dart';
import 'package:islamic_todo_app/data/datasources/local/hive_service.dart';
import 'package:islamic_todo_app/data/services/notification_service.dart';
import 'prayer_provider.dart';
import 'notification_provider.dart';

/// State notifier for managing tasks
class TaskNotifier extends StateNotifier<List<Task>> {
  final HiveService _hiveService;
  final NotificationService _notificationService;
  
  TaskNotifier(this._hiveService, this._notificationService) : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = _hiveService.tasksBox.values.toList();
    state = tasks;
  }

  Future<void> addTask(Task task) async {
    await _hiveService.tasksBox.put(task.id, task);
    state = [...state, task];
    
    // Schedule notification if task has reminder enabled
    await _scheduleTaskNotification(task);
  }

  Future<void> updateTask(Task task) async {
    await _hiveService.tasksBox.put(task.id, task);
    state = state.map((t) => t.id == task.id ? task : t).toList();
    
    // Reschedule notification
    await _notificationService.cancelTaskNotification(task.id, isReligious: task.isReligious);
    await _scheduleTaskNotification(task);
  }

  Future<void> deleteTask(String taskId) async {
    // Get task before deletion to check isReligious
    final task = state.firstWhere((t) => t.id == taskId, orElse: () => Task(
      id: taskId,
      title: '',
      createdAt: DateTime.now(),
    ));
    
    await _hiveService.tasksBox.delete(taskId);
    state = state.where((t) => t.id != taskId).toList();
    
    // Cancel notification
    await _notificationService.cancelTaskNotification(taskId, isReligious: task.isReligious);
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: task.isCompleted ? null : DateTime.now(),
    );
    await _hiveService.tasksBox.put(task.id, updatedTask);
    state = state.map((t) => t.id == taskId ? updatedTask : t).toList();
    
    // Cancel notification if completed
    if (updatedTask.isCompleted) {
      await _notificationService.cancelTaskNotification(taskId, isReligious: task.isReligious);
    } else {
      await _scheduleTaskNotification(updatedTask);
    }
  }
  
  /// Schedule notification for a task if it has reminder enabled
  Future<void> _scheduleTaskNotification(Task task) async {
    if (!task.hasNotification) return;
    if (task.isCompleted) return;
    if (task.scheduledTime == null || task.scheduledTime!.isBefore(DateTime.now())) return;

    await _notificationService.scheduleTaskNotification(
      taskId: task.id,
      taskTitle: task.title,
      scheduledTime: task.scheduledTime!,
      minutesBefore: 0, // Default to 0 if not specified in Task
      isReligious: task.isReligious,
      category: task.category,
    );
  }

  /// Reorder tasks within a prayer block using indices
  Future<void> reorderTasks(int oldIndex, int newIndex, String? blockId) async {
    if (blockId == null) return;

    // Get tasks in this block, sorted by current orderIndex
    final blockTasks = state
        .where((t) => t.prayerBlockId == blockId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    if (oldIndex < 0 || oldIndex >= blockTasks.length) {
      return;
    }
    if (newIndex < 0 || newIndex >= blockTasks.length) {
      return;
    }
    if (oldIndex == newIndex) {
      return;
    }

    // Remove and insert at new position
    final draggedTask = blockTasks.removeAt(oldIndex);
    blockTasks.insert(newIndex, draggedTask);

    // Build updated tasks list with new order indices
    final updatedBlockTasks = <Task>[];
    for (int i = 0; i < blockTasks.length; i++) {
      final task = blockTasks[i];
      final updatedTask = task.copyWith(orderIndex: i);
      updatedBlockTasks.add(updatedTask);
      await _hiveService.tasksBox.put(task.id, updatedTask);
    }

    // Update state immediately with new order (don't wait for reload)
    final newState = state.map((t) {
      if (t.prayerBlockId == blockId) {
        final updated = updatedBlockTasks.firstWhere(
          (u) => u.id == t.id,
          orElse: () => t,
        );
        return updated;
      }
      return t;
    }).toList();
    state = newState;
  }

  List<Task> getTasksForDate(DateTime date) {
    return state.where((t) {
      if (t.scheduledTime == null) return false;
      return t.scheduledTime!.year == date.year &&
             t.scheduledTime!.month == date.month &&
             t.scheduledTime!.day == date.day;
    }).toList();
  }

  List<Task> getTasksByCategory(String category) {
    return state.where((t) => t.category == category).toList();
  }

  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return state.where((t) =>
      !t.isCompleted &&
      t.deadline != null &&
      t.deadline!.isBefore(now)
    ).toList();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>(
  (ref) {
    final hiveService = ref.watch(hiveServiceProvider);
    final notificationService = ref.watch(notificationServiceProvider);
    return TaskNotifier(hiveService, notificationService);
  },
);

/// Provider for today's tasks
final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final today = DateTime.now();
  
  return tasks.where((t) {
    if (t.scheduledTime == null) return false;
    return t.scheduledTime!.year == today.year &&
           t.scheduledTime!.month == today.month &&
           t.scheduledTime!.day == today.day;
  }).toList()
    ..sort((a, b) {
      // Sort by completion status, then by priority
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.priority.compareTo(a.priority);
    });
});

/// Provider for incomplete tasks count
final incompleteTasksCountProvider = Provider<int>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((t) => !t.isCompleted).length;
});

/// Provider for tasks grouped by category
final tasksByCategoryProvider = Provider<Map<String, List<Task>>>((ref) {
  final tasks = ref.watch(taskProvider);
  final Map<String, List<Task>> grouped = {};
  
  for (final task in tasks) {
    final category = task.category ?? 'Uncategorized';
    grouped[category] = [...(grouped[category] ?? []), task];
  }
  
  return grouped;
});

/// Provider for task completion statistics
final taskStatsProvider = Provider<TaskStats>((ref) {
  final tasks = ref.watch(taskProvider);
  final today = DateTime.now();
  final weekAgo = today.subtract(const Duration(days: 7));
  
  final completedThisWeek = tasks.where((t) =>
    t.isCompleted &&
    t.completedAt != null &&
    t.completedAt!.isAfter(weekAgo)
  ).length;
  
  final totalThisWeek = tasks.where((t) =>
    t.createdAt.isAfter(weekAgo)
  ).length;
  
  return TaskStats(
    totalTasks: tasks.length,
    completedTasks: tasks.where((t) => t.isCompleted).length,
    pendingTasks: tasks.where((t) => !t.isCompleted).length,
    completedThisWeek: completedThisWeek,
    totalThisWeek: totalThisWeek,
    completionRate: totalThisWeek > 0 ? completedThisWeek / totalThisWeek : 0,
  );
});

/// Task statistics model
class TaskStats {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int completedThisWeek;
  final int totalThisWeek;
  final double completionRate;

  TaskStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completedThisWeek,
    required this.totalThisWeek,
    required this.completionRate,
  });
}
