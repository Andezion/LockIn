import 'package:flutter/material.dart';
import 'package:lockin/models/user_profile.dart';

class LevelProgressCard extends StatelessWidget {
  final UserProfile profile;

  const LevelProgressCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final currentLevelXp = profile.currentLevelXp;
    final nextLevelXp = profile.nextLevelXp;
    final progressXp = profile.totalXp - currentLevelXp;
    final requiredXp = nextLevelXp - currentLevelXp;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Level ${profile.level} → ${profile.level + 1}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: profile.levelProgress / 100,
                minHeight: 24,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // XP numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$progressXp / $requiredXp XP',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${profile.levelProgress.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              'Keep completing tasks to level up!',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
