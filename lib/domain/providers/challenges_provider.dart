import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for custom tasbih item
class TasbihItem {
  final String id;
  final String arabic;
  final String transliteration;
  final String translation;
  final int count;
  final int target;

  const TasbihItem({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.count = 0,
    this.target = 33,
  });

  TasbihItem copyWith({int? count, int? target}) {
    return TasbihItem(
      id: id,
      arabic: arabic,
      transliteration: transliteration,
      translation: translation,
      count: count ?? this.count,
      target: target ?? this.target,
    );
  }

  bool get isCompleted => count >= target;
}

/// Model for daily challenge progress
class DailyChallenges {
  // Tasbih counters (basic 3)
  final int subhanAllahCount;
  final int alhamdulillahCount;
  final int allahuAkbarCount;
  
  // Tasbih targets (customizable)
  final int subhanAllahTarget;
  final int alhamdulillahTarget;
  final int allahuAkbarTarget;
  
  // Extra tasbihat counts
  final int laIlahaIllallahCount;
  final int laHawlaCount;
  final int astaghfirullahCount;
  final int salawatCount;
  final int hasbunaAllahCount;
  
  // Extra tasbihat targets
  final int laIlahaIllallahTarget;
  final int laHawlaTarget;
  final int astaghfirullahTarget;
  final int salawatTarget;
  final int hasbunaAllahTarget;
  
  // Adhkar completion
  final bool adhkarSabahCompleted;
  final bool adhkarSalatCompleted;
  final bool adhkarMasaCompleted;
  final bool adhkarNawmCompleted;
  
  // Quran progress - Manual tracking (not linked to in-app reader)
  final int dailyHizbTarget; // User's daily goal (e.g., 1 hizb per day)
  final int hizbsCompletedToday; // How many completed today
  final int totalHizbsCompleted; // All-time total
  final int quranReadingStreak; // Days in a row
  final int currentPosition; // Current position (1-60)
  
  // Displayed extra tasbihat (list of tasbih type IDs shown in main widget)
  final List<String> displayedTasbihat;
  
  // Date tracking
  final DateTime date;

  const DailyChallenges({
    this.subhanAllahCount = 0,
    this.alhamdulillahCount = 0,
    this.allahuAkbarCount = 0,
    this.subhanAllahTarget = 33,
    this.alhamdulillahTarget = 33,
    this.allahuAkbarTarget = 33,
    this.laIlahaIllallahCount = 0,
    this.laHawlaCount = 0,
    this.astaghfirullahCount = 0,
    this.salawatCount = 0,
    this.hasbunaAllahCount = 0,
    this.laIlahaIllallahTarget = 100,
    this.laHawlaTarget = 33,
    this.astaghfirullahTarget = 100,
    this.salawatTarget = 100,
    this.hasbunaAllahTarget = 33,
    this.adhkarSabahCompleted = false,
    this.adhkarSalatCompleted = false,
    this.adhkarMasaCompleted = false,
    this.adhkarNawmCompleted = false,
    this.dailyHizbTarget = 1,
    this.hizbsCompletedToday = 0,
    this.totalHizbsCompleted = 0,
    this.quranReadingStreak = 0,
    this.currentPosition = 1,
    this.displayedTasbihat = const [],
    required this.date,
  });

