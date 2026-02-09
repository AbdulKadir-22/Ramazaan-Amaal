// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zikr_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZikrItemAdapter extends TypeAdapter<ZikrItem> {
  @override
  final int typeId = 1;

  @override
  ZikrItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZikrItem(
      id: fields[0] as String,
      name: fields[1] as String,
      currentCount: fields[2] as int,
      targetCount: fields[3] as int,
      reminderTime: fields[4] as String?,
      lastUpdatedDate: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ZikrItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.currentCount)
      ..writeByte(3)
      ..write(obj.targetCount)
      ..writeByte(4)
      ..write(obj.reminderTime)
      ..writeByte(5)
      ..write(obj.lastUpdatedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZikrItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
