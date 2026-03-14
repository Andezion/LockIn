import 'package:lockin/models/day_entry.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/models/recurrence.dart';
import 'package:lockin/services/hive_service.dart';
import 'package:lockin/services/xp_calculator.dart';

class ProcessedDayPenalty {
  final int totalPenalty;
  final Map<LifeCategory, double> categoryReductions;

  ProcessedDayPenalty({
    required this.totalPenalty,
    required this.categoryReductions,
  });
}

class PenaltyService {
  static Future<ProcessedDayPenalty> processPenaltiesForDate(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final allTasks = HiveService.getAllActiveTasks();
    final tasksForDate = allTasks
        .where((task) =>
            task.recurrence.shouldOccurOn(normalizedDate, task.createdAt))
        .toList();

    if (tasksForDate.isEmpty) {
      return ProcessedDayPenalty(totalPenalty: 0, categoryReductions: {});
    }

    final actionLogs = HiveService.getAllActionLogs();
    final completedLogsForDate = actionLogs.where((log) {
      final logDate = DateTime(
        log.completedAt.year,
        log.completedAt.month,
        log.completedAt.day,
      );
      return logDate.isAtSameMomentAs(normalizedDate);
    }).toList();

    final Map<String, int> completionCounts = {};
    for (final log in completedLogsForDate) {
      completionCounts[log.taskId] =
          (completionCounts[log.taskId] ?? 0) + log.completionCount;
    }

    int totalPenalty = 0;
    final Map<LifeCategory, double> categoryReductions = {};

    for (final task in tasksForDate) {
      final completedCount = completionCounts[task.id] ?? 0;
      final required = task.dailyGoal;

      if (completedCount < required) {
        final missedCount = required - completedCount;

        final penaltyPerMiss = task.difficulty + 1;
        final taskPenalty = penaltyPerMiss * missedCount;

        totalPenalty += taskPenalty;

        final catReduction =
            XPCalculator.calculateCategoryProgress(difficulty: task.difficulty) *
                missedCount;
        categoryReductions[task.category] =
            (categoryReductions[task.category] ?? 0) + catReduction;
      }
    }

    if (totalPenalty > 0) {
      await _savePenalty(normalizedDate, totalPenalty);
    }

    return ProcessedDayPenalty(
      totalPenalty: totalPenalty,
      categoryReductions: categoryReductions,
    );
  }

  static Future<Map<DateTime, ProcessedDayPenalty>> processAllPendingPenalties() async {
    final Map<DateTime, ProcessedDayPenalty> penalties = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final profile = HiveService.getProfile();
    final lastActivityDate = profile.lastActiveDate ?? today;

    DateTime checkDate = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );

    while (checkDate.isBefore(today)) {
      final result = await processPenaltiesForDate(checkDate);
      if (result.totalPenalty > 0) {
        penalties[checkDate] = result;
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }

    return penalties;
  }

  static int getTotalPenaltyForPeriod(DateTime start, DateTime end) {
    int total = 0;
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    DateTime current = startDate;
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final dayEntry = HiveService.getDayEntry(current);
      if (dayEntry != null && dayEntry.penaltyXp != null) {
        total += dayEntry.penaltyXp!;
      }
      current = current.add(const Duration(days: 1));
    }

    return total;
  }

  static bool arePenaltiesAppliedForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dayEntry = HiveService.getDayEntry(normalizedDate);
    return dayEntry?.penaltyXp != null;
  }

  static Future<void> _savePenalty(DateTime date, int penalty) async {
    var dayEntry = HiveService.getDayEntry(date);

    if (dayEntry == null) {
      dayEntry = DayEntry(date: date, penaltyXp: penalty);
    } else {
      dayEntry.addPenalty(penalty);
    }

    await HiveService.saveDayEntry(dayEntry);
  }

  static Future<int> rescheduleOverdueOnceTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final allTasks = HiveService.getAllActiveTasks();
    final allActionLogs = HiveService.getAllActionLogs();
    int count = 0;

    for (final task in allTasks) {
      if (task.recurrence.type != RecurrenceType.once) continue;

      final taskDate = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );

      if (!taskDate.isBefore(today)) continue;

      final completionsOnTaskDate = allActionLogs.where((log) {
        final logDate = DateTime(
          log.completedAt.year,
          log.completedAt.month,
          log.completedAt.day,
        );
        return log.taskId == task.id && logDate.isAtSameMomentAs(taskDate);
      }).fold(0, (sum, log) => sum + log.completionCount);

      if (completionsOnTaskDate < task.dailyGoal) {
        task.createdAt = today;
        await HiveService.saveTask(task);
        count++;
      }
    }

    return count;
  }
}
