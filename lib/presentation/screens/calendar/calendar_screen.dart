import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/prayer_data.dart';
import '../../../core/constants/islamic_events.dart';
import '../../../data/models/prayer_completion.dart';
import '../../../data/services/prayer_time_service.dart';
import '../../../domain/providers/prayer_provider.dart';
import '../../../domain/providers/task_provider.dart';
import '../../../domain/providers/nafila_provider.dart';
import '../../../domain/providers/settings_provider.dart';
import 'package:hijri/hijri_calendar.dart';

/// Calendar screen - Daily and weekly view of prayers and tasks
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.fromDate(_focusedDay);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        toolbarHeight: 40,
        title: Text(
          '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            icon: const Icon(Icons.today, size: 18),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      body: Column(
        children: [
          
          // Calendar
          _buildCalendar(),

          // Day summary card
          if (_selectedDay != null) _buildDaySummary(),

          // Timeline view
          Expanded(
            child: _buildTimelineView(),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummary() {
    final completions = ref.watch(prayerCompletionProvider);
    final tasks = ref.watch(taskProvider);
    
    // Get completion for selected day
    PrayerCompletion? dayCompletion;
    try {
      dayCompletion = completions.firstWhere(
        (c) => c.date.year == _selectedDay!.year &&
               c.date.month == _selectedDay!.month &&
               c.date.day == _selectedDay!.day,
      );
    } catch (_) {
      dayCompletion = null;
    }
    
    // Count completed prayers
    int prayersCompleted = 0;
    if (dayCompletion != null) {
      if (dayCompletion.fajrCompleted == 1) prayersCompleted++;
      if (dayCompletion.dhuhrCompleted == 1) prayersCompleted++;
      if (dayCompletion.asrCompleted == 1) prayersCompleted++;
      if (dayCompletion.maghribCompleted == 1) prayersCompleted++;
      if (dayCompletion.ishaCompleted == 1) prayersCompleted++;
    }
    
    // Count tasks for selected day
    final dayTasks = tasks.where((t) {
      if (t.scheduledTime == null) return false;
      return t.scheduledTime!.year == _selectedDay!.year &&
             t.scheduledTime!.month == _selectedDay!.month &&
             t.scheduledTime!.day == _selectedDay!.day;
    }).toList();
    
    final tasksCompleted = dayTasks.where((t) => t.isCompleted).length;
    
    // Get Hijri date
    final hijri = HijriCalendar.fromDate(_selectedDay!);
    
    // Get Islamic events for selected day
    final islamicEvents = IslamicEventsService.getEventsForDate(_selectedDay!);
    
    // Check if selected day is today
    final isToday = isSameDay(_selectedDay, DateTime.now());
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact date header with stats inline
          Row(
            children: [
              // Hijri + Gregorian compact
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      DateFormat('EEE, d MMM').format(_selectedDay!),
                      style: const TextStyle(
                        color: AppColors.gray500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Compact stats inline
              Text(
                '$prayersCompleted/5',
                style: TextStyle(
                  color: prayersCompleted == 5 ? AppColors.white : AppColors.gray400,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.mosque, size: 12, color: prayersCompleted == 5 ? AppColors.white : AppColors.gray500),
              if (dayTasks.isNotEmpty) ...[
                const SizedBox(width: 10),
                Text(
                  '$tasksCompleted/${dayTasks.length}',
                  style: TextStyle(
                    color: tasksCompleted == dayTasks.length ? AppColors.white : AppColors.gray400,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.task_alt, size: 12, color: tasksCompleted == dayTasks.length ? AppColors.white : AppColors.gray500),
              ],
            ],
          ),
          // Show first Islamic event if any
          if (islamicEvents.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  _getEventIcon(islamicEvents.first.type),
                  size: 12,
                  color: AppColors.white,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    islamicEvents.length > 1
                        ? '${islamicEvents.first.name} +${islamicEvents.length - 1}'
                        : islamicEvents.first.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  IconData _getEventIcon(IslamicEventType type) {
    switch (type) {
      case IslamicEventType.eid:
        return Icons.celebration;
      case IslamicEventType.ramadan:
        return Icons.nightlight_round;
      case IslamicEventType.fastingDay:
        return Icons.water_drop_outlined; // Clearer fasting indicator (abstaining)
      case IslamicEventType.sacredMonth:
        return Icons.shield;
      case IslamicEventType.specialNight:
        return Icons.star;
      case IslamicEventType.hajj:
        return Icons.location_on;
      default:
        return Icons.event;
    }
  }
  
  Widget _buildDayCell(DateTime day, {required bool isSelected, required bool isToday, required bool isOutside}) {
    final hijri = HijriCalendar.fromDate(day);
    
    Color bgColor;
    Color textColor;
    Color subTextColor;
    
    if (isSelected) {
      bgColor = AppColors.black;
      textColor = AppColors.white;
      subTextColor = AppColors.gray400;
    } else if (isToday) {
      bgColor = AppColors.gray200;
      textColor = AppColors.black;
      subTextColor = AppColors.gray600;
    } else if (isOutside) {
      bgColor = Colors.transparent;
      textColor = AppColors.gray300;
      subTextColor = AppColors.gray300;
    } else {
      bgColor = Colors.transparent;
      textColor = AppColors.black;
      subTextColor = AppColors.gray500;
    }
    
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${hijri.hDay}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 9,
                color: subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    bool isComplete = false,
    bool isWarning = false,
    bool isHighlight = false,
  }) {
    return const SizedBox.shrink(); // No longer used
  }
  
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) {
        // Return all events for markers - each event = one dot
        final events = IslamicEventsService.getEventsForDate(day);
        return events; // Show dot for every event
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        // Today's style
        todayDecoration: BoxDecoration(
          color: AppColors.gray200,
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
        // Selected day style
        selectedDecoration: const BoxDecoration(
          color: AppColors.black,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
        // Default day style
        defaultTextStyle: const TextStyle(color: AppColors.black),
        weekendTextStyle: const TextStyle(color: AppColors.gray600),
        outsideTextStyle: const TextStyle(color: AppColors.gray400),
        // Markers for Islamic events
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
          color: AppColors.black,
          shape: BoxShape.circle,
        ),
        markerSize: 4,
        markersAlignment: Alignment.bottomCenter,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        formatButtonTextStyle: const TextStyle(
          color: AppColors.black,
          fontSize: 12,
        ),
        leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.black),
        rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.black),
        titleTextStyle: Theme.of(context).textTheme.titleMedium!,
      ),
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, day) {
          final hijri = HijriCalendar.fromDate(day);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${hijri.longMonthName} ${hijri.hYear}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(day),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.gray500,
                ),
              ),
            ],
          );
        },
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, isSelected: false, isToday: false, isOutside: false);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, isSelected: true, isToday: false, isOutside: false);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, isSelected: false, isToday: true, isOutside: false);
        },
        outsideBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, isSelected: false, isToday: false, isOutside: true);
        },
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
        weekendStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.gray500,
            ),
      ),
    );
  }

  Widget _buildTimelineView() {
    if (_selectedDay == null) return const SizedBox();
    
    final settings = ref.watch(settingsProvider);
    final tasks = ref.watch(taskProvider);
    final completions = ref.watch(prayerCompletionProvider);
    final nafilas = ref.watch(enabledNafilasProvider);
    final prayerService = PrayerTimeService();
    
    // Get Islamic events for selected day
    final islamicEvents = IslamicEventsService.getEventsForDate(_selectedDay!);
    
    // Get prayer times for selected day
    final prayerTimes = prayerService.getPrayerTimes(
      latitude: settings.latitude ?? 21.4225,
      longitude: settings.longitude ?? 39.8262,
      date: _selectedDay!,
      calculationMethod: settings.calculationMethod,
      madhab: settings.madhab,
    );
    
    // Get completion status for selected day
    PrayerCompletion? dayCompletion;
    try {
      dayCompletion = completions.firstWhere(
        (c) => c.date.year == _selectedDay!.year &&
               c.date.month == _selectedDay!.month &&
               c.date.day == _selectedDay!.day,
      );
    } catch (_) {
      dayCompletion = null;
    }
    
    // Build timeline items
    List<_TimelineItem> items = [];
    
    // Add ALL Islamic events at the top (no specific time)
    for (final event in islamicEvents) {
      items.add(_TimelineItem(
        time: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 0, 0),
        title: event.name,
        subtitle: event.description.length > 80 
            ? '${event.description.substring(0, 77)}...' 
            : event.description,
        type: 'islamic_event',
        eventType: event.type,
        isCompleted: false,
        source: event.source,
        islamicEvent: event, // Pass full event for details
      ));
    }
    
    // Add prayers
    items.add(_TimelineItem(
      time: prayerTimes.fajr,
      title: 'Fajr',
      type: 'prayer',
      isCompleted: dayCompletion?.fajrCompleted == 1,
    ));
    
    items.add(_TimelineItem(
      time: prayerTimes.dhuhr,
      title: 'Dhuhr',
      type: 'prayer',
      isCompleted: dayCompletion?.dhuhrCompleted == 1,
    ));
    
    items.add(_TimelineItem(
      time: prayerTimes.asr,
      title: 'Asr',
      type: 'prayer',
      isCompleted: dayCompletion?.asrCompleted == 1,
    ));
    
    items.add(_TimelineItem(
      time: prayerTimes.maghrib,
      title: 'Maghrib',
      type: 'prayer',
      isCompleted: dayCompletion?.maghribCompleted == 1,
    ));
    
    items.add(_TimelineItem(
      time: prayerTimes.isha,
      title: 'Isha',
      type: 'prayer',
      isCompleted: dayCompletion?.ishaCompleted == 1,
    ));
    
    // Add enabled nafilas with approximate times
    for (final nafila in nafilas) {
      final info = PrayerData.nafilaPrayers.firstWhere(
        (p) => p.id == nafila.prayerInfoId,
        orElse: () => PrayerData.nafilaPrayers.first,
      );
      
      // Estimate nafila time based on associated prayer
      DateTime nafilaTime;
      switch (info.id) {
        case 'tahajjud':
        case 'witr':
          nafilaTime = prayerTimes.lastThirdOfNight;
          break;
        case 'fajr_sunnah':
          nafilaTime = prayerTimes.fajr.subtract(const Duration(minutes: 15));
          break;
        case 'ishraq':
        case 'duha':
          nafilaTime = prayerTimes.sunrise.add(const Duration(minutes: 20));
          break;
        case 'dhuhr_before':
          nafilaTime = prayerTimes.dhuhr.subtract(const Duration(minutes: 15));
          break;
        case 'dhuhr_after':
          nafilaTime = prayerTimes.dhuhr.add(const Duration(minutes: 20));
          break;
        case 'asr_before':
          nafilaTime = prayerTimes.asr.subtract(const Duration(minutes: 15));
          break;
        case 'maghrib_after':
        case 'awwabin':
          nafilaTime = prayerTimes.maghrib.add(const Duration(minutes: 10));
          break;
        case 'isha_after':
          nafilaTime = prayerTimes.isha.add(const Duration(minutes: 15));
          break;
        default:
          nafilaTime = prayerTimes.dhuhr;
      }
      
      items.add(_TimelineItem(
        time: nafilaTime,
        title: '${info.name} (Nafila)',
        type: 'nafila',
        isCompleted: nafila.lastCompletedAt != null && 
            nafila.lastCompletedAt!.year == _selectedDay!.year &&
            nafila.lastCompletedAt!.month == _selectedDay!.month &&
            nafila.lastCompletedAt!.day == _selectedDay!.day,
      ));
    }
    
    // Add tasks for selected day
    final dayTasks = tasks.where((t) {
      if (t.scheduledTime == null) return false;
      return t.scheduledTime!.year == _selectedDay!.year &&
             t.scheduledTime!.month == _selectedDay!.month &&
             t.scheduledTime!.day == _selectedDay!.day;
    }).toList();
    
    for (final task in dayTasks) {
      items.add(_TimelineItem(
        time: task.scheduledTime!,
        title: task.title,
        type: 'task',
        isCompleted: task.isCompleted,
      ));
    }
    
    // Sort by time, but keep Islamic events at top
    items.sort((a, b) {
      if (a.type == 'islamic_event' && b.type != 'islamic_event') return -1;
      if (a.type != 'islamic_event' && b.type == 'islamic_event') return 1;
      return a.time.compareTo(b.time);
    });
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: AppColors.gray300),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'No events for this day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
        vertical: AppDimensions.paddingMd,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _TimelineTile(
          item: item, 
          isLast: index == items.length - 1,
          use24Hour: settings.use24HourFormat,
          madhab: settings.madhab,
        );
      },
    );
  }
}

