import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockin/providers/action_logs_provider.dart';
import 'package:lockin/providers/day_entries_provider.dart';
import 'package:lockin/providers/tasks_provider.dart';
import 'package:lockin/screens/daily/widgets/calendar_strip.dart';
import 'package:lockin/screens/daily/journal_screen.dart';
import 'package:lockin/screens/daily/widgets/task_item.dart';
import 'package:lockin/screens/daily/add_task_screen.dart';
import 'package:lockin/screens/daily/widgets/completed_actions_list.dart';
import 'package:lockin/screens/daily/widgets/wellness_section.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class DailyView extends ConsumerWidget {
  const DailyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasksForDate = ref.watch(tasksForDateProvider(selectedDate));
    final completedActions = ref.watch(actionLogsForDateProvider(selectedDate));

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
                WellnessSection(date: selectedDate),
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
                _buildSectionHeader(
                    context, 'Completed Actions', Icons.check_circle),
                const SizedBox(height: 8),
                if (completedActions.isEmpty)
                  _buildEmptyState('No actions completed yet')
                else
                  CompletedActionsList(actions: completedActions),
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
}
