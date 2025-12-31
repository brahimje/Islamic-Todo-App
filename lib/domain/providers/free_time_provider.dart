import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task.dart';
import '../../data/services/free_time_service.dart';
import 'prayer_provider.dart';
import 'task_provider.dart';

// ============================================================================
// UNIFIED TIME MANAGEMENT SYSTEM
// ============================================================================
// This is the SINGLE SOURCE OF TRUTH for all time calculations in the app.
// All components must use these providers to ensure consistency:
//
// 1. Block Management:
//    - freeTimeBlocksProvider: List of all free time blocks for today
//    - blockTimeUsageProvider: Map of block usage (scheduled, remaining, etc.)
//
// 2. Time Queries (use these instead of calculating manually):
//    - getBlockRemainingMinutes(): Get remaining minutes for a block
//    - canScheduleTask(): Check if a task fits in a block
//    - validateTaskScheduling(): Full validation before adding/updating task
//
// 3. Rules:
//    - Past blocks: remainingMinutes = 0
//    - Current blocks: min(schedule-remaining, real-time-remaining)
//    - Future blocks: total - scheduled
//    - Preparation time is already subtracted from availableDuration
// ============================================================================

/// Provider for prayer time settings
final prayerTimeSettingsProvider = StateNotifierProvider<PrayerTimeSettingsNotifier, PrayerTimeSettings>((ref) {
  return PrayerTimeSettingsNotifier();
});

class PrayerTimeSettingsNotifier extends StateNotifier<PrayerTimeSettings> {
  PrayerTimeSettingsNotifier() : super(const PrayerTimeSettings());

  void updateSettings({
    Map<String, int>? preparationTimes,
    Map<String, int>? prayerDurations,
    int? sleepHour,
    int? sleepMinute,
    int? wakeUpMinutesBefore,
    bool? enableQiyam,
    QiyamWakeTimeOption? qiyamWakeOption,
    int? qiyamCustomMinutes,
  }) {
    state = state.copyWith(
      preparationTimes: preparationTimes,
      prayerDurations: prayerDurations,
      sleepHour: sleepHour,
      sleepMinute: sleepMinute,
      wakeUpMinutesBefore: wakeUpMinutesBefore,
      enableQiyam: enableQiyam,
      qiyamWakeOption: qiyamWakeOption,
      qiyamCustomMinutes: qiyamCustomMinutes,
    );
  }

  /// Update preparation time for a specific prayer
  void setPreparationTime(String prayerName, int minutes) {
    final updated = Map<String, int>.from(state.preparationTimes);
    updated[prayerName] = minutes;
    state = state.copyWith(preparationTimes: updated);
  }

  /// Update prayer duration for a specific prayer
  void setPrayerDuration(String prayerName, int minutes) {
    final updated = Map<String, int>.from(state.prayerDurations);
    updated[prayerName] = minutes;
    state = state.copyWith(prayerDurations: updated);
  }

  void toggleQiyam() {
    state = state.copyWith(enableQiyam: !state.enableQiyam);
  }

  void setSleepTime(int hour, int minute) {
    state = state.copyWith(sleepHour: hour, sleepMinute: minute);
  }

  /// Set Qiyam wake time option
  void setQiyamWakeOption(QiyamWakeTimeOption option) {
    state = state.copyWith(qiyamWakeOption: option);
  }

  /// Set custom Qiyam minutes (for custom option)
  void setQiyamCustomMinutes(int minutes) {
    state = state.copyWith(qiyamCustomMinutes: minutes);
  }
}

/// Provider for free time service
final freeTimeServiceProvider = Provider<FreeTimeService>((ref) {
  final settings = ref.watch(prayerTimeSettingsProvider);
  return FreeTimeService(settings: settings);
});

