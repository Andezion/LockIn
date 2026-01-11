import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/models/recurrence.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/providers/tasks_provider.dart';
import 'package:lockin/services/action_classifier.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const AddTaskScreen({super.key, required this.initialDate});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  LifeCategory? _selectedCategory;
  int _difficulty = 2;
  int _dailyGoal = 1;
  RecurrenceType _recurrenceType = RecurrenceType.once;
  bool _autoDetectCategory = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Task Title *',
              border: OutlineInputBorder(),
              helperText: 'What do you want to accomplish?',
            ),
            autofocus: true,
            onChanged: _onTitleChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
              helperText: 'Add more details about this task',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<LifeCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Select Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: LifeCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _autoDetectCategory = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _autoDetectCategory ? Icons.auto_fix_high : Icons.edit,
                  color: _autoDetectCategory ? Colors.blue : Colors.grey,
                ),
                tooltip: _autoDetectCategory
                    ? 'Auto-detect enabled'
                    : 'Manual selection',
                onPressed: () {
                  setState(() {
                    _autoDetectCategory = !_autoDetectCategory;
                    if (_autoDetectCategory) {
                      _detectCategory();
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Difficulty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: List.generate(5, (index) {
                  final difficulty = index + 1;
                  return RadioListTile<int>(
                    value: difficulty,
                    groupValue: _difficulty,
                    onChanged: (value) => setState(() => _difficulty = value!),
                    title: Row(
                      children: [
                        Text(difficulty.toString()),
                        const SizedBox(width: 8),
                        ...List.generate(
                          difficulty,
                          (i) => Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Daily Goal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How many times per day?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _dailyGoal > 1
                            ? () => setState(() => _dailyGoal--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Expanded(
                        child: Text(
                          _dailyGoal == 1
                              ? '1 time (complete once)'
                              : '$_dailyGoal times',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: _dailyGoal < 10
                            ? () => setState(() => _dailyGoal++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dailyGoal == 1
                        ? 'Task needs to be completed once'
                        : 'Task needs to be completed $_dailyGoal times per day',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recurrence',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<RecurrenceType>(
            value: _recurrenceType,
            decoration: const InputDecoration(
              labelText: 'How often?',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                  value: RecurrenceType.once, child: Text('One-time')),
              DropdownMenuItem(
                  value: RecurrenceType.daily, child: Text('Daily')),
              DropdownMenuItem(
                  value: RecurrenceType.weekly, child: Text('Weekly')),
            ],
            onChanged: (value) => setState(() => _recurrenceType = value!),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _addTask,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void _onTitleChanged(String value) {
    if (_autoDetectCategory) {
      _detectCategory();
    }
  }

  void _detectCategory() {
    final detected = ActionClassifier.classify(_titleController.text);
    if (detected != null) {
      setState(() => _selectedCategory = detected);
    }
  }

  void _addTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      category: _selectedCategory!,
      difficulty: _difficulty,
      estimatedMinutes: null,
      recurrence: Recurrence(type: _recurrenceType),
      createdAt: widget.initialDate,
      dailyGoal: _dailyGoal,
    );

    await ref.read(tasksProvider.notifier).addTask(task);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully! 🎉')),
      );
    }
  }
}
