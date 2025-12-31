import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ActivityBarChart extends StatelessWidget {
  final List completions;
  final List tasks;

  const ActivityBarChart({required this.completions, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final activity = <DateTime, double>{};
    for (final d in days) {
      double score = 0;
      // Prayer completion
      for (final c in completions) {
        if (c.date.year == d.year && c.date.month == d.month && c.date.day == d.day) {
          score += c.fardCompletedCount / 5;
          break;
        }
      }
      // Task completion
      final dayTasks = tasks.where((t) {
        if (t.scheduledTime == null) return false;
        return t.scheduledTime!.year == d.year &&
               t.scheduledTime!.month == d.month &&
               t.scheduledTime!.day == d.day;
      }).toList();
      if (dayTasks.isNotEmpty) {
        final completed = dayTasks.where((t) => t.isCompleted).length;
        score += completed / dayTasks.length;
      }
      activity[d] = score.clamp(0.0, 2.0) / 2; // Normalize to 0-1
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...days.map((d) {
          final value = activity[d]!;
          final dateLabel = "${d.month}/${d.day}";
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text(dateLabel, style: const TextStyle(fontSize: 12, color: AppColors.gray600))),
                Expanded(
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text("${(value * 100).round()}%", style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
