import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/free_time_service.dart';
import '../../domain/providers/free_time_provider.dart';

/// Widget showing current free time block with countdown
class CurrentTimeBlockCard extends ConsumerWidget {
  final VoidCallback? onAddTask;
  
  const CurrentTimeBlockCard({
    super.key,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBlock = ref.watch(currentFreeTimeBlockProvider);
    final remaining = ref.watch(remainingTimeProvider);
    final settings = ref.watch(prayerTimeSettingsProvider);

    if (currentBlock == null) {
      return _buildPrayerTimeCard(context);
    }

    final hours = remaining?.inHours ?? 0;
    final minutes = (remaining?.inMinutes ?? 0) % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.black,
            AppColors.gray800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'FREE TIME',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.mosque,
                  color: AppColors.gray400,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time remaining
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hours > 0 ? '$hours' : '$minutes',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hours > 0 ? 'hours' : 'minutes',
                        style: TextStyle(
                          color: AppColors.gray400,
                          fontSize: 16,
                        ),
                      ),
                      if (hours > 0)
                        Text(
                          '$minutes min',
                          style: TextStyle(
                            color: AppColors.gray500,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                // Add task button
                GestureDetector(
                  onTap: onAddTask,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Context info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'After ${currentBlock.afterPrayer}',
                          style: TextStyle(
                            color: AppColors.gray400,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentBlock.timeRangeText,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.gray600,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Before ${currentBlock.beforePrayer}',
                            style: TextStyle(
                              color: AppColors.gray400,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Prepare in ${remaining?.inMinutes ?? 0}m',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.mosque, color: AppColors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prayer Time',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Time to pray! Your tasks can wait.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget showing all time blocks for the day
class DayTimelineWidget extends ConsumerWidget {
  final Function(FreeTimeBlock)? onBlockTap;
  
  const DayTimelineWidget({
    super.key,
    this.onBlockTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocks = ref.watch(freeTimeBlocksProvider);
    final currentBlock = ref.watch(currentFreeTimeBlockProvider);

    if (blocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Today\'s Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...blocks.map((block) => _buildTimeBlock(
            context,
            block,
            isActive: block.id == currentBlock?.id,
          )),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(BuildContext context, FreeTimeBlock block, {bool isActive = false}) {
    final isPast = block.endTime.isBefore(DateTime.now());
    
    return GestureDetector(
      onTap: () => onBlockTap?.call(block),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green
                        : isPast
                            ? AppColors.gray300
                            : AppColors.black,
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: Colors.green.shade200, width: 3)
                        : null,
                  ),
                ),
                Container(
                  width: 2,
                  height: 50,
                  color: isPast ? AppColors.gray200 : AppColors.gray300,
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Block info
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : isPast
                          ? AppColors.gray50
                          : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? Colors.green
                        : isPast
                            ? AppColors.gray200
                            : AppColors.gray300,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${block.afterPrayer} → ${block.beforePrayer}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isPast ? AppColors.gray500 : AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            block.timeRangeText,
                            style: TextStyle(
                              color: AppColors.gray600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green
                            : isPast
                                ? AppColors.gray200
                                : AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        block.durationText,
                        style: TextStyle(
                          color: isActive ? AppColors.white : AppColors.gray700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact time block selector for task creation
class TimeBlockSelector extends ConsumerWidget {
  final FreeTimeBlock? selectedBlock;
  final ValueChanged<FreeTimeBlock>? onBlockSelected;
  
  const TimeBlockSelector({
    super.key,
    this.selectedBlock,
    this.onBlockSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocks = ref.watch(freeTimeBlocksProvider);
    final now = DateTime.now();
    
    // Filter to show only current and future blocks
    final availableBlocks = blocks.where((b) => 
      b.endTime.isAfter(now) && b.availableDuration.inMinutes > 5
    ).toList();

    if (availableBlocks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('No available time blocks today'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule for:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableBlocks.map((block) {
            final isSelected = selectedBlock?.id == block.id;
            return GestureDetector(
              onTap: () => onBlockSelected?.call(block),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.black : AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.black : AppColors.gray300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${block.afterPrayer} → ${block.beforePrayer}',
                      style: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      block.durationText,
                      style: TextStyle(
                        color: isSelected ? AppColors.gray300 : AppColors.gray600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Duration selector based on available time
class TaskDurationSelector extends StatelessWidget {
  final FreeTimeBlock? block;
  final Duration? selectedDuration;
  final ValueChanged<Duration>? onDurationSelected;
  
  const TaskDurationSelector({
    super.key,
    this.block,
    this.selectedDuration,
    this.onDurationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = block?.getSuggestedTaskDurations() ?? [
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(minutes: 45),
      const Duration(minutes: 60),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((duration) {
            final isSelected = selectedDuration == duration;
            final mins = duration.inMinutes;
            final label = mins >= 60 
                ? '${mins ~/ 60}h${mins % 60 > 0 ? ' ${mins % 60}m' : ''}'
                : '${mins}m';
            
            return GestureDetector(
              onTap: () => onDurationSelected?.call(duration),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.black : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.black : AppColors.gray300,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
