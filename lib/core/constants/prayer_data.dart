import 'package:flutter/material.dart';

/// Nafila prayer data with Quranic and Hadith references
class NafilaPrayerInfo {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final String quranicReference;
  final String hadithReference;
  final int minRakah;
  final int maxRakah;
  final int recommendedRakah;
  final TimeOfDay? suggestedTime;
  final String timeDescription;
  final String benefits;
  final bool isDaily;

  const NafilaPrayerInfo({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    this.quranicReference = '',
    this.hadithReference = '',
    required this.minRakah,
    required this.maxRakah,
    required this.recommendedRakah,
    this.suggestedTime,
    required this.timeDescription,
    this.benefits = '',
    this.isDaily = true,
  });
}

/// Predefined Nafila prayers with authentic references
class PrayerData {
  PrayerData._();

  static const List<String> fardPrayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static const Map<String, int> fardRakah = {
    'Fajr': 2,
    'Dhuhr': 4,
    'Asr': 4,
    'Maghrib': 3,
    'Isha': 4,
  };

  static final List<NafilaPrayerInfo> nafilaPrayers = [
    NafilaPrayerInfo(
      id: 'tahajjud',
      name: 'Tahajjud',
      arabicName: 'تهجد',
      description:
          'The night prayer performed in the last third of the night. One of the most virtuous voluntary prayers.',
      quranicReference:
          'Quran 17:79 - "And from [part of] the night, pray with it as additional [worship] for you; it is expected that your Lord will resurrect you to a praised station."',
      hadithReference:
          'Sahih Bukhari 1154 - The Prophet ﷺ said: "The best prayer after the obligatory prayers is the night prayer."',
      minRakah: 2,
      maxRakah: 12,
      recommendedRakah: 8,
      suggestedTime: const TimeOfDay(hour: 3, minute: 30),
      timeDescription: 'Last third of the night, before Fajr',
      benefits:
          'Forgiveness of sins, answered duas, closeness to Allah, and spiritual elevation',
    ),
    NafilaPrayerInfo(
      id: 'doha',
      name: 'Salat al-Doha',
      arabicName: 'صلاة الضحى',
      description:
          'The forenoon prayer, also known as Chaasht prayer. A highly recommended Sunnah prayer.',
      quranicReference:
          'Quran 93:1 - "By the morning brightness" - The Surah Ad-Duha is named after this blessed time.',
      hadithReference:
          'Sahih Muslim 719 - The Prophet ﷺ said: "In the morning, charity is due from every joint of your body... and two rakʿahs of Doha prayer fulfills all of this."',
      minRakah: 2,
      maxRakah: 12,
      recommendedRakah: 4,
      suggestedTime: const TimeOfDay(hour: 9, minute: 0),
      timeDescription: '15-20 minutes after sunrise until just before Dhuhr',
      benefits:
          'Equivalent to giving charity for every joint in the body (360 joints)',
    ),
    NafilaPrayerInfo(
      id: 'ishraq',
      name: 'Salat al-Ishraq',
      arabicName: 'صلاة الإشراق',
      description:
          'Prayer performed shortly after sunrise. Related to Doha but at the earliest permissible time.',
      hadithReference:
          'Jami` at-Tirmidhi 586 - The Prophet ﷺ said: "Whoever prays Fajr in congregation, then sits remembering Allah until the sun rises, then prays two rakʿahs, will have a reward like that of Hajj and Umrah, complete, complete, complete."',
      minRakah: 2,
      maxRakah: 4,
      recommendedRakah: 2,
      suggestedTime: const TimeOfDay(hour: 7, minute: 0),
      timeDescription: '15-20 minutes after sunrise',
      benefits:
          'Reward equivalent to a complete Hajj and Umrah when combined with Fajr remembrance',
    ),
    NafilaPrayerInfo(
      id: 'awwabin',
      name: 'Salat al-Awwabin',
      arabicName: 'صلاة الأوابين',
      description:
          'Prayer of the oft-returning (to Allah). Performed between Maghrib and Isha.',
      hadithReference:
          'Sahih Muslim 730 - The Prophet ﷺ said: "Whoever prays six rakʿahs after Maghrib without speaking ill between them will have a reward equal to twelve years of worship."',
      minRakah: 6,
      maxRakah: 20,
      recommendedRakah: 6,
      suggestedTime: const TimeOfDay(hour: 18, minute: 30),
      timeDescription: 'Between Maghrib and Isha prayers',
      benefits: 'Reward equal to 12 years of worship',
    ),
    NafilaPrayerInfo(
      id: 'witr',
      name: 'Salat al-Witr',
      arabicName: 'صلاة الوتر',
      description:
          'The odd-numbered prayer performed after Isha. Strongly emphasized Sunnah (Sunnah Mu\'akkadah).',
      hadithReference:
          'Sahih Bukhari 998 - The Prophet ﷺ said: "Make Witr your last prayer of the night."',
      minRakah: 1,
      maxRakah: 11,
      recommendedRakah: 3,
      suggestedTime: const TimeOfDay(hour: 22, minute: 0),
      timeDescription: 'After Isha, preferably as the last prayer before sleep',
      benefits:
          'Sealing the night prayers, highly beloved to Allah. The Prophet ﷺ never left it, even when traveling.',
    ),
    NafilaPrayerInfo(
      id: 'tahiyyat_masjid',
      name: 'Tahiyyat al-Masjid',
      arabicName: 'تحية المسجد',
      description:
          'The greeting prayer of the mosque. Performed upon entering any mosque before sitting.',
      hadithReference:
          'Sahih Bukhari 444 - The Prophet ﷺ said: "When one of you enters the mosque, let him not sit down until he has prayed two rakʿahs."',
      minRakah: 2,
      maxRakah: 2,
      recommendedRakah: 2,
      timeDescription: 'Upon entering the mosque, before sitting',
      benefits:
          'Greeting the mosque and honoring the sacred space. Should not be abandoned even during the khutbah.',
      isDaily: false,
    ),
    NafilaPrayerInfo(
      id: 'sunnah_fajr',
      name: 'Sunnah of Fajr',
      arabicName: 'سنة الفجر',
      description:
          'Two rakʿahs before the Fajr prayer. The most emphasized of the regular Sunnah prayers.',
      hadithReference:
          'Sahih Muslim 725 - The Prophet ﷺ said: "The two rakʿahs of Fajr are better than the world and everything in it."',
      minRakah: 2,
      maxRakah: 2,
      recommendedRakah: 2,
      timeDescription: 'Before Fajr prayer, after Adhan',
      benefits:
          'Better than the entire world and all it contains. The Prophet ﷺ never abandoned it.',
    ),
    NafilaPrayerInfo(
      id: 'sunnah_dhuhr_before',
      name: 'Sunnah before Dhuhr',
      arabicName: 'سنة قبل الظهر',
      description: 'Four rakʿahs before the Dhuhr prayer.',
      hadithReference:
          'Sunan an-Nasa\'i 1816 - The Prophet ﷺ said: "Whoever guards four rakʿahs before Dhuhr and four after it, Allah will forbid the Fire from touching him."',
      minRakah: 2,
      maxRakah: 4,
      recommendedRakah: 4,
      timeDescription: 'Before Dhuhr prayer, after Adhan',
      benefits: 'Protection from the Hellfire when combined with post-Dhuhr Sunnah',
    ),
    NafilaPrayerInfo(
      id: 'sunnah_dhuhr_after',
      name: 'Sunnah after Dhuhr',
      arabicName: 'سنة بعد الظهر',
      description: 'Two or four rakʿahs after the Dhuhr prayer.',
      hadithReference:
          'Sahih Muslim 729 - The Prophet ﷺ used to pray four rakʿahs after Dhuhr.',
      minRakah: 2,
      maxRakah: 4,
      recommendedRakah: 2,
      timeDescription: 'After Dhuhr prayer',
      benefits: 'Continuation of the Dhuhr Sunnah prayers',
    ),
    NafilaPrayerInfo(
      id: 'sunnah_maghrib',
      name: 'Sunnah after Maghrib',
      arabicName: 'سنة بعد المغرب',
      description: 'Two rakʿahs after the Maghrib prayer.',
      hadithReference:
          'Sahih Bukhari 1180 - The Prophet ﷺ would pray two rakʿahs after Maghrib.',
      minRakah: 2,
      maxRakah: 2,
      recommendedRakah: 2,
      timeDescription: 'After Maghrib prayer',
      benefits: 'Regular Sunnah practiced by the Prophet ﷺ',
    ),
    NafilaPrayerInfo(
      id: 'sunnah_isha',
      name: 'Sunnah after Isha',
      arabicName: 'سنة بعد العشاء',
      description: 'Two rakʿahs after the Isha prayer.',
      hadithReference:
          'Sahih Muslim 728 - The Prophet ﷺ used to pray two rakʿahs after Isha at home.',
      minRakah: 2,
      maxRakah: 2,
      recommendedRakah: 2,
      timeDescription: 'After Isha prayer',
      benefits: 'Regular Sunnah practiced by the Prophet ﷺ',
    ),
  ];

  /// Get a Nafila prayer by ID
  static NafilaPrayerInfo? getNafilaById(String id) {
    try {
      return nafilaPrayers.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all daily Nafila prayers
  static List<NafilaPrayerInfo> getDailyNafilaPrayers() {
    return nafilaPrayers.where((p) => p.isDaily).toList();
  }

  /// Get recommended starter set for new users
  static List<String> getRecommendedStarterSet() {
    return ['sunnah_fajr', 'witr', 'doha'];
  }
}
