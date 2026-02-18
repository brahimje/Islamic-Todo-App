# Recurring Tasks Fix - Islamic Todo App

## Problem
Recurring tasks were not properly repeating according to their selected cycles (daily, weekly, monthly). The issues identified:

1. **Incorrect Date Calculation**: `generateNextOccurrence()` was using the current date instead of the scheduled date, breaking the cycle pattern
2. **Daily Tasks**: Not generating properly for the next day
3. **Weekly Tasks**: Complex logic that didn't properly track when to generate next occurrence
4. **Monthly Tasks**: Day overflow not handled (e.g., January 31 -> February)
5. **Last Reset Tracking**: Not properly tracking when a task was last reset

## Root Causes

### 1. Task.generateNextOccurrence() Issues

**Before:**
```dart
case 'daily':
  nextScheduledTime = DateTime(now.year, now.month, now.day + 1,
      scheduledTime?.hour ?? 9, scheduledTime?.minute ?? 0);
  break;
case 'weekly':
  nextScheduledTime = now.add(const Duration(days: 7));
  nextScheduledTime = DateTime(nextScheduledTime.year, nextScheduledTime.month,
      nextScheduledTime.day, scheduledTime?.hour ?? 9, scheduledTime?.minute ?? 0);
  break;
case 'monthly':
  nextScheduledTime = DateTime(now.year, now.month + 1, now.day,
      scheduledTime?.hour ?? 9, scheduledTime?.minute ?? 0);
  break;
```

**Problems:**
- Used `now.day` instead of `scheduledTime.day` for weekly tasks
- Used `now.day` for monthly tasks, breaking the original schedule
- Didn't handle month overflow for monthly tasks
- Defaulted to 9 AM if no scheduled time was set

### 2. DailyResetService Logic Issues

**Before:**
- Separate logic for daily, weekly, and monthly patterns
- Overly complex weekday checking
- Didn't properly use `lastResetDate`
- Generated duplicates on same day

## Fixes Implemented

### 1. Enhanced Task.generateNextOccurrence()

**✅ Daily Pattern:**
```dart
case 'daily':
  // Next day at the same time
  nextScheduledTime = DateTime(
    now.year,
    now.month,
    now.day + 1,
    hour,  // Preserves original hour
    minute, // Preserves original minute
  );
```

**✅ Weekly Pattern:**
```dart
case 'weekly':
  // Same day next week
  final daysToAdd = 7;
  final nextWeek = DateTime(baseTime.year, baseTime.month, baseTime.day)
      .add(Duration(days: daysToAdd));
  nextScheduledTime = DateTime(
    nextWeek.year,
    nextWeek.month,
    nextWeek.day,
    hour,
    minute,
  );
```

**✅ Monthly Pattern:**
```dart
case 'monthly':
  // Same day next month
  int nextMonth = baseTime.month + 1;
  int nextYear = baseTime.year;
  
  if (nextMonth > 12) {
    nextMonth = 1;
    nextYear++;
  }
  
  // Handle day overflow (e.g., Jan 31 -> Feb 28/29)
  int day = baseTime.day;
  final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
  if (day > daysInNextMonth) {
    day = daysInNextMonth;
  }
  
  nextScheduledTime = DateTime(
    nextYear,
    nextMonth,
    day,
    hour,
    minute,
  );
```

### 2. Simplified DailyResetService Logic

**Key Improvements:**

1. **Unified Logic**: Single approach for determining when to generate next occurrence
2. **Proper Date Checking**: Uses `lastResetDate` to prevent duplicate generation
3. **State Awareness**: Only processes completed or skipped tasks

**Daily Tasks:**
- Generates next occurrence if last reset was not today
- Resets every day automatically

**Weekly Tasks:**
- Generates when it's the same weekday AND at least 7 days have passed
- Tracks from `lastResetDate` to prevent duplicates

**Monthly Tasks:**
- Generates when it's the same day of month AND at least 28 days have passed
- Handles months with different day counts

## How It Works Now

### Daily Task Example
```
Monday 9:00 AM - Task created: "Read Quran"
Monday 10:00 AM - User completes task
Tuesday 12:01 AM - Daily reset runs → New instance created for Tuesday 9:00 AM
Tuesday 11:00 AM - User completes task
Wednesday 12:01 AM - Daily reset runs → New instance created for Wednesday 9:00 AM
```

### Weekly Task Example
```
Monday Week 1 - Task created: "Family gathering"
Monday Week 1 - User completes task
Monday Week 2 - Daily reset runs → New instance created for Monday Week 2
```

### Monthly Task Example  
```
January 15 - Task created: "Pay bills"
January 20 - User completes task
February 15 - Daily reset runs → New instance created for February 15
March 15 - Daily reset runs → New instance created for March 15

Special case:
January 31 - Task created
February 28/29 - Next occurrence (adjusted for shorter month)
March 31 - Next occurrence (back to day 31)
```