  DailyChallenges copyWith({
    int? subhanAllahCount,
    int? alhamdulillahCount,
    int? allahuAkbarCount,
    int? subhanAllahTarget,
    int? alhamdulillahTarget,
    int? allahuAkbarTarget,
    int? laIlahaIllallahCount,
    int? laHawlaCount,
    int? astaghfirullahCount,
    int? salawatCount,
    int? hasbunaAllahCount,
    int? laIlahaIllallahTarget,
    int? laHawlaTarget,
    int? astaghfirullahTarget,
    int? salawatTarget,
    int? hasbunaAllahTarget,
    bool? adhkarSabahCompleted,
    bool? adhkarSalatCompleted,
    bool? adhkarMasaCompleted,
    bool? adhkarNawmCompleted,
    int? dailyHizbTarget,
    int? hizbsCompletedToday,
    int? totalHizbsCompleted,
    int? quranReadingStreak,
    int? currentPosition,
    List<String>? displayedTasbihat,
    DateTime? date,
  }) {
    return DailyChallenges(
      subhanAllahCount: subhanAllahCount ?? this.subhanAllahCount,
      alhamdulillahCount: alhamdulillahCount ?? this.alhamdulillahCount,
      allahuAkbarCount: allahuAkbarCount ?? this.allahuAkbarCount,
      subhanAllahTarget: subhanAllahTarget ?? this.subhanAllahTarget,
      alhamdulillahTarget: alhamdulillahTarget ?? this.alhamdulillahTarget,
      allahuAkbarTarget: allahuAkbarTarget ?? this.allahuAkbarTarget,
      laIlahaIllallahCount: laIlahaIllallahCount ?? this.laIlahaIllallahCount,
      laHawlaCount: laHawlaCount ?? this.laHawlaCount,
      astaghfirullahCount: astaghfirullahCount ?? this.astaghfirullahCount,
      salawatCount: salawatCount ?? this.salawatCount,
      hasbunaAllahCount: hasbunaAllahCount ?? this.hasbunaAllahCount,
      laIlahaIllallahTarget: laIlahaIllallahTarget ?? this.laIlahaIllallahTarget,
      laHawlaTarget: laHawlaTarget ?? this.laHawlaTarget,
      astaghfirullahTarget: astaghfirullahTarget ?? this.astaghfirullahTarget,
      salawatTarget: salawatTarget ?? this.salawatTarget,
      hasbunaAllahTarget: hasbunaAllahTarget ?? this.hasbunaAllahTarget,
      adhkarSabahCompleted: adhkarSabahCompleted ?? this.adhkarSabahCompleted,
      adhkarSalatCompleted: adhkarSalatCompleted ?? this.adhkarSalatCompleted,
      adhkarMasaCompleted: adhkarMasaCompleted ?? this.adhkarMasaCompleted,
      adhkarNawmCompleted: adhkarNawmCompleted ?? this.adhkarNawmCompleted,
      dailyHizbTarget: dailyHizbTarget ?? this.dailyHizbTarget,
      hizbsCompletedToday: hizbsCompletedToday ?? this.hizbsCompletedToday,
      totalHizbsCompleted: totalHizbsCompleted ?? this.totalHizbsCompleted,
      quranReadingStreak: quranReadingStreak ?? this.quranReadingStreak,
      currentPosition: currentPosition ?? this.currentPosition,
      displayedTasbihat: displayedTasbihat ?? this.displayedTasbihat,
      date: date ?? this.date,
    );
  }

  // Computed properties
  bool get tasbihCompleted =>
      subhanAllahCount >= subhanAllahTarget &&
      alhamdulillahCount >= alhamdulillahTarget &&
      allahuAkbarCount >= allahuAkbarTarget;
  
  bool get quranCompleted => hizbsCompletedToday >= dailyHizbTarget;

  int get adhkarCompletedCount => [
        adhkarSabahCompleted,
        adhkarSalatCompleted,
        adhkarMasaCompleted,
        adhkarNawmCompleted,
      ].where((c) => c).length;

  int get totalChallenges => 6; // Tasbih + 4 Adhkar + Quran
  
  int get completedChallenges {
    int count = 0;
    if (tasbihCompleted) count++;
    if (adhkarSabahCompleted) count++;
    if (adhkarSalatCompleted) count++;
    if (adhkarMasaCompleted) count++;
    if (adhkarNawmCompleted) count++;
    if (quranCompleted) count++;
    return count;
  }

  double get completionRate => 
      totalChallenges > 0 ? completedChallenges / totalChallenges : 0.0;
  
