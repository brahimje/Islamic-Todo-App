import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/localization_extensions.dart';
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

    final completedCount = tasks.where((t) => t.state == TaskState.completed).length;
    final totalCount = tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.todaysTasks,
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
                  context.l10n.noTasks,
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
                      onSkip: () {
                        taskNotifier.skipTask(task.id);
                      },
                      onArchive: () {
                        taskNotifier.archiveTask(task.id);
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
                          context.l10n.addTask,
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
  final VoidCallback onSkip;
  final VoidCallback onArchive;

  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onSkip,
    required this.onArchive,
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

  Color? get _stateBackgroundColor {
    switch (task.state) {
      case TaskState.completed:
        return AppColors.successLight;
      case TaskState.skipped:
        return AppColors.gray100;
      case TaskState.archived:
        return AppColors.gray50;
      case TaskState.overdue:
        return AppColors.errorLight;
      default:
        return null;
    }
  }

  String get _stateLabel {
    switch (task.state) {
      case TaskState.completed:
        return '✓ Done';
      case TaskState.skipped:
        return '⊘ Skipped';
      case TaskState.archived:
        return '📦 Archived';
      case TaskState.overdue:
        return '⚠ Overdue';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: task.state == TaskState.active ? onToggle : null,
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
                color: task.state == TaskState.completed ? AppColors.success : AppColors.white,
                border: Border.all(
                  color: task.state == TaskState.completed ? AppColors.success : AppColors.gray400,
                  width: 2,
                ),
              ),
              child: task.state == TaskState.completed
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.white,
                    )
                  : task.state == TaskState.skipped
                      ? const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.gray400,
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
                          decoration: (task.state == TaskState.completed ||
                                  task.state == TaskState.skipped)
                              ? TextDecoration.lineThrough
                              : null,
                          color: (task.state == TaskState.completed ||
                                  task.state == TaskState.skipped)
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
                  if (task.state != TaskState.active) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _stateBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _stateLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action buttons
            if (task.state == TaskState.active)
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'skip',
                    child: Row(
                      children: [
                        const Icon(Icons.skip_next, size: 18),
                        const SizedBox(width: 8),
                        Text(context.l10n.skip),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        const Icon(Icons.archive, size: 18),
                        const SizedBox(width: 8),
                        Text(context.l10n.archive),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'skip') {
                    onSkip();
                  } else if (value == 'archive') {
                    onArchive();
                  }
                },
                child: IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.gray400,
                  ),
                  iconSize: 20,
                  onPressed: null,
                ),
              )
            else
              IconButton(
                icon: const Icon(
                  Icons.archive,
                  color: AppColors.gray400,
                ),
                iconSize: 20,
                onPressed: onArchive,
              ),
          ],
        ),
      ),
    );
  }
}
