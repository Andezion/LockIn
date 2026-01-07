import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/providers/action_logs_provider.dart';
import 'package:lockin/providers/tasks_provider.dart';
import 'package:lockin/screens/daily/widgets/complete_task_dialog.dart';

class TaskItem extends ConsumerStatefulWidget {
  final Task task;
  final DateTime date;

  const TaskItem({
    super.key,
    required this.task,
    required this.date,
  });

  @override
  ConsumerState<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends ConsumerState<TaskItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final completedActions = ref.watch(actionLogsForDateProvider(widget.date));
    final isCompleted =
        completedActions.any((log) => log.taskId == widget.task.id);

    final now = DateTime.now();
    final taskDate =
        DateTime(widget.date.year, widget.date.month, widget.date.day);
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = !isCompleted && taskDate.isBefore(today);

    Color getBackgroundColor() {
      if (isCompleted) {
        return Colors.green.withOpacity(0.15);
      } else if (isOverdue) {
        return Colors.red.withOpacity(0.15);
      } else {
        return Colors.grey.withOpacity(0.1);
      }
    }

    Color getBorderColor() {
      if (isCompleted) {
        return Colors.green;
      } else if (isOverdue) {
        return Colors.red;
      } else {
        return Colors.grey.shade300;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: getBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: getBorderColor(),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Checkbox(
              value: isCompleted,
              onChanged:
                  isCompleted ? null : (_) => _showCompleteDialog(context),
            ),
            title: Text(
              widget.task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isOverdue)
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.red[700],
                    size: 20,
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red[400],
                  onPressed: () => _showDeleteDialog(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                border: Border(
                  top: BorderSide(
                    color: getBorderColor().withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.title, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Full Title:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.task.title,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 12),
                  if (widget.task.description != null &&
                      widget.task.description!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.description,
                            size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Description:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.task.description!,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Category:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.task.category.displayName,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_alt,
                          size: 16, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Difficulty:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(
                        widget.task.difficulty,
                        (index) => Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  if (widget.task.estimatedMinutes != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Estimated Time:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '~${widget.task.estimatedMinutes} мин',
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CompleteTaskDialog(task: widget.task),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content:
            Text('Are you sure you want to delete "${widget.task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(tasksProvider.notifier).deleteTask(widget.task.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task deleted')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