/// Provider for all free time blocks
final freeTimeBlocksProvider = Provider<List<FreeTimeBlock>>((ref) {
  final prayerTimes = ref.watch(prayerTimesProvider);
  final freeTimeService = ref.watch(freeTimeServiceProvider);
  
  return freeTimeService.calculateFreeTimeBlocks(prayerTimes);
});

/// Provider for Qiyam al-Layl times
final qiyamTimesProvider = Provider<QiyamTimes>((ref) {
  final prayerTimes = ref.watch(prayerTimesProvider);
  final freeTimeService = ref.watch(freeTimeServiceProvider);
  
  return freeTimeService.calculateQiyamTimes(prayerTimes);
});

/// Provider for total available time (sum of ALL blocks including Qiyam)
final totalAvailableTimeProvider = Provider<Duration>((ref) {
  final blocks = ref.watch(freeTimeBlocksProvider);
  
  // Sum ALL blocks for total available time
  return blocks.fold(Duration.zero, (total, block) => total + block.availableDuration);
});

/// Provider for total scheduled task time for today
/// This includes ALL tasks (completed and incomplete) that have been assigned time
final scheduledTaskTimeProvider = Provider<Duration>((ref) {
  final tasks = ref.watch(todayTasksProvider);
  
  int totalMinutes = 0;
  for (final task in tasks) {
    // Count ALL tasks with estimated time (completed or not)
    // This represents time that has been allocated/planned
    if (task.estimatedMinutes != null) {
      totalMinutes += task.estimatedMinutes!;
    }
  }
  
  return Duration(minutes: totalMinutes);
});

/// Provider for remaining available time (real-time-aware)
/// Only counts time in current/future blocks, not past time
final remainingAvailableTimeProvider = Provider<Duration>((ref) {
  final timeUsage = ref.watch(timeUsageProvider);
  return timeUsage.remaining;
});

/// Provider for time usage breakdown
/// This provider gives a real-time-aware view of time allocation
final timeUsageProvider = Provider<TimeUsage>((ref) {
  final blocks = ref.watch(freeTimeBlocksProvider);
  final scheduledTime = ref.watch(scheduledTaskTimeProvider);
  final settings = ref.watch(prayerTimeSettingsProvider);
  final tasks = ref.watch(todayTasksProvider);
  final prayerTimes = ref.watch(prayerTimesProvider);
  final freeTimeService = ref.watch(freeTimeServiceProvider);
  final now = DateTime.now();
  
  // Calculate actual remaining free time considering:
  // 1. Only future time is available (past blocks are gone)
  // 2. Current block: only remaining real time counts
  // 3. Subtract already scheduled tasks from future blocks
  
  int totalFutureMinutes = 0; // Time that is actually available (not in the past)
  int scheduledInFutureMinutes = 0; // Tasks scheduled in current/future blocks
  
  for (final block in blocks) {
    // Get tasks in this block
    final blockTasks = tasks.where((t) => t.prayerBlockId == block.id).toList();
    int blockScheduledMinutes = 0;
    for (final task in blockTasks) {
      if (task.estimatedMinutes != null) {
        blockScheduledMinutes += task.estimatedMinutes!;
      }
    }
    
    if (block.endTime.isBefore(now)) {
      // Past block - no available time left, tasks are already counted as used
      continue;
    } else if (block.startTime.isBefore(now) && block.endTime.isAfter(now)) {
      // Current block - only remaining real time is available
      final remainingInBlock = block.endTime.difference(now).inMinutes;
      totalFutureMinutes += remainingInBlock;
      // Scheduled tasks still count (they need to be done in remaining time)
      scheduledInFutureMinutes += blockScheduledMinutes;
    } else {
      // Future block - full time available
      totalFutureMinutes += block.availableDuration.inMinutes;
      scheduledInFutureMinutes += blockScheduledMinutes;
    }
  }
  
  // Calculate completed task time (for display purposes)
  int completedMinutes = 0;
  for (final task in tasks) {
    if (task.isCompleted && task.estimatedMinutes != null) {
      completedMinutes += task.estimatedMinutes!;
    }
  }
  
  // Qiyam time - calculate based on selected Sunnah option
  int qiyamMinutes = 0;
  if (settings.enableQiyam && prayerTimes != null) {
    final qiyamTimes = freeTimeService.calculateQiyamTimes(prayerTimes);
    final duration = qiyamTimes.getQiyamDurationForOption(
      settings.qiyamWakeOption,
      settings.qiyamCustomMinutes,
    );
    qiyamMinutes = duration.inMinutes;
  }
  
  // Calculate sleep duration
  Duration sleepDuration = Duration.zero;
  if (prayerTimes != null) {
    final sleepTime = settings.getSleepTime(now);
    final qiyamTimes = freeTimeService.calculateQiyamTimes(prayerTimes);
    
    // Wake time depends on Qiyam settings
    DateTime wakeTime;
    if (settings.enableQiyam) {
      wakeTime = qiyamTimes.getWakeTimeForOption(
        settings.qiyamWakeOption,
        settings.qiyamCustomMinutes,
      );
    } else {
      wakeTime = qiyamTimes.fajr; // Wake at Fajr
    }
    
    sleepDuration = wakeTime.difference(sleepTime);
    // Handle if sleep time is after midnight
    if (sleepDuration.isNegative) {
      sleepDuration = sleepDuration + const Duration(hours: 24);
    }
  }
  
  return TimeUsage(
    totalFutureAvailable: Duration(minutes: totalFutureMinutes),
    scheduledInFuture: Duration(minutes: scheduledInFutureMinutes),
    totalScheduled: scheduledTime,
    completedTasks: Duration(minutes: completedMinutes),
    qiyamTime: Duration(minutes: qiyamMinutes),
    sleepTime: sleepDuration,
  );
});

