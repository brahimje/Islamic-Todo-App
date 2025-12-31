import 'prayer_time_service.dart';

/// Qiyam al-Layl wake time options based on Quran and Sunnah
enum QiyamWakeTimeOption {
  /// نصف الليل - Half of the night (Surah Al-Muzzammil: "قم الليل إلا قليلا نصفه")
  nisfAlLayl,
  
  /// الثلث الأخير - Last third of the night (Hadith: "ينزل ربنا...")
  thuluthAlAkhir,
  
  /// السدس الأخير - Last sixth of the night
  sudusAlAkhir,
  
  /// الربع الأخير - Last quarter of the night  
  rubuAlAkhir,
  
  /// قبل الفجر - Custom minutes before Fajr
  custom,
}

/// Qiyam al-Layl calculation results with Sunnah-based times
class QiyamTimes {
  final DateTime maghrib; // Night starts
  final DateTime fajr; // Night ends
  final DateTime nisfAlLayl; // نصف الليل - Middle of the night
  final DateTime thuluthAlAkhir; // الثلث الأخير - Last third
  final DateTime sudusAlAkhir; // السدس الأخير - Last sixth
  final DateTime rubuAlAkhir; // الربع الأخير - Last quarter
  final DateTime sleepTime;
  final DateTime wakeUpTime;
  final Duration nightDuration;
  final bool isEnabled;
  final QiyamWakeTimeOption selectedOption;

  const QiyamTimes({
    required this.maghrib,
    required this.fajr,
    required this.nisfAlLayl,
    required this.thuluthAlAkhir,
    required this.sudusAlAkhir,
    required this.rubuAlAkhir,
    required this.sleepTime,
    required this.wakeUpTime,
    required this.nightDuration,
    this.isEnabled = false,
    this.selectedOption = QiyamWakeTimeOption.thuluthAlAkhir,
  });

  /// Get wake time for a specific option
  DateTime getWakeTimeForOption(QiyamWakeTimeOption option, int customMinutes) {
    switch (option) {
      case QiyamWakeTimeOption.nisfAlLayl:
        return nisfAlLayl;
      case QiyamWakeTimeOption.thuluthAlAkhir:
        return thuluthAlAkhir;
      case QiyamWakeTimeOption.sudusAlAkhir:
        return sudusAlAkhir;
      case QiyamWakeTimeOption.rubuAlAkhir:
        return rubuAlAkhir;
      case QiyamWakeTimeOption.custom:
        return fajr.subtract(Duration(minutes: customMinutes));
    }
  }

  /// Get Qiyam duration for an option (time from wake until Fajr)
  Duration getQiyamDurationForOption(QiyamWakeTimeOption option, int customMinutes) {
    final wakeTime = getWakeTimeForOption(option, customMinutes);
    return fajr.difference(wakeTime);
  }

  /// Get Arabic name for option
  static String getArabicName(QiyamWakeTimeOption option) {
    switch (option) {
      case QiyamWakeTimeOption.nisfAlLayl:
        return 'نصف الليل';
      case QiyamWakeTimeOption.thuluthAlAkhir:
        return 'الثلث الأخير';
      case QiyamWakeTimeOption.sudusAlAkhir:
        return 'السدس الأخير';
      case QiyamWakeTimeOption.rubuAlAkhir:
        return 'الربع الأخير';
      case QiyamWakeTimeOption.custom:
        return 'مخصص';
    }
  }

  /// Get English name for option
  static String getEnglishName(QiyamWakeTimeOption option) {
    switch (option) {
      case QiyamWakeTimeOption.nisfAlLayl:
        return 'Half Night';
      case QiyamWakeTimeOption.thuluthAlAkhir:
        return 'Last Third';
      case QiyamWakeTimeOption.sudusAlAkhir:
        return 'Last Sixth';
      case QiyamWakeTimeOption.rubuAlAkhir:
        return 'Last Quarter';
      case QiyamWakeTimeOption.custom:
        return 'Custom';
    }
  }

  /// Get description/reference for option
  static String getReference(QiyamWakeTimeOption option) {
    switch (option) {
      case QiyamWakeTimeOption.nisfAlLayl:
        return 'Surah Al-Muzzammil: "قم الليل إلا قليلا نصفه"';
      case QiyamWakeTimeOption.thuluthAlAkhir:
        return 'Hadith: Allah descends to the lowest heaven in the last third';
      case QiyamWakeTimeOption.sudusAlAkhir:
        return 'The Prophet ﷺ would sometimes pray in the last sixth';
      case QiyamWakeTimeOption.rubuAlAkhir:
        return 'Minimum recommended time for night prayer';
      case QiyamWakeTimeOption.custom:
        return 'Set your own wake time before Fajr';
    }
  }
}

