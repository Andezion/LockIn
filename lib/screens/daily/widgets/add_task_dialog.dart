import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/models/recurrence.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/providers/tasks_provider.dart';
import 'package:lockin/services/action_classifier.dart';
import 'package:uuid/uuid.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const AddTaskDialog({super.key, required this.initialDate});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedMinutesController = TextEditingController();

  LifeCategory? _selectedCategory;
  int _difficulty = 2;
  RecurrenceType _recurrenceType = RecurrenceType.once;
  bool _autoDetectCategory = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                border: OutlineInputBorder(),
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
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Category selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<LifeCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
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
            const SizedBox(height: 16),

            // Difficulty
            Text('Difficulty', style: Theme.of(context).textTheme.labelLarge),
            Row(
              children: List.generate(5, (index) {
                final difficulty = index + 1;
                return Expanded(
                  child: RadioListTile<int>(
                    value: difficulty,
                    groupValue: _difficulty,
                    onChanged: (value) => setState(() => _difficulty = value!),
                    title: Text(difficulty.toString()),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _estimatedMinutesController,
              decoration: const InputDecoration(
                labelText: 'Estimated Time (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Recurrence
            DropdownButtonFormField<RecurrenceType>(
              value: _recurrenceType,
              decoration: const InputDecoration(
                labelText: 'Repeat',
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _addTask,
          child: const Text('Add Task'),
        ),
      ],
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

    final estimatedMinutes = _estimatedMinutesController.text.trim().isNotEmpty
        ? int.tryParse(_estimatedMinutesController.text.trim())
        : null;

    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      category: _selectedCategory!,
      difficulty: _difficulty,
      estimatedMinutes: estimatedMinutes,
      recurrence: Recurrence(type: _recurrenceType),
      createdAt: widget.initialDate,
    );

    await ref.read(tasksProvider.notifier).addTask(task);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully!')),
      );
    }
  }
}
