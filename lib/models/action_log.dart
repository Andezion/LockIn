import 'package:hive/hive.dart';
import 'life_category.dart';

/// Records when a task was completed
@HiveType(typeId: 4)
class ActionLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String taskId; // Reference to Task

  @HiveField(2)
  String taskTitle; // Denormalized for quick access

  @HiveField(3)
  LifeCategory category;

  @HiveField(4)
  int difficulty;

  @HiveField(5)
  DateTime completedAt;

  @HiveField(6)
  int? durationMinutes; // Actual time spent

  @HiveField(7)
  int xpEarned; // Calculated at completion time

  @HiveField(8)
  String? notes; // Optional notes about the completion

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

  /// Get the date portion (without time) for grouping
  DateTime get dateOnly {
    return DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
  }
}
