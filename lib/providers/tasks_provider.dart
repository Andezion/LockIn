import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/services/hive_service.dart';

/// Provider for all tasks
final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

/// Provider for tasks on a specific date
final tasksForDateProvider = Provider.family<List<Task>, DateTime>((ref, date) {
  final allTasks = ref.watch(tasksProvider);
  return allTasks
      .where((task) => task.recurrence.shouldOccurOn(date, task.createdAt))
      .toList();
});

class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super([]) {
    _loadTasks();
  }

  void _loadTasks() {
    state = HiveService.getAllActiveTasks();
  }

  /// Add a new task
  Future<void> addTask(Task task) async {
    await HiveService.saveTask(task);
    _loadTasks();
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    await HiveService.saveTask(task);
    _loadTasks();
  }

  /// Delete a task (mark as inactive)
  Future<void> deleteTask(String taskId) async {
    await HiveService.deleteTask(taskId);
    _loadTasks();
  }

  /// Reload tasks from database
  void reload() {
    _loadTasks();
  }
}
