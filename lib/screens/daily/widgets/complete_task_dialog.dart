import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/providers/action_logs_provider.dart';

class CompleteTaskDialog extends ConsumerStatefulWidget {
  final Task task;

  const CompleteTaskDialog({super.key, required this.task});

  @override
  ConsumerState<CompleteTaskDialog> createState() => _CompleteTaskDialogState();
}

class _CompleteTaskDialogState extends ConsumerState<CompleteTaskDialog> {
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task.estimatedMinutes != null) {
      _durationController.text = widget.task.estimatedMinutes.toString();
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
          onPressed: _complete,
          child: const Text('Complete'),
        ),
      ],
    );
  }

  void _complete() async {
    final durationText = _durationController.text.trim();
    final notes = _notesController.text.trim();

    final duration =
        durationText.isNotEmpty ? int.tryParse(durationText) : null;

    await ref.read(actionLogsProvider.notifier).completeTask(
          task: widget.task,
          durationMinutes: duration,
          notes: notes.isNotEmpty ? notes : null,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.task.title} completed! 🎉')),
      );
    }
  }
}
