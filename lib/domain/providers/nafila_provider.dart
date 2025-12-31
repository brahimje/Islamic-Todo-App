import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_todo_app/data/models/nafila_prayer.dart';
import 'package:islamic_todo_app/data/datasources/local/hive_service.dart';
import 'package:islamic_todo_app/core/constants/prayer_data.dart';
import 'prayer_provider.dart';

/// State notifier for managing nafila prayers
class NafilaPrayerNotifier extends StateNotifier<List<NafilaPrayer>> {
  final HiveService _hiveService;
  
  NafilaPrayerNotifier(this._hiveService) : super([]) {
    _loadNafilaPrayers();
  }

  Future<void> _loadNafilaPrayers() async {
    final nafilas = _hiveService.nafilaPrayersBox.values.toList();
    if (nafilas.isEmpty) {
      // Initialize with default nafila prayers
      await _initializeDefaultNafilas();
    } else {
      state = nafilas;
    }
  }

  Future<void> _initializeDefaultNafilas() async {
    final defaultNafilas = PrayerData.nafilaPrayers.map((info) {
      return NafilaPrayer(
        id: info.id,
        prayerInfoId: info.id,
        isEnabled: false, // Disabled by default
        frequency: 0, // Daily
        notificationEnabled: false,
      );
    }).toList();

    for (final nafila in defaultNafilas) {
      await _hiveService.nafilaPrayersBox.put(nafila.id, nafila);
    }
    
    state = defaultNafilas;
  }

  Future<void> toggleNafilaEnabled(String nafilaId) async {
    final nafila = state.firstWhere((n) => n.id == nafilaId);
    final updated = nafila.copyWith(isEnabled: !nafila.isEnabled);
    await _hiveService.nafilaPrayersBox.put(updated.id, updated);
    state = state.map((n) => n.id == nafilaId ? updated : n).toList();
  }

  Future<void> toggleNafilaReminder(String nafilaId) async {
    final nafila = state.firstWhere((n) => n.id == nafilaId);
    final updated = nafila.copyWith(notificationEnabled: !nafila.notificationEnabled);
    await _hiveService.nafilaPrayersBox.put(updated.id, updated);
    state = state.map((n) => n.id == nafilaId ? updated : n).toList();
  }

  Future<void> markNafilaCompleted(String nafilaId) async {
    final nafila = state.firstWhere((n) => n.id == nafilaId);
    final updated = nafila.copyWith(
      lastCompletedAt: DateTime.now(),
      totalCompletions: nafila.totalCompletions + 1,
      streakCount: nafila.isCompletedToday ? nafila.streakCount : nafila.streakCount + 1,
    );
    await _hiveService.nafilaPrayersBox.put(updated.id, updated);
    state = state.map((n) => n.id == nafilaId ? updated : n).toList();
  }

  bool isNafilaCompletedForDate(String nafilaId, DateTime date) {
    final nafila = state.firstWhere(
      (n) => n.id == nafilaId,
      orElse: () => NafilaPrayer(id: '', prayerInfoId: ''),
    );
    if (nafila.lastCompletedAt == null) return false;
    return nafila.lastCompletedAt!.year == date.year &&
           nafila.lastCompletedAt!.month == date.month &&
           nafila.lastCompletedAt!.day == date.day;
  }

  int getCompletionCountForWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    int count = 0;
    
    for (final nafila in state.where((n) => n.isEnabled)) {
      if (nafila.lastCompletedAt != null && nafila.lastCompletedAt!.isAfter(weekAgo)) {
        count += 1;
      }
    }
    
    return count;
  }
}

final nafilaPrayerProvider = 
    StateNotifierProvider<NafilaPrayerNotifier, List<NafilaPrayer>>(
  (ref) {
    final hiveService = ref.watch(hiveServiceProvider);
    return NafilaPrayerNotifier(hiveService);
  },
);

/// Provider for enabled nafila prayers only
final enabledNafilasProvider = Provider<List<NafilaPrayer>>((ref) {
  final nafilas = ref.watch(nafilaPrayerProvider);
  return nafilas.where((n) => n.isEnabled).toList();
});

/// Provider for today's nafila prayers with completion status
final todayNafilasProvider = Provider<List<NafilaPrayer>>((ref) {
  final nafilas = ref.watch(enabledNafilasProvider);
  return nafilas.where((n) => n.isScheduledForToday).toList();
});

/// Provider for nafila prayer info from static data
final nafilaPrayerInfoProvider = Provider<List<NafilaPrayerInfo>>((ref) {
  return PrayerData.nafilaPrayers;
});
