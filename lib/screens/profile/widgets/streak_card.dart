import 'package:flutter/material.dart';
import 'package:lockin/models/user_profile.dart';

class StreakCard extends StatelessWidget {
  final UserProfile profile;

  const StreakCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStreakItem(
                context,
                'Current Streak',
                profile.currentStreak,
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.grey[300],
            ),
            Expanded(
              child: _buildStreakItem(
                context,
                'Best Streak',
                profile.longestStreak,
                Icons.emoji_events,
                Colors.amber[700]!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem(
    BuildContext context,
    String label,
    int days,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          days.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        Text(
          days == 1 ? 'day' : 'days',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
