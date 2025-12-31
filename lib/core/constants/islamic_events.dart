import 'package:hijri/hijri_calendar.dart';

/// Types of Islamic events
enum IslamicEventType {
  eid,           // Eid al-Fitr, Eid al-Adha
  ramadan,       // Ramadan days
  fastingDay,    // Sunnah fasting days
  sacredMonth,   // Haram months
  specialNight,  // Laylatul Qadr, etc.
  hajj,          // Hajj days
  islamicDate,   // Other significant dates
}

/// Islamic event model
class IslamicEvent {
  final String id;
  final String name;
  final String nameArabic;
  final String description;
  final IslamicEventType type;
  final bool isObligatory;
  final String? source; // Quran/Hadith reference
  final int priority; // 1 = highest (Eid), 5 = lowest

  const IslamicEvent({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.type,
    this.isObligatory = false,
    this.source,
    this.priority = 3,
  });
}

/// Service to get Islamic events for any date
class IslamicEventsService {
  
  /// Hijri month names
  static const List<String> hijriMonths = [
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhul Qa\'dah',
    'Dhul Hijjah',
  ];
  
  /// Sacred (Haram) months - Fighting prohibited
  static const List<int> sacredMonths = [1, 7, 11, 12]; // Muharram, Rajab, Dhul Qa'dah, Dhul Hijjah
  
  /// Get all Islamic events for a given Gregorian date
  static List<IslamicEvent> getEventsForDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final events = <IslamicEvent>[];
    
    // Check for fixed Hijri date events
    events.addAll(_getFixedDateEvents(hijri));
    
    // Check for recurring events (Monday/Thursday fasting, white days)
    events.addAll(_getRecurringEvents(date, hijri));
    
    // Check for Ramadan
    if (hijri.hMonth == 9) {
      events.add(_getRamadanEvent(hijri));
    }
    
    // Check for sacred month
    if (sacredMonths.contains(hijri.hMonth)) {
      events.add(_getSacredMonthEvent(hijri));
    }
    
    // Sort by priority
    events.sort((a, b) => a.priority.compareTo(b.priority));
    