/// Time usage breakdown model
/// Real-time aware - only counts actual available future time
class TimeUsage {
  /// Time available in current + future blocks (excludes past time)
  final Duration totalFutureAvailable;
  
  /// Time scheduled for tasks in current + future blocks
  final Duration scheduledInFuture;
  
  /// Total scheduled time for all tasks today (for reference)
  final Duration totalScheduled;
  
  /// Time spent on completed tasks (for display purposes)
  final Duration completedTasks;
  
  /// Time dedicated to Qiyam (subtracted from free time)
  final Duration qiyamTime;
  
  /// Sleep duration (subtracted from free time)
  final Duration sleepTime;
  
  TimeUsage({
    required this.totalFutureAvailable,
    required this.scheduledInFuture,
    required this.totalScheduled,
    required this.completedTasks,
    required this.qiyamTime,
    required this.sleepTime,
  });
  
  /// Real free time remaining = Future Available - Scheduled Tasks in Future
  /// Note: Qiyam and Sleep are typically in separate blocks, not subtracted here
  Duration get remaining {
    final remaining = totalFutureAvailable - scheduledInFuture;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  double get usagePercentage {
    if (totalFutureAvailable.inMinutes == 0) return 0;
    // Usage = scheduled in future / future available
    final used = scheduledInFuture.inMinutes;
    return (used / totalFutureAvailable.inMinutes).clamp(0.0, 1.0);
  }
}

/// Provider for current free time block
final currentFreeTimeBlockProvider = Provider<FreeTimeBlock?>((ref) {
  final blocks = ref.watch(freeTimeBlocksProvider);
  return blocks.where((b) => b.isCurrentBlock).firstOrNull;
});

/// Provider for time used per block (blockId -> minutes used)
/// This is the PRIMARY source of truth for block time tracking
final blockTimeUsageProvider = Provider<Map<String, BlockTimeUsage>>((ref) {
  final tasks = ref.watch(todayTasksProvider);
  final blocks = ref.watch(freeTimeBlocksProvider);
  final now = DateTime.now();
  
  final Map<String, BlockTimeUsage> usage = {};
  
  for (final block in blocks) {
    final blockTasks = tasks.where((t) => t.prayerBlockId == block.id).toList();
    int scheduledMinutes = 0;
    int completedMinutes = 0;
    
    for (final task in blockTasks) {
      if (task.estimatedMinutes != null) {
        scheduledMinutes += task.estimatedMinutes!;
        if (task.isCompleted) {
          completedMinutes += task.estimatedMinutes!;
        }
      }
    }
    
    // Calculate elapsed time in this block (for past and current blocks)
    int elapsedMinutes = 0;
    if (block.endTime.isBefore(now)) {
      // Block is completely in the past - all time has elapsed
      elapsedMinutes = block.availableDuration.inMinutes;
    } else if (block.startTime.isBefore(now) && block.endTime.isAfter(now)) {
      // Current block - calculate how much time has passed
      elapsedMinutes = now.difference(block.startTime).inMinutes;
    }
    // Future blocks have 0 elapsed time
    
    // Wasted time = elapsed time - completed task time (but not negative)
    final wastedMinutes = (elapsedMinutes - completedMinutes).clamp(0, elapsedMinutes);
    
    usage[block.id] = BlockTimeUsage(
      blockId: block.id,
      totalAvailable: block.availableDuration.inMinutes,
      scheduledMinutes: scheduledMinutes,
      completedMinutes: completedMinutes,
      elapsedMinutes: elapsedMinutes,
      wastedMinutes: wastedMinutes,
      taskCount: blockTasks.length,
      isPast: block.endTime.isBefore(now),
      isCurrent: block.isCurrentBlock,
    );
  }
  
  return usage;
});

/// Time usage for a specific block
class BlockTimeUsage {
  final String blockId;
  final int totalAvailable;
  final int scheduledMinutes;
  final int completedMinutes;
  final int elapsedMinutes;
  final int wastedMinutes;
  final int taskCount;
  final bool isPast;
  final bool isCurrent;
  
