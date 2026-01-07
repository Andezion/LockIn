import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockin/providers/day_entries_provider.dart';
import 'package:lockin/providers/tasks_provider.dart';
import 'package:lockin/screens/daily/widgets/calendar_strip.dart';
import 'package:lockin/screens/daily/journal_screen.dart';
import 'package:lockin/screens/daily/widgets/task_item.dart';
import 'package:lockin/screens/daily/add_task_screen.dart';
import 'package:lockin/screens/daily/wellness_screen.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class DailyView extends ConsumerWidget {
  const DailyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasksForDate = ref.watch(tasksForDateProvider(selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEEE, MMMM d, y').format(selectedDate)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const CalendarStrip(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FilledButton.icon(
                  onPressed: () => _navigateToAddTask(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Task'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Wellness Check', Icons.favorite),
                const SizedBox(height: 8),
                _buildWellnessButton(context, ref, selectedDate),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Planned Tasks', Icons.task_alt),
                const SizedBox(height: 8),
                if (tasksForDate.isEmpty)
                  _buildEmptyState('No tasks planned for this day')
                else
                  ...tasksForDate.map((task) => TaskItem(
                        task: task,
                        date: selectedDate,
                      )),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Daily Journal', Icons.book),
                const SizedBox(height: 8),
                _buildJournalButton(context, ref, selectedDate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWellnessButton(
      BuildContext context, WidgetRef ref, DateTime date) {
    final entry = ref.watch(dayEntryProvider(date));
    final hasWellness = entry?.wellnessScore != null;
    final now = DateTime.now();
    final timeSinceCheck = hasWellness && entry?.lastModified != null
        ? now.difference(entry!.lastModified!)
        : null;

    String getTimeAgo() {
      if (timeSinceCheck == null) return '';

      final hours = timeSinceCheck.inHours;
      final minutes = timeSinceCheck.inMinutes;

      if (hours > 24) {
        final days = timeSinceCheck.inDays;
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      } else if (hours > 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      } else if (minutes > 0) {
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    }

    Color getScoreColor(double score) {
      if (score >= 4.0) return Colors.green;
      if (score >= 3.0) return Colors.blue;
      if (score >= 2.0) return Colors.orange;
      return Colors.red;
    }

    return Card(
      child: InkWell(
        onTap: () => _navigateToWellness(context, date),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                hasWellness ? Icons.favorite : Icons.favorite_border,
                color: hasWellness
                    ? getScoreColor(entry!.wellnessScore!)
                    : Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasWellness
                          ? 'View Wellness Check'
                          : 'Take Wellness Check',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    if (hasWellness) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: getScoreColor(entry!.wellnessScore!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${entry.wellnessScore!.toStringAsFixed(1)}/5',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            getTimeAgo(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        'Track your daily well-being',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalButton(
      BuildContext context, WidgetRef ref, DateTime date) {
    final entry = ref.watch(dayEntryProvider(date));
    final hasEntry =
        entry?.journalText != null && entry!.journalText!.isNotEmpty;

    return Card(
      child: InkWell(
        onTap: () => _navigateToJournal(context, date),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                hasEntry ? Icons.book : Icons.book_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasEntry ? 'View Journal Entry' : 'Add Journal Entry',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    if (hasEntry)
                      Text(
                        entry.journalText!.length > 50
                            ? '${entry.journalText!.substring(0, 50)}...'
                            : entry.journalText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddTask(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          initialDate: ref.read(selectedDateProvider),
        ),
      ),
    );
  }

  void _navigateToJournal(BuildContext context, DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalScreen(date: date),
      ),
    );
  }

  void _navigateToWellness(BuildContext context, DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WellnessScreen(date: date),
      ),
    );
  }
}
