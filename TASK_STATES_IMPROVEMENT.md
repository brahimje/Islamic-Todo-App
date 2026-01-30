# Task States & Lifecycle - Improvement Suggestions

## Current Issues

### 1. **Limited Task States**
Currently, tasks only have binary state: `isCompleted` (true/false)
- ❌ No "In Progress" state
- ❌ No "Snoozed/Postponed" state
- ❌ No "Archived" state
- ❌ No "Overdue" differentiation in state

### 2. **Recurring Tasks Not Properly Managed**
- ✅ `isRecurring` field exists
- ✅ `recurringPattern` field exists (daily, weekly, monthly)
- ❌ **BUT**: No automatic reset logic for daily tasks
- ❌ No history of completions tracked
- ❌ No streak counting system
- ❌ Completed daily task stays marked as done forever

### 3. **Task Cleanup Issues**
- ❌ Completed tasks from past dates remain in list
- ❌ No auto-archival of old tasks
- ❌ UI gets cluttered with completed past tasks
- ❌ No distinction between today's tasks and historical tasks

### 4. **Missing Lifecycle Features**
- ❌ No automatic daily reset for recurring tasks
- ❌ No task snoozing/postponing
- ❌ No completion history tracking
- ❌ No streak management

---

## Proposed Solution: Enhanced Task State System

### 1. **Add TaskState Enum**

```dart
@HiveType(typeId: 7)
enum TaskState {
  @HiveField(0)
  notStarted,        // Not completed yet

  @HiveField(1)
  inProgress,        // User started the task

  @HiveField(2)
  completed,         // Task is done

  @HiveField(3)
  snoozed,           // Postponed until later

  @HiveField(4)
  archived,          // Old task, hidden from view

  @HiveField(5)
  overdue,           // Deadline passed, not completed
}
```

### 2. **Enhanced Task Model - Add These Fields**

```dart
@HiveType(typeId: 2)
class Task extends HiveObject {
  // ... existing fields ...
  
  // NEW FIELDS FOR STATE MANAGEMENT
  
  @HiveField(19)
  final int state; // 0=notStarted, 1=inProgress, 2=completed, 3=snoozed, 4=archived, 5=overdue
  
  @HiveField(20)
  final DateTime? snoozedUntil; // When to show snoozed task again
  
  @HiveField(21)
  final bool isFromRecurring; // Is this instance from a recurring task?
  
  @HiveField(22)
  final String? recurringInstanceId; // Link to original recurring task
  
  @HiveField(23)
  final List<DateTime> completionHistory; // Track all completion dates
  
  @HiveField(24)
  final int currentStreak; // Current completion streak
  
  @HiveField(25)
  final int longestStreak; // Best streak achieved
  
  @HiveField(26)
  final DateTime? lastCompletedDate; // Last date completed
  
  @HiveField(27)
  final bool autoReset; // Auto-reset at midnight for recurring tasks
  
  // ... rest of fields ...

  TaskState get currentState => TaskState.values[state];
  
  bool get isArchived => state == 4;
  bool get isOverdue => state == 5;
  bool get isSnoozed => state == 3;
  bool get isInProgress => state == 1;
  bool get isNotStarted => state == 0;
}
```

### 3. **Create RecurringTaskTemplate Model**

Separate model for managing recurring tasks:

```dart
@HiveType(typeId: 8)
class RecurringTaskTemplate extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final String recurringPattern; // 'daily', 'weekly', 'monthly'
  
  @HiveField(4)
  final List<int> daysOfWeek; // For weekly: [1,3,5] = Mon, Wed, Fri
  
  @HiveField(5)
  final int dayOfMonth; // For monthly: 15
  
  @HiveField(6)
  final TimeOfDay timeOfDay; // When task should appear
  
  @HiveField(7)
  final int priority;
  
  @HiveField(8)
  final String? category;
  
  @HiveField(9)
  final bool isActive;
  
  @HiveField(10)
  final DateTime createdAt;
  
  @HiveField(11)
  final DateTime? endDate; // When to stop recurring
  
  @HiveField(12)
  final int currentStreak;
  
  @HiveField(13)
  final int longestStreak;
  
  @HiveField(14)
  final DateTime? lastCompletedDate;
  
  @HiveField(15)
  final bool isReligious;
  
  @HiveField(16)
  final bool hasNotification;
}
```

### 4. **Task Lifecycle Logic - New Methods in Task Model**

