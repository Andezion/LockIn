import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lockin/models/action_log.dart';
import 'package:lockin/models/life_category.dart';

class ActivityTimeline extends StatelessWidget {
  final List<ActionLog> actions;

  const ActivityTimeline({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No recent activity',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: actions.take(10).map((action) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(action.category),
              radius: 20,
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            title: Text(action.taskTitle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.category.displayName),
                Text(
                  DateFormat('MMM d, HH:mm').format(action.completedAt),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${action.xpEarned}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
                if (action.durationMinutes != null)
                  Text(
                    '${action.durationMinutes}m',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(LifeCategory category) {
    switch (category) {
      case LifeCategory.sport:
        return Colors.red;
      case LifeCategory.learning:
        return Colors.blue;
      case LifeCategory.discipline:
        return Colors.purple;
      case LifeCategory.order:
        return Colors.green;
      case LifeCategory.social:
        return Colors.orange;
      case LifeCategory.nutrition:
        return Colors.teal;
      case LifeCategory.career:
        return Colors.indigo;
    }
  }
}
