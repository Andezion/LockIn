import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/providers/action_logs_provider.dart';
import 'package:lockin/providers/profile_provider.dart';
import 'package:lockin/providers/stats_provider.dart';
import 'package:lockin/services/hive_service.dart';
import 'package:lockin/screens/statistics/widgets/category_radar_chart.dart';
import 'package:lockin/screens/statistics/widgets/stats_overview.dart';

enum StatsPeriod { week, month, all }

class StatisticsView extends ConsumerStatefulWidget {
  const StatisticsView({super.key});

  @override
  ConsumerState<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView> {
  StatsPeriod _selectedPeriod = StatsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final stats = _selectedPeriod == StatsPeriod.week
        ? ref.watch(weeklyStatsProvider)
        : ref.watch(monthlyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(profileProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear statistics',
            onPressed: () => _showClearConfirmation(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          StatsOverview(stats: stats),
          const SizedBox(height: 24),
          Text(
            'Life Balance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          CategoryRadarChart(categoryLevels: profile.categoryLevels),
          const SizedBox(height: 24),
          Text(
            'Activity Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildCategoryBreakdown(stats),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Statistics'),
        content: const Text(
          'This will delete all action logs, day entries, and reset your profile (XP, levels, streaks). Tasks will be kept.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await HiveService.actionLogs.clear();
              await HiveService.dayEntries.clear();
              await HiveService.clearAllData();
              ref.read(actionLogsProvider.notifier).reload();
              ref.read(profileProvider.notifier).reload();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<StatsPeriod>(
      segments: const [
        ButtonSegment(
          value: StatsPeriod.week,
          label: Text('Week'),
          icon: Icon(Icons.calendar_view_week),
        ),
        ButtonSegment(
          value: StatsPeriod.month,
          label: Text('Month'),
          icon: Icon(Icons.calendar_month),
        ),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<StatsPeriod> newSelection) {
        setState(() {
          _selectedPeriod = newSelection.first;
        });
      },
    );
  }

  Widget _buildCategoryBreakdown(StatsData stats) {
    if (stats.actionsByCategory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No activity data for this period',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final sortedCategories = stats.actionsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.map((entry) {
        final category = LifeCategory.values.firstWhere(
          (c) => c.name == entry.key.name,
        );
        final count = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(category),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(category.displayName),
            subtitle: null,
            trailing: SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: count / stats.totalActions,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(_getCategoryColor(category)),
              ),
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
