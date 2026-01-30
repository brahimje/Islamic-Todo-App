# Islamic Productivity App - Flutter Implementation Plan

**Cross-Platform App for iOS, Android, Windows, macOS, and Web**

A minimalist black-and-white productivity app for Muslims that seamlessly integrates daily worship routines (especially Nafila prayers) with task management. Built with Flutter for universal platform support, inspired by Notion's clean design.

---

## Tech Stack & Architecture

### Core Technologies
- **Framework**: Flutter 3.16+ (stable)
- **Language**: Dart 3.2+
- **State Management**: Riverpod 2.x (or Provider/Bloc based on preference)
- **Local Database**: Hive or Isar (NoSQL, fast, cross-platform)
- **API Communication**: Dio + Retrofit (for prayer times API)
- **Notifications**: flutter_local_notifications + awesome_notifications
- **Background Tasks**: workmanager (Android/iOS)

### Design System
- **Theme**: Custom black-white minimalist theme
- **Typography**: Google Fonts (e.g., Inter, Poppins)
- **Icons**: Custom icon set + Material/Cupertino icons
- **Animations**: Flutter's implicit/explicit animations
- **Layout**: Responsive design using LayoutBuilder/MediaQuery

---

## Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Black/white theme colors
│   │   ├── app_strings.dart        # All text strings
│   │   ├── prayer_data.dart        # Nafila prayer definitions
│   │   └── app_dimensions.dart     # Spacing, sizes
│   ├── theme/
│   │   ├── app_theme.dart          # ThemeData configuration
│   │   └── text_styles.dart        # Typography styles
│   ├── utils/
│   │   ├── date_utils.dart         # Date formatting helpers
│   │   ├── time_utils.dart         # Time calculations
│   │   └── notification_helper.dart
│   └── router/
│       └── app_router.dart         # Navigation setup (go_router)
│
├── data/
│   ├── models/
│   │   ├── prayer.dart             # Prayer model
│   │   ├── nafila_prayer.dart      # Nafila prayer model
│   │   ├── task.dart               # Task model
│   │   ├── daily_quote.dart        # Quranic verse model
│   │   └── user_settings.dart      # Settings model
│   ├── repositories/
│   │   ├── prayer_repository.dart  # Prayer data logic
│   │   ├── task_repository.dart    # Task CRUD operations
│   │   ├── quote_repository.dart   # Daily quotes
│   │   └── settings_repository.dart
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── hive_service.dart   # Local DB wrapper
│   │   │   └── boxes.dart          # Hive box definitions
│   │   └── remote/
│   │       ├── prayer_api.dart     # Aladhan API integration
│   │       └── quote_api.dart      # Quran API integration
│   └── services/
│       ├── prayer_calculation_service.dart  # Adhan package wrapper
│       ├── notification_service.dart
│       └── location_service.dart   # GPS for prayer times
│
├── domain/
│   ├── entities/
│   │   └── ... (if using clean architecture)
│   └── usecases/
│       └── ... (business logic layer)
│
├── presentation/
│   ├── providers/
│   │   ├── prayer_provider.dart    # Prayer state management
│   │   ├── task_provider.dart      # Task state management
│   │   ├── calendar_provider.dart  # Calendar state
│   │   └── settings_provider.dart  # User settings
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── prayer_card.dart
│   │   │       ├── task_list.dart
│   │   │       └── daily_quote_widget.dart
│   │   ├── prayers/
│   │   │   ├── prayer_planner_screen.dart
│   │   │   ├── nafila_selector_screen.dart
│   │   │   └── widgets/
│   │   │       ├── prayer_time_item.dart
│   │   │       └── nafila_card.dart
│   │   ├── tasks/
│   │   │   ├── task_management_screen.dart
│   │   │   ├── add_edit_task_screen.dart
│   │   │   └── widgets/
│   │   │       ├── task_item.dart
│   │   │       └── time_slot_picker.dart
│   │   ├── calendar/
│   │   │   ├── calendar_screen.dart
│   │   │   ├── daily_view.dart
│   │   │   ├── weekly_view.dart
│   │   │   └── widgets/
│   │   │       ├── calendar_day_cell.dart
│   │   │       └── timeline_view.dart
│   │   ├── progress/
│   │   │   ├── progress_screen.dart
│   │   │   └── widgets/
│   │   │       ├── streak_widget.dart
│   │   │       ├── completion_chart.dart
│   │   │       └── statistics_card.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       ├── notification_settings_screen.dart
│   │       └── prayer_preferences_screen.dart
│   └── widgets/
│       ├── common/
│       │   ├── app_button.dart
│       │   ├── app_text_field.dart
│       │   ├── loading_indicator.dart
│       │   └── empty_state.dart
│       └── shared/
│           ├── bottom_nav_bar.dart
│           └── app_drawer.dart
│
└── l10n/                           # Internationalization
    ├── app_en.arb
    └── app_ar.arb
