import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/models/task.dart';
import '../../../../data/services/free_time_service.dart';
import '../../../../domain/providers/free_time_provider.dart';
import '../../../../domain/providers/prayer_provider.dart';
import '../../../../domain/providers/settings_provider.dart';
import '../../../../domain/providers/task_provider.dart';

/// Unified prayer timeline showing prayers, free time, and tasks
class PrayerTimelineWidget extends ConsumerWidget {
  const PrayerTimelineWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(todayPrayersProvider);
    final blocks = ref.watch(freeTimeBlocksProvider);
    final tasks = ref.watch(todayTasksProvider);
    final timeUsage = ref.watch(timeUsageProvider);
    final settings = ref.watch(prayerTimeSettingsProvider);
    final qiyamTimes = ref.watch(qiyamTimesProvider);
    final completionNotifier = ref.read(prayerCompletionProvider.notifier);

    // Build timeline items
    final timelineItems = _buildTimelineItems(
      prayers: prayers,
      blocks: blocks,
      tasks: tasks,
      settings: settings,
      qiyamTimes: qiyamTimes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with time usage
        _buildHeader(context, timeUsage, settings, qiyamTimes),
        const SizedBox(height: AppDimensions.spacingMd),
        
        // Timeline
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Column(
            children: [
              for (int i = 0; i < timelineItems.length; i++) ...[
                _buildTimelineItem(
                  context,
                  ref,
                  timelineItems[i],
                  isFirst: i == 0,
                  isLast: i == timelineItems.length - 1,
                  onPrayerToggle: (prayerName, isCompleted) {
                    if (isCompleted) {
                      completionNotifier.unmarkPrayerCompleted(prayerName);
                    } else {
                      completionNotifier.markPrayerCompleted(prayerName);
                    }
                  },
                ),
                if (i < timelineItems.length - 1)
                  const Divider(height: 1, indent: 56),
              ],
            ],
          ),
        ),

