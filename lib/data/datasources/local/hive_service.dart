import 'package:hive_flutter/hive_flutter.dart';
import '../../models/models.dart';

/// Hive box names
class HiveBoxes {
  HiveBoxes._();

  static const String prayers = 'prayers';
  static const String nafilaPrayers = 'nafilaPrayers';
  static const String tasks = 'tasks';
  static const String quotes = 'quotes';
  static const String settings = 'settings';
  static const String prayerCompletions = 'prayerCompletions';
}

/// Service for managing Hive local database
class HiveService {
  HiveService._();

  static final HiveService _instance = HiveService._();
  static HiveService get instance => _instance;

  bool _isInitialized = false;

  /// Initialize Hive and register all adapters
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(PrayerAdapter());
    Hive.registerAdapter(NafilaPrayerAdapter());
    Hive.registerAdapter(NafilaFrequencyAdapter());
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(DailyQuoteAdapter());
    Hive.registerAdapter(QuoteTypeAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(CalculationMethodAdapter());
    Hive.registerAdapter(PrayerCompletionAdapter());

    // Open boxes
    await Future.wait([
      Hive.openBox<Prayer>(HiveBoxes.prayers),
      Hive.openBox<NafilaPrayer>(HiveBoxes.nafilaPrayers),
      Hive.openBox<Task>(HiveBoxes.tasks),
      Hive.openBox<DailyQuote>(HiveBoxes.quotes),
      Hive.openBox<UserSettings>(HiveBoxes.settings),
      Hive.openBox<PrayerCompletion>(HiveBoxes.prayerCompletions),
    ]);

    _isInitialized = true;
  }

  // Box getters
  Box<Prayer> get prayersBox => Hive.box<Prayer>(HiveBoxes.prayers);
  Box<NafilaPrayer> get nafilaPrayersBox =>
      Hive.box<NafilaPrayer>(HiveBoxes.nafilaPrayers);
  Box<Task> get tasksBox => Hive.box<Task>(HiveBoxes.tasks);
  Box<DailyQuote> get quotesBox => Hive.box<DailyQuote>(HiveBoxes.quotes);
  Box<UserSettings> get settingsBox =>
      Hive.box<UserSettings>(HiveBoxes.settings);
  Box<PrayerCompletion> get prayerCompletionsBox =>
      Hive.box<PrayerCompletion>(HiveBoxes.prayerCompletions);

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }

  /// Clear all data (for testing/reset)
  Future<void> clearAll() async {
    await prayersBox.clear();
    await nafilaPrayersBox.clear();
    await tasksBox.clear();
    await quotesBox.clear();
    await settingsBox.clear();
    await prayerCompletionsBox.clear();
  }

  /// Alias for clearAll for better readability
  Future<void> clearAllData() => clearAll();
  
  /// Get user settings (or null if not set)
  UserSettings? getSettings() {
    if (settingsBox.isEmpty) return null;
    return settingsBox.get('default');
  }
  
  /// Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    await settingsBox.put('default', settings);
  }
}
