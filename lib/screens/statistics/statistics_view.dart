import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/providers/profile_provider.dart';
import 'package:lockin/providers/stats_provider.dart';
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
        final minutes = stats.minutesByCategory[entry.key] ?? 0;
        final hours = (minutes / 60).toStringAsFixed(1);

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
