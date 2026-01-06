import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockin/models/action_log.dart';
import 'package:lockin/providers/action_logs_provider.dart';

class CompletedActionsList extends ConsumerWidget {
  final List<ActionLog> actions;

  const CompletedActionsList({super.key, required this.actions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: actions
          .map((action) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(action.category.name),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 20),
                  ),
                  title: Text(action.taskTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(action.category.displayName),
                      Text(
                        DateFormat('HH:mm').format(action.completedAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${action.xpEarned} XP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (action.durationMinutes != null)
                            Text(
                              '${action.durationMinutes} min',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red[400],
                        onPressed: () =>
                            _showDeleteDialog(context, ref, action),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, ActionLog action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Completed Task'),
        content: Text(
            'Are you sure you want to delete "${action.taskTitle}" from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(actionLogsProvider.notifier)
                  .deleteActionLog(action.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task deleted from history')),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'sport':
        return Colors.red;
      case 'learning':
        return Colors.blue;
      case 'discipline':
        return Colors.purple;
      case 'order':
        return Colors.green;
      case 'social':
        return Colors.orange;
      case 'nutrition':
        return Colors.teal;
      case 'career':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
