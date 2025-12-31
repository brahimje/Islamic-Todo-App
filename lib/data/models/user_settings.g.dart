// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 4;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      locationName: fields[0] as String?,
      latitude: fields[1] as double?,
      longitude: fields[2] as double?,
      calculationMethod: (fields[3] as int?) ?? 0,
      notificationsEnabled: (fields[4] as bool?) ?? true,
      defaultReminderMinutes: (fields[5] as int?) ?? 10,
      showNafilaReminders: (fields[6] as bool?) ?? true,
      showTaskReminders: (fields[7] as bool?) ?? true,
      language: (fields[8] as String?) ?? 'en',
      dailyReviewHour: fields[9] as int?,
      dailyReviewMinute: fields[10] as int?,
      isOnboardingComplete: (fields[11] as bool?) ?? false,
      useSilentNotifications: (fields[12] as bool?) ?? false,
      madhab: (fields[13] as int?) ?? 0,
      use24HourFormat: (fields[14] as bool?) ?? true,
      showCompletedTasks: (fields[15] as bool?) ?? true,
      autoArchiveCompletedTasks: (fields[16] as bool?) ?? false,
      weekStartDay: (fields[17] as int?) ?? 1,
      showMorningAdhkarReminder: (fields[18] as bool?) ?? true,
      showEveningAdhkarReminder: (fields[19] as bool?) ?? true,
      showAfterPrayerAdhkarReminder: (fields[20] as bool?) ?? false,
      showSleepAdhkarReminder: (fields[21] as bool?) ?? false,
      morningAdhkarHour: (fields[22] as int?) ?? 6,
      eveningAdhkarHour: (fields[23] as int?) ?? 17,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.locationName)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.calculationMethod)
      ..writeByte(4)
      ..write(obj.notificationsEnabled)
      ..writeByte(5)
      ..write(obj.defaultReminderMinutes)
      ..writeByte(6)
      ..write(obj.showNafilaReminders)
      ..writeByte(7)
      ..write(obj.showTaskReminders)
      ..writeByte(8)
      ..write(obj.language)
      ..writeByte(9)
      ..write(obj.dailyReviewHour)
      ..writeByte(10)
      ..write(obj.dailyReviewMinute)
      ..writeByte(11)
      ..write(obj.isOnboardingComplete)
      ..writeByte(12)
      ..write(obj.useSilentNotifications)
      ..writeByte(13)
      ..write(obj.madhab)
      ..writeByte(14)
      ..write(obj.use24HourFormat)
      ..writeByte(15)
      ..write(obj.showCompletedTasks)
      ..writeByte(16)
      ..write(obj.autoArchiveCompletedTasks)
      ..writeByte(17)
      ..write(obj.weekStartDay)
      ..writeByte(18)
      ..write(obj.showMorningAdhkarReminder)
      ..writeByte(19)
      ..write(obj.showEveningAdhkarReminder)
      ..writeByte(20)
      ..write(obj.showAfterPrayerAdhkarReminder)
      ..writeByte(21)
      ..write(obj.showSleepAdhkarReminder)
      ..writeByte(22)
      ..write(obj.morningAdhkarHour)
      ..writeByte(23)
      ..write(obj.eveningAdhkarHour);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CalculationMethodAdapter extends TypeAdapter<CalculationMethod> {
  @override
  final int typeId = 8;

  @override
  CalculationMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CalculationMethod.muslimWorldLeague;
      case 1:
        return CalculationMethod.egyptian;
      case 2:
        return CalculationMethod.karachi;
      case 3:
        return CalculationMethod.ummAlQura;
      case 4:
        return CalculationMethod.dubai;
      case 5:
        return CalculationMethod.qatar;
      case 6:
        return CalculationMethod.kuwait;
      case 7:
        return CalculationMethod.moonsightingCommittee;
      case 8:
        return CalculationMethod.singapore;
      case 9:
        return CalculationMethod.northAmerica;
      case 10:
        return CalculationMethod.other;
      default:
        return CalculationMethod.muslimWorldLeague;
    }
  }

  @override
  void write(BinaryWriter writer, CalculationMethod obj) {
    switch (obj) {
      case CalculationMethod.muslimWorldLeague:
        writer.writeByte(0);
        break;
      case CalculationMethod.egyptian:
        writer.writeByte(1);
        break;
      case CalculationMethod.karachi:
        writer.writeByte(2);
        break;
      case CalculationMethod.ummAlQura:
        writer.writeByte(3);
        break;
      case CalculationMethod.dubai:
        writer.writeByte(4);
        break;
      case CalculationMethod.qatar:
        writer.writeByte(5);
        break;
      case CalculationMethod.kuwait:
        writer.writeByte(6);
        break;
      case CalculationMethod.moonsightingCommittee:
        writer.writeByte(7);
        break;
      case CalculationMethod.singapore:
        writer.writeByte(8);
        break;
      case CalculationMethod.northAmerica:
        writer.writeByte(9);
        break;
      case CalculationMethod.other:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculationMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