```

---

## Detailed Feature Implementation

### 1. Project Initialization & Setup

#### Step 1.1: Flutter Project Creation
```bash
flutter create islamic_todo_app
cd islamic_todo_app
flutter pub add riverpod flutter_riverpod
flutter pub add hive hive_flutter
flutter pub add dio
flutter pub add flutter_local_notifications awesome_notifications
flutter pub add geolocator permission_handler
flutter pub add adhan  # Islamic prayer times calculation
flutter pub add intl
flutter pub add go_router
flutter pub add google_fonts
flutter pub add fl_chart  # For progress charts
flutter pub add table_calendar  # For calendar view
flutter pub add workmanager
flutter pub add shared_preferences
flutter pub add uuid

# Dev dependencies
flutter pub add --dev build_runner
flutter pub add --dev hive_generator
flutter pub add --dev json_serializable
```

#### Step 1.2: Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to calculate accurate prayer times</string>
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>processing</string>
</array>
```

---

### 2. Data Models & Database Schema

#### Prayer Model
```dart
@HiveType(typeId: 0)
class Prayer extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name; // Fajr, Dhuhr, Asr, Maghrib, Isha
  
  @HiveField(2)
  final DateTime time;
  
  @HiveField(3)
  final bool isCompleted;
  
  @HiveField(4)
  final DateTime date;
  
  @HiveField(5)
  final bool notificationEnabled;
  
  @HiveField(6)
  final int reminderMinutesBefore; // e.g., 10 minutes before
}
```

#### Nafila Prayer Model
```dart
@HiveType(typeId: 1)
class NafilaPrayer extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name; // Doha, Tahajjud, Ishraq, Awwabin, etc.
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String quranicReference; // e.g., "Quran 17:79"
  
  @HiveField(4)
  final String hadithReference;
  
  @HiveField(5)
  final int rakahCount; // Number of units
  
  @HiveField(6)
  final bool isEnabled; // User has selected this
  
  @HiveField(7)
  final String frequency; // daily, weekly, etc.
  
  @HiveField(8)
  final TimeOfDay? preferredTime;
  
  @HiveField(9)
  final List<int> selectedDays; // 1-7 for days of week
  
  @HiveField(10)
  final bool isCompleted; // For today
  
  @HiveField(11)
  final DateTime? lastCompleted;
  
  @HiveField(12)
  final int streakCount;
}
```

#### Task Model
```dart
@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final DateTime? scheduledTime;
  
  @HiveField(4)
  final DateTime? deadline;
  
  @HiveField(5)
  final int? estimatedMinutes;
  
  @HiveField(6)
  final bool isCompleted;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime? completedAt;
  
  @HiveField(9)
  final TaskPriority priority; // high, medium, low
  
  @HiveField(10)
  final bool hasNotification;
  
  @HiveField(11)
  final String? category; // work, personal, family, etc.
  
  @HiveField(12)
  final List<String> tags;
}
```

#### Daily Quote Model
```dart
@HiveType(typeId: 3)
class DailyQuote {
  @HiveField(0)
  final String arabicText;
  
  @HiveField(1)
  final String translation;
  
  @HiveField(2)
  final String reference; // Surah:Ayah or Hadith source
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final QuoteType type; // quran, hadith
}
```

#### User Settings Model
```dart
@HiveType(typeId: 4)
class UserSettings extends HiveObject {
  @HiveField(0)
  String? locationName;
  
  @HiveField(1)
  double? latitude;
  
  @HiveField(2)
  double? longitude;
  
  @HiveField(3)
  String calculationMethod; // MWL, ISNA, Egypt, etc.
  
  @HiveField(4)
  bool notificationsEnabled;
  
  @HiveField(5)
  int defaultReminderMinutes;
  
  @HiveField(6)
  bool darkModeEnabled; // For future feature
  
  @HiveField(7)
  String language; // en, ar
  
  @HiveField(8)
  bool showNafilaReminders;
  
  @HiveField(9)
  bool showTaskReminders;
  
  @HiveField(10)
  TimeOfDay? dailyReviewTime; // Time to show daily summary
}
```

