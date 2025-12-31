import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/task.dart';
import '../../../data/services/free_time_service.dart';
import '../../../domain/providers/free_time_provider.dart';
import '../../../domain/providers/task_provider.dart';

/// Screen for adding or editing a task
class AddEditTaskScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final String? initialPrayerBlockId;

  const AddEditTaskScreen({
    super.key, 
    this.taskId,
    this.initialPrayerBlockId,
  });

  bool get isEditing => taskId != null;

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  DateTime? _deadline;
  int _priority = 1; // 0=low, 1=medium, 2=high
  String? _category;
  int? _estimatedMinutes;
  bool _hasNotification = true;
  Task? _existingTask;
  
  // New fields
  bool _isReligious = false;
  String? _selectedPrayerBlockId;

  // Normal task categories
  final List<String> _normalCategories = [
    AppStrings.categoryWork,
    AppStrings.categoryPersonal,
    AppStrings.categoryFamily,
    AppStrings.categoryHealth,
    AppStrings.categoryLearning,
    AppStrings.categoryOther,
  ];

  // Religious task categories
  final List<String> _religiousCategories = [
    'Quran Reading',
    'Dhikr',
    'Nafila',
    'Islamic Study',
    'Dua',
    'Charity',
    'Other Ibadah',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadTask();
    } else {
      // Default to today for new tasks
      _scheduledDate = DateTime.now();
      // If prayer block was provided, pre-select it
      if (widget.initialPrayerBlockId != null) {
        _selectedPrayerBlockId = widget.initialPrayerBlockId;
      }
    }
  }

  void _loadTask() {
    final tasks = ref.read(taskProvider);
    _existingTask = tasks.firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => throw Exception('Task not found'),
    );
    
    _titleController.text = _existingTask!.title;
    _descriptionController.text = _existingTask!.description ?? '';
    _scheduledDate = _existingTask!.scheduledTime;
    _deadline = _existingTask!.deadline;
    _priority = _existingTask!.priority;
    _category = _existingTask!.category;
    _estimatedMinutes = _existingTask!.estimatedMinutes;
    _hasNotification = _existingTask!.hasNotification;
    _isReligious = _existingTask!.isReligious;
    _selectedPrayerBlockId = _existingTask!.prayerBlockId;
    
    if (_existingTask!.scheduledTime != null) {
      _scheduledTime = TimeOfDay.fromDateTime(_existingTask!.scheduledTime!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Get available time for selected prayer block using the centralized calculation
  int _getAvailableMinutes(List<FreeTimeBlock> blocks, List<Task> tasks) {
    if (_selectedPrayerBlockId == null) return 0;
    
    return calculateBlockRemainingMinutes(
      blocks: blocks,
      tasks: tasks,
      blockId: _selectedPrayerBlockId!,
      excludeTaskId: widget.taskId, // Exclude current task when editing
    );
  }

  /// Get available minutes for a specific block using the centralized calculation
  int _getBlockAvailableMinutes(FreeTimeBlock block, List<FreeTimeBlock> blocks, List<Task> tasks) {
    return calculateBlockRemainingMinutes(
      blocks: blocks,
      tasks: tasks,
      blockId: block.id,
      excludeTaskId: widget.taskId, // Exclude current task when editing
    );
  }

  /// Get suggested time options based on available time
  List<int> _getSuggestedTimes(int availableMinutes) {
    final suggestions = <int>[];
    if (availableMinutes >= 5) suggestions.add(5);
    if (availableMinutes >= 10) suggestions.add(10);
    if (availableMinutes >= 15) suggestions.add(15);
    if (availableMinutes >= 25) suggestions.add(25);
    if (availableMinutes >= 30) suggestions.add(30);
    if (availableMinutes >= 45) suggestions.add(45);
    if (availableMinutes >= 60) suggestions.add(60);
    if (availableMinutes >= 90) suggestions.add(90);
    if (availableMinutes >= 120) suggestions.add(120);
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    final blocks = ref.watch(freeTimeBlocksProvider);
    final tasks = ref.watch(todayTasksProvider); // Use today's tasks to match timeline calculations
    final availableMinutes = _selectedPrayerBlockId != null 
        ? _getAvailableMinutes(blocks, tasks) 
        : 999;
    final suggestedTimes = _getSuggestedTimes(availableMinutes);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? AppStrings.editTask : AppStrings.addTask),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
            vertical: AppDimensions.screenPaddingVertical,
          ),
          children: [
            // Task Type Selector
            _buildTaskTypeSelector(context),
            const SizedBox(height: AppDimensions.spacingLg),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppStrings.taskTitle,
                hintText: _isReligious 
                    ? 'e.g., Read Surah Al-Kahf'
                    : 'What do you need to do?',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingMd),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: AppStrings.taskDescription,
                hintText: 'Add details...',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // Prayer Block Selector
            _buildPrayerBlockSelector(context, blocks, tasks, availableMinutes),
            const SizedBox(height: AppDimensions.spacingLg),

            // Schedule (only if no prayer block selected)
            if (_selectedPrayerBlockId == null) ...[
              Text(
                'Schedule',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      context,
                      label: 'Date',
                      value: _scheduledDate,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _scheduledDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _scheduledDate = date);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: _buildTimePicker(
                      context,
                      label: 'Time',
                      value: _scheduledTime,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _scheduledTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => _scheduledTime = time);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMd),

              // Deadline
              _buildDatePicker(
                context,
                label: 'Deadline (optional)',
                value: _deadline,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _deadline = date);
                  }
                },
                onClear: _deadline != null
                    ? () => setState(() => _deadline = null)
                    : null,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
            ],

            // Priority
            Text(
              AppStrings.taskPriority,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              children: [
                _buildPriorityChip(0, AppStrings.priorityLow, AppColors.gray400),
                const SizedBox(width: AppDimensions.spacingSm),
                _buildPriorityChip(1, AppStrings.priorityMedium, AppColors.warning),
                const SizedBox(width: AppDimensions.spacingSm),
                _buildPriorityChip(2, AppStrings.priorityHigh, AppColors.error),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // Category
            Text(
              AppStrings.taskCategory,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Wrap(
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              children: (_isReligious ? _religiousCategories : _normalCategories).map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _category = selected ? cat : null);
                  },
                  selectedColor: _isReligious ? AppColors.gray800 : AppColors.black,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // Estimated time with availability indicator
            _buildEstimatedTimeSection(context, suggestedTimes, availableMinutes),
            const SizedBox(height: AppDimensions.spacingLg),

            // Notification toggle
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray200),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_outlined, size: 22),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Text(
                      'Remind me',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Switch(
                    value: _hasNotification,
                    onChanged: (value) {
                      setState(() => _hasNotification = value);
                    },
                    activeColor: AppColors.black,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),

            // Save button - uses unified validation
            ElevatedButton(
              onPressed: _canSave(blocks, tasks) ? _saveTask : null,
              child: Text(widget.isEditing ? 'Update Task' : AppStrings.saveTask),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
          ],
        ),
      ),
    );
  }

  /// Build task type selector (Religious vs Normal)
  Widget _buildTaskTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Type',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Row(
          children: [
            Expanded(
              child: _buildTypeChip(
                context,
                icon: Icons.work_outline,
                label: 'Normal',
                isSelected: !_isReligious,
                onTap: () {
                  setState(() {
                    _isReligious = false;
                    _category = null; // Reset category
                  });
                },
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: _buildTypeChip(
                context,
                icon: Icons.mosque_outlined,
                label: 'Religious',
                isSelected: _isReligious,
                onTap: () {
                  setState(() {
                    _isReligious = true;
                    _category = null; // Reset category
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMd,
          horizontal: AppDimensions.paddingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.white : AppColors.gray600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.white : AppColors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build prayer block selector
  Widget _buildPrayerBlockSelector(
    BuildContext context, 
    List<FreeTimeBlock> blocks,
    List<Task> tasks,
    int availableMinutes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Schedule in Prayer Block',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            if (_selectedPrayerBlockId != null)
              TextButton(
                onPressed: () => setState(() => _selectedPrayerBlockId = null),
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          'Tasks are scheduled within prayer blocks to respect prayer times',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        
        // Prayer block chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: blocks.where((b) => b.availableDuration.inMinutes > 5).map((block) {
              final isSelected = _selectedPrayerBlockId == block.id;
              final blockAvailable = _getBlockAvailableMinutes(block, blocks, tasks);
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: blockAvailable > 0 ? () {
                    setState(() {
                      _selectedPrayerBlockId = block.id;
                      // Auto-set date based on block
                      _scheduledDate = block.startTime;
                      _scheduledTime = TimeOfDay.fromDateTime(block.startTime);
                      // Reset estimated minutes if exceeds available
                      if (_estimatedMinutes != null && _estimatedMinutes! > blockAvailable) {
                        _estimatedMinutes = null;
                      }
                    });
                  } : null,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.black 
                          : blockAvailable > 0 
                              ? AppColors.white 
                              : AppColors.gray100,
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.black 
                            : blockAvailable > 0 
                                ? AppColors.gray300 
                                : AppColors.gray200,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${block.afterPrayer} → ${block.beforePrayer}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected 
                                ? AppColors.white 
                                : blockAvailable > 0 
                                    ? AppColors.black 
                                    : AppColors.gray400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          blockAvailable > 0 
                              ? '${_formatMinutesReadable(blockAvailable)} available'
                              : 'Full',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected 
                                ? AppColors.gray300 
                                : blockAvailable > 0 
                                    ? Colors.green 
                                    : AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        // Show available time indicator with prep time info
        if (_selectedPrayerBlockId != null) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          Builder(
            builder: (context) {
              final selectedBlock = blocks.where((b) => b.id == _selectedPrayerBlockId).firstOrNull;
              return Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSm),
                decoration: BoxDecoration(
                  color: availableMinutes > 0 
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(
                    color: availableMinutes > 0 
                        ? Colors.green.withValues(alpha: 0.3)
                        : AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          availableMinutes > 0 ? Icons.check_circle : Icons.warning,
                          size: 16,
                          color: availableMinutes > 0 ? Colors.green : AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            availableMinutes > 0
                                ? '${_formatMinutesReadable(availableMinutes)} available for tasks'
                                : 'This block is fully scheduled',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: availableMinutes > 0 ? Colors.green : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Show preparation time info
                    if (selectedBlock != null && selectedBlock.preparationMinutes > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${selectedBlock.preparationMinutes} min reserved for ${selectedBlock.beforePrayer} prep',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.gray500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  /// Build estimated time section with availability check
  Widget _buildEstimatedTimeSection(
    BuildContext context, 
    List<int> suggestedTimes, 
    int availableMinutes,
  ) {
    final hasBlockSelected = _selectedPrayerBlockId != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Estimated Time',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (hasBlockSelected) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'max ${_formatMinutesReadable(availableMinutes)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        if (suggestedTimes.isEmpty && hasBlockSelected)
          Text(
            'No time slots available in this block',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
          )
        else
          Wrap(
            spacing: AppDimensions.spacingSm,
            runSpacing: AppDimensions.spacingSm,
            children: [
              // Add "Use Max" button when block is selected
              if (hasBlockSelected && availableMinutes > 0)
                ActionChip(
                  avatar: const Icon(Icons.maximize, size: 16),
                  label: Text('Use Max (${_formatMinutesReadable(availableMinutes)})'),
                  onPressed: () {
                    setState(() => _estimatedMinutes = availableMinutes);
                  },
                  backgroundColor: _estimatedMinutes == availableMinutes 
                      ? AppColors.black 
                      : Colors.green.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: _estimatedMinutes == availableMinutes 
                        ? AppColors.white 
                        : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              // Regular time chips
              ...(hasBlockSelected ? suggestedTimes : [15, 30, 60, 120]).map((mins) {
              final isSelected = _estimatedMinutes == mins;
              final isDisabled = hasBlockSelected && mins > availableMinutes;
              final label = _formatMinutesReadable(mins);
              
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: isDisabled ? null : (selected) {
                  setState(() => _estimatedMinutes = selected ? mins : null);
                },
                selectedColor: AppColors.black,
                disabledColor: AppColors.gray100,
                labelStyle: TextStyle(
                  color: isDisabled 
                      ? AppColors.gray400 
                      : isSelected 
                          ? AppColors.white 
                          : AppColors.black,
                ),
              );
            }),
            ],
          ),
        
        // Warning if estimated time exceeds available
        if (_estimatedMinutes != null && 
            hasBlockSelected && 
            _estimatedMinutes! > availableMinutes) ...[
          const SizedBox(height: AppDimensions.spacingSm),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSm),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, size: 16, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Task duration exceeds available time (${_formatMinutesReadable(availableMinutes)})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray200),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.gray600,
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                  Text(
                    value != null
                        ? DateFormat('MMM d, yyyy').format(value)
                        : 'Not set',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context, {
    required String label,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray200),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 20,
              color: AppColors.gray600,
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                  ),
                  Text(
                    value != null ? value.format(context) : 'Not set',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(int priority, String label, Color color) {
    final isSelected = _priority == priority;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _priority = priority),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : AppColors.white,
            border: Border.all(
              color: isSelected ? color : AppColors.gray200,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format minutes to readable format (e.g., "5 min", "1h 30min", "2 hours")
  String _formatMinutesReadable(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes == 60) {
      return '1 hour';
    } else if (minutes == 90) {
      return '1h 30min';
    } else if (minutes == 120) {
      return '2 hours';
    } else if (minutes % 60 == 0) {
      return '${minutes ~/ 60} hours';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}min';
    }
  }

  /// Validate using the unified time management system
  TaskSchedulingValidation _validateTask(List<FreeTimeBlock> blocks, List<Task> tasks) {
    return validateTaskScheduling(
      blocks: blocks,
      tasks: tasks,
      blockId: _selectedPrayerBlockId,
      estimatedMinutes: _estimatedMinutes,
      excludeTaskId: widget.taskId, // Exclude current task when editing
    );
  }

  /// Check if task can be saved (respects time limits)
  bool _canSave(List<FreeTimeBlock> blocks, List<Task> tasks) {
    // If a block is selected, validate with the unified system
    if (_selectedPrayerBlockId != null) {
      final validation = _validateTask(blocks, tasks);
      return validation.isValid;
    }
    return true;
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Get current blocks and tasks for validation
      final blocks = ref.read(freeTimeBlocksProvider);
      final tasks = ref.read(todayTasksProvider);
      
      // Final validation before saving
      if (_selectedPrayerBlockId != null) {
        final validation = _validateTask(blocks, tasks);
        if (!validation.isValid) {
          // Show error dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validation.errorMessage ?? 'Cannot schedule this task'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }
      
      DateTime? scheduledDateTime;
      if (_scheduledDate != null) {
        if (_scheduledTime != null) {
          scheduledDateTime = DateTime(
            _scheduledDate!.year,
            _scheduledDate!.month,
            _scheduledDate!.day,
            _scheduledTime!.hour,
            _scheduledTime!.minute,
          );
        } else {
          scheduledDateTime = _scheduledDate;
        }
      }

      final task = Task(
        id: widget.isEditing ? widget.taskId! : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        scheduledTime: scheduledDateTime,
        deadline: _deadline,
        priority: _priority,
        category: _category,
        estimatedMinutes: _estimatedMinutes,
        hasNotification: _hasNotification,
        isCompleted: _existingTask?.isCompleted ?? false,
        completedAt: _existingTask?.completedAt,
        createdAt: _existingTask?.createdAt ?? DateTime.now(),
        isReligious: _isReligious,
        prayerBlockId: _selectedPrayerBlockId,
      );

      if (widget.isEditing) {
        ref.read(taskProvider.notifier).updateTask(task);
      } else {
        ref.read(taskProvider.notifier).addTask(task);
      }
      
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskProvider.notifier).deleteTask(widget.taskId!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
