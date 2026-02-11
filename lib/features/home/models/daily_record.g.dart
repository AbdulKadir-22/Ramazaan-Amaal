// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyRecordAdapter extends TypeAdapter<DailyRecord> {
  @override
  final int typeId = 0;

  @override
  DailyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyRecord(
      date: fields[0] as DateTime,
      salah: (fields[1] as Map).cast<String, bool>(),
      extraSalah: (fields[2] as Map).cast<String, bool>(),
      suhoorNiyat: (fields[3] as bool?) ?? false,
      rozaNiyat: (fields[8] as bool?) ?? false,
      tilawatPages: (fields[4] as int?) ?? 0,
      selfReflection: (fields[6] as Map?)?.cast<String, bool>(),
      duas: (fields[9] as Map?)?.cast<String, bool>(),
      zikr: (fields[10] as Map?)?.cast<String, int>(),
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.salah)
      ..writeByte(2)
      ..write(obj.extraSalah)
      ..writeByte(3)
      ..write(obj.suhoorNiyat)
      ..writeByte(4)
      ..write(obj.tilawatPages)
      ..writeByte(6)
      ..write(obj.selfReflection)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.rozaNiyat)
      ..writeByte(9)
      ..write(obj.duas)
      ..writeByte(10)
      ..write(obj.zikr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
