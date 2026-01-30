# Task States - Visual Comparison

## Current Behavior ❌

### Scenario 1: Daily Task
```
Monday (Day 1)
┌────────────────────────────────┐
│ Read Quran (Daily)             │
│ ○ Not completed   [Complete]   │
└────────────────────────────────┘
        ↓ User completes task
┌────────────────────────────────┐
│ Read Quran (Daily)             │
│ ✓ Completed                    │
│ (Stays completed forever)       │
└────────────────────────────────┘

Tuesday (Day 2)
❌ PROBLEM: Same completed task appears in list
   - No automatic reset
   - Confusing for user
   - Task needs manual deletion
```

### Scenario 2: Completed Past Task
```
Jan 20 (Old completed task)
┌────────────────────────────────┐
│ Exercise (Completed)           │
│ ✓ Completed on Jan 20          │
│ (Still visible, clutters list) │
└────────────────────────────────┘

Jan 30 (Still showing up!)
❌ PROBLEM: Old completed tasks clog the interface
   - No auto-archival
   - Manual cleanup needed
   - Messy UI
```

### Scenario 3: Missed Task
```
Jan 20 (Deadline: Jan 20, 5 PM)
┌────────────────────────────────┐
│ Submit report                  │
│ ○ Not completed                │
└────────────────────────────────┘

Jan 21 (After deadline!)
❌ PROBLEM: Task still shown as "not completed"
   - No clear overdue indicator
   - No visual urgency
   - Treated same as today's tasks
```

---

## Proposed Behavior ✅

### Scenario 1: Daily Recurring Task
```
Monday (Day 1)
┌────────────────────────────────┐
│ 📿 Read Quran (Daily)          │
│ ○ Not Started    [Start] [Snooze]
│ Streak: 1 day 🔥               │
│ Best streak: 5 days            │
└────────────────────────────────┘
        ↓ User completes task
┌────────────────────────────────┐
│ 📿 Read Quran (Daily)          │
│ ✓ Completed                    │
│ Streak: 1 day 🔥               │
└────────────────────────────────┘

Tuesday (Day 2) - AUTOMATIC RESET! ✨
┌────────────────────────────────┐
│ 📿 Read Quran (Daily)          │
│ ○ Not Started    [Start] [Snooze]
│ Streak: 2 days 🔥 (continuing)│
│ Best streak: 5 days            │
└────────────────────────────────┘
        ↓ User completes task
┌────────────────────────────────┐
│ 📿 Read Quran (Daily)          │
│ ✓ Completed                    │
│ Streak: 2 days 🔥              │
└────────────────────────────────┘

✅ BENEFITS:
   ✓ Auto-resets at midnight
   ✓ Tracks completion history
   ✓ Shows current streak
   ✓ Shows best streak (motivation!)
   ✓ User keeps same task ID
```

### Scenario 2: Completed Past Tasks with Auto-Archive
```
Jan 20 (Old Task - Completed)
┌────────────────────────────────┐
│ Exercise                       │
│ ✓ Completed on Jan 20          │
│ (Visible - recent)             │
└────────────────────────────────┘

Jan 30 (After 30 days)
APP AUTOMATICALLY ARCHIVES IT ✨

User taps "Recent/Archive" to see:
┌────────────────────────────────┐
│ 📦 Archived Tasks              │
│ ├─ Exercise (completed Jan 20) │
│ ├─ Run (completed Jan 15)      │
│ └─ Yoga (completed Jan 8)      │
└────────────────────────────────┘

✅ BENEFITS:
   ✓ Clean interface (no clutter)
   ✓ Recent tasks visible by default
   ✓ Old tasks accessible if needed
   ✓ Better organization
   ✓ Automatic cleanup
```

### Scenario 3: Overdue Task with Clear Status
```
Jan 20, 5 PM (Before deadline)
┌────────────────────────────────┐
│ Submit report                  │
│ ⏰ Due: Jan 20, 5 PM          │
│ ○ Not Started    [Start] [Snooze]
│ Status: Due Soon 🔴            │
└────────────────────────────────┘

Jan 21, 10 AM (After deadline)
┌────────────────────────────────┐
│ Submit Report                  │
│ ⏰ Was due: Jan 20, 5 PM      │
│ ○ Not Started    [Complete]   │
│ Status: OVERDUE ⚠️             │
│ Days late: 1                    │
└────────────────────────────────┘

✅ BENEFITS:
   ✓ Clear overdue indicator
   ✓ Visual urgency (red)
   ✓ Days overdue counter
   ✓ Stands out in list
```

