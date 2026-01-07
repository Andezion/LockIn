part of 'overdue_task.dart';

class OverdueTaskAdapter extends TypeAdapter<OverdueTask> {
  @override
  final int typeId = 6;

  @override
  OverdueTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OverdueTask(
      taskId: fields[0] as String,
      overdueDate: fields[1] as DateTime,
      penaltyApplied: fields[2] as bool,
      penaltyXp: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OverdueTask obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.taskId)
      ..writeByte(1)
      ..write(obj.overdueDate)
      ..writeByte(2)
      ..write(obj.penaltyApplied)
      ..writeByte(3)
      ..write(obj.penaltyXp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverdueTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
