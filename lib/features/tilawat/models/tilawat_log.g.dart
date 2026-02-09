// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tilawat_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TilawatLogAdapter extends TypeAdapter<TilawatLog> {
  @override
  final int typeId = 1;

  @override
  TilawatLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TilawatLog(
      date: fields[0] as DateTime,
      juzNumber: fields[1] as int,
      pagesRead: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TilawatLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.juzNumber)
      ..writeByte(2)
      ..write(obj.pagesRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TilawatLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