  BlockTimeUsage({
    required this.blockId,
    required this.totalAvailable,
    required this.scheduledMinutes,
    required this.completedMinutes,
    required this.elapsedMinutes,
    required this.wastedMinutes,
    required this.taskCount,
    required this.isPast,
    required this.isCurrent,
  });
  
  /// Remaining time available to schedule new tasks
  /// For current blocks: min of (total - scheduled, total - elapsed)
  /// For past blocks: 0
  /// For future blocks: total - scheduled
  int get remainingMinutes {
    if (isPast) return 0;
    
    final scheduleRemaining = totalAvailable - scheduledMinutes;
    
    if (isCurrent) {
      final realRemaining = totalAvailable - elapsedMinutes;
      return scheduleRemaining.clamp(0, realRemaining.clamp(0, totalAvailable));
    }
    
    return scheduleRemaining.clamp(0, totalAvailable);
  }
  
  // For current block: remaining real time (not yet elapsed)
  int get remainingRealMinutes => (totalAvailable - elapsedMinutes).clamp(0, totalAvailable);
  
  bool get isFull => remainingMinutes <= 0;
  bool get hasWastedTime => wastedMinutes > 0;
  
  double get usagePercentage => totalAvailable > 0 ? (scheduledMinutes / totalAvailable).clamp(0.0, 1.0) : 0.0;
  double get completionPercentage => scheduledMinutes > 0 ? (completedMinutes / scheduledMinutes).clamp(0.0, 1.0) : 0.0;
  double get wastedPercentage => totalAvailable > 0 ? (wastedMinutes / totalAvailable).clamp(0.0, 1.0) : 0.0;
}

/// Provider for remaining time in current block
final remainingTimeProvider = Provider<Duration?>((ref) {
  final currentBlock = ref.watch(currentFreeTimeBlockProvider);
  if (currentBlock == null) return null;

  final settings = ref.watch(prayerTimeSettingsProvider);
  final now = DateTime.now();
  final prepTime = settings.getPreparationTime(currentBlock.beforePrayer);
  final effectiveEnd = currentBlock.endTime.subtract(Duration(minutes: prepTime));
  
  if (now.isAfter(effectiveEnd)) return Duration.zero;
  return effectiveEnd.difference(now);
});

/// Provider for upcoming blocks
final upcomingBlocksProvider = Provider<List<FreeTimeBlock>>((ref) {
  final blocks = ref.watch(freeTimeBlocksProvider);
  final now = DateTime.now();
  return blocks.where((b) => b.startTime.isAfter(now)).toList();
});

/// Calculate remaining available minutes for a specific block
/// 
/// This function mirrors BlockTimeUsage.remainingMinutes but with the ability
/// to exclude a specific task (used when editing an existing task).
/// 
/// IMPORTANT: This uses the SAME LOGIC as BlockTimeUsage.remainingMinutes:
/// - Past blocks: 0
/// - Current blocks: min(total - scheduled, total - elapsed)
/// - Future blocks: total - scheduled
/// 
/// Use this function in UI screens (like add_edit_task_screen) where you need
/// to check remaining time while excluding the current task being edited.
/// 
/// Use blockTimeUsageProvider in displays (like prayer_timeline_widget) where
/// you need the full picture without exclusions.
int calculateBlockRemainingMinutes({
  required List<FreeTimeBlock> blocks,
  required List<Task> tasks,
  required String blockId,
  String? excludeTaskId,
}) {
  final now = DateTime.now();
  
  // Find the block
  final block = blocks.where((b) => b.id == blockId).firstOrNull;
  if (block == null) return 0;
  
  // Past blocks have no available time
  if (block.endTime.isBefore(now)) return 0;
  
  // Calculate time already scheduled by tasks in this block
  int scheduledMinutes = 0;
  for (final task in tasks) {
    if (task.prayerBlockId == blockId && 
        task.estimatedMinutes != null &&
        task.id != excludeTaskId) { // Exclude the task being edited
      scheduledMinutes += task.estimatedMinutes!;
    }
  }
  
  // Base remaining = total available - already scheduled
  int remaining = block.availableDuration.inMinutes - scheduledMinutes;
  
  // For current block, also account for elapsed real time
  if (block.isCurrentBlock && now.isAfter(block.startTime)) {
    final elapsedMinutes = now.difference(block.startTime).inMinutes;
    final realRemaining = block.availableDuration.inMinutes - elapsedMinutes;
    // Take the minimum of schedule-based and real-time-based remaining
    remaining = remaining.clamp(0, realRemaining.clamp(0, 999));
  }
  
  return remaining.clamp(0, 999);
}

// ============================================================================
// VALIDATION FUNCTIONS - Use these before adding/updating tasks
// ============================================================================

/// Result of task scheduling validation
class TaskSchedulingValidation {
  final bool isValid;
  final String? errorMessage;
  final int availableMinutes;
  final int requestedMinutes;
  
