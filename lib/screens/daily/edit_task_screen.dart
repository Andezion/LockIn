import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/models/recurrence.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/providers/tasks_provider.dart';
import 'package:lockin/services/action_classifier.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _estimatedMinutesController;

  LifeCategory? _selectedCategory;
  int _difficulty = 2;
  int _dailyGoal = 1;
  RecurrenceType _recurrenceType = RecurrenceType.once;
  bool _autoDetectCategory = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description ?? '');
    _estimatedMinutesController = TextEditingController(
        text: widget.task.estimatedMinutes?.toString() ?? '');
    _selectedCategory = widget.task.category;
    _difficulty = widget.task.difficulty;
    _dailyGoal = widget.task.dailyGoal;
    _recurrenceType = widget.task.recurrence.type;
    _autoDetectCategory = false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
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
            onPressed: _saveTask,
            icon: const Icon(Icons.save),
            label: const Text('Save Changes'),
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

  void _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    final estimatedMinutes = _estimatedMinutesController.text.trim().isNotEmpty
        ? int.tryParse(_estimatedMinutesController.text.trim())
        : null;

    final updated = Task(
      id: widget.task.id,
      title: title,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      category: _selectedCategory!,
      difficulty: _difficulty,
      estimatedMinutes: estimatedMinutes,
      recurrence: Recurrence(type: _recurrenceType),
      createdAt: widget.task.createdAt,
      dailyGoal: _dailyGoal,
    );

    await ref.read(tasksProvider.notifier).updateTask(updated);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated')),
      );
    }
  }
}