---

### 3. Prayer Time Integration

#### Prayer Calculation Service
```dart
class PrayerCalculationService {
  // Uses 'adhan' package for accurate calculations
  
  Future<PrayerTimes> calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    required CalculationMethod method,
  }) async {
    final coordinates = Coordinates(latitude, longitude);
    final params = method.getParameters();
    final prayerTimes = PrayerTimes.today(coordinates, params);
    
    return prayerTimes;
  }
  
  Future<Map<String, DateTime>> getTodayPrayerTimes() async {
    // Get from cache or calculate
    // Return Map with keys: fajr, sunrise, dhuhr, asr, maghrib, isha
  }
  
  Prayer? getNextPrayer() {
    // Determine which prayer is coming next
  }
  
  Duration? getTimeUntilNextPrayer() {
    // Calculate countdown
  }
}
```

#### Nafila Prayer Definitions (Constants)
```dart
class NafilaPrayerData {
  static final List<NafilaPrayer> defaultNafilaPrayers = [
    NafilaPrayer(
      id: 'doha',
      name: 'Salat al-Duha',
      description: 'The forenoon prayer, prayed after sunrise',
      quranicReference: 'Quran 93:1-2',
      hadithReference: 'Sahih Muslim 719',
      rakahCount: 2, // minimum, can be up to 8
      isEnabled: false,
      frequency: 'daily',
    ),
    NafilaPrayer(
      id: 'tahajjud',
      name: 'Tahajjud (Qiyam al-Layl)',
      description: 'The night prayer, prayed in the last third of the night',
      quranicReference: 'Quran 17:79, 73:1-4',
      hadithReference: 'Sahih Bukhari 1154',
      rakahCount: 8,
      isEnabled: false,
      frequency: 'daily',
    ),
    NafilaPrayer(
      id: 'ishraq',
      name: 'Salat al-Ishraq',
      description: 'Prayer after sunrise (15-20 mins)',
      quranicReference: '',
      hadithReference: 'Sunan Ibn Majah 1382',
      rakahCount: 2,
      isEnabled: false,
      frequency: 'daily',
    ),
    NafilaPrayer(
      id: 'awwabin',
      name: 'Salat al-Awwabin',
      description: 'Prayer between Maghrib and Isha',
      quranicReference: '',
      hadithReference: 'Sahih Muslim 730',
      rakahCount: 6,
      isEnabled: false,
      frequency: 'daily',
    ),
    NafilaPrayer(
      id: 'tahiyyat_masjid',
      name: 'Tahiyyat al-Masjid',
      description: 'Greeting the mosque',
      quranicReference: '',
      hadithReference: 'Sahih Bukhari 444',
      rakahCount: 2,
      isEnabled: false,
      frequency: 'as_needed',
    ),
    NafilaPrayer(
      id: 'witr',
      name: 'Salat al-Witr',
      description: 'Odd-numbered prayer after Isha',
      quranicReference: '',
      hadithReference: 'Sahih Bukhari 998',
      rakahCount: 3,
      isEnabled: false,
      frequency: 'daily',
    ),
  ];
}
```

---

### 4. State Management (Riverpod)

#### Prayer Provider
```dart
final prayerProvider = StateNotifierProvider<PrayerNotifier, PrayerState>((ref) {
  return PrayerNotifier(ref.read(prayerRepositoryProvider));
});

class PrayerState {
  final Map<String, DateTime> todayPrayerTimes;
  final List<Prayer> prayers;
  final Prayer? nextPrayer;
  final Duration? timeUntilNext;
  final bool isLoading;
  final String? error;
}

class PrayerNotifier extends StateNotifier<PrayerState> {
  final PrayerRepository _repository;
  
  Future<void> loadTodayPrayers() async { }
  Future<void> markPrayerCompleted(String prayerId) async { }
  Future<void> refreshPrayerTimes() async { }
  void startCountdown() { } // Update countdown every minute
}
```

#### Nafila Prayer Provider
```dart
final nafilaProvider = StateNotifierProvider<NafilaNotifier, NafilaState>((ref) {
  return NafilaNotifier(ref.read(nafilaRepositoryProvider));
});

class NafilaNotifier extends StateNotifier<NafilaState> {
  Future<void> toggleNafilaPrayer(String id, bool enabled) async { }
  Future<void> updatePreferredTime(String id, TimeOfDay time) async { }
  Future<void> markNafilaCompleted(String id) async { }
  Future<void> updateFrequency(String id, String frequency, List<int> days) async { }
}
```

