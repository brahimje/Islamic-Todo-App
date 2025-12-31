// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_quote.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyQuoteAdapter extends TypeAdapter<DailyQuote> {
  @override
  final int typeId = 3;

  @override
  DailyQuote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyQuote(
      id: fields[0] as String,
      arabicText: fields[1] as String,
      translation: fields[2] as String,
      reference: fields[3] as String,
      date: fields[4] as DateTime,
      type: fields[5] as int,
      surahName: fields[6] as String?,
      ayahNumber: fields[7] as int?,
      narrator: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyQuote obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.arabicText)
      ..writeByte(2)
      ..write(obj.translation)
      ..writeByte(3)
      ..write(obj.reference)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.surahName)
      ..writeByte(7)
      ..write(obj.ayahNumber)
      ..writeByte(8)
      ..write(obj.narrator);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyQuoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuoteTypeAdapter extends TypeAdapter<QuoteType> {
  @override
  final int typeId = 7;

  @override
  QuoteType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuoteType.quran;
      case 1:
        return QuoteType.hadith;
      default:
        return QuoteType.quran;
    }
  }

  @override
  void write(BinaryWriter writer, QuoteType obj) {
    switch (obj) {
      case QuoteType.quran:
        writer.writeByte(0);
        break;
      case QuoteType.hadith:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