class _TimelineItem {
  final DateTime time;
  final String title;
  final String? subtitle;
  final String type; // prayer, nafila, task, islamic_event
  final IslamicEventType? eventType;
  final bool isCompleted;
  final String? source;
  final IslamicEvent? islamicEvent; // Full event data for details

  _TimelineItem({
    required this.time,
    required this.title,
    this.subtitle,
    required this.type,
    this.eventType,
    required this.isCompleted,
    this.source,
    this.islamicEvent,
  });
}

class _TimelineTile extends StatelessWidget {
  final _TimelineItem item;
  final bool isLast;
  final bool use24Hour;
  final int madhab; // 0=Shafi, 1=Hanafi

  const _TimelineTile({
    required this.item, 
    required this.isLast,
    this.use24Hour = false,
    this.madhab = 0,
  });

  String get _formattedTime {
    if (item.type == 'islamic_event') return 'ALL DAY';
    if (use24Hour) {
      return DateFormat('HH:mm').format(item.time);
    }
    return DateFormat('h:mm a').format(item.time);
  }

  IconData get _icon {
    if (item.type == 'islamic_event' && item.eventType != null) {
      switch (item.eventType!) {
        case IslamicEventType.eid:
          return Icons.celebration;
        case IslamicEventType.ramadan:
          return Icons.nightlight_round;
        case IslamicEventType.fastingDay:
          return Icons.water_drop_outlined; // Clearer fasting indicator
        case IslamicEventType.sacredMonth:
          return Icons.shield;
        case IslamicEventType.specialNight:
          return Icons.star;
        case IslamicEventType.hajj:
          return Icons.location_on;
        case IslamicEventType.islamicDate:
          return Icons.event;
      }
    }
    switch (item.type) {
      case 'prayer':
        return Icons.mosque;
      case 'nafila':
        return Icons.mosque_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color get _iconColor {
    if (item.isCompleted) return AppColors.gray600;
    if (item.type == 'islamic_event') return AppColors.white;
    switch (item.type) {
      case 'prayer':
        return AppColors.black;
      case 'nafila':
        return AppColors.gray500;
      default:
        return AppColors.gray600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIslamicEvent = item.type == 'islamic_event';
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          SizedBox(
            width: 75,
            child: Text(
              _formattedTime,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isIslamicEvent 
                        ? AppColors.black 
                        : item.isCompleted 
                            ? AppColors.gray400 
                            : AppColors.gray600,
                    fontWeight: isIslamicEvent ? FontWeight.bold : FontWeight.w500,
                    fontSize: isIslamicEvent ? 9 : null,
                  ),
            ),
          ),

          // Timeline line and dot
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isCompleted 
                      ? AppColors.black 
                      : isIslamicEvent 
                          ? AppColors.black 
                          : AppColors.white,
                  border: Border.all(
                    color: item.isCompleted || isIslamicEvent 
                        ? AppColors.black 
                        : AppColors.gray400,
                    width: 2,
                  ),
                ),
                child: item.isCompleted
                    ? const Icon(Icons.check, size: 8, color: AppColors.white)
                    : isIslamicEvent
                        ? Icon(_icon, size: 6, color: AppColors.white)
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.gray300,
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppDimensions.spacingMd),

          // Content - tappable for Islamic events
          Expanded(
            child: GestureDetector(
              onTap: isIslamicEvent && item.islamicEvent != null
                  ? () => _showEventDetails(context, item.islamicEvent!, madhab)
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                decoration: BoxDecoration(
                  color: item.isCompleted 
                      ? AppColors.gray100 
                      : isIslamicEvent || item.type == 'prayer'
                          ? AppColors.black 
                          : AppColors.white,
                  border: Border.all(
                    color: item.isCompleted 
                        ? AppColors.gray300 
                        : isIslamicEvent || item.type == 'prayer'
                            ? AppColors.black 
                            : AppColors.gray300,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _icon,
                          size: 18,
                          color: item.isCompleted 
                              ? AppColors.gray500 
                              : isIslamicEvent || item.type == 'prayer'
                                  ? AppColors.white 
                                  : _iconColor,
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      decoration: item.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: item.isCompleted
                                          ? AppColors.gray500
                                          : isIslamicEvent || item.type == 'prayer'
                                              ? AppColors.white
                                              : AppColors.black,
                                      fontWeight: isIslamicEvent || item.type == 'prayer' 
                                          ? FontWeight.w600 
                                          : null,
                                    ),
                              ),
                              if (item.type == 'nafila')
                                Text(
                                  'Sunnah Prayer',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: item.isCompleted 
                                            ? AppColors.gray400 
                                            : AppColors.gray500,
                                        fontSize: 10,
                                      ),
                                ),
                              if (item.type == 'task')
                                Text(
                                  'Task',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: item.isCompleted 
                                            ? AppColors.gray400 
                                            : AppColors.gray500,
                                        fontSize: 10,
                                      ),
                                ),
                            ],
                          ),
                        ),
                        if (item.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'DONE',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isIslamicEvent && item.eventType == IslamicEventType.eid)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'عيد',
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Tap indicator for Islamic events
                        if (isIslamicEvent) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.gray400,
                          ),
                        ],
                      ],
                    ),
                    // Compact preview for Islamic events
                    if (isIslamicEvent) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tap for details & guidance',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show detailed event information
  void _showEventDetails(BuildContext context, IslamicEvent event, int madhab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _IslamicEventDetailsSheet(event: event, madhab: madhab),
    );
  }
}

