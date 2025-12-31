// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_completion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerCompletionAdapter extends TypeAdapter<PrayerCompletion> {
  @override
  final int typeId = 9;

  @override
  PrayerCompletion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerCompletion(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      fajrCompleted: fields[2] as int,
      dhuhrCompleted: fields[3] as int,
      asrCompleted: fields[4] as int,
      maghribCompleted: fields[5] as int,
      ishaCompleted: fields[6] as int,
      nafilaCompleted: (fields[7] as List).cast<String>(),
      fajrCompletedAt: fields[8] as DateTime?,
      dhuhrCompletedAt: fields[9] as DateTime?,
      asrCompletedAt: fields[10] as DateTime?,
      maghribCompletedAt: fields[11] as DateTime?,
      ishaCompletedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerCompletion obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.fajrCompleted)
      ..writeByte(3)
      ..write(obj.dhuhrCompleted)
      ..writeByte(4)
      ..write(obj.asrCompleted)
      ..writeByte(5)
      ..write(obj.maghribCompleted)
      ..writeByte(6)
      ..write(obj.ishaCompleted)
      ..writeByte(7)
      ..write(obj.nafilaCompleted)
      ..writeByte(8)
      ..write(obj.fajrCompletedAt)
      ..writeByte(9)
      ..write(obj.dhuhrCompletedAt)
      ..writeByte(10)
      ..write(obj.asrCompletedAt)
      ..writeByte(11)
      ..write(obj.maghribCompletedAt)
      ..writeByte(12)
      ..write(obj.ishaCompletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerCompletionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
