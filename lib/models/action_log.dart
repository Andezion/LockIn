import 'package:hive/hive.dart';
import 'life_category.dart';

part 'action_log.g.dart';

@HiveType(typeId: 4)
class ActionLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String taskId;

  @HiveField(2)
  String taskTitle;

  @HiveField(3)
  LifeCategory category;

  @HiveField(4)
  int difficulty;

  @HiveField(5)
  DateTime completedAt;

  @HiveField(6)
  int? durationMinutes;

  @HiveField(7)
  int xpEarned;

  @HiveField(8)
  String? notes;

  ActionLog({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.category,
    required this.difficulty,
    required this.completedAt,
    this.durationMinutes,
    required this.xpEarned,
    this.notes,
  });

  DateTime get dateOnly {
    return DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
  }
}
