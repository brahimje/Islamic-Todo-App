// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nafila_prayer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NafilaPrayerAdapter extends TypeAdapter<NafilaPrayer> {
  @override
  final int typeId = 1;

  @override
  NafilaPrayer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NafilaPrayer(
      id: fields[0] as String,
      prayerInfoId: fields[1] as String,
      isEnabled: fields[2] as bool,
      frequency: fields[3] as int,
      preferredHour: fields[4] as int?,
      preferredMinute: fields[5] as int?,
      selectedDays: (fields[6] as List).cast<int>(),
      notificationEnabled: fields[7] as bool,
      reminderMinutesBefore: fields[8] as int,
      customRakahCount: fields[9] as int,
      lastCompletedAt: fields[10] as DateTime?,
      streakCount: fields[11] as int,
      totalCompletions: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NafilaPrayer obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.prayerInfoId)
      ..writeByte(2)
      ..write(obj.isEnabled)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.preferredHour)
      ..writeByte(5)
      ..write(obj.preferredMinute)
      ..writeByte(6)
      ..write(obj.selectedDays)
      ..writeByte(7)
      ..write(obj.notificationEnabled)
      ..writeByte(8)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(9)
      ..write(obj.customRakahCount)
      ..writeByte(10)
      ..write(obj.lastCompletedAt)
      ..writeByte(11)
      ..write(obj.streakCount)
      ..writeByte(12)
      ..write(obj.totalCompletions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NafilaPrayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NafilaFrequencyAdapter extends TypeAdapter<NafilaFrequency> {
  @override
  final int typeId = 5;

  @override
  NafilaFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NafilaFrequency.daily;
      case 1:
        return NafilaFrequency.weekly;
      case 2:
        return NafilaFrequency.occasionally;
      case 3:
        return NafilaFrequency.asNeeded;
      default:
        return NafilaFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, NafilaFrequency obj) {
    switch (obj) {
      case NafilaFrequency.daily:
        writer.writeByte(0);
        break;
      case NafilaFrequency.weekly:
        writer.writeByte(1);
        break;
      case NafilaFrequency.occasionally:
        writer.writeByte(2);
        break;
      case NafilaFrequency.asNeeded:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NafilaFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
