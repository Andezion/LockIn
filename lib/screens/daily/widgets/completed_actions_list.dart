import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lockin/models/action_log.dart';

class CompletedActionsList extends StatelessWidget {
  final List<ActionLog> actions;

  const CompletedActionsList({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
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
                  trailing: Column(
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
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ))
          .toList(),
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
