import 'package:lockin/models/day_entry.dart';
import 'package:lockin/services/hive_service.dart';

/// Сервис для обработки штрафов за невыполненные задачи
class PenaltyService {
  /// Проверить задачи за конкретный день и применить штрафы
  /// Возвращает сумму штрафов
  static Future<int> processPenaltiesForDate(DateTime date) async {
    // Нормализуем дату
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Получаем все активные задачи для этой даты
    final allTasks = HiveService.getAllActiveTasks();
    final tasksForDate = allTasks
        .where((task) =>
            task.recurrence.shouldOccurOn(normalizedDate, task.createdAt))
        .toList();

    if (tasksForDate.isEmpty) {
      return 0;
    }

    // Получаем все завершенные действия за этот день
    final actionLogs = HiveService.getAllActionLogs();
    final completedLogsForDate = actionLogs.where((log) {
      final logDate = DateTime(
        log.completedAt.year,
        log.completedAt.month,
        log.completedAt.day,
      );
      return logDate.isAtSameMomentAs(normalizedDate);
    }).toList();

    // Подсчитываем завершенные задачи
    final Map<String, int> completionCounts = {};
    for (final log in completedLogsForDate) {
      completionCounts[log.taskId] =
          (completionCounts[log.taskId] ?? 0) + log.completionCount;
    }

    // Считаем штрафы за невыполненные задачи
    int totalPenalty = 0;
    final List<String> penalizedTasks = [];

    for (final task in tasksForDate) {
      final completedCount = completionCounts[task.id] ?? 0;
      final required = task.dailyGoal;

      if (completedCount < required) {
        // Задача не выполнена или выполнена не полностью
        final missedCount = required - completedCount;

        // Штраф = (сложность задачи + 1) за каждое невыполненное требование
        final penaltyPerMiss = task.difficulty + 1;
        final taskPenalty = penaltyPerMiss * missedCount;

        totalPenalty += taskPenalty;
        penalizedTasks.add('${task.title}: -$taskPenalty XP');
      }
    }

    // Сохраняем штрафы в DayEntry
    if (totalPenalty > 0) {
      await _savePenalty(normalizedDate, totalPenalty);
    }

    return totalPenalty;
  }

  /// Проверить все дни с момента последней проверки до сегодня
  static Future<Map<DateTime, int>> processAllPendingPenalties() async {
    final Map<DateTime, int> penalties = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Получаем профиль для определения последней активности
    final profile = HiveService.getProfile();
    final lastActivityDate = profile.lastActiveDate ?? today;

    // Проверяем все дни с последней активности до вчерашнего дня
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

  /// Получить общую сумму штрафов за период
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

  /// Проверить, были ли уже применены штрафы для даты
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
