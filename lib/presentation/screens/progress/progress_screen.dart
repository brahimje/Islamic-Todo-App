import 'dart:math' as math;
import 'package:islamic_todo_app/core/constants/prayer_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_todo_app/domain/providers/prayer_provider.dart';
import 'package:islamic_todo_app/domain/providers/task_provider.dart';
import 'package:islamic_todo_app/domain/providers/nafila_provider.dart';
import 'package:islamic_todo_app/domain/providers/challenges_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:islamic_todo_app/core/constants/app_colors.dart';
import 'package:islamic_todo_app/presentation/screens/progress/_activity_bar_chart.dart';
/// Progress screen - Minimalist statistics and tracking
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completions = ref.watch(prayerCompletionProvider);
    final tasks = ref.watch(taskProvider);
    final nafilas = ref.watch(enabledNafilasProvider);
    
    // Calculate data
    final prayerStreak = _calculatePrayerStreak(completions);
    final taskStreak = _calculateTaskStreak(tasks);
    final now = DateTime.now();
    
    // Monthly stats
    final monthTasks = tasks.where((t) => 
      t.createdAt.month == now.month && t.createdAt.year == now.year
    ).toList();
    final monthTasksCompleted = monthTasks.where((t) => t.isCompleted).length;
    final monthTasksTotal = monthTasks.length;
    
    int monthPrayersCompleted = 0;
    for (final c in completions.where((c) => 
      c.date.month == now.month && c.date.year == now.year
    )) {
      monthPrayersCompleted += c.fardCompletedCount;
    }
    final monthPrayersTotal = now.day * 5;
    
    // Combined productivity score
    final prayerScore = monthPrayersTotal > 0 ? monthPrayersCompleted / monthPrayersTotal : 0.0;
    final taskScore = monthTasksTotal > 0 ? monthTasksCompleted / monthTasksTotal : 1.0;
    final productivityScore = ((prayerScore * 0.6) + (taskScore * 0.4) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Productivity Meter + Streaks Row
              Row(
                children: [
                  // Productivity Meter
                  Expanded(
                    child: _ProductivityMeter(
                      score: productivityScore,
                      prayersCompleted: monthPrayersCompleted,
                      prayersTotal: monthPrayersTotal,
                      tasksCompleted: monthTasksCompleted,
                      tasksTotal: monthTasksTotal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Streaks Column
                  Expanded(
                    child: Column(
                      children: [
                        _MiniStreakCard(
                          icon: Icons.mosque_outlined,
                          count: prayerStreak,
                          label: 'Prayer streak',
                        ),
                        const SizedBox(height: 8),
                        _MiniStreakCard(
                          icon: Icons.check_circle_outline,
                          count: taskStreak,
                          label: 'Task streak',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Weekly Productivity Insights
              _ProductivityInsightsCard(),
              const SizedBox(height: 20),
              
              // Daily Challenges Section
              _DailyChallengesCard(),
              const SizedBox(height: 20),
              
              // Activity Bar Chart
              ActivityBarChart(completions: completions, tasks: tasks),
              const SizedBox(height: 20),
              
              // Achievements
              _AchievementsSection(
                prayerStreak: prayerStreak,
                taskStreak: taskStreak,
                monthPrayersCompleted: monthPrayersCompleted,
                monthTasksCompleted: monthTasksCompleted,
                nafilasEnabled: nafilas.length,
              ),
              const SizedBox(height: 20),
              
              // Nafila Progress (compact)
              if (nafilas.isNotEmpty)
                _NafilaProgressCompact(nafilas: nafilas),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  int _calculatePrayerStreak(List completions) {
    if (completions.isEmpty) return 0;
    
    int streak = 0;
    final sorted = List.from(completions)..sort((a, b) => b.date.compareTo(a.date));
    final today = DateTime.now();
    var checkDate = DateTime(today.year, today.month, today.day);
    
    for (final c in sorted) {
      final cDate = DateTime(c.date.year, c.date.month, c.date.day);
      if (cDate == checkDate || cDate == checkDate.subtract(const Duration(days: 1))) {
        if (c.fardCompletedCount >= 4) {
          streak++;
          checkDate = cDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else if (cDate.isBefore(checkDate.subtract(const Duration(days: 1)))) {
        break;
      }
    }
    return streak;
  }

  int _calculateTaskStreak(List tasks) {
    if (tasks.isEmpty) return 0;
    
    int streak = 0;
    final today = DateTime.now();
    var checkDate = DateTime(today.year, today.month, today.day);
    
    for (int i = 0; i < 365; i++) {
      final dayTasks = tasks.where((t) {
        if (t.scheduledTime == null) return false;
        return t.scheduledTime!.year == checkDate.year &&
               t.scheduledTime!.month == checkDate.month &&
               t.scheduledTime!.day == checkDate.day;
      }).toList();
      
      if (dayTasks.isEmpty) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }
      
      final completed = dayTasks.where((t) => t.isCompleted).length;
      if (completed >= dayTasks.length * 0.7) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}

// ============ PRODUCTIVITY METER ============

class _ProductivityMeter extends StatelessWidget {
  final int score;
  final int prayersCompleted;
  final int prayersTotal;
  final int tasksCompleted;
  final int tasksTotal;

  const _ProductivityMeter({
    required this.score,
    required this.prayersCompleted,
    required this.prayersTotal,
    required this.tasksCompleted,
    required this.tasksTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _CircularProgressPainter(score / 100),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '%',
                      style: TextStyle(
                        color: AppColors.gray400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Productivity',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniStat(icon: Icons.mosque_outlined, value: '$prayersCompleted/$prayersTotal'),
              const SizedBox(width: 16),
              _MiniStat(icon: Icons.check_circle_outline, value: '$tasksCompleted/$tasksTotal'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MiniStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.gray400),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: AppColors.gray400, fontSize: 11),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  
  _CircularProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    
    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.gray700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, bgPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============ MINI STREAK CARD ============

class _MiniStreakCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const _MiniStreakCard({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.black),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('days', style: TextStyle(fontSize: 11, color: AppColors.gray500)),
                ],
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ PRODUCTIVITY INSIGHTS CARD ============

class _ProductivityInsightsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final completions = ref.watch(prayerCompletionProvider);
    final now = DateTime.now();
    
    // Calculate this week's date range
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    // Get tasks for this week
    final thisWeekTasks = tasks.where((t) {
      if (t.deadline == null) return false;
      return t.deadline!.isAfter(weekStart.subtract(const Duration(days: 1))) && 
             t.deadline!.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    
    final completedThisWeek = thisWeekTasks.where((t) => t.isCompleted).length;
    final totalThisWeek = thisWeekTasks.length;
    final weeklyRate = totalThisWeek > 0 ? (completedThisWeek / totalThisWeek * 100).round() : 0;
    
    // Calculate last week for comparison
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = lastWeekStart.add(const Duration(days: 6));
    final lastWeekTasks = tasks.where((t) {
      if (t.deadline == null) return false;
      return t.deadline!.isAfter(lastWeekStart.subtract(const Duration(days: 1))) && 
             t.deadline!.isBefore(lastWeekEnd.add(const Duration(days: 1)));
    }).toList();
    final lastWeekCompleted = lastWeekTasks.where((t) => t.isCompleted).length;
    final lastWeekTotal = lastWeekTasks.length;
    final lastWeekRate = lastWeekTotal > 0 ? (lastWeekCompleted / lastWeekTotal * 100).round() : 0;
    final weekTrend = weeklyRate - lastWeekRate;
    
    // Find most productive prayer slot
    final slotProductivity = <String, int>{
      'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0,
    };
    for (final task in tasks.where((t) => t.isCompleted && t.prayerBlockId != null)) {
      final slot = task.prayerBlockId!.toLowerCase();
      if (slotProductivity.containsKey(slot)) {
        slotProductivity[slot] = slotProductivity[slot]! + 1;
      }
    }
    final bestSlot = slotProductivity.entries.fold<MapEntry<String, int>?>(
      null,
      (prev, e) => prev == null || e.value > prev.value ? e : prev,
    );
    final bestSlotName = bestSlot != null && bestSlot.value > 0 
        ? bestSlot.key[0].toUpperCase() + bestSlot.key.substring(1)
        : 'N/A';
    
    // Find best day of week
    final dayProductivity = <int, int>{};
    for (int i = 1; i <= 7; i++) {
      dayProductivity[i] = 0;
    }
    for (final task in tasks.where((t) => t.isCompleted && t.completedAt != null)) {
      final day = task.completedAt!.weekday;
      dayProductivity[day] = dayProductivity[day]! + 1;
    }
    final bestDay = dayProductivity.entries.fold<MapEntry<int, int>?>(
      null,
      (prev, e) => prev == null || e.value > prev.value ? e : prev,
    );
    final dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final bestDayName = bestDay != null && bestDay.value > 0 
        ? dayNames[bestDay.key] 
        : 'N/A';
    
    // Prayer completion rate this week
    final thisWeekCompletions = completions.where((c) {
      return c.date.isAfter(weekStart.subtract(const Duration(days: 1))) && 
             c.date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    final prayersCompleted = thisWeekCompletions.fold<int>(
      0, (sum, c) => sum + c.fardCompletedCount);
    final daysInWeekSoFar = now.weekday;
    final expectedPrayers = daysInWeekSoFar * 5;
    final prayerRate = expectedPrayers > 0 ? (prayersCompleted / expectedPrayers * 100).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.insights_outlined, size: 16, color: AppColors.black),
              const SizedBox(width: 6),
              const Text(
                'Weekly Insights',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
              const Spacer(),
              // Week trend indicator
              if (weekTrend != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: weekTrend > 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        weekTrend > 0 ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: weekTrend > 0 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${weekTrend > 0 ? '+' : ''}$weekTrend%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: weekTrend > 0 ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Main stats row
          Row(
            children: [
              Expanded(
                child: _InsightStatItem(
                  icon: Icons.check_circle_outline,
                  value: '$weeklyRate%',
                  label: 'Task rate',
                ),
              ),
              Expanded(
                child: _InsightStatItem(
                  icon: Icons.mosque_outlined,
                  value: '$prayerRate%',
                  label: 'Prayer rate',
                ),
              ),
              Expanded(
                child: _InsightStatItem(
                  icon: Icons.schedule_outlined,
                  value: bestSlotName,
                  label: 'Best slot',
                ),
              ),
              Expanded(
                child: _InsightStatItem(
                  icon: Icons.calendar_today_outlined,
                  value: bestDayName,
                  label: 'Best day',
                ),
              ),
            ],
          ),
          
          // Weekly summary
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completedThisWeek of $totalThisWeek tasks',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$prayersCompleted of $expectedPrayers prayers',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Mini balance indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getBalanceColor(weeklyRate, prayerRate),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    _getBalanceIcon(weeklyRate, prayerRate),
                    size: 18,
                    color: _getBalanceColor(weeklyRate, prayerRate),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getBalanceColor(int taskRate, int prayerRate) {
    final diff = (taskRate - prayerRate).abs();
    if (diff <= 15 && taskRate >= 50 && prayerRate >= 50) {
      return Colors.green.shade600; // Well balanced
    } else if (taskRate < 30 && prayerRate < 30) {
      return Colors.red.shade400; // Both low
    } else {
      return Colors.orange.shade400; // Imbalanced
    }
  }
  
  IconData _getBalanceIcon(int taskRate, int prayerRate) {
    final diff = (taskRate - prayerRate).abs();
    if (diff <= 15 && taskRate >= 50 && prayerRate >= 50) {
      return Icons.balance; // Balanced
    } else if (prayerRate > taskRate + 15) {
      return Icons.mosque_outlined; // More prayers than tasks
    } else if (taskRate > prayerRate + 15) {
      return Icons.work_outline; // More tasks than prayers
    } else {
      return Icons.trending_up;
    }
  }
}

class _InsightStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InsightStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.black),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.gray500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ============ HEATMAP CALENDAR ============


// ============ ACHIEVEMENTS ============

class _AchievementsSection extends StatelessWidget {
  final int prayerStreak;
  final int taskStreak;
  final int monthPrayersCompleted;
  final int monthTasksCompleted;
  final int nafilasEnabled;

  const _AchievementsSection({
    required this.prayerStreak,
    required this.taskStreak,
    required this.monthPrayersCompleted,
    required this.monthTasksCompleted,
    required this.nafilasEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = <_Achievement>[
      _Achievement(
        icon: Icons.wb_sunny_outlined,
        title: 'First Light',
        description: 'Pray 5 prayers in a day',
        unlocked: monthPrayersCompleted >= 5,
      ),
      _Achievement(
        icon: Icons.local_fire_department_outlined,
        title: 'On Fire',
        description: '7-day prayer streak',
        unlocked: prayerStreak >= 7,
      ),
      _Achievement(
        icon: Icons.star_outline,
        title: 'Star',
        description: '30-day prayer streak',
        unlocked: prayerStreak >= 30,
      ),
      _Achievement(
        icon: Icons.check_circle_outline,
        title: 'Taskmaster',
        description: 'Complete 10 tasks',
        unlocked: monthTasksCompleted >= 10,
      ),
      _Achievement(
        icon: Icons.volunteer_activism_outlined,
        title: 'Devoted',
        description: 'Enable 3 nafila prayers',
        unlocked: nafilasEnabled >= 3,
      ),
      _Achievement(
        icon: Icons.nightlight_outlined,
        title: 'Night Owl',
        description: '7-day task streak',
        unlocked: taskStreak >= 7,
      ),
    ];
    
    final unlockedCount = achievements.where((a) => a.unlocked).length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$unlockedCount/${achievements.length}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: achievements.map((a) => _AchievementBadge(achievement: a)).toList(),
        ),
      ],
    );
  }
}

class _Achievement {
  final IconData icon;
  final String title;
  final String description;
  final bool unlocked;

  const _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.unlocked,
  });
}

class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${achievement.title}: ${achievement.description}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: achievement.unlocked ? AppColors.black : AppColors.gray100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              achievement.icon,
              size: 14,
              color: achievement.unlocked ? AppColors.white : AppColors.gray400,
            ),
            const SizedBox(width: 4),
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 12,
                color: achievement.unlocked ? AppColors.white : AppColors.gray400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ NAFILA PROGRESS COMPACT ============

class _NafilaProgressCompact extends StatelessWidget {
  final List nafilas;

  const _NafilaProgressCompact({required this.nafilas});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = now.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nafila Prayers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...nafilas.take(4).map((nafila) {
          final info = PrayerData.nafilaPrayers.firstWhere(
            (p) => p.id == nafila.prayerInfoId,
            orElse: () => PrayerData.nafilaPrayers.first,
          );
          final completed = nafila.streakCount.clamp(0, daysInMonth);
          final progress = daysInMonth > 0 ? completed / daysInMonth : 0.0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    info.name,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$completed/$daysInMonth',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.gray500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ============ DAILY ADHKAR CARD ============

class _DailyChallengesCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(dailyChallengesProvider);
    final challengeItems = challenges.challengeItems;
    if (challengeItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No daily Adkar available.',
          style: TextStyle(fontSize: 14, color: AppColors.gray500),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Adkar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in challengeItems)
                _ChallengeChip(
                  item: item,
                  emojiColor: 'black',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChallengeChip extends StatelessWidget {
  final ChallengeItem item;
  final String emojiColor; // 'black' or 'white'

  const _ChallengeChip({required this.item, this.emojiColor = 'black'});

  String getColoredEmoji(String emoji, String color) {
    // Replace common colored emoji with black/white variants if possible
    // (You can expand this mapping as needed)
    final map = {
      '📖': color == 'black' ? '📖' : '📖', // Book emoji (no color variant)
      '🕋': color == 'black' ? '🕋' : '🕋', // Kaaba emoji (no color variant)
      '🕊️': color == 'black' ? '🕊️' : '🕊️', // Dove emoji (no color variant)
      // Add more mappings if you use colored emojis elsewhere
    };
    return map[emoji] ?? emoji;
  }

  @override
  Widget build(BuildContext context) {
    IconData _getAdkarIcon(String id) {
      switch (id) {
        case 'adhkar_sabah':
          return Icons.wb_sunny_outlined; // Morning
        case 'adhkar_salat':
          return Icons.mosque_outlined; // After Prayer
        case 'adhkar_masa':
          return Icons.nightlight_outlined; // Evening
        case 'adhkar_nawm':
          return Icons.bedtime_outlined; // Sleep
        case 'tasbih':
          return Icons.brightness_low_outlined; // Tasbih (beads)
        case 'quran':
          return Icons.menu_book_outlined; // Quran
        default:
          return Icons.circle_outlined;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: item.isCompleted ? AppColors.black : AppColors.gray100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getAdkarIcon(item.id),
            size: 14,
            color: item.isCompleted ? AppColors.white : AppColors.gray400,
          ),
          const SizedBox(width: 4),
          Text(
            item.title.split(' ').first,
            style: TextStyle(
              fontSize: 12,
              color: item.isCompleted ? AppColors.white : AppColors.gray400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
