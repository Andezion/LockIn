import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/providers/action_logs_provider.dart';
import 'package:lockin/providers/tasks_provider.dart';
import 'package:lockin/services/hive_service.dart';

final overdueTasksProvider = Provider.family<List<Task>, DateTime>((ref, date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final checkDate = DateTime(date.year, date.month, date.day);

  if (!checkDate.isBefore(today)) {
    return [];
  }

  final tasksForDate = ref.watch(tasksForDateProvider(date));
  final completedActions = ref.watch(actionLogsForDateProvider(date));

  return tasksForDate.where((task) {
    return !completedActions.any((log) => log.taskId == task.id);
  }).toList();
});

final overdueTasksPenaltyNotifier =
    Provider<OverdueTasksPenaltyNotifier>((ref) {
  return OverdueTasksPenaltyNotifier(ref);
});

class OverdueTasksPenaltyNotifier {
  final Ref ref;

  OverdueTasksPenaltyNotifier(this.ref);

  Future<void> applyPenaltiesForDate(DateTime date) async {
    final overdueTasks = ref.read(overdueTasksProvider(date));

    if (overdueTasks.isEmpty) {
      return;
    }

    int totalPenalty = 0;

    for (final task in overdueTasks) {
      final penaltyPerTask = task.difficulty * 5;
      totalPenalty += penaltyPerTask;
    }

    if (totalPenalty > 0) {
      await HiveService.addPenaltyForOverdueTask(date, totalPenalty);
    }
  }

  Future<void> checkYesterday() async {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));

    await applyPenaltiesForDate(yesterday);
  }
}