/// Represents a free time block between prayers
class FreeTimeBlock {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String afterPrayer; // Prayer that just ended
  final String beforePrayer; // Upcoming prayer
  final Duration totalDuration;
  final Duration availableDuration; // After accounting for preparation
  final bool isCurrentBlock;

  FreeTimeBlock({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.afterPrayer,
    required this.beforePrayer,
    required this.totalDuration,
    required this.availableDuration,
    required this.isCurrentBlock,
  });

  /// Get preparation time in minutes (difference between total and available)
  int get preparationMinutes => (totalDuration.inMinutes - availableDuration.inMinutes).clamp(0, 999);

  /// Get a human-readable duration string
  String get durationText {
    final hours = availableDuration.inHours;
    final minutes = availableDuration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Get time range text
  String get timeRangeText {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMin = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMin = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMin - $endHour:$endMin';
  }

  /// Check if a task with given duration fits in this block
  bool canFitTask(Duration taskDuration) {
    return taskDuration <= availableDuration;
  }

  /// Get suggested task durations for this block
  List<Duration> getSuggestedTaskDurations() {
    final suggestions = <Duration>[];
    final mins = availableDuration.inMinutes;
    
    if (mins >= 5) suggestions.add(const Duration(minutes: 5));
    if (mins >= 10) suggestions.add(const Duration(minutes: 10));
    if (mins >= 15) suggestions.add(const Duration(minutes: 15));
    if (mins >= 25) suggestions.add(const Duration(minutes: 25)); // Pomodoro
    if (mins >= 30) suggestions.add(const Duration(minutes: 30));
    if (mins >= 45) suggestions.add(const Duration(minutes: 45));
    if (mins >= 60) suggestions.add(const Duration(minutes: 60));
    if (mins >= 90) suggestions.add(const Duration(minutes: 90));
    
    return suggestions;
  }
}

/// Settings for prayer time calculations
class PrayerTimeSettings {
  // Simplified: just preparation time per prayer (user sets total including wudu, travel, etc.)
  final Map<String, int> preparationTimes; // Minutes to prepare before each prayer
  final Map<String, int> prayerDurations; // Duration for each prayer in minutes
  
  // Sleep settings
  final int sleepHour; // Hour to sleep (0-23)
  final int sleepMinute; // Minute
  final int wakeUpMinutesBefore; // Minutes before Fajr to wake up (for custom option)
  
  // Qiyam settings
  final bool enableQiyam; // Whether to enable Qiyam al-Layl
  final QiyamWakeTimeOption qiyamWakeOption; // Selected Sunnah-based wake time
  final int qiyamCustomMinutes; // Custom minutes before Fajr (for custom option)

  const PrayerTimeSettings({
    this.preparationTimes = const {
      'Fajr': 5,
      'Dhuhr': 5,
      'Asr': 5,
      'Maghrib': 5,
      'Isha': 5,
    },
    this.prayerDurations = const {
      'Fajr': 15,
      'Dhuhr': 15,
      'Asr': 15,
      'Maghrib': 10,
      'Isha': 20,
    },
    this.sleepHour = 23,
    this.sleepMinute = 0,
    this.wakeUpMinutesBefore = 30,
    this.enableQiyam = false,
    this.qiyamWakeOption = QiyamWakeTimeOption.thuluthAlAkhir,
    this.qiyamCustomMinutes = 45,
  });

  /// Get sleep time as DateTime for today
  DateTime getSleepTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, sleepHour, sleepMinute);
  }

  /// Get preparation time needed before a prayer
  int getPreparationTime(String prayer) {
    return preparationTimes[prayer] ?? 5;
  }

  /// Get total time for a prayer session
  int getPrayerSessionTime(String prayer) {
    return prayerDurations[prayer] ?? 15;
  }

  /// Copy with new values
  PrayerTimeSettings copyWith({
    Map<String, int>? preparationTimes,
    Map<String, int>? prayerDurations,
    int? sleepHour,
    int? sleepMinute,
    int? wakeUpMinutesBefore,
    bool? enableQiyam,
    QiyamWakeTimeOption? qiyamWakeOption,
    int? qiyamCustomMinutes,
  }) {
    return PrayerTimeSettings(
      preparationTimes: preparationTimes ?? this.preparationTimes,
      prayerDurations: prayerDurations ?? this.prayerDurations,
      sleepHour: sleepHour ?? this.sleepHour,
      sleepMinute: sleepMinute ?? this.sleepMinute,
      wakeUpMinutesBefore: wakeUpMinutesBefore ?? this.wakeUpMinutesBefore,
      enableQiyam: enableQiyam ?? this.enableQiyam,
      qiyamWakeOption: qiyamWakeOption ?? this.qiyamWakeOption,
      qiyamCustomMinutes: qiyamCustomMinutes ?? this.qiyamCustomMinutes,
    );
  }
}