#### Task Provider
```dart
final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.read(taskRepositoryProvider));
});

class TaskNotifier extends StateNotifier<TaskState> {
  Future<void> addTask(Task task) async { }
  Future<void> updateTask(Task task) async { }
  Future<void> deleteTask(String id) async { }
  Future<void> toggleTaskCompletion(String id) async { }
  List<Task> getTasksForTimeSlot(DateTime start, DateTime end) { }
  List<Task> getTodayTasks() { }
  List<Task> getIncompleteTasks() { }
}
```

---

### 5. User Interface Implementation

#### Home Screen Layout
```
┌─────────────────────────────────────┐
│  Islamic Todo                    ⚙  │ ← App bar (white bg, black text)
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │  📿 Daily Quote Widget         │ │ ← Quranic verse/Hadith
│  │  "And seek help through..."   │ │   (Subtle gray card)
│  │  — Quran 2:45                 │ │
│  └───────────────────────────────┘ │
│                                     │
│  ⏰ Next Prayer                     │
│  ┌───────────────────────────────┐ │
│  │  Dhuhr in 2h 34m              │ │ ← Large countdown
│  │  12:45 PM                     │ │
│  └───────────────────────────────┘ │
│                                     │
│  🕌 Today's Prayers                 │
│  ☑ Fajr       5:30 AM    ✓         │
│  ☐ Doha       7:00 AM    (Optional)│ ← Nafila prayers in lighter gray
│  ☐ Dhuhr     12:45 PM              │
│  ☐ Asr        3:30 PM              │
│  ☐ Maghrib    5:45 PM              │
│  ☐ Isha       7:15 PM              │
│  ☐ Tahajjud   2:00 AM    (Optional)│
│                                     │
│  ✅ Today's Tasks (3/7)             │
│  ☑ Morning exercise                │
│  ☐ Team meeting - 2:00 PM          │
│  ☐ Grocery shopping                │
│  + Add Task                        │
│                                     │
└─────────────────────────────────────┘
│  Home │ Calendar │ Progress │ More │ ← Bottom nav
└─────────────────────────────────────┘
```

#### Calendar Screen (Weekly View)
```
┌─────────────────────────────────────┐
│  ← December 2025           Today  → │
├─────────────────────────────────────┤
│  Mon   Tue   Wed   Thu   Fri   Sat │
│   9     10    11    12    13    14  │
│  4/6   5/6   6/6   ?/?   —    —    │ ← Prayer completion
│  3/5   4/5   2/5   1/3   —    —    │ ← Task completion
├─────────────────────────────────────┤
│  Thursday, December 12              │
│                                     │
│  05:30 AM  ✓ Fajr                  │
│  07:00 AM  ⬜ Doha (Nafila)        │
│  09:00 AM  ⬜ Team standup         │ ← Tasks between prayers
│  12:45 PM  ⬜ Dhuhr                │
│  02:00 PM  ⬜ Project work         │
│  03:30 PM  ⬜ Asr                  │
│  05:00 PM  ⬜ Grocery shopping     │
│  05:45 PM  ⬜ Maghrib              │
│  06:30 PM  ⬜ Awwabin (Nafila)     │
│  07:15 PM  ⬜ Isha                 │
│  09:00 PM  ⬜ Family time          │
│                                     │
└─────────────────────────────────────┘
```

#### Progress Screen
```
┌─────────────────────────────────────┐
│  Progress & Statistics              │
├─────────────────────────────────────┤
│                                     │
│  🔥 Current Streaks                 │
│  ┌─────────────┬─────────────┐     │
│  │ Prayers     │  Tasks      │     │
│  │   15 days   │   8 days    │     │
│  └─────────────┴─────────────┘     │
│                                     │
│  📊 This Month                      │
│  Prayers completed: 142/155 (92%)  │
│  [████████████░░] Progress bar     │
│                                     │
│  Tasks completed: 67/89 (75%)      │
│  [██████████░░░░] Progress bar     │
│                                     │
│  🕌 Nafila Prayers                  │
│  Doha:     12/30 days              │
│  Tahajjud:  8/30 days              │
│  Witr:     28/30 days              │
│                                     │
│  📈 Weekly Chart                    │
│  [Bar chart showing daily progress]│
│                                     │
│  🎯 Achievements                    │
│  ⭐ 7-day prayer streak            │
│  ⭐ 100 prayers completed          │
│  🔒 Complete 30 Tahajjud           │
│                                     │
└─────────────────────────────────────┘
```

---

### 6. Notification System

