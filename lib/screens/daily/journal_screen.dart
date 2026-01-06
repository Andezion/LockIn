import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockin/providers/day_entries_provider.dart';

class JournalScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const JournalScreen({super.key, required this.date});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _controller = TextEditingController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadJournal();
  }

  void _loadJournal() {
    final entry = ref.read(dayEntriesNotifier).getDayEntry(widget.date);
    _controller.text = entry?.journalText ?? '';
    _hasChanges = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(dayEntryProvider(widget.date));
    final hasExistingEntry =
        entry?.journalText != null && entry!.journalText!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Journal - ${DateFormat('MMM d, y').format(widget.date)}'),
        centerTitle: true,
        actions: [
          if (hasExistingEntry)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteDialog,
              tooltip: 'Delete entry',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts for today...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) {
                  if (!_hasChanges) {
                    setState(() => _hasChanges = true);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_hasChanges)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _loadJournal();
                        setState(() => _hasChanges = false);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saveJournal,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            if (!_hasChanges)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _saveJournal() async {
    final text = _controller.text.trim();

    await ref.read(dayEntriesNotifier).updateJournal(
          widget.date,
          text,
        );

    setState(() => _hasChanges = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal saved ✓')),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal Entry'),
        content:
            const Text('Are you sure you want to delete this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(dayEntriesNotifier).updateJournal(
                    widget.date,
                    '',
                  );
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Journal entry deleted')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
