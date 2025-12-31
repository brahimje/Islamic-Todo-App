import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_todo_app/data/models/prayer.dart' as models;
import 'package:islamic_todo_app/data/models/prayer_completion.dart';
import 'package:islamic_todo_app/data/datasources/local/hive_service.dart';
import 'package:islamic_todo_app/data/services/prayer_time_service.dart';
import 'package:islamic_todo_app/domain/providers/settings_provider.dart';

/// Provider for HiveService instance
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService.instance);

/// Provider for PrayerTimeService instance
final prayerTimeServiceProvider = Provider<PrayerTimeService>((ref) => PrayerTimeService());

/// Provider for calculated prayer times based on user location
final prayerTimesProvider = Provider<PrayerTimesResult>((ref) {
  final settings = ref.watch(settingsProvider);
  final service = ref.watch(prayerTimeServiceProvider);
  
  // Use default location if not set (Makkah)
  final latitude = settings.latitude ?? 21.4225;
  final longitude = settings.longitude ?? 39.8262;
  
  return service.getPrayerTimes(
    latitude: latitude,
    longitude: longitude,
    date: DateTime.now(),
    calculationMethod: settings.calculationMethod,
    madhab: settings.madhab,
  );
});

/// Provider for Qibla direction
final qiblaDirectionProvider = Provider<double>((ref) {
  final settings = ref.watch(settingsProvider);
  final service = ref.watch(prayerTimeServiceProvider);
  
  final latitude = settings.latitude ?? 21.4225;
  final longitude = settings.longitude ?? 39.8262;
  
  return service.getQiblaDirection(
    latitude: latitude,
    longitude: longitude,
  );
});

/// State notifier for managing prayer completions
class PrayerCompletionNotifier extends StateNotifier<List<PrayerCompletion>> {
  final HiveService _hiveService;
  
  PrayerCompletionNotifier(this._hiveService) : super([]) {
    _loadCompletions();
  }

  Future<void> _loadCompletions() async {
    final completions = _hiveService.prayerCompletionsBox.values.toList();
    state = completions;
  }

  /// Get or create today's completion record
  PrayerCompletion _getOrCreateTodayCompletion() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Find existing completion for today
    final existing = state.firstWhere(
      (c) => c.date.year == todayDate.year &&
             c.date.month == todayDate.month &&
             c.date.day == todayDate.day,
      orElse: () => PrayerCompletion(
        id: todayDate.millisecondsSinceEpoch.toString(),
        date: todayDate,
      ),
    );
    
    return existing;
  }

  Future<void> markPrayerCompleted(String prayerName) async {
    final completion = _getOrCreateTodayCompletion();
    PrayerCompletion updated;
    
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        updated = completion.copyWith(
          fajrCompleted: 1,
          fajrCompletedAt: DateTime.now(),
        );
        break;
      case 'dhuhr':
        updated = completion.copyWith(
          dhuhrCompleted: 1,
          dhuhrCompletedAt: DateTime.now(),
        );
        break;
      case 'asr':
        updated = completion.copyWith(
          asrCompleted: 1,
          asrCompletedAt: DateTime.now(),
        );
        break;
      case 'maghrib':
        updated = completion.copyWith(
          maghribCompleted: 1,
          maghribCompletedAt: DateTime.now(),
        );
        break;
      case 'isha':
        updated = completion.copyWith(
          ishaCompleted: 1,
          ishaCompletedAt: DateTime.now(),
        );
        break;
      default:
        return;
    }
    
    await _hiveService.prayerCompletionsBox.put(updated.id, updated);
    await _loadCompletions();
  }

  Future<void> unmarkPrayerCompleted(String prayerName) async {
    final completion = _getOrCreateTodayCompletion();
    PrayerCompletion updated;
    
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        updated = completion.copyWith(fajrCompleted: 0);
        break;
      case 'dhuhr':
        updated = completion.copyWith(dhuhrCompleted: 0);
        break;
      case 'asr':
        updated = completion.copyWith(asrCompleted: 0);
        break;
      case 'maghrib':
        updated = completion.copyWith(maghribCompleted: 0);
        break;
      case 'isha':
        updated = completion.copyWith(ishaCompleted: 0);
        break;
      default:
        return;
    }
    
    await _hiveService.prayerCompletionsBox.put(updated.id, updated);
    await _loadCompletions();
  }

  bool isPrayerCompletedForDate(String prayerName, DateTime date) {
    final completion = state.firstWhere(
      (c) => c.date.year == date.year &&
             c.date.month == date.month &&
             c.date.day == date.day,
      orElse: () => PrayerCompletion(
        id: '',
        date: date,
      ),
    );
    
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return completion.fajrCompleted == 1;
      case 'dhuhr':
        return completion.dhuhrCompleted == 1;
      case 'asr':
        return completion.asrCompleted == 1;
      case 'maghrib':
        return completion.maghribCompleted == 1;
      case 'isha':
        return completion.ishaCompleted == 1;
      default:
        return false;
    }
  }

  /// Mark a nafila prayer (including Qiyam) as completed
  Future<void> markNafilaCompleted(String nafilaId) async {
    final completion = _getOrCreateTodayCompletion();
    
    // Add to nafila list if not already there
    if (!completion.nafilaCompleted.contains(nafilaId)) {
      final updatedNafila = List<String>.from(completion.nafilaCompleted)..add(nafilaId);
      final updated = completion.copyWith(nafilaCompleted: updatedNafila);
      
      await _hiveService.prayerCompletionsBox.put(updated.id, updated);
      await _loadCompletions();
    }
  }

  /// Unmark a nafila prayer (including Qiyam)
  Future<void> unmarkNafilaCompleted(String nafilaId) async {
    final completion = _getOrCreateTodayCompletion();
    
    // Remove from nafila list
    if (completion.nafilaCompleted.contains(nafilaId)) {
      final updatedNafila = List<String>.from(completion.nafilaCompleted)..remove(nafilaId);
      final updated = completion.copyWith(nafilaCompleted: updatedNafila);
      
      await _hiveService.prayerCompletionsBox.put(updated.id, updated);
      await _loadCompletions();
    }
  }

  /// Check if a nafila prayer is completed today
  bool isNafilaCompletedToday(String nafilaId) {
    final completion = _getOrCreateTodayCompletion();
    return completion.nafilaCompleted.contains(nafilaId);
  }

  double getCompletionRateForWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekCompletions = state.where((c) => c.date.isAfter(weekAgo)).toList();
    
    int totalCompleted = 0;
    for (final c in weekCompletions) {
      totalCompleted += c.fardCompletedCount;
    }
    
    final totalPossible = 7 * 5; // 7 days * 5 prayers
    return totalCompleted / totalPossible;
  }
}

