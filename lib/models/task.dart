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

  @HiveField(9)
  int dailyGoal;

  @HiveField(10)
  int categoryPoints;

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
    this.dailyGoal = 1,
    int? categoryPoints,
  }) : categoryPoints = categoryPoints ?? _calculatePoints(difficulty);

  static int _calculatePoints(int difficulty) {
    switch (difficulty) {
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 5;
      case 4:
        return 7;
      case 5:
        return 10;
      default:
        return 3;
    }
  }

  factory Task.oneTime({
    required String id,
    required String title,
    String? description,
    required LifeCategory category,
    int difficulty = 2,
    int? estimatedMinutes,
    required DateTime createdAt,
    int dailyGoal = 1,
    int? categoryPoints,
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
      dailyGoal: dailyGoal,
      categoryPoints: categoryPoints,
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
    int dailyGoal = 1,
    int? categoryPoints,
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
      dailyGoal: dailyGoal,
      categoryPoints: categoryPoints,
    );
  }
}
