import 'package:hive/hive.dart';

part 'overdue_task.g.dart';

@HiveType(typeId: 6)
class OverdueTask extends HiveObject {
  @HiveField(0)
  String taskId;

  @HiveField(1)
  DateTime overdueDate;

  @HiveField(2)
  bool penaltyApplied;

  @HiveField(3)
  int penaltyXp;

  OverdueTask({
    required this.taskId,
    required this.overdueDate,
    this.penaltyApplied = false,
    this.penaltyXp = 0,
  });
}