  double get hizbProgress => dailyHizbTarget > 0 
      ? (hizbsCompletedToday / dailyHizbTarget).clamp(0.0, 1.0) 
      : 0.0;

  // Get challenge items for display
  List<ChallengeItem> get challengeItems => [
    ChallengeItem(
      id: 'tasbih',
      title: 'Daily Tasbih',
      subtitle: 'سبحان الله، الحمد لله، الله أكبر',
      icon: '📿',
      isCompleted: tasbihCompleted,
      progress: _tasbihProgress,
    ),
    ChallengeItem(
      id: 'adhkar_sabah',
      title: 'Morning Adhkar',
      subtitle: 'أذكار الصباح',
      icon: '🌅',
      isCompleted: adhkarSabahCompleted,
      progress: adhkarSabahCompleted ? 1.0 : 0.0,
    ),
    ChallengeItem(
      id: 'adhkar_salat',
      title: 'After Prayer Adhkar',
      subtitle: 'أذكار الصلاة',
      icon: '🕌',
      isCompleted: adhkarSalatCompleted,
      progress: adhkarSalatCompleted ? 1.0 : 0.0,
    ),
    ChallengeItem(
      id: 'adhkar_masa',
      title: 'Evening Adhkar',
      subtitle: 'أذكار المساء',
      icon: '🌙',
      isCompleted: adhkarMasaCompleted,
      progress: adhkarMasaCompleted ? 1.0 : 0.0,
    ),
    ChallengeItem(
      id: 'adhkar_nawm',
      title: 'Sleep Adhkar',
      subtitle: 'أذكار النوم',
      icon: '😴',
      isCompleted: adhkarNawmCompleted,
      progress: adhkarNawmCompleted ? 1.0 : 0.0,
    ),
    ChallengeItem(
      id: 'quran',
      title: 'Quran Reading',
      subtitle: '$hizbsCompletedToday / $dailyHizbTarget hizb today',
      icon: '📖',
      isCompleted: quranCompleted,
      progress: hizbProgress,
    ),
  ];

  double get _tasbihProgress {
    final total = subhanAllahTarget + alhamdulillahTarget + allahuAkbarTarget;
    final current = subhanAllahCount.clamp(0, subhanAllahTarget) +
        alhamdulillahCount.clamp(0, alhamdulillahTarget) +
        allahuAkbarCount.clamp(0, allahuAkbarTarget);
    return total > 0 ? current / total : 0.0;
  }
}

/// Challenge item model for display
class ChallengeItem {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final bool isCompleted;
  final double progress;

  const ChallengeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.progress,
  });
}

/// Notifier for managing daily challenges
class DailyChallengesNotifier extends StateNotifier<DailyChallenges> {
    /// Toggle completion of a challenge by id
    void toggleChallenge(String id) {
      switch (id) {
        case 'adhkar_sabah':
          state = state.copyWith(adhkarSabahCompleted: !state.adhkarSabahCompleted);
          break;
        case 'adhkar_salat':
          state = state.copyWith(adhkarSalatCompleted: !state.adhkarSalatCompleted);
          break;
        case 'adhkar_masa':
          state = state.copyWith(adhkarMasaCompleted: !state.adhkarMasaCompleted);
          break;
        case 'adhkar_nawm':
          state = state.copyWith(adhkarNawmCompleted: !state.adhkarNawmCompleted);
          break;
        // Add more cases as needed for other challenge types
        default:
          return;
      }
      _saveToPrefs();
    }
  DailyChallengesNotifier() 
      : super(DailyChallenges(date: DateTime.now())) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('challenges_date') ?? '';
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    // Load persistent Quran data
    final dailyHizbTarget = prefs.getInt('quran_daily_target') ?? 1;
    final totalHizbsCompleted = prefs.getInt('quran_total_hizbs') ?? 0;
    final quranReadingStreak = prefs.getInt('quran_streak') ?? 0;
    final currentPosition = prefs.getInt('quran_current_position') ?? 1;
    
