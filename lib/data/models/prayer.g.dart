// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerAdapter extends TypeAdapter<Prayer> {
  @override
  final int typeId = 0;

  @override
  Prayer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Prayer(
      id: fields[0] as String,
      name: fields[1] as String,
      time: fields[2] as DateTime,
      isCompleted: fields[3] as bool,
      date: fields[4] as DateTime,
      notificationEnabled: fields[5] as bool,
      reminderMinutesBefore: fields[6] as int,
      completedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Prayer obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.notificationEnabled)
      ..writeByte(6)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(7)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