```dart
class Task {
  /// Check if task should be reset (for daily recurring)
  bool shouldResetToday() {
    if (!isFromRecurring || !autoReset) return false;
    
    // Reset if last completed date is not today
    if (lastCompletedDate == null) return true;
    
    final now = DateTime.now();
    return lastCompletedDate!.year != now.year ||
           lastCompletedDate!.month != now.month ||
           lastCompletedDate!.day != now.day;
  }

  /// Create next instance of recurring task
  Task createNextInstance() {
    return Task(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      scheduledTime: _calculateNextScheduledTime(),
      priority: priority,
      category: category,
      tags: tags,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
      isReligious: isReligious,
      recurringInstanceId: recurringInstanceId ?? id,
      isFromRecurring: true,
      createdAt: DateTime.now(),
      state: 0, // notStarted
    );
  }

  /// Calculate next scheduled time based on recurring pattern
  DateTime _calculateNextScheduledTime() {
    final now = DateTime.now();
    
    switch (recurringPattern?.toLowerCase()) {
      case 'daily':
        return now.add(const Duration(days: 1));
      case 'weekly':
        return now.add(const Duration(days: 7));
      case 'monthly':
        return now.add(const Duration(days: 30));
      default:
        return now;
    }
  }

  /// Update completion streak
  Task updateStreak() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    int newStreak = currentStreak;
    int newLongestStreak = longestStreak;
    
    // If completed today already, don't increase streak
    if (lastCompletedDate?.isSameDay(now) == true) {
      newStreak = currentStreak;
    }
    // If completed yesterday, continue streak
    else if (lastCompletedDate?.isSameDay(yesterday) == true) {
      newStreak = currentStreak + 1;
    }
    // Otherwise, start new streak
    else {
      newStreak = 1;
    }
    
    // Update longest streak if new streak is higher
    newLongestStreak = max(newStreak, longestStreak);
    
    return copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastCompletedDate: now,
      completionHistory: [...completionHistory, now],
    );
  }

  /// Check if same day
  bool isSameDay(DateTime other) {
    return year == other.year &&
           month == other.month &&
           day == other.day;
  }

  /// Mark task as needs archival (old tasks)
  bool shouldBeArchived() {
    // Archive completed tasks older than 30 days
    if (state == 2 && completedAt != null) {
      final daysSinceCompletion = DateTime.now().difference(completedAt!).inDays;
      return daysSinceCompletion > 30;
    }
    return false;
  }

  /// Check if should be marked overdue
  bool shouldBeMarkedOverdue() {
    if (state == 2 || state == 4) return false; // Already completed or archived
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }
}
```

### 5. **Enhanced TaskNotifier with State Management**

```dart
class TaskNotifier extends StateNotifier<List<Task>> {
  // ... existing code ...

  /// Process daily recurring tasks (call this on app start)
  Future<void> processDailyRecurringTasks() async {
    final tasksToReset = <Task>[];
    
    for (final task in state) {
      if (task.shouldResetToday()) {
        // Mark as not started for new day
        final resetTask = task.copyWith(
          state: 0, // notStarted
          isCompleted: false,
        );
        tasksToReset.add(resetTask);
        await _hiveService.tasksBox.put(task.id, resetTask);
      }
    }
    
    if (tasksToReset.isNotEmpty) {
      state = [...state.map((t) => 
        tasksToReset.any((r) => r.id == t.id) 
          ? tasksToReset.firstWhere((r) => r.id == t.id)
          : t
      )];
    }
  }

  /// Mark task as in progress
  Future<void> startTask(String taskId) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final updated = task.copyWith(state: 1); // inProgress
    await _hiveService.tasksBox.put(taskId, updated);
    state = state.map((t) => t.id == taskId ? updated : t).toList();
  }

  /// Mark task as completed with streak update
  Future<void> completeTask(String taskId) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final updated = task.updateStreak().copyWith(
      state: 2, // completed
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    
    await _hiveService.tasksBox.put(taskId, updated);
    state = state.map((t) => t.id == taskId ? updated : t).toList();
    
    // If recurring, create next instance
    if (task.isRecurring) {
      final nextInstance = task.createNextInstance();
      await addTask(nextInstance);
    }

    // Cancel notification
    await _notificationService.cancelTaskNotification(
      taskId,
      isReligious: task.isReligious,
    );
  }

  /// Snooze task until specific time
  Future<void> snoozeTask(String taskId, DateTime until) async {
    final task = state.firstWhere((t) => t.id == taskId);
    final updated = task.copyWith(
      state: 3, // snoozed
      snoozedUntil: until,
    );
    
    await _hiveService.tasksBox.put(taskId, updated);
    state = state.map((t) => t.id == taskId ? updated : t).toList();
  }

  /// Archive old completed tasks automatically
  Future<void> archiveOldTasks() async {
    final tasksToArchive = state.where((t) => t.shouldBeArchived()).toList();
    
    for (final task in tasksToArchive) {
      final updated = task.copyWith(state: 4); // archived
      await _hiveService.tasksBox.put(task.id, updated);
    }
    
    state = state.map((t) => 
      tasksToArchive.any((a) => a.id == t.id)
        ? tasksToArchive.firstWhere((a) => a.id == t.id).copyWith(state: 4)
        : t
    ).toList();
  }

  /// Mark overdue tasks
  Future<void> updateOverdueTasks() async {
    for (final task in state) {
      if (task.shouldBeMarkedOverdue() && task.state != 5) {
        final updated = task.copyWith(state: 5); // overdue
        await _hiveService.tasksBox.put(task.id, updated);
      }
    }
  }

  /// Get visible tasks (exclude archived and snoozed)
  List<Task> getVisibleTasks() {
    return state.where((t) => 
      t.state != 4 && // Not archived
      (t.state != 3 || (t.snoozedUntil?.isBefore(DateTime.now()) ?? false)) // Not snoozed (or snooze expired)
    ).toList();
  }

  /// Get tasks by state
  List<Task> getTasksByState(TaskState state) {
    return this.state.where((t) => t.currentState == state).toList();
  }

  /// Get today's tasks (with auto-reset for recurring)
  List<Task> getTodaysTasks() {
    final today = DateTime.now();
    return getVisibleTasks()
        .where((t) {
          if (t.scheduledTime == null) return false;
          return t.scheduledTime!.year == today.year &&
                 t.scheduledTime!.month == today.month &&
                 t.scheduledTime!.day == today.day;
        })
        .toList()
        ..sort((a, b) {
          // Sort by state (not started > in progress > completed)
          if (a.state != b.state) {
            return a.state.compareTo(b.state);
          }
          // Then by priority
          return b.priority.compareTo(a.priority);
        });
  }
}
```

