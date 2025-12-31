import 'package:adhan_dart/adhan_dart.dart' as adhan;

/// Service for calculating accurate prayer times using adhan_dart
class PrayerTimeService {
  static final PrayerTimeService _instance = PrayerTimeService._internal();
  factory PrayerTimeService() => _instance;
  PrayerTimeService._internal();

  /// Get prayer times for a specific date and location
  PrayerTimesResult getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    int calculationMethod = 0,
    int madhab = 0,
  }) {
    try {
      final coordinates = adhan.Coordinates(latitude, longitude);
      final params = _getCalculationParams(calculationMethod, madhab);
      
      final prayerTimes = adhan.PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
        precision: true,
      );

      // Get Sunnah times for Qiyam calculations
      final sunnahTimes = adhan.SunnahTimes(prayerTimes);

      return PrayerTimesResult(
        fajr: prayerTimes.fajr.toLocal(),
        sunrise: prayerTimes.sunrise.toLocal(),
        dhuhr: prayerTimes.dhuhr.toLocal(),
        asr: prayerTimes.asr.toLocal(),
        maghrib: prayerTimes.maghrib.toLocal(),
        isha: prayerTimes.isha.toLocal(),
        middleOfNight: sunnahTimes.middleOfTheNight.toLocal(),
        lastThirdOfNight: sunnahTimes.lastThirdOfTheNight.toLocal(),
        date: date,
      );
    } catch (e) {
      // Return fallback times if calculation fails
      return _getFallbackTimes(date);
    }
  }

  /// Get Qibla direction from coordinates
  double getQiblaDirection({
    required double latitude,
    required double longitude,
  }) {
    final coordinates = adhan.Coordinates(latitude, longitude);
    return adhan.Qibla.qibla(coordinates);
  }

  /// Get current prayer name
  String getCurrentPrayer({
    required double latitude,
    required double longitude,
    int calculationMethod = 0,
    int madhab = 0,
  }) {
    final now = DateTime.now();
    final coordinates = adhan.Coordinates(latitude, longitude);
    final params = _getCalculationParams(calculationMethod, madhab);
    
    final prayerTimes = adhan.PrayerTimes(
      coordinates: coordinates,
      date: now,
      calculationParameters: params,
    );

    final current = prayerTimes.currentPrayer(date: now);
    return _prayerToString(current);
  }

  /// Get next prayer name
  String getNextPrayer({
    required double latitude,
    required double longitude,
    int calculationMethod = 0,
    int madhab = 0,
  }) {
    final now = DateTime.now();
    final coordinates = adhan.Coordinates(latitude, longitude);
    final params = _getCalculationParams(calculationMethod, madhab);
    
    final prayerTimes = adhan.PrayerTimes(
      coordinates: coordinates,
      date: now,
      calculationParameters: params,
    );

    final next = prayerTimes.nextPrayer(date: now);
    return _prayerToString(next);
  }

  /// Get time until next prayer
  Duration getTimeUntilNextPrayer({
    required double latitude,
    required double longitude,
    int calculationMethod = 0,
    int madhab = 0,
  }) {
    final now = DateTime.now();
    final coordinates = adhan.Coordinates(latitude, longitude);
    final params = _getCalculationParams(calculationMethod, madhab);
    
    final prayerTimes = adhan.PrayerTimes(
      coordinates: coordinates,
      date: now,
      calculationParameters: params,
    );

    final next = prayerTimes.nextPrayer(date: now);
    final nextTime = prayerTimes.timeForPrayer(next);
    
    // nextTime should always be valid - return difference to next prayer
    return nextTime.toLocal().difference(now);
  }

  /// Convert calculation method index to adhan_dart params
  adhan.CalculationParameters _getCalculationParams(int method, int madhab) {
    adhan.CalculationParameters params;
    
    switch (method) {
      case 0:
        params = adhan.CalculationMethodParameters.muslimWorldLeague();
        break;
      case 1:
        params = adhan.CalculationMethodParameters.egyptian();
        break;
      case 2:
        params = adhan.CalculationMethodParameters.karachi();
        break;
      case 3:
        params = adhan.CalculationMethodParameters.ummAlQura();
        break;
      case 4:
        params = adhan.CalculationMethodParameters.dubai();
        break;
      case 5:
        params = adhan.CalculationMethodParameters.qatar();
        break;
      case 6:
        params = adhan.CalculationMethodParameters.kuwait();
        break;
      case 7:
        params = adhan.CalculationMethodParameters.moonsightingCommittee();
        break;
      case 8:
        params = adhan.CalculationMethodParameters.singapore();
        break;
      case 9:
        params = adhan.CalculationMethodParameters.northAmerica();
        break;
      default:
        params = adhan.CalculationMethodParameters.muslimWorldLeague();
    }

    // Set madhab (0 = Shafi, 1 = Hanafi)
    params.madhab = madhab == 1 ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    
    return params;
  }

  String _prayerToString(adhan.Prayer prayer) {
    switch (prayer) {
      case adhan.Prayer.fajr:
        return 'Fajr';
      case adhan.Prayer.sunrise:
        return 'Sunrise';
      case adhan.Prayer.dhuhr:
        return 'Dhuhr';
      case adhan.Prayer.asr:
        return 'Asr';
      case adhan.Prayer.maghrib:
        return 'Maghrib';
      case adhan.Prayer.isha:
        return 'Isha';
      default:
        return 'None';
    }
  }

  /// Fallback times when calculation fails
  PrayerTimesResult _getFallbackTimes(DateTime date) {
    return PrayerTimesResult(
      fajr: DateTime(date.year, date.month, date.day, 5, 0),
      sunrise: DateTime(date.year, date.month, date.day, 6, 30),
      dhuhr: DateTime(date.year, date.month, date.day, 12, 30),
      asr: DateTime(date.year, date.month, date.day, 15, 30),
      maghrib: DateTime(date.year, date.month, date.day, 18, 30),
      isha: DateTime(date.year, date.month, date.day, 20, 0),
      middleOfNight: DateTime(date.year, date.month, date.day, 23, 30),
      lastThirdOfNight: DateTime(date.year, date.month, date.day + 1, 2, 30),
      date: date,
    );
  }

  /// Get calculation method name from index
  static String getCalculationMethodName(int index) {
    switch (index) {
      case 0:
        return 'Muslim World League';
      case 1:
        return 'Egyptian General Authority';
      case 2:
        return 'University of Karachi';
      case 3:
        return 'Umm Al-Qura (Makkah)';
      case 4:
        return 'Dubai';
      case 5:
        return 'Qatar';
      case 6:
        return 'Kuwait';
      case 7:
        return 'Moonsighting Committee';
      case 8:
        return 'Singapore';
      case 9:
        return 'North America (ISNA)';
      default:
        return 'Muslim World League';
    }
  }

  /// Get all available calculation methods
  static List<CalculationMethodOption> getCalculationMethods() {
    return [
      CalculationMethodOption(0, 'Muslim World League', 'Standard worldwide'),
      CalculationMethodOption(1, 'Egyptian General Authority', 'Egypt, Africa'),
      CalculationMethodOption(2, 'University of Karachi', 'Pakistan, South Asia'),
      CalculationMethodOption(3, 'Umm Al-Qura', 'Saudi Arabia, Gulf'),
      CalculationMethodOption(4, 'Dubai', 'UAE'),
      CalculationMethodOption(5, 'Qatar', 'Qatar'),
      CalculationMethodOption(6, 'Kuwait', 'Kuwait'),
      CalculationMethodOption(7, 'Moonsighting Committee', 'North America, UK'),
      CalculationMethodOption(8, 'Singapore', 'Southeast Asia'),
      CalculationMethodOption(9, 'North America (ISNA)', 'USA, Canada'),
    ];
  }
}

