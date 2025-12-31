import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/models/task.dart';
import '../../../../domain/providers/task_provider.dart';

/// Widget showing today's task list with completion status
class TaskListWidget extends ConsumerWidget {
  const TaskListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(todayTasksProvider);
    final taskNotifier = ref.read(taskProvider.notifier);

    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.todaysTasks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSm,
                vertical: AppDimensions.paddingXs,
              ),
              decoration: BoxDecoration(
                color: completedCount == totalCount && totalCount > 0
                    ? AppColors.successLight
                    : AppColors.gray100,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                '$completedCount/$totalCount',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: completedCount == totalCount && totalCount > 0
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.task_alt,
                  size: 48,
                  color: AppColors.gray300,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  AppStrings.noTasks,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray500,
                      ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _TaskTile(
                      task: task,
                      onToggle: () {
                        taskNotifier.toggleTaskCompletion(task.id);
                      },
                      onDelete: () {
                        taskNotifier.deleteTask(task.id);
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                InkWell(
                  onTap: () => context.push(AppRoutes.addTask),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMd),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.gray600,
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Text(
                          AppStrings.addTask,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.gray600,
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
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  Color get _priorityColor {
    switch (task.priorityEnum) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.warning;
      default:
        return AppColors.gray400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      onLongPress: () {
        context.push('${AppRoutes.editTask}/${task.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm,
        ),
        child: Row(
          children: [
            // Priority indicator
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: _priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),

            // Checkbox
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: task.isCompleted ? AppColors.black : AppColors.white,
                border: Border.all(
                  color: task.isCompleted ? AppColors.black : AppColors.gray400,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.white,
                    )
                  : null,
            ),
            const SizedBox(width: AppDimensions.spacingMd),

            // Task details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? AppColors.gray500
                              : AppColors.black,
                        ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Delete button
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.gray400,
              ),
              iconSize: 20,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
