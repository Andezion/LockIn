import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/services/hive_service.dart';

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

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

  Future<void> addTask(Task task) async {
    await HiveService.saveTask(task);
    _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await HiveService.saveTask(task);
    _loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await HiveService.deleteTask(taskId);
    _loadTasks();
  }

  void reload() {
    _loadTasks();
  }
}