/// Result object containing all prayer times
class PrayerTimesResult {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime middleOfNight;
  final DateTime lastThirdOfNight;
  final DateTime date;

  PrayerTimesResult({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.middleOfNight,
    required this.lastThirdOfNight,
    required this.date,
  });

  /// Get prayer time by name
  DateTime? getTimeByName(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'sunrise':
        return sunrise;
      case 'dhuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      default:
        return null;
    }
  }

  /// Get all prayer times as a map
  Map<String, DateTime> toMap() {
    return {
      'Fajr': fajr,
      'Sunrise': sunrise,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
  }

  /// Get next prayer from current time
  MapEntry<String, DateTime>? getNextPrayer() {
    final now = DateTime.now();
    final times = toMap();
    
    for (final entry in times.entries) {
      if (entry.value.isAfter(now)) {
        return entry;
      }
    }
    
    return null; // All prayers passed, next is tomorrow's Fajr
  }

  /// Get current prayer
  String getCurrentPrayer() {
    final now = DateTime.now();
    
    if (now.isBefore(fajr)) {
      return 'Isha'; // Previous day's Isha
    } else if (now.isBefore(sunrise)) {
      return 'Fajr';
    } else if (now.isBefore(dhuhr)) {
      return 'Sunrise';
    } else if (now.isBefore(asr)) {
      return 'Dhuhr';
    } else if (now.isBefore(maghrib)) {
      return 'Asr';
    } else if (now.isBefore(isha)) {
      return 'Maghrib';
    } else {
      return 'Isha';
    }
  }
}

/// Calculation method option for UI display
class CalculationMethodOption {
  final int index;
  final String name;
  final String region;

  CalculationMethodOption(this.index, this.name, this.region);
}