/// Service to calculate free time blocks between prayers
class FreeTimeService {
  final PrayerTimeSettings settings;

  FreeTimeService({this.settings = const PrayerTimeSettings()});

  /// Calculate Qiyam al-Layl times based on Maghrib and Fajr
  QiyamTimes calculateQiyamTimes(PrayerTimesResult prayerTimes) {
    final maghrib = prayerTimes.maghrib;
    final fajr = prayerTimes.fajr;
    final today = DateTime(fajr.year, fajr.month, fajr.day);
    
    // Sleep time
    final sleepTime = settings.getSleepTime(today.subtract(const Duration(days: 1)));
    
    // Calculate night duration (Maghrib to Fajr)
    DateTime effectiveMaghrib = maghrib;
    if (maghrib.isAfter(fajr)) {
      effectiveMaghrib = maghrib.subtract(const Duration(days: 1));
    }
    
    final nightDuration = fajr.difference(effectiveMaghrib);
    
    // نصف الليل - Nisf al-Layl (Middle of the night) - halfway between Maghrib and Fajr
    final nisfAlLayl = effectiveMaghrib.add(Duration(
      minutes: nightDuration.inMinutes ~/ 2,
    ));
    
    // الثلث الأخير - Thuluth al-Akhir (Last third of the night)
    // The night is divided into 3 parts, last third starts at 2/3
    final thuluthAlAkhir = effectiveMaghrib.add(Duration(
      minutes: (nightDuration.inMinutes * 2) ~/ 3,
    ));
    
    // السدس الأخير - Sudus al-Akhir (Last sixth of the night)
    // Last 1/6 of the night
    final sudusAlAkhir = effectiveMaghrib.add(Duration(
      minutes: (nightDuration.inMinutes * 5) ~/ 6,
    ));
    
    // الربع الأخير - Rubu al-Akhir (Last quarter of the night)
    // Last 1/4 of the night
    final rubuAlAkhir = effectiveMaghrib.add(Duration(
      minutes: (nightDuration.inMinutes * 3) ~/ 4,
    ));
    
    // Calculate wake up time based on selected option
    DateTime wakeUpTime;
    switch (settings.qiyamWakeOption) {
      case QiyamWakeTimeOption.nisfAlLayl:
        wakeUpTime = nisfAlLayl;
        break;
      case QiyamWakeTimeOption.thuluthAlAkhir:
        wakeUpTime = thuluthAlAkhir;
        break;
      case QiyamWakeTimeOption.sudusAlAkhir:
        wakeUpTime = sudusAlAkhir;
        break;
      case QiyamWakeTimeOption.rubuAlAkhir:
        wakeUpTime = rubuAlAkhir;
        break;
      case QiyamWakeTimeOption.custom:
        wakeUpTime = fajr.subtract(Duration(minutes: settings.qiyamCustomMinutes));
        break;
    }
    
    return QiyamTimes(
      maghrib: effectiveMaghrib,
      fajr: fajr,
      nisfAlLayl: nisfAlLayl,
      thuluthAlAkhir: thuluthAlAkhir,
      sudusAlAkhir: sudusAlAkhir,
      rubuAlAkhir: rubuAlAkhir,
      sleepTime: sleepTime,
      wakeUpTime: wakeUpTime,
      nightDuration: nightDuration,
      isEnabled: settings.enableQiyam,
      selectedOption: settings.qiyamWakeOption,
    );
  }

  /// Calculate all free time blocks for a given day
  List<FreeTimeBlock> calculateFreeTimeBlocks(PrayerTimesResult prayerTimes) {
    final blocks = <FreeTimeBlock>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Define prayer order and times
    final prayers = [
      ('Fajr', prayerTimes.fajr),
      ('Dhuhr', prayerTimes.dhuhr),
      ('Asr', prayerTimes.asr),
      ('Maghrib', prayerTimes.maghrib),
      ('Isha', prayerTimes.isha),
    ];

    // Calculate block before Fajr if Qiyam is enabled
    if (settings.enableQiyam) {
      final qiyamTimes = calculateQiyamTimes(prayerTimes);
      final qiyamStart = qiyamTimes.thuluthAlAkhir;
      final fajrTime = prayers[0].$2;
      final prepTime = settings.getPreparationTime('Fajr');
      final availableEnd = fajrTime.subtract(Duration(minutes: prepTime));
      
      if (availableEnd.isAfter(qiyamStart)) {
        blocks.add(_createBlock(
          'qiyam',
          qiyamStart,
          fajrTime,
          'Qiyam',
          'Fajr',
          prepTime,
          now,
        ));
      }
    }

    // Calculate blocks between prayers
    for (int i = 0; i < prayers.length - 1; i++) {
      final currentPrayer = prayers[i];
      final nextPrayer = prayers[i + 1];

      final currentPrayerEnd = currentPrayer.$2.add(
        Duration(minutes: settings.getPrayerSessionTime(currentPrayer.$1)),
      );
      final nextPrayerStart = nextPrayer.$2;

      // Calculate preparation time for next prayer
      final prepTime = settings.getPreparationTime(nextPrayer.$1);
      
      blocks.add(_createBlock(
        '${currentPrayer.$1.toLowerCase()}-${nextPrayer.$1.toLowerCase()}',
        currentPrayerEnd,
        nextPrayerStart,
        currentPrayer.$1,
        nextPrayer.$1,
        prepTime,
        now,
      ));
    }

    // Calculate block after Isha (until sleep time)
    final ishaEnd = prayers.last.$2.add(
      Duration(minutes: settings.getPrayerSessionTime('Isha')),
    );
    final sleepTime = settings.getSleepTime(today);
    if (sleepTime.isAfter(ishaEnd)) {
      blocks.add(_createBlock(
        'post-isha',
        ishaEnd,
        sleepTime,
        'Isha',
        'Sleep',
        0, // No preparation needed for sleep
        now,
      ));
    }

    return blocks;
  }

