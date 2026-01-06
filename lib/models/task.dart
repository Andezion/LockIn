import 'package:hive/hive.dart';
import 'life_category.dart';
import 'recurrence.dart';

part 'task.g.dart';

@HiveType(typeId: 3)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  LifeCategory category;

  @HiveField(4)
  int difficulty;

  @HiveField(5)
  int? estimatedMinutes;

  @HiveField(6)
  Recurrence recurrence;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool isActive;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.difficulty = 2,
    this.estimatedMinutes,
    required this.recurrence,
    required this.createdAt,
    this.isActive = true,
  });

  factory Task.oneTime({
    required String id,
    required String title,
    String? description,
    required LifeCategory category,
    int difficulty = 2,
    int? estimatedMinutes,
    required DateTime createdAt,
  }) {
    return Task(
      id: id,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      estimatedMinutes: estimatedMinutes,
      recurrence: Recurrence(type: RecurrenceType.once),
      createdAt: createdAt,
    );
  }

  factory Task.daily({
    required String id,
    required String title,
    String? description,
    required LifeCategory category,
    int difficulty = 2,
    int? estimatedMinutes,
    required DateTime createdAt,
  }) {
    return Task(
      id: id,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      estimatedMinutes: estimatedMinutes,
      recurrence: Recurrence(type: RecurrenceType.daily),
      createdAt: createdAt,
    );
  }
}
