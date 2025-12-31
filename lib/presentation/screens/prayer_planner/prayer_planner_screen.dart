import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/free_time_service.dart';
import '../../../domain/providers/free_time_provider.dart';
import '../../../domain/providers/prayer_provider.dart';

/// Prayer Planner / Day Timeline Screen
/// Shows the entire day organized around prayer times
class PrayerPlannerScreen extends ConsumerWidget {
  const PrayerPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerTimes = ref.watch(prayerTimesProvider);
    final blocks = ref.watch(freeTimeBlocksProvider);
    final settings = ref.watch(prayerTimeSettingsProvider);
    final currentBlock = ref.watch(currentFreeTimeBlockProvider);

    final prayers = [
      ('Fajr', prayerTimes.fajr, Icons.wb_twilight),
      ('Sunrise', prayerTimes.sunrise, Icons.wb_sunny_outlined),
      ('Dhuhr', prayerTimes.dhuhr, Icons.wb_sunny),
      ('Asr', prayerTimes.asr, Icons.sunny_snowing),
      ('Maghrib', prayerTimes.maghrib, Icons.nights_stay_outlined),
      ('Isha', prayerTimes.isha, Icons.nights_stay),
    ];

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Day Timeline'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            _buildSummaryCard(context, blocks, settings),
            const SizedBox(height: 20),
            
            // Timeline
            const Text(
              'TODAY\'S SCHEDULE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 12),
            
            // Build timeline with prayers and blocks interspersed
            ..._buildTimeline(context, prayers, blocks, currentBlock),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addTask),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    List<FreeTimeBlock> blocks,
    PrayerTimeSettings settings,
  ) {
    final now = DateTime.now();
    final availableBlocks = blocks.where((b) => 
      b.endTime.isAfter(now) && b.availableDuration.inMinutes > 0
    ).toList();
    
    final totalAvailable = availableBlocks.fold<int>(
      0,
      (sum, b) {
        if (b.isCurrentBlock) {
          final remaining = b.endTime
              .subtract(Duration(minutes: settings.getPreparationTime(b.beforePrayer)))
              .difference(now);
          return sum + (remaining.inMinutes > 0 ? remaining.inMinutes : 0);
        }
        return sum + b.availableDuration.inMinutes;
      },
    );

    final hours = totalAvailable ~/ 60;
    final minutes = totalAvailable % 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mosque,
                color: AppColors.gray400,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Prayer Preparation',
                style: TextStyle(
                  color: AppColors.gray400,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hours > 0 ? '$hours' : '$minutes',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 48,
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
                      style: TextStyle(color: AppColors.gray400, fontSize: 14),
                    ),
                    if (hours > 0)
                      Text(
                        '$minutes min',
                        style: TextStyle(color: AppColors.gray500, fontSize: 12),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Available Today',
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(Icons.timer, '${settings.getPreparationTime("Fajr")}m avg prep'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gray800,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gray400),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.gray400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeline(
    BuildContext context,
    List<(String, DateTime, IconData)> prayers,
    List<FreeTimeBlock> blocks,
    FreeTimeBlock? currentBlock,
  ) {
    final widgets = <Widget>[];
    final now = DateTime.now();

    // Create combined list of events sorted by time
    final events = <_TimelineEvent>[];

    // Add prayers
    for (final prayer in prayers) {
      events.add(_TimelineEvent(
        time: prayer.$2,
        type: _EventType.prayer,
        title: prayer.$1,
        icon: prayer.$3,
      ));
    }

    // Add free time blocks
    for (final block in blocks) {
      if (block.availableDuration.inMinutes > 5) {
        events.add(_TimelineEvent(
          time: block.startTime,
          type: _EventType.freeTime,
          title: '${block.afterPrayer} → ${block.beforePrayer}',
          duration: block.availableDuration,
          isActive: block.id == currentBlock?.id,
          block: block,
        ));
      }
    }

    // Sort by time
    events.sort((a, b) => a.time.compareTo(b.time));

    for (int i = 0; i < events.length; i++) {
      final event = events[i];
      final isPast = event.time.isBefore(now) && 
          (event.type == _EventType.prayer || 
           (event.block != null && event.block!.endTime.isBefore(now)));
      
      widgets.add(_buildTimelineItem(
        context,
        event: event,
        isPast: isPast,
        isLast: i == events.length - 1,
      ));
    }

    return widgets;
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required _TimelineEvent event,
    required bool isPast,
    required bool isLast,
  }) {
    final timeStr = '${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 50,
            child: Text(
              timeStr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isPast ? AppColors.gray400 : AppColors.gray700,
              ),
            ),
          ),
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: event.isActive
                      ? AppColors.white
                      : event.type == _EventType.prayer
                          ? (isPast ? AppColors.gray300 : AppColors.black)
                          : Colors.transparent,
                  border: event.type == _EventType.freeTime
                      ? Border.all(
                          color: event.isActive
                              ? AppColors.black
                              : isPast
                                  ? AppColors.gray300
                                  : AppColors.gray400,
                          width: 2,
                        )
                      : null,
                  shape: BoxShape.circle,
                ),
                child: event.isActive
                    ? const Icon(Icons.play_arrow, size: 8, color: AppColors.black)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isPast ? AppColors.gray200 : AppColors.gray300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: event.type == _EventType.prayer
                    ? (isPast ? AppColors.gray100 : AppColors.white)
                    : event.isActive
                        ? AppColors.black
                        : AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: event.isActive
                      ? AppColors.gray700
                      : event.type == _EventType.prayer
                          ? AppColors.gray200
                          : AppColors.gray200,
                ),
              ),
              child: Row(
                children: [
                  if (event.type == _EventType.prayer)
                    Icon(
                      event.icon,
                      size: 20,
                      color: isPast ? AppColors.gray400 : AppColors.black,
                    ),
                  if (event.type == _EventType.freeTime)
                    Icon(
                      Icons.schedule,
                      size: 20,
                      color: event.isActive
                          ? AppColors.white
                          : isPast
                              ? AppColors.gray400
                              : AppColors.gray600,
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.type == _EventType.prayer
                              ? event.title
                              : 'Free Time',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: event.isActive 
                                ? AppColors.white 
                                : isPast 
                                    ? AppColors.gray500 
                                    : AppColors.black,
                          ),
                        ),
                        if (event.type == _EventType.freeTime)
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 12,
                              color: event.isActive 
                                  ? AppColors.gray400 
                                  : AppColors.gray600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (event.duration != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: event.isActive
                            ? AppColors.white
                            : isPast
                                ? AppColors.gray200
                                : AppColors.gray100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatDuration(event.duration!),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: event.isActive
                              ? AppColors.black
                              : AppColors.gray700,
                        ),
                      ),
                    ),
                  if (event.type == _EventType.prayer)
                    Icon(
                      isPast ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 20,
                      color: isPast ? AppColors.gray600 : AppColors.gray400,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}

enum _EventType { prayer, freeTime }

class _TimelineEvent {
  final DateTime time;
  final _EventType type;
  final String title;
  final IconData? icon;
  final Duration? duration;
  final bool isActive;
  final FreeTimeBlock? block;

  _TimelineEvent({
    required this.time,
    required this.type,
    required this.title,
    this.icon,
    this.duration,
    this.isActive = false,
    this.block,
  });
}