        // Qiyam al-Layl section
        if (settings.enableQiyam) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          _buildQiyamSection(context, qiyamTimes),
        ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context, TimeUsage timeUsage, PrayerTimeSettings settings, QiyamTimes qiyamTimes) {
    final remaining = timeUsage.remaining;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final hasScheduledTime = timeUsage.scheduledInFuture.inMinutes > 0 || timeUsage.qiyamTime.inMinutes > 0;
    
    // Calculate sleep info
    final now = DateTime.now();
    final sleepTime = settings.getSleepTime(now);
    final sleepTimeStr = DateFormat('HH:mm').format(sleepTime);
    
    // Calculate wake time based on Qiyam settings
    String wakeTimeStr;
    if (settings.enableQiyam) {
      final wakeTime = qiyamTimes.getWakeTimeForOption(
        settings.qiyamWakeOption, 
        settings.qiyamCustomMinutes,
      );
      wakeTimeStr = DateFormat('HH:mm').format(wakeTime);
    } else {
      // Default wake at Fajr time
      wakeTimeStr = DateFormat('HH:mm').format(qiyamTimes.fajr);
    }
    
    // Calculate sleep duration
    Duration sleepDuration;
    if (settings.enableQiyam) {
      final wakeTime = qiyamTimes.getWakeTimeForOption(
        settings.qiyamWakeOption,
        settings.qiyamCustomMinutes,
      );
      sleepDuration = wakeTime.difference(sleepTime);
    } else {
      sleepDuration = qiyamTimes.fajr.difference(sleepTime);
    }
    // Handle if sleep time is after midnight calculation
    if (sleepDuration.isNegative) {
      sleepDuration = sleepDuration + const Duration(hours: 24);
    }
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.gray700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Schedule',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Prayer prep info
                    Row(
                      children: [
                        Icon(
                          Icons.mosque,
                          size: 12,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${settings.getPreparationTime("Fajr")}m prep',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Sleep info
                        Icon(
                          Icons.bedtime_outlined,
                          size: 12,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$sleepTimeStr→$wakeTimeStr (${_formatDuration(sleepDuration)})',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.gray400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMd,
                  vertical: AppDimensions.paddingSm,
                ),
                decoration: BoxDecoration(
                  color: remaining.inMinutes > 0 
                      ? AppColors.white
                      : AppColors.gray800,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule, 
                      size: 16, 
                      color: remaining.inMinutes > 0 ? AppColors.black : AppColors.gray400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m free',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: remaining.inMinutes > 0 ? AppColors.black : AppColors.gray400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Show time breakdown if there are scheduled items
          if (hasScheduledTime) ...[
            const SizedBox(height: 12),
            _buildTimeBreakdown(context, timeUsage),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeBreakdown(BuildContext context, TimeUsage timeUsage) {
    // Build list of items to subtract
    final subtractItems = <Widget>[];
    
    if (timeUsage.scheduledInFuture.inMinutes > 0) {
      subtractItems.add(_buildTimeChip(context, 'Tasks', _formatDuration(timeUsage.scheduledInFuture), AppColors.gray300));
    }
    if (timeUsage.qiyamTime.inMinutes > 0) {
      subtractItems.add(_buildTimeChip(context, 'Qiyam', _formatDuration(timeUsage.qiyamTime), AppColors.gray400));
    }
    if (timeUsage.sleepTime.inMinutes > 0) {
      subtractItems.add(_buildTimeChip(context, 'Sleep', _formatDuration(timeUsage.sleepTime), AppColors.gray500));
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray700),
      ),
      child: Row(
        children: [
          _buildTimeChip(context, 'Available', _formatDuration(timeUsage.totalFutureAvailable), AppColors.white),
          const SizedBox(width: 6),
          const Text('−', style: TextStyle(color: AppColors.gray500, fontSize: 12)),
          const SizedBox(width: 6),
          // Show subtract items with minus signs between them
          for (int i = 0; i < subtractItems.length; i++) ...[
            subtractItems[i],
            if (i < subtractItems.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('−', style: TextStyle(color: AppColors.gray500, fontSize: 12)),
              ),
          ],
          const Spacer(),
          const Text('=', style: TextStyle(color: AppColors.gray500, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 6),
          _buildTimeChip(context, 'Free', _formatDuration(timeUsage.remaining), AppColors.white, isBold: true),
        ],
      ),
    );
  }

  Widget _buildTimeChip(BuildContext context, String label, String value, Color color, {bool isBold = false}) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  List<_TimelineItem> _buildTimelineItems({
    required List prayers,
    required List<FreeTimeBlock> blocks,
    required List<Task> tasks,
    required PrayerTimeSettings settings,
    required QiyamTimes qiyamTimes,
  }) {
    final items = <_TimelineItem>[];
    final now = DateTime.now();

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final isPast = prayer.time.isBefore(now);
      final isNext = !isPast && (i == 0 || prayers[i - 1].time.isBefore(now));

      // Add prayer item
      items.add(_TimelineItem(
        type: _TimelineItemType.prayer,
        title: prayer.name,
        time: prayer.time,
        isCompleted: prayer.isCompleted,
        isPast: isPast,
        isActive: isNext,
      ));

      // Find free time block after this prayer
      final block = blocks.where((b) => b.afterPrayer == prayer.name).firstOrNull;
      if (block != null && block.availableDuration.inMinutes > 0) {
        // Find tasks scheduled in this time block by prayerBlockId
        final blockTasks = tasks.where((t) {
          // Match by prayerBlockId (primary method)
          if (t.prayerBlockId != null) {
            return t.prayerBlockId == block.id;
          }
          // Fallback: match by scheduled time
          if (t.scheduledTime == null) return false;
          return t.scheduledTime!.isAfter(block.startTime) &&
                 t.scheduledTime!.isBefore(block.endTime);
        }).toList();
        
        // Sort tasks by orderIndex for proper drag/drop ordering
        blockTasks.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

        items.add(_TimelineItem(
          type: _TimelineItemType.freeTime,
          title: block.durationText,
          subtitle: block.timeRangeText,
          time: block.startTime,
          endTime: block.endTime,
          duration: block.availableDuration,
          isActive: block.isCurrentBlock,
          isPast: block.endTime.isBefore(now),
          tasks: blockTasks,
          beforePrayer: block.beforePrayer,
          blockId: block.id,
          availableMinutes: block.availableDuration.inMinutes,
        ));
      }
    }

    // Add sleep item
    final sleepTime = settings.getSleepTime(DateTime.now());
    items.add(_TimelineItem(
      type: _TimelineItemType.sleep,
      title: 'Sleep',
      time: sleepTime,
      isPast: sleepTime.isBefore(now),
    ));

    return items;
  }

  Widget _buildTimelineItem(
    BuildContext context,
    WidgetRef ref,
    _TimelineItem item, {
    required bool isFirst,
    required bool isLast,
    required Function(String, bool) onPrayerToggle,
  }) {
    final userSettings = ref.watch(settingsProvider);
    final timeFormat = userSettings.use24HourFormat ? 'HH:mm' : 'h:mm a';
    final timeStr = DateFormat(timeFormat).format(item.time);

    switch (item.type) {
      case _TimelineItemType.prayer:
        return _buildPrayerRow(context, item, timeStr, onPrayerToggle);
      case _TimelineItemType.freeTime:
        return _buildFreeTimeRow(context, ref, item);
      case _TimelineItemType.sleep:
        return _buildSleepRow(context, item, timeStr);
    }
  }

  Widget _buildPrayerRow(
    BuildContext context,
    _TimelineItem item,
    String timeStr,
    Function(String, bool) onPrayerToggle,
  ) {
    return InkWell(
      onTap: () => onPrayerToggle(item.title, item.isCompleted),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm + 4,
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isCompleted
                    ? AppColors.black
                    : item.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppColors.white,
                border: Border.all(
                  color: item.isCompleted
                      ? AppColors.black
                      : item.isActive
                          ? Colors.green
                          : AppColors.gray300,
                  width: 2,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : item.isActive
                      ? Container(
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
            ),
            const SizedBox(width: AppDimensions.spacingMd),

            // Prayer info
            Expanded(
              child: Row(
                children: [
                  Icon(
                    _getPrayerIcon(item.title),
                    size: 18,
                    color: item.isPast ? AppColors.gray400 : AppColors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: item.isPast ? AppColors.gray500 : AppColors.black,
                      decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (item.isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Time
            Text(
              timeStr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: item.isActive ? Colors.green : AppColors.gray500,
                fontWeight: item.isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeTimeRow(BuildContext context, WidgetRef ref, _TimelineItem item) {
    final hasTasks = item.tasks != null && item.tasks!.isNotEmpty;
    final blockUsage = ref.watch(blockTimeUsageProvider);
    final usage = item.blockId != null ? blockUsage[item.blockId] : null;
    
    // Calculate remaining time for scheduling
    final remainingMinutes = usage?.remainingMinutes ?? item.availableMinutes;
    final isFull = usage?.isFull ?? false;
    final usagePercentage = usage?.usagePercentage ?? 0.0;
    
    // Wasted time tracking
    final wastedMinutes = usage?.wastedMinutes ?? 0;
    final hasWastedTime = wastedMinutes > 0;
    final isPastBlock = usage?.isPast ?? item.isPast;
    final isCurrentBlock = usage?.isCurrent ?? item.isActive;
    
    // For current block, show remaining real time
    final remainingRealMinutes = usage?.remainingRealMinutes ?? remainingMinutes;
    
    // Color coding for time status
    Color statusColor;
    String statusText;
    IconData? statusIcon;
    
    if (isPastBlock) {
      // Past block - show wasted time or completed status
      if (hasWastedTime) {
        statusColor = AppColors.error;
        final hours = wastedMinutes ~/ 60;
        final mins = wastedMinutes % 60;
        statusText = hours > 0 ? '${hours}h ${mins}m lost' : '${mins}m lost';
        statusIcon = Icons.warning_amber_rounded;
      } else if (usage != null && usage.completedMinutes > 0) {
        statusColor = Colors.green;
        statusText = 'Completed';
        statusIcon = Icons.check_circle_outline;
      } else {
        statusColor = AppColors.gray400;
        statusText = 'Passed';
      }
    } else if (isCurrentBlock) {
      // Current block - show remaining real time
      if (remainingRealMinutes <= 0) {
        statusColor = AppColors.error;
        statusText = 'Ending';
      } else if (remainingRealMinutes <= 15) {
        statusColor = Colors.orange;
        statusText = '${remainingRealMinutes}m left';
      } else {
        statusColor = Colors.green;
        final hours = remainingRealMinutes ~/ 60;
        final mins = remainingRealMinutes % 60;
        statusText = hours > 0 ? '${hours}h ${mins}m left' : '${mins}m left';
      }
    } else {
      // Future block - show remaining time to schedule
      if (isFull) {
        statusColor = Colors.blue;
        statusText = 'Planned';
        statusIcon = Icons.event_available;
      } else if (remainingMinutes <= 15) {
        statusColor = Colors.amber;
        statusText = '${remainingMinutes}m free';
      } else {
        statusColor = Colors.green;
        final hours = remainingMinutes ~/ 60;
        final mins = remainingMinutes % 60;
        statusText = hours > 0 ? '${hours}h ${mins}m free' : '${mins}m free';
      }
    }
    
    return Container(
      color: isCurrentBlock
          ? Colors.green.withValues(alpha: 0.05)
          : isPastBlock && hasWastedTime
              ? AppColors.error.withValues(alpha: 0.03)
              : AppColors.gray50,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Free time header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCurrentBlock
                      ? Colors.green.withValues(alpha: 0.2)
                      : isPastBlock && hasWastedTime
                          ? AppColors.error.withValues(alpha: 0.2)
                          : AppColors.gray200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isPastBlock && hasWastedTime ? Icons.hourglass_empty : Icons.access_time,
                  size: 16,
                  color: isCurrentBlock 
                      ? Colors.green 
                      : isPastBlock && hasWastedTime
                          ? AppColors.error
                          : AppColors.gray500,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCurrentBlock
                                ? Colors.green
                                : isPastBlock
                                    ? AppColors.gray300
                                    : AppColors.gray700,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (statusIcon != null) ...[
                                Icon(statusIcon, size: 10, color: statusColor),
                                const SizedBox(width: 3),
                              ],
                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Progress bar (show for blocks with tasks or wasted time)
                    if (usage != null && (usage.taskCount > 0 || hasWastedTime)) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final totalWidth = constraints.maxWidth;
                                final completedWidth = totalWidth * usage.completionPercentage * usagePercentage;
                                final scheduledWidth = totalWidth * usagePercentage;
                                final wastedWidth = totalWidth * usage.wastedPercentage;
                                
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: SizedBox(
                                    height: 4,
                                    child: Stack(
                                      children: [
                                        // Background
                                        Container(
                                          width: totalWidth,
                                          height: 4,
                                          color: AppColors.gray200,
                                        ),
                                        // Scheduled (light green)
                                        if (usage.scheduledMinutes > 0)
                                          Container(
                                            width: scheduledWidth,
                                            height: 4,
                                            color: Colors.green.withValues(alpha: 0.4),
                                          ),
                                        // Completed (green)
                                        if (usage.completedMinutes > 0)
                                          Container(
                                            width: completedWidth,
                                            height: 4,
                                            color: Colors.green,
                                          ),
                                        // Wasted time (red) - from the right side
                                        if (hasWastedTime && isPastBlock)
                                          Positioned(
                                            right: 0,
                                            child: Container(
                                              width: wastedWidth,
                                              height: 4,
                                              color: AppColors.error,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasWastedTime && isPastBlock
                                ? '${usage.completedMinutes}m done'
                                : '${usage.taskCount} task${usage.taskCount > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Add task button (disabled when full or past)
              if (!isPastBlock)
                GestureDetector(
                  onTap: isFull ? null : () {
                    final blockId = item.blockId;
                    if (blockId != null) {
                      context.push('${AppRoutes.addTask}?blockId=$blockId');
                    } else {
                      context.push(AppRoutes.addTask);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isFull 
                          ? AppColors.gray300 
                          : (isCurrentBlock ? Colors.green : AppColors.black),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isFull ? Icons.check : Icons.add,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),

          // Tasks in this block
          if (hasTasks) ...[
            const SizedBox(height: 8),
            _buildReorderableTaskList(context, ref, item.tasks!, item.blockId),
          ],
        ],
      ),
    );
  }

  Widget _buildReorderableTaskList(BuildContext context, WidgetRef ref, List<Task> tasks, String? blockId) {
    if (blockId == null || tasks.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: tasks.map((task) => _buildTaskItem(context, ref, task, 0, 1, null)).toList(),
      );
    }
    
    return _ReorderableTaskListWidget(
      tasks: tasks,
      blockId: blockId,
      ref: ref,
      buildTaskItem: (task, index, totalCount) => _buildDraggableTaskItem(
        key: ValueKey('reorder_${task.id}'),
        context: context,
        ref: ref,
        task: task,
        index: index,
        totalCount: totalCount,
        blockId: blockId,
      ),
    );
  }

  Widget _buildDraggableTaskItem({
    required Key key,
    required BuildContext context,
    required WidgetRef ref,
    required Task task,
    required int index,
    required int totalCount,
    required String? blockId,
  }) {
    final taskColor = _getTaskColor(task);
    final taskNotifier = ref.read(taskProvider.notifier);
    
    // Wrap with key for ReorderableListView
    return KeyedSubtree(
      key: key,
      child: Dismissible(
        key: ValueKey('dismiss_${task.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(left: 40, top: 4),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(
            Icons.delete_outline,
            color: AppColors.white,
            size: 20,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Task'),
              content: Text('Delete "${task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) {
          taskNotifier.deleteTask(task.id);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 40, top: 4),
          child: GestureDetector(
            onTap: () => _showTaskDetailsSheet(context, ref, task),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: taskColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: taskColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  // Drag handle for reordering
                  if (totalCount > 1)
                    ReorderableDragStartListener(
                      index: index,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Icon(
                            Icons.drag_indicator,
                            size: 20,
                            color: taskColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  if (totalCount > 1)
                    const SizedBox(width: 4),
                  // Religious indicator icon
                  if (task.isReligious)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.mosque,
                        size: 14,
                        color: taskColor,
                      ),
                    ),
                // Completion checkbox
                GestureDetector(
                  onTap: () => taskNotifier.toggleTaskCompletion(task.id),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? taskColor
                          : Colors.transparent,
                      border: Border.all(
                        color: taskColor,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 12, color: AppColors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: taskColor,
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      // Show category and description
                      if (task.category != null || (task.description != null && task.description!.isNotEmpty))
                        Text(
                          _formatTaskSubtitle(task),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: taskColor.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (task.estimatedMinutes != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: taskColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.formattedEstimatedTime,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: taskColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildTaskItem(BuildContext context, WidgetRef ref, Task task, int index, int totalCount, String? blockId) {
    final taskColor = _getTaskColor(task);
    final taskNotifier = ref.read(taskProvider.notifier);
    
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 4),
      child: GestureDetector(
        onTap: () => _showTaskDetailsSheet(context, ref, task),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: taskColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: taskColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Religious indicator icon
              if (task.isReligious)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.mosque,
                    size: 14,
                    color: taskColor,
                  ),
                ),
              // Completion checkbox
              GestureDetector(
                onTap: () => taskNotifier.toggleTaskCompletion(task.id),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? taskColor
                        : Colors.transparent,
                    border: Border.all(
                      color: taskColor,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 12, color: AppColors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: taskColor,
                        fontWeight: FontWeight.w500,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.category != null || (task.description != null && task.description!.isNotEmpty))
                      Text(
                        _formatTaskSubtitle(task),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: taskColor.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (task.estimatedMinutes != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: taskColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.formattedEstimatedTime,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: taskColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, Task task, TaskNotifier taskNotifier) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              taskNotifier.deleteTask(task.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  /// Show task details in a bottom sheet
  void _showTaskDetailsSheet(BuildContext context, WidgetRef ref, Task task) {
    final userSettings = ref.read(settingsProvider);
    final timeFormat = userSettings.use24HourFormat ? 'MMM d, HH:mm' : 'MMM d, h:mm a';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isReligious ? AppColors.gray800 : AppColors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        task.isReligious ? Icons.mosque : Icons.work_outline,
                        size: 12,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.isReligious ? 'Religious' : 'Normal',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isCompleted 
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: task.isCompleted 
                          ? Colors.green.withValues(alpha: 0.3)
                          : AppColors.gray200,
                    ),
                  ),
                  child: Text(
                    task.isCompleted ? '✓ Completed' : 'Pending',
                    style: TextStyle(
                      color: task.isCompleted ? Colors.green : AppColors.gray600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              task.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            // Description
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                task.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            
            // Details grid
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                if (task.category != null)
                  _buildDetailItem(context, Icons.label_outline, 'Category', task.category!),
                if (task.estimatedMinutes != null)
                  _buildDetailItem(context, Icons.timer_outlined, 'Duration', task.formattedEstimatedTime),
                _buildDetailItem(
                  context, 
                  Icons.flag_outlined, 
                  'Priority', 
                  task.priority == 0 ? 'Low' : task.priority == 1 ? 'Medium' : 'High',
                ),
                if (task.scheduledTime != null)
                  _buildDetailItem(
                    context, 
                    Icons.access_time, 
                    'Scheduled', 
                    DateFormat(timeFormat).format(task.scheduledTime!),
                  ),
                if (task.deadline != null)
                  _buildDetailItem(
                    context, 
                    Icons.event, 
                    'Deadline', 
                    DateFormat('MMM d, yyyy').format(task.deadline!),
                  ),
                _buildDetailItem(
                  context, 
                  Icons.notifications_outlined, 
                  'Reminder', 
                  task.hasNotification ? 'On' : 'Off',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('${AppRoutes.editTask}/${task.id}');
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      side: const BorderSide(color: AppColors.gray300),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      task.isCompleted ? Icons.undo : Icons.check,
                      size: 18,
                    ),
                    label: Text(task.isCompleted ? 'Undo' : 'Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    return SizedBox(
      width: 140,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.gray500),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.gray500,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepRow(BuildContext context, _TimelineItem item, String timeStr) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingSm + 4,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bedtime,
              size: 16,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              'Sleep',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.gray600,
              ),
            ),
          ),
          Text(
            timeStr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiyamSection(BuildContext context, QiyamTimes qiyamTimes) {
    return Consumer(
      builder: (context, ref, child) {
        final todayCompletion = ref.watch(todayPrayerCompletionProvider);
        final isQiyamCompleted = todayCompletion.nafilaCompleted.contains('qiyam');
        final settings = ref.watch(prayerTimeSettingsProvider);
        final userSettings = ref.watch(settingsProvider);
        final timeFormat = userSettings.use24HourFormat ? 'HH:mm' : 'h:mm a';
        
        // Get the selected wake time and duration
        final wakeTime = qiyamTimes.wakeUpTime;
        final qiyamDuration = qiyamTimes.fajr.difference(wakeTime);
        final durationText = qiyamDuration.inHours > 0 
            ? '${qiyamDuration.inHours}h ${qiyamDuration.inMinutes % 60}m'
            : '${qiyamDuration.inMinutes}m';
        
        // Check if it's Qiyam time now
        final now = DateTime.now();
        final isQiyamTime = now.isAfter(wakeTime) && now.isBefore(qiyamTimes.fajr);
        
        return GestureDetector(
          onTap: () => _showQiyamBottomSheet(context, ref, qiyamTimes, qiyamDuration, timeFormat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd, vertical: AppDimensions.paddingSm + 4),
            decoration: BoxDecoration(
              color: isQiyamCompleted ? AppColors.gray900 : AppColors.black,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: isQiyamTime ? AppColors.white : isQiyamCompleted ? AppColors.gray600 : AppColors.gray700,
                width: isQiyamTime ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Completion toggle
                GestureDetector(
                  onTap: () {
                    final notifier = ref.read(prayerCompletionProvider.notifier);
                    if (isQiyamCompleted) {
                      notifier.unmarkNafilaCompleted('qiyam');
                    } else {
                      notifier.markNafilaCompleted('qiyam');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isQiyamCompleted ? AppColors.white : AppColors.gray800,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gray600),
                    ),
                    child: Icon(
                      isQiyamCompleted ? Icons.check : Icons.nights_stay,
                      color: isQiyamCompleted ? AppColors.black : AppColors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Qiyam al-Layl',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (isQiyamTime)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('NOW', style: TextStyle(color: AppColors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          if (isQiyamCompleted && !isQiyamTime)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gray700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('✓', style: TextStyle(color: AppColors.white, fontSize: 10)),
                            ),
                        ],
                      ),
                      Text(
                        '${DateFormat(timeFormat).format(wakeTime)} → ${DateFormat(timeFormat).format(qiyamTimes.fajr)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
                      ),
                    ],
                  ),
                ),
                // Duration badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gray800,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    durationText,
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.gray500, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQiyamBottomSheet(BuildContext context, WidgetRef ref, QiyamTimes qiyamTimes, Duration qiyamDuration, String timeFormat) {
    final settings = ref.read(prayerTimeSettingsProvider);
    final wakeTime = qiyamTimes.wakeUpTime;
    final recommendedRakaat = _getRecommendedRakaat(qiyamDuration.inMinutes);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.nights_stay, color: AppColors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Qiyam al-Layl', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('قيام الليل - ${QiyamTimes.getArabicName(settings.qiyamWakeOption)}', style: const TextStyle(color: AppColors.gray400, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Time info
            Row(
              children: [
                Expanded(
                  child: _buildQiyamInfoCard(context, 'Wake Up', DateFormat(timeFormat).format(wakeTime), Icons.alarm),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQiyamInfoCard(context, 'Until Fajr', DateFormat(timeFormat).format(qiyamTimes.fajr), Icons.wb_twilight),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Recommendations
            Text('Recommended', style: TextStyle(color: AppColors.gray400, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildRecommendationChip('🕌 ${recommendedRakaat.rakaat} Rakaat'),
                _buildRecommendationChip('📖 Quran'),
                _buildRecommendationChip('🤲 Dua'),
                _buildRecommendationChip('💧 Witr'),
              ],
            ),
            const SizedBox(height: 16),
            // Hadith
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Text(
                      '"ينزل ربنا تبارك وتعالى كل ليلة إلى السماء الدنيا حين يبقى ثلث الليل الآخر"',
                      style: TextStyle(color: AppColors.gray300, fontSize: 12, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Our Lord descends every night to the lowest heaven when the last third remains.', style: TextStyle(color: AppColors.gray500, fontSize: 10)),
                  const Text('— Sahih al-Bukhari & Muslim', style: TextStyle(color: AppColors.gray600, fontSize: 9, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildQiyamInfoCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gray400, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.gray500, fontSize: 10)),
              Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gray800,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.white, fontSize: 12)),
    );
  }

  Widget _buildSunnahGuidance(BuildContext context, Duration qiyamDuration) {
    // Calculate recommended rakaat based on duration
    final minutes = qiyamDuration.inMinutes;
    final recommendedRakaat = _getRecommendedRakaat(minutes);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Actions',
          style: TextStyle(
            color: AppColors.gray400,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSunnahChip('🕌 ${recommendedRakaat.rakaat} Rakaat', recommendedRakaat.description),
            _buildSunnahChip('📖 Quran Recitation', 'Read or listen'),
            _buildSunnahChip('🤲 Dua & Istighfar', 'Best time for dua'),
            _buildSunnahChip('💧 Witr', 'End with odd number'),
          ],
        ),
        const SizedBox(height: 10),
        // Surah recommendations
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gray800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray700),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_stories, color: AppColors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recite: Al-Mulk, As-Sajdah, Al-Muzammil, or your memorized surahs',
                  style: TextStyle(
                    color: AppColors.gray400,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSunnahChip(String text, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.gray800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray600),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  ({int rakaat, String description}) _getRecommendedRakaat(int availableMinutes) {
    // Based on Sunnah: Prophet ﷺ usually prayed 11 rakaat including Witr
    // Minimum: 2 rakaat + 1 Witr = 3
    // Each 2 rakaat takes approximately 5-10 minutes
    
    if (availableMinutes >= 120) {
      return (rakaat: 11, description: 'Full Tahajjud (8 + 3 Witr) - Sunnah of Prophet ﷺ');
    } else if (availableMinutes >= 90) {
      return (rakaat: 9, description: '6 Tahajjud + 3 Witr');
    } else if (availableMinutes >= 60) {
      return (rakaat: 7, description: '4 Tahajjud + 3 Witr');
    } else if (availableMinutes >= 45) {
      return (rakaat: 5, description: '2 Tahajjud + 3 Witr');
    } else if (availableMinutes >= 30) {
      return (rakaat: 3, description: '3 Witr minimum');
    } else {
      return (rakaat: 1, description: '1 Witr - Don\'t miss it!');
    }
  }

  /// Format task subtitle with category and details
  String _formatTaskSubtitle(Task task) {
    final parts = <String>[];
    if (task.category != null) {
      parts.add(task.category!);
    }
    if (task.description != null && task.description!.isNotEmpty) {
      // Limit description to 40 chars
      final desc = task.description!.length > 40 
          ? '${task.description!.substring(0, 40)}...' 
          : task.description!;
      parts.add(desc);
    }
    return parts.join(' · ');
  }

  Widget _buildQiyamTime(BuildContext context, String title, String arabic, String time) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gray800,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray700),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray400,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              arabic,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.sunny_snowing;
      case 'maghrib':
        return Icons.nights_stay_outlined;
      case 'isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }

  Color _getTaskColor(Task task) {
    // Religious tasks use grayscale theme
    if (task.isReligious) {
      switch (task.priority) {
        case 2: // High
          return AppColors.black;
        case 1: // Medium
          return AppColors.gray700;
        case 0: // Low
        default:
          return AppColors.gray500;
      }
    }
    
    // Normal tasks use color coding
    switch (task.priority) {
      case 2: // High
        return Colors.red.shade600;
      case 1: // Medium
        return Colors.orange.shade600;
      case 0: // Low
      default:
        return Colors.blue.shade600;
    }
  }
}

enum _TimelineItemType { prayer, freeTime, sleep }

class _TimelineItem {
  final _TimelineItemType type;
  final String title;
  final String? subtitle;
  final DateTime time;
  final DateTime? endTime;
  final Duration? duration;
  final bool isCompleted;
  final bool isPast;
  final bool isActive;
  final List<Task>? tasks;
  final String? beforePrayer;
  final String? blockId;
  final int availableMinutes; // Total available minutes in this block

  _TimelineItem({
    required this.type,
    required this.title,
    this.subtitle,
    required this.time,
    this.endTime,
    this.duration,
    this.isCompleted = false,
    this.isPast = false,
    this.isActive = false,
    this.tasks,
    this.beforePrayer,
    this.blockId,
    this.availableMinutes = 0,
  });
}

/// Stateful widget for reorderable task list to maintain local state during drag
class _ReorderableTaskListWidget extends StatefulWidget {
  final List<Task> tasks;
  final String blockId;
  final WidgetRef ref;
  final Widget Function(Task task, int index, int totalCount) buildTaskItem;

  const _ReorderableTaskListWidget({
    required this.tasks,
    required this.blockId,
    required this.ref,
    required this.buildTaskItem,
  });

  @override
  State<_ReorderableTaskListWidget> createState() => _ReorderableTaskListWidgetState();
}

class _ReorderableTaskListWidgetState extends State<_ReorderableTaskListWidget> {
  late List<Task> _localTasks;
  bool _isDragging = false;
  String? _lastReorderedTaskId; // Track last reordered task to prevent bounce-back

  @override
  void initState() {
    super.initState();
    _localTasks = List<Task>.from(widget.tasks);
  }

  @override
  void didUpdateWidget(_ReorderableTaskListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only sync from provider when NOT dragging
    if (_isDragging) return;
    
    // Get current task IDs
    final providerIds = widget.tasks.map((t) => t.id).toSet();
    final localIds = _localTasks.map((t) => t.id).toSet();
    
    // If task IDs are different (task added/removed), always sync from provider
    if (!_setsEqual(providerIds, localIds)) {
      _localTasks = List<Task>.from(widget.tasks);
      _lastReorderedTaskId = null;
      return;
    }
    
    // Same tasks, potentially different order
    // Only sync if we haven't just done a reorder ourselves
    if (_lastReorderedTaskId == null) {
      // No recent reorder - sync from provider
      _localTasks = List<Task>.from(widget.tasks);
    } else {
      // We recently reordered - check if provider caught up
      final providerOrder = widget.tasks.map((t) => t.id).toList();
      final localOrder = _localTasks.map((t) => t.id).toList();
      
      if (_listsEqual(providerOrder, localOrder)) {
        // Provider caught up with our local state
        _lastReorderedTaskId = null;
      }
      // Otherwise keep local state (provider hasn't synced yet)
    }
  }

  bool _setsEqual(Set<String> a, Set<String> b) {
    return a.length == b.length && a.containsAll(b);
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: _localTasks.length,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final double elevation = Tween<double>(begin: 0, end: 8).evaluate(animation);
            final double scale = Tween<double>(begin: 1.0, end: 1.02).evaluate(animation);
            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: elevation,
                color: Colors.transparent,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      onReorderStart: (index) {
        setState(() {
          _isDragging = true;
        });
      },
      onReorderEnd: (index) {
        setState(() {
          _isDragging = false;
        });
      },
      onReorder: (oldIndex, newIndex) {
        
        // Handle the index adjustment for ReorderableListView
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        
        if (oldIndex != newIndex && oldIndex >= 0 && newIndex >= 0 && 
            oldIndex < _localTasks.length && newIndex < _localTasks.length) {
          final task = _localTasks[oldIndex];
          
          // Update local state immediately for smooth UI
          setState(() {
            _localTasks.removeAt(oldIndex);
            _localTasks.insert(newIndex, task);
            _lastReorderedTaskId = task.id; // Mark that we reordered
          });
          
          // Persist to provider
          widget.ref.read(taskProvider.notifier).reorderTasks(oldIndex, newIndex, widget.blockId);
        }
      },
      itemBuilder: (context, index) {
        final task = _localTasks[index];
        return widget.buildTaskItem(task, index, _localTasks.length);
      },
    );
  }
}