    return events;
  }
  
  /// Get fixed Hijri date events
  static List<IslamicEvent> _getFixedDateEvents(HijriCalendar hijri) {
    final events = <IslamicEvent>[];
    final month = hijri.hMonth;
    final day = hijri.hDay;
    
    // === MUHARRAM (Month 1) ===
    if (month == 1) {
      if (day == 1) {
        events.add(const IslamicEvent(
          id: 'islamic_new_year',
          name: 'Islamic New Year',
          nameArabic: 'رأس السنة الهجرية',
          description: 'First day of the Islamic calendar year',
          type: IslamicEventType.islamicDate,
          priority: 2,
        ));
      }
      if (day == 9) {
        events.add(const IslamicEvent(
          id: 'tasu\'a',
          name: 'Tasu\'a - Fast Recommended',
          nameArabic: 'تاسوعاء',
          description: 'Recommended to fast with Ashura. The Prophet ﷺ said: "If I live until next year, I will fast the ninth day (along with the tenth)."',
          type: IslamicEventType.fastingDay,
          source: 'Sahih Muslim 1134',
          priority: 3,
        ));
      }
      if (day == 10) {
        events.add(const IslamicEvent(
          id: 'ashura',
          name: 'Day of Ashura - Fast Recommended',
          nameArabic: 'عاشوراء',
          description: 'Fasting this day expiates sins of the previous year. The Prophet ﷺ said: "Fasting the day of Ashura, I hope Allah will expiate thereby for the year that came before it."',
          type: IslamicEventType.fastingDay,
          source: 'Sahih Muslim 1162',
          priority: 2,
        ));
      }
      if (day == 11) {
        events.add(const IslamicEvent(
          id: 'ashura_after',
          name: 'Day After Ashura - Fast Recommended',
          nameArabic: 'يوم بعد عاشوراء',
          description: 'Recommended to fast with Ashura to differ from the People of the Book.',
          type: IslamicEventType.fastingDay,
          source: 'Musnad Ahmad',
          priority: 4,
        ));
      }
    }
    
    // === RAJAB (Month 7) ===
    if (month == 7 && day == 27) {
      events.add(const IslamicEvent(
        id: 'isra_miraj',
        name: 'Isra and Mi\'raj',
        nameArabic: 'الإسراء والمعراج',
        description: 'Night journey of Prophet Muhammad ﷺ from Makkah to Jerusalem and ascension to the heavens.',
        type: IslamicEventType.islamicDate,
        source: 'Surah Al-Isra 17:1',
        priority: 2,
      ));
    }
    
    // === SHA'BAN (Month 8) ===
    if (month == 8) {
      // Fasting in Sha'ban is recommended
      if (day >= 1 && day <= 15) {
        events.add(const IslamicEvent(
          id: 'shaban_fasting',
          name: 'Sha\'ban Fasting Recommended',
          nameArabic: 'صيام شعبان',
          description: 'The Prophet ﷺ used to fast most of Sha\'ban. Aisha (RA) said: "I never saw him fast a complete month except Ramadan, and I never saw him fast more in any month than in Sha\'ban."',
          type: IslamicEventType.fastingDay,
          source: 'Sahih Bukhari 1969, Sahih Muslim 1156',
          priority: 4,
        ));
      }
    }
    
    // === RAMADAN (Month 9) - Handled separately ===
    
    // === SHAWWAL (Month 10) ===
    if (month == 10) {
      if (day == 1) {
        events.add(const IslamicEvent(
          id: 'eid_fitr',
          name: 'Eid al-Fitr',
          nameArabic: 'عيد الفطر',
          description: 'Festival of Breaking the Fast. Fasting is PROHIBITED on this day.',
          type: IslamicEventType.eid,
          source: 'Sahih Bukhari 1990',
          priority: 1,
        ));
      }
      if (day >= 2 && day <= 7) {
        events.add(const IslamicEvent(
          id: 'shawwal_six',
          name: 'Six Days of Shawwal',
          nameArabic: 'ست من شوال',
          description: 'Fasting six days of Shawwal with Ramadan is like fasting the whole year. The Prophet ﷺ said: "Whoever fasts Ramadan and follows it with six days of Shawwal, it will be as if he fasted for a lifetime."',
          type: IslamicEventType.fastingDay,
          source: 'Sahih Muslim 1164',
          priority: 2,
        ));
      }
    }
    
    // === DHUL HIJJAH (Month 12) ===
    if (month == 12) {
      // First 10 days - Best days of the year
      if (day >= 1 && day <= 9) {
        events.add(const IslamicEvent(
          id: 'dhul_hijjah_ten',
          name: 'Best 10 Days - Fast Recommended',
          nameArabic: 'العشر الأوائل من ذي الحجة',
          description: 'The Prophet ﷺ said: "There are no days in which righteous deeds are more beloved to Allah than these ten days." Fasting is highly recommended.',
          type: IslamicEventType.fastingDay,
          source: 'Sahih Bukhari 969',
          priority: 2,
        ));
      }
      if (day == 8) {
        events.add(const IslamicEvent(
          id: 'yawm_tarwiyah',
          name: 'Day of Tarwiyah (Hajj begins)',
          nameArabic: 'يوم التروية',
          description: 'The day pilgrims go to Mina. Beginning of Hajj rituals.',
          type: IslamicEventType.hajj,
          priority: 3,
        ));
      }
      if (day == 9) {
        events.add(const IslamicEvent(
          id: 'day_arafah',
          name: 'Day of Arafah - Fast Highly Recommended',
          nameArabic: 'يوم عرفة',
          description: 'Greatest day of the year. Fasting expiates sins of previous and coming year. The Prophet ﷺ said: "Fasting the Day of Arafah expiates the sins of two years: the past one and the coming one."',
          type: IslamicEventType.fastingDay,
          source: 'Sahih Muslim 1162',
          priority: 1,
        ));
        events.add(const IslamicEvent(
          id: 'arafah_hajj',
          name: 'Standing at Arafah (Hajj)',
          nameArabic: 'الوقوف بعرفة',
          description: 'The pillar of Hajj. The Prophet ﷺ said: "Hajj is Arafah."',
          type: IslamicEventType.hajj,
          source: 'Sunan Tirmidhi 889',
          priority: 1,
        ));
      }
      if (day == 10) {
        events.add(const IslamicEvent(
          id: 'eid_adha',
          name: 'Eid al-Adha',
          nameArabic: 'عيد الأضحى',
          description: 'Festival of Sacrifice. Fasting is PROHIBITED. Day of sacrifice and Hajj rituals.',
          type: IslamicEventType.eid,
          source: 'Sahih Bukhari 5545',
          priority: 1,
        ));
      }
      if (day >= 11 && day <= 13) {
        events.add(const IslamicEvent(
          id: 'ayyam_tashreeq',
          name: 'Days of Tashreeq - NO FASTING',
          nameArabic: 'أيام التشريق',
          description: 'Days of eating, drinking, and remembering Allah. Fasting is PROHIBITED. The Prophet ﷺ said: "The days of Tashreeq are days of eating, drinking, and remembering Allah."',
          type: IslamicEventType.eid,
          source: 'Sahih Muslim 1141',
          priority: 2,
        ));
      }
    }
    
    return events;
  }
  
  /// Get recurring events (weekly fasting, monthly white days)
  static List<IslamicEvent> _getRecurringEvents(DateTime date, HijriCalendar hijri) {
    final events = <IslamicEvent>[];
    
    // Monday fasting
    if (date.weekday == DateTime.monday) {
      events.add(const IslamicEvent(
        id: 'monday_fast',
        name: 'Monday - Sunnah Fast',
        nameArabic: 'صيام الإثنين',
        description: 'The Prophet ﷺ was asked about fasting on Monday, and he said: "That is the day on which I was born and the day on which I received Revelation."',
        type: IslamicEventType.fastingDay,
        source: 'Sahih Muslim 1162',
        priority: 4,
      ));
    }
    
    // Thursday fasting
    if (date.weekday == DateTime.thursday) {
      events.add(const IslamicEvent(
        id: 'thursday_fast',
        name: 'Thursday - Sunnah Fast',
        nameArabic: 'صيام الخميس',
        description: 'The Prophet ﷺ used to fast on Monday and Thursday. He said: "Deeds are shown (to Allah) on Monday and Thursday, and I like my deeds to be shown when I am fasting."',
        type: IslamicEventType.fastingDay,
        source: 'Sunan Tirmidhi 747',
        priority: 4,
      ));
    }
    
    // Ayyam al-Beed (White Days) - 13th, 14th, 15th of each Hijri month
    if (hijri.hDay == 13 || hijri.hDay == 14 || hijri.hDay == 15) {
      events.add(IslamicEvent(
        id: 'ayyam_beed_${hijri.hDay}',
        name: 'Ayyam al-Beed (White Days) - Fast',
        nameArabic: 'أيام البيض',
        description: 'The Prophet ﷺ commanded to fast three days of every month: the 13th, 14th, and 15th. Abu Dharr reported: "The Messenger of Allah ﷺ said: \'If you fast three days of the month, then fast the 13th, 14th, and 15th.\'"',
        type: IslamicEventType.fastingDay,
        source: 'Sunan Tirmidhi 761, Sunan Nasai 2424',
        priority: 3,
      ));
    }
    
    // Friday - Day of Jumu'ah
    if (date.weekday == DateTime.friday) {
      events.add(const IslamicEvent(
        id: 'jumuah',
        name: 'Jumu\'ah (Friday Prayer)',
        nameArabic: 'يوم الجمعة',
        description: 'Best day of the week. The Prophet ﷺ said: "The best day on which the sun rises is Friday." Remember to send Salawat upon the Prophet ﷺ.',
        type: IslamicEventType.islamicDate,
        source: 'Sahih Muslim 854',
        priority: 4,
      ));
    }
    
    return events;
  }
  
  /// Get Ramadan specific event
  static IslamicEvent _getRamadanEvent(HijriCalendar hijri) {
    final day = hijri.hDay;
    
    // Last 10 nights
    if (day >= 21) {
      final isOddNight = day % 2 == 1;
      if (isOddNight) {
        return IslamicEvent(
          id: 'laylatul_qadr_search',
          name: 'Laylatul Qadr - Seek it!',
          nameArabic: 'ليلة القدر',
          description: 'Night ${day} of Ramadan. The Prophet ﷺ said: "Seek Laylatul Qadr in the odd nights of the last ten days of Ramadan." This night is better than a thousand months.',
          type: IslamicEventType.specialNight,
          source: 'Surah Al-Qadr 97:3, Sahih Bukhari 2017',
          priority: 1,
        );
      }
    }
    
    return IslamicEvent(
      id: 'ramadan_day_$day',
      name: 'Ramadan Day $day - Obligatory Fast',
      nameArabic: 'رمضان',
      description: 'The blessed month of fasting. Allah says: "O you who believe, fasting is prescribed for you as it was prescribed for those before you, that you may attain Taqwa."',
      type: IslamicEventType.ramadan,
      isObligatory: true,
      source: 'Surah Al-Baqarah 2:183',
      priority: 1,
    );
  }
  
  /// Get sacred month event
  static IslamicEvent _getSacredMonthEvent(HijriCalendar hijri) {
    final monthName = hijriMonths[hijri.hMonth - 1];
    return IslamicEvent(
      id: 'sacred_month_${hijri.hMonth}',
      name: 'Sacred Month: $monthName',
      nameArabic: 'الأشهر الحرم',
      description: 'One of the four sacred months in which fighting was prohibited. Allah says: "Indeed, the number of months with Allah is twelve months in the register of Allah from the day He created the heavens and the earth; of these, four are sacred."',
      type: IslamicEventType.sacredMonth,
      source: 'Surah At-Tawbah 9:36',
      priority: 5,
    );
  }
  
  /// Check if fasting is prohibited on this date
  static bool isFastingProhibited(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    
    // Eid al-Fitr (1 Shawwal)
    if (hijri.hMonth == 10 && hijri.hDay == 1) return true;
    
    // Eid al-Adha and Days of Tashreeq (10-13 Dhul Hijjah)
    if (hijri.hMonth == 12 && hijri.hDay >= 10 && hijri.hDay <= 13) return true;
    
    return false;
  }
  
  /// Check if today is a recommended fasting day
  static bool isRecommendedFastingDay(DateTime date) {
    if (isFastingProhibited(date)) return false;
    
    final hijri = HijriCalendar.fromDate(date);
    
    // Monday or Thursday
    if (date.weekday == DateTime.monday || date.weekday == DateTime.thursday) {
      return true;
    }
    
    // White days
    if (hijri.hDay >= 13 && hijri.hDay <= 15) return true;
    
    // Day of Arafah
    if (hijri.hMonth == 12 && hijri.hDay == 9) return true;
    
    // Ashura
    if (hijri.hMonth == 1 && (hijri.hDay == 9 || hijri.hDay == 10)) return true;
    
    // First 9 days of Dhul Hijjah
    if (hijri.hMonth == 12 && hijri.hDay >= 1 && hijri.hDay <= 9) return true;
    
    // Six days of Shawwal
    if (hijri.hMonth == 10 && hijri.hDay >= 2 && hijri.hDay <= 7) return true;
    
    return false;
  }
  
  /// Get upcoming important events within next N days
  static List<MapEntry<DateTime, IslamicEvent>> getUpcomingEvents(int days) {
    final events = <MapEntry<DateTime, IslamicEvent>>[];
    final today = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = today.add(Duration(days: i));
      final dayEvents = getEventsForDate(date);
      
      // Only include high priority events (1-2)
      for (final event in dayEvents.where((e) => e.priority <= 2)) {
        events.add(MapEntry(date, event));
      }
    }
    
    return events;
  }
}
