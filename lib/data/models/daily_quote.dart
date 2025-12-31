import 'package:hive/hive.dart';

part 'daily_quote.g.dart';

/// Type of inspirational quote
@HiveType(typeId: 7)
enum QuoteType {
  @HiveField(0)
  quran,

  @HiveField(1)
  hadith,
}

/// Represents a daily inspirational quote
@HiveType(typeId: 3)
class DailyQuote extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String arabicText;

  @HiveField(2)
  final String translation;

  @HiveField(3)
  final String reference;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final int type; // 0=quran, 1=hadith

  @HiveField(6)
  final String? surahName;

  @HiveField(7)
  final int? ayahNumber;

  @HiveField(8)
  final String? narrator; // For hadith

  DailyQuote({
    required this.id,
    required this.arabicText,
    required this.translation,
    required this.reference,
    required this.date,
    this.type = 0,
    this.surahName,
    this.ayahNumber,
    this.narrator,
  });

  /// Get type as enum
  QuoteType get quoteType => QuoteType.values[type];

  /// Check if this quote is for today
  bool get isForToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get formatted reference
  String get formattedReference {
    if (quoteType == QuoteType.quran && surahName != null) {
      return '$surahName ${ayahNumber != null ? ':$ayahNumber' : ''}';
    }
    return reference;
  }

  /// Create a copy with updated fields
  DailyQuote copyWith({
    String? id,
    String? arabicText,
    String? translation,
    String? reference,
    DateTime? date,
    int? type,
    String? surahName,
    int? ayahNumber,
    String? narrator,
  }) {
    return DailyQuote(
      id: id ?? this.id,
      arabicText: arabicText ?? this.arabicText,
      translation: translation ?? this.translation,
      reference: reference ?? this.reference,
      date: date ?? this.date,
      type: type ?? this.type,
      surahName: surahName ?? this.surahName,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      narrator: narrator ?? this.narrator,
    );
  }

  @override
  String toString() => 'DailyQuote(reference: $reference, date: $date)';
}
