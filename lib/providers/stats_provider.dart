import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/action_log.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/providers/action_logs_provider.dart';

class StatsData {
  final int totalActions;
  final int totalMinutes;
  final int totalXp;
  final Map<LifeCategory, int> actionsByCategory;
  final Map<LifeCategory, int> minutesByCategory;
  final List<ActionLog> recentActions;

  StatsData({
    required this.totalActions,
    required this.totalMinutes,
    required this.totalXp,
    required this.actionsByCategory,
    required this.minutesByCategory,
    required this.recentActions,
  });

  factory StatsData.empty() {
    return StatsData(
      totalActions: 0,
      totalMinutes: 0,
      totalXp: 0,
      actionsByCategory: {},
      minutesByCategory: {},
      recentActions: [],
    );
  }
}

final statsProvider =
    Provider.family<StatsData, ({DateTime start, DateTime end})>((ref, range) {
  final allLogs = ref.watch(actionLogsProvider);

  final logsInRange = allLogs.where((log) {
    return log.completedAt
            .isAfter(range.start.subtract(const Duration(days: 1))) &&
        log.completedAt.isBefore(range.end.add(const Duration(days: 1)));
  }).toList();

  if (logsInRange.isEmpty) {
    return StatsData.empty();
  }

  int totalActions = logsInRange.length;
  int totalMinutes = logsInRange
      .map((log) => log.durationMinutes ?? 0)
      .reduce((a, b) => a + b);
  int totalXp = logsInRange.map((log) => log.xpEarned).reduce((a, b) => a + b);

  Map<LifeCategory, int> actionsByCategory = {};
  Map<LifeCategory, int> minutesByCategory = {};

  for (final log in logsInRange) {
    actionsByCategory[log.category] =
        (actionsByCategory[log.category] ?? 0) + 1;
    minutesByCategory[log.category] =
        (minutesByCategory[log.category] ?? 0) + (log.durationMinutes ?? 0);
  }

  return StatsData(
    totalActions: totalActions,
    totalMinutes: totalMinutes,
    totalXp: totalXp,
    actionsByCategory: actionsByCategory,
    minutesByCategory: minutesByCategory,
    recentActions: logsInRange.take(20).toList(),
  );
});

final weeklyStatsProvider = Provider<StatsData>((ref) {
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 7));
  return ref.watch(statsProvider((start: start, end: now)));
});

final monthlyStatsProvider = Provider<StatsData>((ref) {
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 30));
  return ref.watch(statsProvider((start: start, end: now)));
});