    // Check if we need to update streak
    final lastReadDate = prefs.getString('quran_last_read_date') ?? '';
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
    
    // Load displayed tasbihat (persistent)
    final displayedTasbihat = prefs.getStringList('displayed_tasbihat') ?? [];
    
    int currentStreak = quranReadingStreak;
    if (lastReadDate != todayStr && lastReadDate != yesterdayStr) {
      // Streak broken - reset if not read yesterday
      currentStreak = 0;
    }
    
    // If saved date is not today, reset daily progress
    if (savedDate != todayStr) {
      // Reset daily counters but keep targets and Quran progress
      state = DailyChallenges(
        date: today,
        subhanAllahTarget: prefs.getInt('tasbih_target_subhan') ?? 33,
        alhamdulillahTarget: prefs.getInt('tasbih_target_hamd') ?? 33,
        allahuAkbarTarget: prefs.getInt('tasbih_target_akbar') ?? 33,
        laIlahaIllallahTarget: prefs.getInt('tasbih_target_lailaha') ?? 100,
        laHawlaTarget: prefs.getInt('tasbih_target_lahawla') ?? 33,
        astaghfirullahTarget: prefs.getInt('tasbih_target_astaghfir') ?? 100,
        salawatTarget: prefs.getInt('tasbih_target_salawat') ?? 100,
        hasbunaAllahTarget: prefs.getInt('tasbih_target_hasbuna') ?? 33,
        dailyHizbTarget: dailyHizbTarget,
        totalHizbsCompleted: totalHizbsCompleted,
        quranReadingStreak: currentStreak,
        currentPosition: currentPosition,
        displayedTasbihat: displayedTasbihat,
      );
      await prefs.setString('challenges_date', todayStr);
    } else {
      // Load today's progress
      state = DailyChallenges(
        date: today,
        subhanAllahCount: prefs.getInt('tasbih_subhan') ?? 0,
        alhamdulillahCount: prefs.getInt('tasbih_hamd') ?? 0,
        allahuAkbarCount: prefs.getInt('tasbih_akbar') ?? 0,
        subhanAllahTarget: prefs.getInt('tasbih_target_subhan') ?? 33,
        alhamdulillahTarget: prefs.getInt('tasbih_target_hamd') ?? 33,
        allahuAkbarTarget: prefs.getInt('tasbih_target_akbar') ?? 33,
        laIlahaIllallahCount: prefs.getInt('tasbih_lailaha') ?? 0,
        laHawlaCount: prefs.getInt('tasbih_lahawla') ?? 0,
        astaghfirullahCount: prefs.getInt('tasbih_astaghfir') ?? 0,
        salawatCount: prefs.getInt('tasbih_salawat') ?? 0,
        hasbunaAllahCount: prefs.getInt('tasbih_hasbuna') ?? 0,
        laIlahaIllallahTarget: prefs.getInt('tasbih_target_lailaha') ?? 100,
        laHawlaTarget: prefs.getInt('tasbih_target_lahawla') ?? 33,
        astaghfirullahTarget: prefs.getInt('tasbih_target_astaghfir') ?? 100,
        salawatTarget: prefs.getInt('tasbih_target_salawat') ?? 100,
        hasbunaAllahTarget: prefs.getInt('tasbih_target_hasbuna') ?? 33,
        adhkarSabahCompleted: prefs.getBool('adhkar_sabah') ?? false,
        adhkarSalatCompleted: prefs.getBool('adhkar_salat') ?? false,
        adhkarMasaCompleted: prefs.getBool('adhkar_masa') ?? false,
        adhkarNawmCompleted: prefs.getBool('adhkar_nawm') ?? false,
        dailyHizbTarget: dailyHizbTarget,
        hizbsCompletedToday: prefs.getInt('quran_hizbs_today') ?? 0,
        totalHizbsCompleted: totalHizbsCompleted,
        quranReadingStreak: currentStreak,
        currentPosition: currentPosition,
        displayedTasbihat: displayedTasbihat,
      );
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    await prefs.setString('challenges_date', todayStr);
    await prefs.setInt('tasbih_subhan', state.subhanAllahCount);
    await prefs.setInt('tasbih_hamd', state.alhamdulillahCount);
    await prefs.setInt('tasbih_akbar', state.allahuAkbarCount);
    await prefs.setInt('tasbih_target_subhan', state.subhanAllahTarget);
    await prefs.setInt('tasbih_target_hamd', state.alhamdulillahTarget);
    await prefs.setInt('tasbih_target_akbar', state.allahuAkbarTarget);
    await prefs.setBool('adhkar_sabah', state.adhkarSabahCompleted);
    await prefs.setBool('adhkar_salat', state.adhkarSalatCompleted);
    await prefs.setBool('adhkar_masa', state.adhkarMasaCompleted);
    await prefs.setBool('adhkar_nawm', state.adhkarNawmCompleted);
    await prefs.setInt('quran_daily_target', state.dailyHizbTarget);
    await prefs.setInt('quran_hizbs_today', state.hizbsCompletedToday);
    await prefs.setInt('quran_total_hizbs', state.totalHizbsCompleted);
    await prefs.setInt('quran_streak', state.quranReadingStreak);
    await prefs.setInt('quran_current_position', state.currentPosition);
    // Extra tasbihat
    await prefs.setInt('tasbih_lailaha', state.laIlahaIllallahCount);
    await prefs.setInt('tasbih_lahawla', state.laHawlaCount);
    await prefs.setInt('tasbih_astaghfir', state.astaghfirullahCount);
    await prefs.setInt('tasbih_salawat', state.salawatCount);
    await prefs.setInt('tasbih_hasbuna', state.hasbunaAllahCount);
    await prefs.setInt('tasbih_target_lailaha', state.laIlahaIllallahTarget);
    await prefs.setInt('tasbih_target_lahawla', state.laHawlaTarget);
    await prefs.setInt('tasbih_target_astaghfir', state.astaghfirullahTarget);
    await prefs.setInt('tasbih_target_salawat', state.salawatTarget);
    await prefs.setInt('tasbih_target_hasbuna', state.hasbunaAllahTarget);
  }

