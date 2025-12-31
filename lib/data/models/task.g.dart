// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 2;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      scheduledTime: fields[3] as DateTime?,
      deadline: fields[4] as DateTime?,
      estimatedMinutes: fields[5] as int?,
      isCompleted: (fields[6] as bool?) ?? false,
      createdAt: fields[7] as DateTime,
      completedAt: fields[8] as DateTime?,
      priority: (fields[9] as int?) ?? 1,
      hasNotification: (fields[10] as bool?) ?? false,
      category: fields[11] as String?,
      tags: (fields[12] as List?)?.cast<String>() ?? [],
      reminderMinutesBefore: (fields[13] as int?) ?? 10,
      isRecurring: (fields[14] as bool?) ?? false,
      recurringPattern: fields[15] as String?,
      isReligious: (fields[16] as bool?) ?? false,
      prayerBlockId: fields[17] as String?,
      orderIndex: (fields[18] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.scheduledTime)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.estimatedMinutes)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.hasNotification)
      ..writeByte(11)
      ..write(obj.category)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(14)
      ..write(obj.isRecurring)
      ..writeByte(15)
      ..write(obj.recurringPattern)
      ..writeByte(16)
      ..write(obj.isReligious)
      ..writeByte(17)
      ..write(obj.prayerBlockId)
      ..writeByte(18)
      ..write(obj.orderIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 6;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      default:
        return TaskPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.low:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
