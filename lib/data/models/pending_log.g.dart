// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingLogAdapter extends TypeAdapter<PendingLog> {
  @override
  final int typeId = 0;

  @override
  PendingLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingLog(
      employeeId: fields[0] as String,
      timestamp: fields[1] as DateTime,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      localImagePath: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PendingLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.employeeId)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.localImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
