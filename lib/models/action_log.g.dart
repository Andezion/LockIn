// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActionLogAdapter extends TypeAdapter<ActionLog> {
  @override
  final int typeId = 4;

  @override
  ActionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActionLog(
      id: fields[0] as String,
      taskId: fields[1] as String,
      taskTitle: fields[2] as String,
      category: fields[3] as LifeCategory,
      difficulty: fields[4] as int,
      completedAt: fields[5] as DateTime,
      durationMinutes: fields[6] as int?,
      xpEarned: fields[7] as int,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActionLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.taskTitle)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.durationMinutes)
      ..writeByte(7)
      ..write(obj.xpEarned)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