  const TaskSchedulingValidation({
    required this.isValid,
    this.errorMessage,
    required this.availableMinutes,
    required this.requestedMinutes,
  });
  
  factory TaskSchedulingValidation.valid({
    required int availableMinutes,
    required int requestedMinutes,
  }) => TaskSchedulingValidation(
    isValid: true,
    availableMinutes: availableMinutes,
    requestedMinutes: requestedMinutes,
  );
  
  factory TaskSchedulingValidation.invalid({
    required String message,
    required int availableMinutes,
    required int requestedMinutes,
  }) => TaskSchedulingValidation(
    isValid: false,
    errorMessage: message,
    availableMinutes: availableMinutes,
    requestedMinutes: requestedMinutes,
  );
}

/// Validate if a task can be scheduled in a block
/// This is the SINGLE validation function - use this everywhere!
TaskSchedulingValidation validateTaskScheduling({
  required List<FreeTimeBlock> blocks,
  required List<Task> tasks,
  required String? blockId,
  required int? estimatedMinutes,
  String? excludeTaskId, // Exclude when editing
}) {
  // If no block selected, task can be scheduled (unassigned task)
  if (blockId == null) {
    return TaskSchedulingValidation.valid(
      availableMinutes: 999,
      requestedMinutes: estimatedMinutes ?? 0,
    );
  }
  
  // Find the block
  final block = blocks.where((b) => b.id == blockId).firstOrNull;
  if (block == null) {
    return TaskSchedulingValidation.invalid(
      message: 'Selected time block not found',
      availableMinutes: 0,
      requestedMinutes: estimatedMinutes ?? 0,
    );
  }
  
  // Check if block is in the past
  final now = DateTime.now();
  if (block.endTime.isBefore(now)) {
    return TaskSchedulingValidation.invalid(
      message: 'Cannot schedule tasks in past time blocks',
      availableMinutes: 0,
      requestedMinutes: estimatedMinutes ?? 0,
    );
  }
  
  // Calculate remaining time
  final availableMinutes = calculateBlockRemainingMinutes(
    blocks: blocks,
    tasks: tasks,
    blockId: blockId,
    excludeTaskId: excludeTaskId,
  );
  
  // If no estimated time, task can be added (but with warning)
  if (estimatedMinutes == null || estimatedMinutes == 0) {
    // Allow tasks without time estimate, but block must have some time
    if (availableMinutes <= 0) {
      return TaskSchedulingValidation.invalid(
        message: 'This block is fully scheduled',
        availableMinutes: availableMinutes,
        requestedMinutes: 0,
      );
    }
    return TaskSchedulingValidation.valid(
      availableMinutes: availableMinutes,
      requestedMinutes: 0,
    );
  }
  
  // Check if task fits
  if (estimatedMinutes > availableMinutes) {
    return TaskSchedulingValidation.invalid(
      message: 'Task duration ($estimatedMinutes min) exceeds available time ($availableMinutes min)',
      availableMinutes: availableMinutes,
      requestedMinutes: estimatedMinutes,
    );
  }
  
  return TaskSchedulingValidation.valid(
    availableMinutes: availableMinutes,
    requestedMinutes: estimatedMinutes,
  );
}

/// Quick check if a task with given minutes can fit in a block
bool canScheduleTask({
  required List<FreeTimeBlock> blocks,
  required List<Task> tasks,
  required String blockId,
  required int minutes,
  String? excludeTaskId,
}) {
  final remaining = calculateBlockRemainingMinutes(
    blocks: blocks,
    tasks: tasks,
    blockId: blockId,
    excludeTaskId: excludeTaskId,
  );
  return minutes <= remaining;
}

/// Get the maximum minutes that can be scheduled in a block
int getMaxSchedulableMinutes({
  required List<FreeTimeBlock> blocks,
  required List<Task> tasks,
  required String blockId,
  String? excludeTaskId,
}) {
  return calculateBlockRemainingMinutes(
    blocks: blocks,
    tasks: tasks,
    blockId: blockId,
    excludeTaskId: excludeTaskId,
  );
}

/// Provider to suggest best block for a task duration
final bestBlockForTaskProvider = Provider.family<FreeTimeBlock?, Duration>((ref, taskDuration) {
  final blocks = ref.watch(freeTimeBlocksProvider);
  final remaining = ref.watch(remainingTimeProvider);
  
  // First try current block
  final currentBlock = ref.watch(currentFreeTimeBlockProvider);
  if (currentBlock != null && remaining != null && remaining >= taskDuration) {
    return currentBlock;
  }

  // Find smallest suitable upcoming block
  final now = DateTime.now();
  final suitableBlocks = blocks
      .where((b) => b.canFitTask(taskDuration) && b.startTime.isAfter(now))
      .toList()
    ..sort((a, b) => a.availableDuration.compareTo(b.availableDuration));

  return suitableBlocks.firstOrNull;
});