  // Tasbih methods
  void incrementTasbih(String type) {
    switch (type) {
      case 'subhanAllah':
        state = state.copyWith(subhanAllahCount: state.subhanAllahCount + 1);
        break;
      case 'alhamdulillah':
        state = state.copyWith(alhamdulillahCount: state.alhamdulillahCount + 1);
        break;
      case 'allahuAkbar':
        state = state.copyWith(allahuAkbarCount: state.allahuAkbarCount + 1);
        break;
      case 'laIlahaIllallah':
        state = state.copyWith(laIlahaIllallahCount: state.laIlahaIllallahCount + 1);
        break;
      case 'laHawla':
        state = state.copyWith(laHawlaCount: state.laHawlaCount + 1);
        break;
      case 'astaghfirullah':
        state = state.copyWith(astaghfirullahCount: state.astaghfirullahCount + 1);
        break;
      case 'salawat':
        state = state.copyWith(salawatCount: state.salawatCount + 1);
        break;
      case 'hasbunaAllah':
        state = state.copyWith(hasbunaAllahCount: state.hasbunaAllahCount + 1);
        break;
    }
    _saveToPrefs();
  }

  void resetTasbih(String type) {
    switch (type) {
      case 'subhanAllah':
        state = state.copyWith(subhanAllahCount: 0);
        break;
      case 'alhamdulillah':
        state = state.copyWith(alhamdulillahCount: 0);
        break;
      case 'allahuAkbar':
        state = state.copyWith(allahuAkbarCount: 0);
        break;
      case 'laIlahaIllallah':
        state = state.copyWith(laIlahaIllallahCount: 0);
        break;
      case 'laHawla':
        state = state.copyWith(laHawlaCount: 0);
        break;
      case 'astaghfirullah':
        state = state.copyWith(astaghfirullahCount: 0);
        break;
      case 'salawat':
        state = state.copyWith(salawatCount: 0);
        break;
      case 'hasbunaAllah':
        state = state.copyWith(hasbunaAllahCount: 0);
        break;
    }
    _saveToPrefs();
  }