  /// Get total available time for the day
  Duration getTotalAvailableTime(PrayerTimesResult prayerTimes) {
    final blocks = calculateFreeTimeBlocks(prayerTimes);
    return blocks.fold(
      Duration.zero,
      (total, block) => total + block.availableDuration,
    );
  }

  /// Get free time block for a specific prayer (after that prayer)
  FreeTimeBlock? getBlockAfterPrayer(PrayerTimesResult prayerTimes, String prayerName) {
    final blocks = calculateFreeTimeBlocks(prayerTimes);
    return blocks.where((b) => b.afterPrayer == prayerName).firstOrNull;
  }

  FreeTimeBlock _createBlock(
    String id,
    DateTime start,
    DateTime end,
    String afterPrayer,
    String beforePrayer,
    int prepTimeMinutes,
    DateTime now,
  ) {
    final totalDuration = end.difference(start);
    final availableEnd = end.subtract(Duration(minutes: prepTimeMinutes));
    final availableDuration = availableEnd.isAfter(start)
        ? availableEnd.difference(start)
        : Duration.zero;

    final isCurrentBlock = now.isAfter(start) && now.isBefore(end);

    return FreeTimeBlock(
      id: id,
      startTime: start,
      endTime: end,
      afterPrayer: afterPrayer,
      beforePrayer: beforePrayer,
      totalDuration: totalDuration,
      availableDuration: availableDuration,
      isCurrentBlock: isCurrentBlock,
    );
  }

  /// Get the current free time block
  FreeTimeBlock? getCurrentBlock(PrayerTimesResult prayerTimes) {
    final blocks = calculateFreeTimeBlocks(prayerTimes);
    return blocks.where((b) => b.isCurrentBlock).firstOrNull;
  }

  /// Get remaining time in current block
  Duration? getRemainingTimeInCurrentBlock(PrayerTimesResult prayerTimes) {
    final currentBlock = getCurrentBlock(prayerTimes);
    if (currentBlock == null) return null;

    final now = DateTime.now();
    final prepTime = settings.getPreparationTime(currentBlock.beforePrayer);
    final effectiveEnd = currentBlock.endTime.subtract(Duration(minutes: prepTime));
    
    if (now.isAfter(effectiveEnd)) return Duration.zero;
    return effectiveEnd.difference(now);
  }

  /// Get upcoming free time blocks (excluding current)
  List<FreeTimeBlock> getUpcomingBlocks(PrayerTimesResult prayerTimes) {
    final now = DateTime.now();
    return calculateFreeTimeBlocks(prayerTimes)
        .where((b) => b.startTime.isAfter(now))
        .toList();
  }

  /// Suggest which block is best for a task of given duration
  FreeTimeBlock? suggestBestBlockForTask(
    PrayerTimesResult prayerTimes,
    Duration taskDuration,
  ) {
    final blocks = calculateFreeTimeBlocks(prayerTimes);
    
    // First try current block if task fits
    final currentBlock = blocks.where((b) => b.isCurrentBlock).firstOrNull;
    if (currentBlock != null) {
      final remaining = getRemainingTimeInCurrentBlock(prayerTimes);
      if (remaining != null && remaining >= taskDuration) {
        return currentBlock;
      }
    }

    // Find smallest block that fits the task (to optimize time usage)
    final suitableBlocks = blocks
        .where((b) => b.canFitTask(taskDuration) && b.startTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.availableDuration.compareTo(b.availableDuration));

    return suitableBlocks.firstOrNull;
  }
}
