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
      isCompleted: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      completedAt: fields[8] as DateTime?,
      priority: fields[9] as int,
      hasNotification: fields[10] as bool,
      category: fields[11] as String?,
      tags: (fields[12] as List).cast<String>(),
      reminderMinutesBefore: fields[13] as int,
      isRecurring: fields[14] as bool,
      recurringPattern: fields[15] as String?,
      isReligious: fields[16] as bool,
      prayerBlockId: fields[17] as String?,
      orderIndex: fields[18] as int,
      state: fields[19] as TaskState,
      archivedAt: fields[20] as DateTime?,
      lastResetDate: fields[21] as DateTime?,
      recurringEndDate: fields[22] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(23)
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
      ..write(obj.orderIndex)
      ..writeByte(19)
      ..write(obj.state)
      ..writeByte(20)
      ..write(obj.archivedAt)
      ..writeByte(21)
      ..write(obj.lastResetDate)
      ..writeByte(22)
      ..write(obj.recurringEndDate);
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

class TaskStateAdapter extends TypeAdapter<TaskState> {
  @override
  final int typeId = 10;

  @override
  TaskState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskState.active;
      case 1:
        return TaskState.completed;
      case 2:
        return TaskState.skipped;
      case 3:
        return TaskState.archived;
      case 4:
        return TaskState.overdue;
      default:
        return TaskState.active;
    }
  }

  @override
  void write(BinaryWriter writer, TaskState obj) {
    switch (obj) {
      case TaskState.active:
        writer.writeByte(0);
        break;
      case TaskState.completed:
        writer.writeByte(1);
        break;
      case TaskState.skipped:
        writer.writeByte(2);
        break;
      case TaskState.archived:
        writer.writeByte(3);
        break;
      case TaskState.overdue:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