/// Bottom sheet for Islamic event details
class _IslamicEventDetailsSheet extends StatelessWidget {
  final IslamicEvent event;
  final int madhab; // 0=Shafi, 1=Hanafi

  const _IslamicEventDetailsSheet({required this.event, this.madhab = 0});

  String get _madhhabName => madhab == 1 ? 'Hanafi' : 'Shafi\'i';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getEventIcon(event.type),
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          event.nameArabic,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Madhab indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_outlined, size: 14, color: AppColors.gray600),
                    const SizedBox(width: 6),
                    Text(
                      'Guidance according to $_madhhabName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'About',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray700,
                  height: 1.5,
                ),
              ),
              
              // Source reference
              if (event.source != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book, size: 18, color: AppColors.gray600),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          event.source!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // What to do section
              Text(
                'What to Do',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 12),
              ..._getActionsForEvent(event).map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        action,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
              
              // Warning for Eid - No fasting
              if (event.type == IslamicEventType.eid) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Fasting is prohibited on this day',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEventIcon(IslamicEventType type) {
    switch (type) {
      case IslamicEventType.eid:
        return Icons.celebration;
      case IslamicEventType.ramadan:
        return Icons.nightlight_round;
      case IslamicEventType.fastingDay:
        return Icons.water_drop_outlined;
      case IslamicEventType.sacredMonth:
        return Icons.shield;
      case IslamicEventType.specialNight:
        return Icons.star;
      case IslamicEventType.hajj:
        return Icons.location_on;
      default:
        return Icons.event;
    }
  }

  List<String> _getActionsForEvent(IslamicEvent event) {
    final isHanafi = madhab == 1;
    
    switch (event.type) {
      case IslamicEventType.fastingDay:
        return [
          'Fast from Fajr until Maghrib',
          isHanafi 
              ? 'Make intention (niyyah) before Fajr - Hanafi requires intention before dawn'
              : 'Make intention (niyyah) - Shafi\'i allows until before Dhuhr for voluntary fasts',
          'Eat suhoor (pre-dawn meal) - Sunnah',
          'Break fast with dates and water',
          'Make dua at iftar time - dua is accepted',
          isHanafi
              ? 'Pray 20 rakaat Taraweeh (Hanafi recommendation)'
              : 'Pray 8 or 20 rakaat Taraweeh',
        ];
      case IslamicEventType.eid:
        return [
          'Perform Ghusl (ritual bath)',
          'Wear your best clothes',
          event.id.contains('fitr')
              ? 'Eat something sweet before Eid al-Fitr prayer'
              : 'Do not eat before Eid al-Adha prayer until after sacrifice',
          'Fasting is prohibited - enjoy the celebration',
          isHanafi
              ? 'Eid prayer is Wajib (obligatory) - Hanafi'
              : 'Eid prayer is Sunnah Mu\'akkadah - Shafi\'i',
          'Recite Takbeer: الله أكبر الله أكبر لا إله إلا الله',
          'Visit family and give gifts',
          if (event.id.contains('adha')) 'Perform Udhiyah (sacrifice) if able',
        ];
      case IslamicEventType.ramadan:
        return [
          'Fast from Fajr until Maghrib (obligatory)',
          isHanafi
              ? 'Intention must be made before Fajr each night - Hanafi'
              : 'One intention at beginning of Ramadan suffices - Shafi\'i',
          'Increase Quran recitation - aim to complete it',
          isHanafi
              ? 'Pray 20 rakaat Taraweeh - Sunnah Mu\'akkadah (Hanafi)'
              : 'Pray 8 or 20 rakaat Taraweeh',
          'Give charity (Sadaqah) - rewards multiplied',
          'Seek Laylatul Qadr in last 10 odd nights',
          'Pay Zakat al-Fitr before Eid prayer',
        ];
      case IslamicEventType.sacredMonth:
        return [
          'This is one of the 4 sacred months (Ash-hur al-Hurum)',
          'Good deeds are more rewarded',
          'Sins are more severe - be extra careful',
          'Fast voluntary fasts - highly recommended',
          'Give extra charity',
          'Avoid fighting and disputes',
          'Make abundant istighfar (seek forgiveness)',
        ];
      case IslamicEventType.specialNight:
        return [
          'Stay awake in worship (Qiyam al-Layl)',
          isHanafi
              ? 'Pray Tahajjud - minimum 2 rakaat, recommended 8 (Hanafi)'
              : 'Pray Tahajjud - minimum 2 rakaat, recommended 11 (Shafi\'i)',
          'Recite Quran abundantly',
          'Make abundant dua - especially for forgiveness',
          'Recite: اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
          '(O Allah, You are Forgiving and love forgiveness, so forgive me)',
          'Give charity if possible',
        ];
      case IslamicEventType.hajj:
        return [
          'If performing Hajj: Follow the rituals according to your madhab',
          'If not performing Hajj:',
          '  • Fast on Day of Arafah - expiates sins of 2 years',
          '  • Make dua for pilgrims',
          '  • Increase dhikr and remembrance',
          'Days of Tashreeq (11-13 Dhul Hijjah):',
          isHanafi
              ? '  • Fasting is Makruh (disliked) - Hanafi'
              : '  • Fasting is prohibited - Shafi\'i',
          '  • Recite Takbeer after every Fard prayer',
        ];
      default:
        return [
          'Remember Allah throughout the day',
          'Perform extra prayers (Nawafil)',
          'Give charity',
          'Recite Quran',
          'Make dhikr and dua',
        ];
    }
  }
}
