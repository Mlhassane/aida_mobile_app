// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      dateOfBirth: fields[2] as DateTime?,
      lastPeriodDate: fields[3] as DateTime?,
      averageCycleLength: fields[4] as int? ?? 28,
      averagePeriodLength: fields[5] as int? ?? 5,
      minCycleLength: fields[13] as int? ?? 28,
      maxCycleLength: fields[14] as int? ?? 28,
      minPeriodLength: fields[15] as int? ?? 5,
      maxPeriodLength: fields[16] as int? ?? 5,
      allowAiSymptoms: fields[17] as bool? ?? true,
      allowAiJournal: fields[18] as bool? ?? true,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime?,
      weight: fields[8] as double?,
      height: fields[9] as double?,
      notificationsEnabled: fields[10] as bool? ?? true,
      profileImagePath: fields[11] as String?,
      avatarAsset: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dateOfBirth)
      ..writeByte(3)
      ..write(obj.lastPeriodDate)
      ..writeByte(4)
      ..write(obj.averageCycleLength)
      ..writeByte(5)
      ..write(obj.averagePeriodLength)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.weight)
      ..writeByte(9)
      ..write(obj.height)
      ..writeByte(10)
      ..write(obj.notificationsEnabled)
      ..writeByte(11)
      ..write(obj.profileImagePath)
      ..writeByte(12)
      ..write(obj.avatarAsset)
      ..writeByte(13)
      ..write(obj.minCycleLength)
      ..writeByte(14)
      ..write(obj.maxCycleLength)
      ..writeByte(15)
      ..write(obj.minPeriodLength)
      ..writeByte(16)
      ..write(obj.maxPeriodLength)
      ..writeByte(17)
      ..write(obj.allowAiSymptoms)
      ..writeByte(18)
      ..write(obj.allowAiJournal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