  void setTasbihTarget(String type, int target) {
    switch (type) {
      case 'subhanAllah':
        state = state.copyWith(subhanAllahTarget: target);
        break;
      case 'alhamdulillah':
        state = state.copyWith(alhamdulillahTarget: target);
        break;
      case 'allahuAkbar':
        state = state.copyWith(allahuAkbarTarget: target);
        break;
      case 'laIlahaIllallah':
        state = state.copyWith(laIlahaIllallahTarget: target);
        break;
      case 'laHawla':
        state = state.copyWith(laHawlaTarget: target);
        break;
      case 'astaghfirullah':
        state = state.copyWith(astaghfirullahTarget: target);
        break;
      case 'salawat':
        state = state.copyWith(salawatTarget: target);
        break;
      case 'hasbunaAllah':
        state = state.copyWith(hasbunaAllahTarget: target);
        break;
    }
    _saveToPrefs();
  }

  void setTasbihTargets({
    int? subhanAllah,
    int? alhamdulillah,
    int? allahuAkbar,
  }) {
    state = state.copyWith(
      subhanAllahTarget: subhanAllah ?? state.subhanAllahTarget,
      alhamdulillahTarget: alhamdulillah ?? state.alhamdulillahTarget,
      allahuAkbarTarget: allahuAkbar ?? state.allahuAkbarTarget,
    );
    _saveToPrefs();
  }
  
  void setExtraTasbihTarget(String type, int target) {
    switch (type) {
      case 'laIlahaIllallah':
        state = state.copyWith(laIlahaIllallahTarget: target);
        break;
      case 'laHawla':
        state = state.copyWith(laHawlaTarget: target);
        break;
      case 'astaghfirullah':
        state = state.copyWith(astaghfirullahTarget: target);
        break;
      case 'salawat':
        state = state.copyWith(salawatTarget: target);
        break;
      case 'hasbunaAllah':
        state = state.copyWith(hasbunaAllahTarget: target);
        break;
    }
    _saveToPrefs();
  }
  
  // Displayed tasbihat methods
  void addDisplayedTasbih(String type) {
    if (!state.displayedTasbihat.contains(type)) {
      state = state.copyWith(
        displayedTasbihat: [...state.displayedTasbihat, type],
      );
      _saveDisplayedTasbihat();
    }
  }
  
  void removeDisplayedTasbih(String type) {
    state = state.copyWith(
      displayedTasbihat: state.displayedTasbihat.where((t) => t != type).toList(),
    );
    _saveDisplayedTasbihat();
  }
  
