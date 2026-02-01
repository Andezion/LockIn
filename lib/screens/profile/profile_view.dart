import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/providers/profile_provider.dart';
import 'package:lockin/providers/penalty_provider.dart';
import 'package:lockin/screens/profile/widgets/level_progress_card.dart';
import 'package:lockin/screens/profile/widgets/streak_card.dart';
import 'package:lockin/screens/profile/widgets/category_levels_list.dart';
import 'package:lockin/screens/profile/widgets/penalty_info_card.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    'L${profile.level}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Level ${profile.level}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${profile.totalXp} Total XP',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          LevelProgressCard(profile: profile),
          const SizedBox(height: 16),
          StreakCard(profile: profile),
          const SizedBox(height: 16),
          const PenaltyInfoCard(),
          const SizedBox(height: 24),
          Text(
            'Category Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          CategoryLevelsList(categoryLevels: profile.categoryLevels),
          const SizedBox(height: 24),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.sync, color: Colors.blue),
          title: const Text('Check Penalties'),
          subtitle: const Text('Recalculate penalties for incomplete tasks'),
          onTap: () => _checkPenalties(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          subtitle: const Text('Version 1.0.0'),
          onTap: () => _showAboutDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title:
              const Text('Reset All Data', style: TextStyle(color: Colors.red)),
          subtitle: const Text('This cannot be undone'),
          onTap: () => _showResetDialog(context, ref),
        ),
      ],
    );
  }

  void _checkPenalties(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await ref.read(penaltyProvider).checkAndApplyPenalties();

      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  result.hasPenalties
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle,
                  color: result.hasPenalties ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                const Text('Check Completed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.hasPenalties) ...[
                  Text('Penalties Detected:'),
                  const SizedBox(height: 8),
                  Text(
                    '-${result.totalPenalty} XP',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.penaltiesByDate.length == 1
                        ? 'For 1 missed day'
                        : 'For ${result.penaltiesByDate.length} missed days',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ] else ...[
                  Text('Great! No incomplete tasks!'),
                ],
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'LockIn',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.emoji_events, size: 48),
      children: [
        const Text(
          'Track your life progress as an RPG-like system. '
          'Complete tasks, earn XP, level up, and evolve your life attributes.',
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all your tasks, logs, and progress. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Data reset functionality - implement with HiveService'),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