#### Notification Service Implementation
```dart
class NotificationService {
  final AwesomeNotifications _notifications;
  
  Future<void> initialize() async {
    await _notifications.initialize(
      'resource://drawable/app_icon',
      [
        NotificationChannel(
          channelKey: 'prayer_reminders',
          channelName: 'Prayer Reminders',
          importance: NotificationImportance.Max,
          playSound: true,
          soundSource: 'resource://raw/adhan', // Custom adhan sound
        ),
        NotificationChannel(
          channelKey: 'task_reminders',
          channelName: 'Task Reminders',
          importance: NotificationImportance.High,
        ),
      ],
    );
  }
  
  Future<void> schedulePrayerNotifications(List<Prayer> prayers) async {
    for (var prayer in prayers) {
      if (prayer.notificationEnabled) {
        await _notifications.createNotification(
          content: NotificationContent(
            id: prayer.id.hashCode,
            channelKey: 'prayer_reminders',
            title: '🕌 ${prayer.name} Prayer Time',
            body: 'It\'s time for ${prayer.name} prayer',
            category: NotificationCategory.Reminder,
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar.fromDate(
            date: prayer.time.subtract(
              Duration(minutes: prayer.reminderMinutesBefore),
            ),
          ),
        );
      }
    }
  }
  
  Future<void> scheduleTaskNotification(Task task) async { }
  Future<void> cancelNotification(int id) async { }
  Future<void> cancelAllNotifications() async { }
}
```

#### Background Task Scheduling
```dart
// Using workmanager for background prayer time updates
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'updatePrayerTimes':
        // Recalculate prayer times at midnight
        // Update scheduled notifications
        break;
      case 'syncData':
        // Optional: sync with cloud if implemented
        break;
    }
    return Future.value(true);
  });
}

// In main.dart
void main() async {
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'prayer-times-update',
    'updatePrayerTimes',
    frequency: Duration(hours: 24),
    initialDelay: Duration(seconds: 10),
  );
}
```

---

### 7. Theme Configuration

#### Black & White Minimalist Theme
```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colors
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Colors.black,
      colorScheme: ColorScheme.light(
        primary: Colors.black,
        secondary: Colors.grey[800]!,
        surface: Colors.white,
        background: Colors.white,
        error: Colors.grey[900]!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
      ),
      
      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
      ),
      
      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: Colors.grey[50],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    );
  }
}
```

---

### 8. Quran & Hadith Integration

#### Quote Repository
```dart
class QuoteRepository {
  final Dio _dio;
  final HiveBox<DailyQuote> _quoteBox;
  
  // API: https://api.alquran.cloud/v1/ayah/random
  // API: https://hadithapi.com/api/hadiths?apiKey=YOUR_KEY
  
  Future<DailyQuote> getDailyQuote() async {
    // Check if quote for today exists in cache
    final today = DateTime.now();
    final cachedQuote = _quoteBox.values.firstWhereOrNull(
      (quote) => quote.date.day == today.day && quote.date.month == today.month,
    );
    
    if (cachedQuote != null) return cachedQuote;
    
    // Fetch new quote (alternate between Quran and Hadith)
    final isQuranDay = today.day % 2 == 0;
    
    if (isQuranDay) {
      return await _fetchRandomQuranVerse();
    } else {
      return await _fetchRandomHadith();
    }
  }
  
  Future<DailyQuote> _fetchRandomQuranVerse() async {
    // Implement API call
  }
  
  Future<DailyQuote> _fetchRandomHadith() async {
    // Implement API call
  }
}
```

---

### 9. Implementation Phases

#### Phase 1: Foundation (Week 1)
- ✅ Setup Flutter project structure
- ✅ Configure Hive database
- ✅ Implement data models with code generation
- ✅ Create black & white theme
- ✅ Setup navigation with go_router
- ✅ Create basic screen scaffolds

#### Phase 2: Prayer System (Week 2)
- ✅ Integrate Adhan package for prayer calculations
- ✅ Implement prayer repository & state management
- ✅ Create prayer display widgets
- ✅ Add location services for accurate times
- ✅ Build prayer completion tracking
- ✅ Implement Nafila prayer system with customization

#### Phase 3: Task Management (Week 3)
- ✅ Implement task CRUD operations
- ✅ Build task list UI with filtering
- ✅ Add task scheduling with time slots
- ✅ Create add/edit task screens
- ✅ Implement task-prayer integration (time blocking)
- ✅ Add task categories and tags

