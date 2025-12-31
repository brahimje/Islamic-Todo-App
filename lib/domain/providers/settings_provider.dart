import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_todo_app/data/models/user_settings.dart';
import 'package:islamic_todo_app/data/models/daily_quote.dart';
import 'package:islamic_todo_app/data/datasources/local/hive_service.dart';
import 'prayer_provider.dart';

/// State notifier for user settings
class SettingsNotifier extends StateNotifier<UserSettings> {
  final HiveService _hiveService;
  
  SettingsNotifier(this._hiveService) : super(UserSettings.defaults()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = _hiveService.settingsBox.get('default');
    if (settings != null) {
      state = settings;
    } else {
      // Save default settings
      await _hiveService.settingsBox.put('default', state);
    }
  }

  Future<void> updateSettings({
    String? locationName,
    double? latitude,
    double? longitude,
    int? calculationMethod,
    bool? notificationsEnabled,
    int? defaultReminderMinutes,
    bool? showNafilaReminders,
    bool? showTaskReminders,
    String? language,
    int? dailyReviewHour,
    int? dailyReviewMinute,
    bool? isOnboardingComplete,
    bool? useSilentNotifications,
    int? madhab,
    bool? use24HourFormat,
    bool? showCompletedTasks,
    bool? autoArchiveCompletedTasks,
    int? weekStartDay,
  }) async {
    final updated = state.copyWith(
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      calculationMethod: calculationMethod,
      notificationsEnabled: notificationsEnabled,
      defaultReminderMinutes: defaultReminderMinutes,
      showNafilaReminders: showNafilaReminders,
      showTaskReminders: showTaskReminders,
      language: language,
      dailyReviewHour: dailyReviewHour,
      dailyReviewMinute: dailyReviewMinute,
      isOnboardingComplete: isOnboardingComplete,
      useSilentNotifications: useSilentNotifications,
      madhab: madhab,
      use24HourFormat: use24HourFormat,
      showCompletedTasks: showCompletedTasks,
      autoArchiveCompletedTasks: autoArchiveCompletedTasks,
      weekStartDay: weekStartDay,
    );
    await _hiveService.settingsBox.put('default', updated);
    state = updated;
  }

  Future<void> saveSettings(UserSettings settings) async {
    await _hiveService.settingsBox.put('default', settings);
    state = settings;
  }

  Future<void> updateCalculationMethod(int method) async {
    await updateSettings(calculationMethod: method);
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    await updateSettings(notificationsEnabled: enabled);
  }

  Future<void> updateDefaultReminderMinutes(int minutes) async {
    await updateSettings(defaultReminderMinutes: minutes);
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    await updateSettings(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
  }

  Future<void> updateLanguage(String language) async {
    await updateSettings(language: language);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>(
  (ref) {
    final hiveService = ref.watch(hiveServiceProvider);
    return SettingsNotifier(hiveService);
  },
);

/// Provider for notifications enabled status
final notificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.notificationsEnabled;
});

/// Provider for location info
final locationInfoProvider = Provider<LocationInfo>((ref) {
  final settings = ref.watch(settingsProvider);
  return LocationInfo(
    latitude: settings.latitude ?? 0,
    longitude: settings.longitude ?? 0,
    locationName: settings.locationName,
  );
});

/// Location info model
class LocationInfo {
  final double latitude;
  final double longitude;
  final String? locationName;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.locationName,
  });

  bool get isSet => latitude != 0 && longitude != 0;
  
  String get displayName {
    if (locationName != null && locationName!.isNotEmpty) {
      return locationName!;
    }
    if (isSet) {
      return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
    }
    return 'Not set';
  }
}

/// Daily quote provider
class DailyQuoteNotifier extends StateNotifier<DailyQuote?> {
  final HiveService _hiveService;
  
  DailyQuoteNotifier(this._hiveService) : super(null) {
    _loadOrGenerateQuote();
  }

  final List<DailyQuote> _quotes = [
    DailyQuote(
      id: '1',
      arabicText: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      translation: 'Indeed, with hardship comes ease.',
      reference: 'Quran 94:6',
      date: DateTime.now(),
    ),
    DailyQuote(
      id: '2',
      arabicText: 'وَتَوَكَّلْ عَلَى اللَّهِ ۚ وَكَفَىٰ بِاللَّهِ وَكِيلًا',
      translation: 'And put your trust in Allah, and sufficient is Allah as a Disposer of affairs.',
      reference: 'Quran 33:3',
      date: DateTime.now(),
    ),
    DailyQuote(
      id: '3',
      arabicText: 'فَاذْكُرُونِي أَذْكُرْكُمْ',
      translation: 'So remember Me; I will remember you.',
      reference: 'Quran 2:152',
      date: DateTime.now(),
    ),
    DailyQuote(
      id: '4',
      arabicText: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
      translation: 'And whoever fears Allah - He will make for him a way out.',
      reference: 'Quran 65:2',
      date: DateTime.now(),
    ),
    DailyQuote(
      id: '5',
      arabicText: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
      translation: 'My Lord, expand for me my chest and ease for me my task.',
      reference: 'Quran 20:25-26',
      date: DateTime.now(),
    ),
    DailyQuote(
      id: '6',
      arabicText: 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ',
      translation: 'Do not despair of the mercy of Allah.',
      reference: 'Quran 12:87',
      date: DateTime.now(),
    ),
    DailyQuote(
      id: '7',
      arabicText: 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      translation: 'Indeed, Allah is with the patient.',
      reference: 'Quran 2:153',
      date: DateTime.now(),
    ),
    DailyQuote(
      id: '8',
      arabicText: 'خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ',
      translation: 'The best of people are those who are most beneficial to people.',
      reference: 'Hadith - Tabarani',
      date: DateTime.now(),
      type: 1,
    ),
    DailyQuote(
      id: '9',
      arabicText: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
      translation: 'Actions are judged by intentions.',
      reference: 'Hadith - Bukhari & Muslim',
      date: DateTime.now(),
      type: 1,
    ),
    DailyQuote(
      id: '10',
      arabicText: 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
      translation: 'And say, "My Lord, increase me in knowledge."',
      reference: 'Quran 20:114',
      date: DateTime.now(),
    ),
  ];

  Future<void> _loadOrGenerateQuote() async {
    final savedQuote = _hiveService.quotesBox.get('today');
    final today = DateTime.now();
    
    if (savedQuote != null && savedQuote.isForToday) {
      state = savedQuote;
    } else {
      // Generate new quote for today
      final index = today.day % _quotes.length;
      final quote = _quotes[index].copyWith(date: today);
      await _hiveService.quotesBox.put('today', quote);
      state = quote;
    }
  }

  Future<void> refreshQuote() async {
    await _loadOrGenerateQuote();
  }
}

final dailyQuoteProvider = StateNotifierProvider<DailyQuoteNotifier, DailyQuote?>(
  (ref) {
    final hiveService = ref.watch(hiveServiceProvider);
    return DailyQuoteNotifier(hiveService);
  },
);
