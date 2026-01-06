import 'package:hive/hive.dart';

/// Defines how often a task repeats
@HiveType(typeId: 1)
enum RecurrenceType {
  @HiveField(0)
  once,

  @HiveField(1)
  daily,

  @HiveField(2)
  weekly,

  @HiveField(3)
  custom;
}

/// Configuration for recurring tasks
@HiveType(typeId: 2)
class Recurrence extends HiveObject {
  @HiveField(0)
  RecurrenceType type;

  @HiveField(1)
  int? intervalDays; // For custom recurrence

  @HiveField(2)
  List<int>? weekdays; // For weekly: 1=Monday, 7=Sunday

  Recurrence({
    required this.type,
    this.intervalDays,
    this.weekdays,
  });

  /// Check if task should occur on a given date
  bool shouldOccurOn(DateTime date, DateTime taskCreatedDate) {
    switch (type) {
      case RecurrenceType.once:
        return isSameDay(date, taskCreatedDate);
      case RecurrenceType.daily:
        return date.isAfter(taskCreatedDate.subtract(const Duration(days: 1)));
      case RecurrenceType.weekly:
        if (weekdays == null || weekdays!.isEmpty) return false;
        return weekdays!.contains(date.weekday);
      case RecurrenceType.custom:
        if (intervalDays == null) return false;
        final daysDiff = date.difference(taskCreatedDate).inDays;
        return daysDiff >= 0 && daysDiff % intervalDays! == 0;
    }
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
