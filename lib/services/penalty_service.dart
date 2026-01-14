import 'package:lockin/models/day_entry.dart';
import 'package:lockin/services/hive_service.dart';

class PenaltyService {
  static Future<int> processPenaltiesForDate(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final allTasks = HiveService.getAllActiveTasks();
    final tasksForDate = allTasks
        .where((task) =>
            task.recurrence.shouldOccurOn(normalizedDate, task.createdAt))
        .toList();

    if (tasksForDate.isEmpty) {
      return 0;
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
    final List<String> penalizedTasks = [];

    for (final task in tasksForDate) {
      final completedCount = completionCounts[task.id] ?? 0;
      final required = task.dailyGoal;

      if (completedCount < required) {
        final missedCount = required - completedCount;

        final penaltyPerMiss = task.difficulty + 1;
        final taskPenalty = penaltyPerMiss * missedCount;

        totalPenalty += taskPenalty;
        penalizedTasks.add('${task.title}: -$taskPenalty XP');
      }
    }

    if (totalPenalty > 0) {
      await _savePenalty(normalizedDate, totalPenalty);
    }

    return totalPenalty;
  }

  static Future<Map<DateTime, int>> processAllPendingPenalties() async {
    final Map<DateTime, int> penalties = {};
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
      final penalty = await processPenaltiesForDate(checkDate);
      if (penalty > 0) {
        penalties[checkDate] = penalty;
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
}