final prayerCompletionProvider = 
    StateNotifierProvider<PrayerCompletionNotifier, List<PrayerCompletion>>(
  (ref) {
    final hiveService = ref.watch(hiveServiceProvider);
    return PrayerCompletionNotifier(hiveService);
  },
);

/// Provider for today's prayer completion record
final todayPrayerCompletionProvider = Provider<PrayerCompletion>((ref) {
  final completions = ref.watch(prayerCompletionProvider);
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  
  return completions.firstWhere(
    (c) => c.date.year == today.year &&
           c.date.month == today.month &&
           c.date.day == today.day,
    orElse: () => PrayerCompletion(
      id: todayDate.millisecondsSinceEpoch.toString(),
      date: todayDate,
    ),
  );
});

/// Provider for today's prayer list with completion status
final todayPrayersProvider = Provider<List<models.Prayer>>((ref) {
  final completions = ref.watch(prayerCompletionProvider);
  final prayerTimes = ref.watch(prayerTimesProvider);
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  
  // Find today's completion record
  final todayCompletion = completions.firstWhere(
    (c) => c.date.year == today.year &&
           c.date.month == today.month &&
           c.date.day == today.day,
    orElse: () => PrayerCompletion(
      id: '',
      date: todayDate,
    ),
  );
  
  final prayers = [
    models.Prayer(
      id: 'fajr',
      name: 'Fajr',
      date: todayDate,
      time: prayerTimes.fajr,
      isCompleted: todayCompletion.fajrCompleted == 1,
    ),
    models.Prayer(
      id: 'dhuhr',
      name: 'Dhuhr',
      date: todayDate,
      time: prayerTimes.dhuhr,
      isCompleted: todayCompletion.dhuhrCompleted == 1,
    ),
    models.Prayer(
      id: 'asr',
      name: 'Asr',
      date: todayDate,
      time: prayerTimes.asr,
      isCompleted: todayCompletion.asrCompleted == 1,
    ),
    models.Prayer(
      id: 'maghrib',
      name: 'Maghrib',
      date: todayDate,
      time: prayerTimes.maghrib,
      isCompleted: todayCompletion.maghribCompleted == 1,
    ),
    models.Prayer(
      id: 'isha',
      name: 'Isha',
      date: todayDate,
      time: prayerTimes.isha,
      isCompleted: todayCompletion.ishaCompleted == 1,
    ),
  ];
  
  return prayers;
});

/// Provider for the next upcoming prayer
final nextPrayerProvider = Provider<models.Prayer?>((ref) {
  final prayers = ref.watch(todayPrayersProvider);
  final now = DateTime.now();
  
  for (final prayer in prayers) {
    if (prayer.time.isAfter(now) && !prayer.isCompleted) {
      return prayer;
    }
  }
  
  // If all prayers are done or past, return tomorrow's Fajr
  if (prayers.isNotEmpty) {
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    // Get tomorrow's prayer times
    final settings = ref.watch(settingsProvider);
    final service = ref.watch(prayerTimeServiceProvider);
    final tomorrowPrayerTimes = service.getPrayerTimes(
      latitude: settings.latitude ?? 21.4225,
      longitude: settings.longitude ?? 39.8262,
      date: tomorrow,
      calculationMethod: settings.calculationMethod,
      madhab: settings.madhab,
    );
    return models.Prayer(
      id: 'fajr_tomorrow',
      name: 'Fajr',
      date: tomorrowDate,
      time: tomorrowPrayerTimes.fajr,
      isCompleted: false,
    );
  }
  
  return null;
});

/// Provider for time remaining until next prayer
final timeUntilNextPrayerProvider = Provider<Duration?>((ref) {
  final nextPrayer = ref.watch(nextPrayerProvider);
  if (nextPrayer == null) return null;
  
  final now = DateTime.now();
  return nextPrayer.time.difference(now);
});

/// Provider for sunrise time (for Ishraq calculations)
final sunriseTimeProvider = Provider<DateTime>((ref) {
  final prayerTimes = ref.watch(prayerTimesProvider);
  return prayerTimes.sunrise;
});