### Scenario 4: Snooze Feature
```
Current (Need to start running)
┌────────────────────────────────┐
│ Go running                      │
│ ○ Not Started    [Start] [❌ Delete]
└────────────────────────────────┘

❌ CURRENT: Delete or complete, no in-between

PROPOSED: Snooze Option ✨
┌────────────────────────────────┐
│ Go running                      │
│ ○ Not Started    [Start] [⏱️ Snooze]
└────────────────────────────────┘

User taps [⏱️ Snooze] → Choose:
- Snooze 1 hour
- Snooze 3 hours
- Snooze until tomorrow 9 AM
- Snooze until next week

┌─────────────────────────────────┐
│ Task snoozed until 3 PM        │
│ (Hidden from list)              │
│ (Will reappear at 3 PM)        │
└─────────────────────────────────┘

✅ BENEFITS:
   ✓ Task doesn't disappear
   ✓ Reappears when needed
   ✓ Flexible scheduling
   ✓ Better than mark complete
```

---

## Task State Flow

### Current (Simple)
```
┌──────────┐
│Not Done  │
└────┬─────┘
     │ [Complete]
     ▼
┌──────────┐
│  Done    │ (Forever stuck here)
└──────────┘
```

### Proposed (Enhanced)
```
┌──────────────┐
│ Not Started  │
└────┬─────────┘
     │
     ├─[Start]──────┐
     │               │
     ├─[Delete]─┐   │
     │           │   ▼
     │        ┌──────────────┐
     ├─[Snooze]→ In Progress │
     │        └──────────────┘
     │               │
     │          [Complete]
     │               │
     │               ▼
     │         ┌──────────┐
     │    ┌───→Completed  │
     │    │   └──────┬─────┘
     │    │          │
     │    └──[If Daily]
     │          │
     │          ▼
     │  ┌─────────────────┐
     │  │Next day resets  │→ Back to "Not Started"
     │  │ (streak +1)    │
     │  └─────────────────┘
     │
     └──────────────────┐
                        │
                        ▼
                   ┌──────────┐
                   │ Archived │ (After 30 days)
                   └──────────┘
```

---

## Feature Comparison Table

| Feature | Current | Proposed | Impact |
|---------|---------|----------|--------|
| Daily recurring reset | ❌ No | ✅ Auto | Automatically reset tasks each day |
| Completion streaks | ❌ No | ✅ Yes | Motivate with streaks 🔥 |
| Snooze feature | ❌ No | ✅ Yes | Postpone without deleting |
| Auto-archive | ❌ No | ✅ Yes | Clean interface automatically |
| Overdue indicator | ❌ No | ✅ Yes | Clear deadline status |
| Task history | ❌ No | ✅ Yes | See past completions |
| Multiple states | ⚠️ 2 | ✅ 6 | Clear task status |
| State transitions | ❌ No | ✅ Yes | Better workflow |
| Archive view | ❌ No | ✅ Yes | Access old tasks |

---

## User Experience Improvements

### Before
```
Task List (Messy)
├─ ✓ Read Quran (completed)
├─ ✓ Exercise (completed)
├─ ✓ Pray Dhuhr (completed)
├─ ✓ Meditate (completed)
├─ ○ Study
├─ ✓ Pray Fajr (from 10 days ago, completed)
├─ ✓ Help Mom (completed)
└─ ○ Work project

😞 Confusing:
   - Too many completed items
   - Can't tell when things happened
   - Old completed tasks mixed in
   - No motivation tracking
```

### After
```
Today's Tasks (Clean)
🔥 Streaks
├─ 📿 Read Quran  ✓ [5 days]
├─ 💪 Exercise  ✓ [3 days]  
├─ 🕌 Pray Dhuhr ✓ [12 days]
├─ ☮️ Meditate ✓ [7 days]
├─ 📚 Study ○ [Start]
├─ 💼 Work project ○ [Start]

Archive (Recent Completions)
├─ ✓ Pray Fajr (10 days ago)
├─ ✓ Help Mom (5 days ago)

😊 Clear & Motivating:
   ✓ Only today's tasks visible
   ✓ Streaks show consistency
   ✓ Old tasks don't clutter
   ✓ Daily reset automatic
   ✓ Progress visible with 🔥
```

---

## Implementation Effort

| Phase | Effort | Time | Impact |
|-------|--------|------|--------|
| Core State System | Medium | 2-3 hrs | Foundation |
| Lifecycle Logic | Medium | 3-4 hrs | Auto-reset & archive |
| Recurring System | Hard | 4-5 hrs | Daily task management |
| UI Updates | Medium | 3-4 hrs | User visibility |
| Testing | Medium | 2-3 hrs | Reliability |
| **TOTAL** | **Hard** | **14-19 hrs** | **Major Feature** |

---

## Recommendation

### 🎯 Start with Phase 1 (Foundation)
- Add TaskState enum and fields
- Update Hive adapter
- Add core logic methods
- Test with one feature

### Then Phase 2 (Lifecycle)
- Add auto-archive
- Add overdue marking
- Test date transitions

### Then Phase 3 (Recurring)
- Most important for daily tasks
- Greatest user benefit
- Enables streak system

Would you like me to start implementing these changes?
