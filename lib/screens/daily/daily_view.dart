import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/providers/action_logs_provider.dart';
import 'package:lockin/providers/day_entries_provider.dart';
import 'package:lockin/providers/tasks_provider.dart';
import 'package:lockin/screens/daily/widgets/calendar_strip.dart';
import 'package:lockin/screens/daily/widgets/journal_section.dart';
import 'package:lockin/screens/daily/widgets/task_item.dart';
import 'package:lockin/screens/daily/widgets/add_task_dialog.dart';
import 'package:lockin/screens/daily/widgets/completed_actions_list.dart';

/// Provider for selected date
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
          // Calendar strip
          const CalendarStrip(),

          // Main content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Tasks section
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

                // Completed actions
                _buildSectionHeader(
                    context, 'Completed Actions', Icons.check_circle),
                const SizedBox(height: 8),

                if (completedActions.isEmpty)
                  _buildEmptyState('No actions completed yet')
                else
                  CompletedActionsList(actions: completedActions),

                const SizedBox(height: 24),

                // Journal section
                _buildSectionHeader(context, 'Daily Journal', Icons.book),
                const SizedBox(height: 8),
                JournalSection(date: selectedDate),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
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

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        initialDate: ref.read(selectedDateProvider),
      ),
    );
  }
}