### 6. **App Initialization Logic**

Add to `main.dart` or app startup:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
  
  // Initialize task management
  _initializeTaskManagement();
}

Future<void> _initializeTaskManagement() async {
  // This ensures tasks are reset daily
  final container = ProviderContainer();
  
  // Process daily recurring tasks
  await container.read(taskProvider.notifier).processDailyRecurringTasks();
  
  // Archive old completed tasks
  await container.read(taskProvider.notifier).archiveOldTasks();
  
  // Mark overdue tasks
  await container.read(taskProvider.notifier).updateOverdueTasks();
}
```

---

## Implementation Priority

### Phase 1: Core State System (Week 1)
- [ ] Add `TaskState` enum
- [ ] Add state, snoozedUntil, and completion history fields to Task
- [ ] Update Task adapter in Hive
- [ ] Add state getter methods

### Phase 2: Lifecycle Management (Week 2)
- [ ] Add streak calculation logic
- [ ] Add `shouldResetToday()` method
- [ ] Add `shouldBeArchived()` method
- [ ] Add `shouldBeMarkedOverdue()` method
- [ ] Update TaskNotifier with new methods

### Phase 3: RecurringTasks System (Week 2-3)
- [ ] Create `RecurringTaskTemplate` model
- [ ] Create RecurringTaskNotifier
- [ ] Update UI to handle recurring task creation
- [ ] Add daily reset logic

### Phase 4: UI Updates (Week 3-4)
- [ ] Update task UI to show state
- [ ] Add snooze button/functionality
- [ ] Display streaks
- [ ] Filter/sort by state
- [ ] Add archive/history view

### Phase 5: Testing & Polish (Week 4)
- [ ] Test daily reset
- [ ] Test recurring creation
- [ ] Test archival logic
- [ ] Test state transitions

---

## User-Facing Features

### Before (Current)
```
Daily Prayer Task
✓ Completed
(stays completed forever)
```

### After (Proposed)
```
Daily Prayer Task
○ Not Started  [Start] [Snooze]
Streak: 12 days 🔥 Best: 25 days

[Next day automatically:]
○ Not Started  [Start] [Snooze]
Streak: 13 days 🔥 Best: 25 days
```

---

## Task State Transitions

```
                    ┌─────────────────┐
                    │   Not Started   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
         [Start]        [Snooze]      [Delete]
              │              │
              ▼              ▼
        ┌──────────┐   ┌──────────┐
        │In Progress│   │  Snoozed │
        └────┬─────┘   └────┬─────┘
             │              │
        [Complete]     [After timeout]
             │              │
             └──────┬───────┘
                    │
                    ▼
            ┌─────────────────┐
            │    Completed    │
            └────────┬────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
    (after 30 days)         (if recurring)
         │                       │
         ▼                       ▼
     ┌──────────┐        ┌──────────────┐
     │ Archived │        │Create Instance│
     └──────────┘        │for tomorrow   │
                         └──────────────┘
```

---

## Database Migration Needed

When implementing, update Hive adapter:

```dart
// task.g.dart will need to be regenerated
// Run: flutter pub run build_runner build --delete-conflicting-outputs

// The adapter will need 11 new fields (19-29)
```

---

## Benefits

✅ **Recurring tasks work properly** - Auto-reset daily  
✅ **Streak tracking** - Motivate users with streaks  
✅ **No clutter** - Old tasks auto-archive  
✅ **Better UX** - Snooze instead of delete  
✅ **Task history** - See past completion data  
✅ **State clarity** - Know task status at glance  
✅ **Overdue tracking** - Never miss deadlines  

---

Would you like me to implement any of these changes? I can start with Phase 1 (Core State System) to get the foundation in place!
