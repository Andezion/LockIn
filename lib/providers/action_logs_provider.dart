import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/action_log.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/providers/profile_provider.dart';
import 'package:lockin/services/hive_service.dart';
import 'package:lockin/services/xp_calculator.dart';
import 'package:uuid/uuid.dart';

/// Provider for all action logs
final actionLogsProvider =
    StateNotifierProvider<ActionLogsNotifier, List<ActionLog>>((ref) {
  return ActionLogsNotifier(ref);
});

/// Provider for action logs on a specific date
final actionLogsForDateProvider =
    Provider.family<List<ActionLog>, DateTime>((ref, date) {
  final allLogs = ref.watch(actionLogsProvider);
  final targetDate = DateTime(date.year, date.month, date.day);
  return allLogs
      .where((log) => _isSameDay(log.completedAt, targetDate))
      .toList()
    ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
});

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class ActionLogsNotifier extends StateNotifier<List<ActionLog>> {
  final Ref ref;

  ActionLogsNotifier(this.ref) : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    state = HiveService.getAllActionLogs();
  }

  /// Complete a task and create an action log
  Future<void> completeTask({
    required Task task,
    int? durationMinutes,
    String? notes,
  }) async {
    final profile = ref.read(profileProvider);

    // Calculate XP
    final xpEarned = XPCalculator.calculateTaskXp(
      difficulty: task.difficulty,
      durationMinutes: durationMinutes,
      currentStreak: profile.currentStreak,
    );

    // Create action log
    final log = ActionLog(
      id: const Uuid().v4(),
      taskId: task.id,
      taskTitle: task.title,
      category: task.category,
      difficulty: task.difficulty,
      completedAt: DateTime.now(),
      durationMinutes: durationMinutes,
      xpEarned: xpEarned,
      notes: notes,
    );

    await HiveService.saveActionLog(log);

    // Update profile
    await ref.read(profileProvider.notifier).addXp(xpEarned);
    await ref.read(profileProvider.notifier).updateStreak(log.completedAt);

    // Update category level
    final categoryPoints = XPCalculator.calculateCategoryProgress(
      difficulty: task.difficulty,
      durationMinutes: durationMinutes,
    );
    await ref.read(profileProvider.notifier).updateCategoryLevel(
          task.category,
          categoryPoints,
        );

    _loadLogs();
  }

  /// Log a quick action (without predefined task)
  Future<void> logQuickAction({
    required String title,
    required LifeCategory category,
    int difficulty = 2,
    int? durationMinutes,
    String? notes,
  }) async {
    final profile = ref.read(profileProvider);

    // Calculate XP
    final xpEarned = XPCalculator.calculateTaskXp(
      difficulty: difficulty,
      durationMinutes: durationMinutes,
      currentStreak: profile.currentStreak,
    );

    // Create action log
    final log = ActionLog(
      id: const Uuid().v4(),
      taskId: 'quick_${const Uuid().v4()}',
      taskTitle: title,
      category: category,
      difficulty: difficulty,
      completedAt: DateTime.now(),
      durationMinutes: durationMinutes,
      xpEarned: xpEarned,
      notes: notes,
    );

    await HiveService.saveActionLog(log);

    // Update profile
    await ref.read(profileProvider.notifier).addXp(xpEarned);
    await ref.read(profileProvider.notifier).updateStreak(log.completedAt);

    // Update category level
    final categoryPoints = XPCalculator.calculateCategoryProgress(
      difficulty: difficulty,
      durationMinutes: durationMinutes,
    );
    await ref.read(profileProvider.notifier).updateCategoryLevel(
          category,
          categoryPoints,
        );

    _loadLogs();
  }

  /// Reload action logs from database
  void reload() {
    _loadLogs();
  }
}
