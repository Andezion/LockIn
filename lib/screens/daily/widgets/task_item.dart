import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/providers/action_logs_provider.dart';
import 'package:lockin/screens/daily/widgets/complete_task_dialog.dart';

class TaskItem extends ConsumerWidget {
  final Task task;
  final DateTime date;

  const TaskItem({
    super.key,
    required this.task,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedActions = ref.watch(actionLogsForDateProvider(date));
    final isCompleted = completedActions.any((log) => log.taskId == task.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged:
              isCompleted ? null : (_) => _showCompleteDialog(context, ref),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.category.displayName),
            if (task.estimatedMinutes != null)
              Text('~${task.estimatedMinutes} min'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(
              task.difficulty,
              (index) => Icon(
                Icons.star,
                size: 16,
                color: Colors.amber[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CompleteTaskDialog(task: task),
    );
  }
}