  Future<void> _saveDisplayedTasbihat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('displayed_tasbihat', state.displayedTasbihat);
  }

  // Adhkar methods
  void toggleAdhkar(String type, bool completed) {
    switch (type) {
      case 'sabah':
        state = state.copyWith(adhkarSabahCompleted: completed);
        break;
      case 'salat':
        state = state.copyWith(adhkarSalatCompleted: completed);
        break;
      case 'masa':
        state = state.copyWith(adhkarMasaCompleted: completed);
        break;
      case 'nawm':
        state = state.copyWith(adhkarNawmCompleted: completed);
        break;
    }
    _saveToPrefs();
  }

  // Quran methods - Manual tracking (independent of in-app reader)
  
  void setDailyHizbTarget(int target) {
    state = state.copyWith(dailyHizbTarget: target.clamp(1, 60));
    _saveToPrefs();
  }
  
  void incrementHizb() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastReadDate = prefs.getString('quran_last_read_date') ?? '';
    
    // Update streak
    int newStreak = state.quranReadingStreak;
    if (lastReadDate != todayStr) {
      // First reading today - increment streak
      newStreak = state.quranReadingStreak + 1;
      await prefs.setString('quran_last_read_date', todayStr);
    }
    
    state = state.copyWith(
      hizbsCompletedToday: state.hizbsCompletedToday + 1,
      totalHizbsCompleted: state.totalHizbsCompleted + 1,
      currentPosition: (state.currentPosition % 60) + 1, // Loop back after 60
      quranReadingStreak: newStreak,
    );
    _saveToPrefs();
  }
  
  void decrementHizb() {
    if (state.hizbsCompletedToday > 0) {
      state = state.copyWith(
        hizbsCompletedToday: state.hizbsCompletedToday - 1,
        totalHizbsCompleted: (state.totalHizbsCompleted - 1).clamp(0, 999999),
        currentPosition: state.currentPosition > 1 ? state.currentPosition - 1 : 60,
      );
      _saveToPrefs();
    }
  }
  
  void setCurrentPosition(int position) {
    state = state.copyWith(currentPosition: position.clamp(1, 60));
    _saveToPrefs();
  }

  void resetQuranDaily() {
    state = state.copyWith(hizbsCompletedToday: 0);
    _saveToPrefs();
  }

  void resetQuranStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quran_last_read_date');
    state = state.copyWith(
      currentPosition: 1,
      totalHizbsCompleted: 0,
      quranReadingStreak: 0,
      hizbsCompletedToday: 0,
      dailyHizbTarget: 1,
    );
    _saveToPrefs();
  }
}

// Provider
final dailyChallengesProvider = 
    StateNotifierProvider<DailyChallengesNotifier, DailyChallenges>(
  (ref) => DailyChallengesNotifier(),
);

// Derived providers for easy access
final challengeItemsProvider = Provider<List<ChallengeItem>>((ref) {
  final challenges = ref.watch(dailyChallengesProvider);
  return challenges.challengeItems;
});

final challengeCompletionRateProvider = Provider<double>((ref) {
  final challenges = ref.watch(dailyChallengesProvider);
  return challenges.completionRate;
});

final challengeStatsProvider = Provider<ChallengeStats>((ref) {
  final challenges = ref.watch(dailyChallengesProvider);
  return ChallengeStats(
    tasbihCompleted: challenges.tasbihCompleted,
    adhkarCompletedCount: challenges.adhkarCompletedCount,
    hizbsCompletedToday: challenges.hizbsCompletedToday,
    dailyHizbTarget: challenges.dailyHizbTarget,
    currentPosition: challenges.currentPosition,
    overallProgress: challenges.completionRate,
    completedChallenges: challenges.completedChallenges,
    totalChallenges: challenges.totalChallenges,
    quranReadingStreak: challenges.quranReadingStreak,
    totalHizbsCompleted: challenges.totalHizbsCompleted,
  );
});

class ChallengeStats {
  final bool tasbihCompleted;
  final int adhkarCompletedCount;
  final int hizbsCompletedToday;
  final int dailyHizbTarget;
  final int currentPosition;
  final double overallProgress;
  final int completedChallenges;
  final int totalChallenges;
  final int quranReadingStreak;
  final int totalHizbsCompleted;

  const ChallengeStats({
    required this.tasbihCompleted,
    required this.adhkarCompletedCount,
    required this.hizbsCompletedToday,
    required this.dailyHizbTarget,
    required this.currentPosition,
    required this.overallProgress,
    required this.completedChallenges,
    required this.totalChallenges,
    required this.quranReadingStreak,
    required this.totalHizbsCompleted,
  });
}
