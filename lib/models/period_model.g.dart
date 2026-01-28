// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PeriodModelAdapter extends TypeAdapter<PeriodModel> {
  @override
  final int typeId = 1;

  @override
  PeriodModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeriodModel(
      id: fields[0] as String,
      startDate: fields[1] as DateTime,
      endDate: fields[2] as DateTime?,
      duration: fields[3] as int,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PeriodModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.endDate)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