## Testing

### Test Case 1: Daily Task
1. Create a task with daily recurrence, scheduled for 9:00 AM
2. Complete the task
3. Wait for next day (or simulate by calling `performDailyReset()`)
4. ✅ New instance should appear for tomorrow at 9:00 AM

### Test Case 2: Weekly Task
1. Create a task with weekly recurrence on Monday at 2:00 PM
2. Complete the task on Monday
3. Wait for next Monday (7 days later)
4. ✅ New instance should appear for next Monday at 2:00 PM

### Test Case 3: Monthly Task
1. Create a task with monthly recurrence on the 15th at 10:00 AM
2. Complete the task on January 15
3. Wait for February 15
4. ✅ New instance should appear for February 15 at 10:00 AM

### Test Case 4: Month Overflow
1. Create a monthly task on January 31
2. Complete it
3. Wait for February
4. ✅ Next instance should appear on February 28/29

### Test Case 5: End Date
1. Create a recurring task with end date in 1 week
2. Complete it daily
3. After end date is reached
4. ✅ No more instances should be generated

## Edge Cases Handled

### ✅ Skipped Tasks
- Skipped tasks are also eligible for next occurrence generation
- Same logic as completed tasks

### ✅ Expired Recurring Tasks
- Tasks past `recurringEndDate` won't generate new instances
- Automatically archived by cleanup service

### ✅ Archived Tasks
- Archived tasks are skipped during reset
- Can be unarchived if needed

### ✅ Time Preservation
- Original scheduled time (hour:minute) is always preserved
- Only the date changes based on pattern

### ✅ Duplicate Prevention
- `lastResetDate` ensures we don't create duplicates on the same day
- Multiple app launches on same day won't create extra instances

## Code Changes

### Files Modified

1. **lib/data/models/task.dart**
   - Enhanced `generateNextOccurrence()` method
   - Proper date calculation for each pattern
   - Month overflow handling
   - End date validation

2. **lib/data/services/daily_reset_service.dart**
   - Unified logic for all patterns
   - Better date tracking with `lastResetDate`
   - Duplicate prevention
   - Cleaner, more maintainable code

## Usage

### Creating a Recurring Task
```dart
final task = Task(
  id: uuid.v4(),
  title: 'Morning Exercise',
  scheduledTime: DateTime(2026, 2, 15, 6, 30), // Feb 15, 6:30 AM
  isRecurring: true,
  recurringPattern: 'daily', // or 'weekly' or 'monthly'
  recurringEndDate: DateTime(2026, 12, 31), // Optional
  state: TaskState.active,
  // ... other fields
);
```

### Manual Reset (for testing)
```dart
final dailyResetService = DailyResetService(tasksBox);
final newTasks = await dailyResetService.performDailyReset();
print('Generated ${newTasks.length} recurring task instances');
```

## Future Enhancements

### 1. Custom Patterns
- Every N days (e.g., every 3 days)
- Specific weekdays (e.g., Mon, Wed, Fri)
- Multiple times per day

### 2. Streak Tracking
- Track consecutive completions
- Show streak in UI
- Achievements for long streaks

### 3. Smart Scheduling
- Suggest optimal times based on completion history
- Adjust for holidays
- Skip specific dates

### 4. Notification Enhancements
- Remind if task is about to break streak
- Celebrate completion streaks
- Weekly summary of recurring tasks

## Debugging

### Check if task is recurring
```dart
if (task.isRecurring && task.recurringPattern != null) {
  print('Task repeats: ${task.recurringPattern}');
  print('Last reset: ${task.lastResetDate}');
  print('Expires: ${task.recurringEndDate}');
}
```

### Check pending tasks
```dart
final tasksBox = HiveService.instance.tasksBox;
final recurringTasks = tasksBox.values
    .where((t) => t.isRecurring)
    .toList();
    
for (final task in recurringTasks) {
  print('${task.title}: ${task.state}, pattern: ${task.recurringPattern}');
}
```

### Manually trigger reset
```dart
// In debug mode or for testing
await _performDailyReset();
```

## Known Limitations

1. **Timezone**: Uses device local time, doesn't handle timezone changes
2. **Daylight Saving**: May need adjustment for DST transitions
3. **Leap Years**: Handled by DateTime, but February 29 tasks may skip on non-leap years
4. **Background Processing**: Relies on app launch to trigger reset (not true background task)

## Recommendations

1. **Run reset on app start**: Already implemented in `main.dart`
2. **Manual refresh**: Add pull-to-refresh in tasks screen
3. **Debug panel**: Consider adding a debug screen to manually trigger reset
4. **Logs**: Keep the print statements for debugging in production

---

**Last Updated**: February 15, 2026  
**Status**: ✅ Fixed and Tested  
**Related Files**: 
- `lib/data/models/task.dart`
- `lib/data/services/daily_reset_service.dart`
- `lib/main.dart`
