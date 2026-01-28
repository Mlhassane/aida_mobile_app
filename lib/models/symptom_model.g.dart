// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SymptomModelAdapter extends TypeAdapter<SymptomModel> {
  @override
  final int typeId = 2;

  @override
  SymptomModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SymptomModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mood: fields[2] as String?,
      symptoms: (fields[3] as List).cast<String>(),
      painLevel: fields[4] as int?,
      flowLevel: fields[5] as String?,
      notes: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SymptomModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.symptoms)
      ..writeByte(4)
      ..write(obj.painLevel)
      ..writeByte(5)
      ..write(obj.flowLevel)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