#### Phase 4: Calendar & Views (Week 4)
- ✅ Implement daily timeline view
- ✅ Build weekly calendar overview
- ✅ Create monthly calendar widget
- ✅ Add completion indicators
- ✅ Implement date navigation

#### Phase 5: Notifications (Week 5)
- ✅ Setup notification channels
- ✅ Implement prayer time notifications
- ✅ Add task deadline reminders
- ✅ Configure background tasks for updates
- ✅ Add custom notification sounds
- ✅ Handle notification permissions

#### Phase 6: Progress & Analytics (Week 6)
- ✅ Build streak tracking system
- ✅ Implement completion statistics
- ✅ Create progress charts
- ✅ Add achievement system
- ✅ Build progress screen UI

#### Phase 7: Islamic Content (Week 7)
- ✅ Integrate Quran API
- ✅ Integrate Hadith API
- ✅ Build daily quote widget
- ✅ Add Quranic references to Nafila prayers
- ✅ Implement quote caching

#### Phase 8: Settings & Polish (Week 8)
- ✅ Build settings screen
- ✅ Add prayer calculation method selection
- ✅ Implement notification preferences
- ✅ Add data backup/restore
- ✅ Implement Arabic localization
- ✅ Final UI polish and animations
- ✅ Performance optimization
- ✅ Testing across platforms

---

### 10. Platform-Specific Considerations

#### iOS
- Configure notification permissions properly
- Handle background app refresh
- Test prayer time accuracy across time zones
- Ensure compliance with App Store guidelines
- Add privacy manifest for location usage

#### Android
- Configure exact alarm permissions (Android 12+)
- Optimize battery usage with WorkManager
- Handle different Android versions
- Test notification channels
- Add adaptive icon

#### Windows/macOS
- Adapt UI for larger screens
- Add keyboard shortcuts
- Implement system tray notifications
- Test window resizing behavior

#### Web
- Use responsive breakpoints
- Handle browser notifications
- Implement PWA capabilities
- Add offline support with service workers
- Test on different browsers

---

### 11. Data Backup & Cloud Sync (Future Enhancement)

#### Optional Cloud Integration
```dart
// Using Firebase or Supabase for cross-device sync
class SyncService {
  Future<void> backupToCloud() async {
    // Upload prayers, tasks, settings
  }
  
  Future<void> restoreFromCloud() async {
    // Download and merge data
  }
  
  Stream<void> enableRealTimeSync() {
    // Listen to cloud changes
  }
}
```

---

### 12. Testing Strategy

#### Unit Tests
- Test prayer calculation logic
- Test task scheduling algorithms
- Test streak calculation
- Test date/time utilities

#### Widget Tests
- Test individual widgets
- Test screen layouts
- Test user interactions

#### Integration Tests
- Test complete user flows
- Test notification triggering
- Test data persistence
- Test cross-platform behavior

---

### 13. Performance Optimization

- Use `const` constructors where possible
- Implement lazy loading for task lists
- Optimize Hive queries with indexes
- Cache prayer times to reduce calculations
- Use `ListView.builder` for long lists
- Implement image caching for quotes
- Profile and optimize heavy operations

---

### 14. Accessibility

- Add semantic labels for screen readers
- Support dynamic text sizing
- Ensure sufficient color contrast (black/white helps)
- Add haptic feedback for interactions
- Support keyboard navigation (desktop)
- Test with TalkBack/VoiceOver

---

## Key APIs & Resources

### Prayer Times
- **Adhan Dart Package**: For local calculations
- **Aladhan API**: https://aladhan.com/prayer-times-api
- **Islamic Finder API**: Backup option

### Quran
- **Al-Quran Cloud API**: https://alquran.cloud/api
- **Quran.com API**: https://api.quran.com/api/v4

### Hadith
- **Hadith API**: https://hadithapi.com/
- **Sunnah.com API**: https://sunnah.api-docs.io/

### Location
- **Geolocator Package**: For device location
- **Geocoding Package**: For location names

---

## Final Notes

This is a comprehensive plan for a cross-platform Islamic productivity app. The implementation prioritizes:

1. **Simplicity**: Clean black-white UI, minimal distractions
2. **Functionality**: Core features that truly help users
3. **Accuracy**: Precise prayer times using established libraries
4. **Cross-platform**: Works seamlessly on all devices
5. **Offline-first**: Local storage with optional cloud sync
6. **Performance**: Fast, responsive, battery-efficient

The phased approach allows for iterative development with testable milestones. Start with Phase 1-2 for MVP, then progressively add features.
