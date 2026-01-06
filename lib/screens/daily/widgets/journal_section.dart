import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/providers/day_entries_provider.dart';

class JournalSection extends ConsumerStatefulWidget {
  final DateTime date;

  const JournalSection({super.key, required this.date});

  @override
  ConsumerState<JournalSection> createState() => _JournalSectionState();
}

class _JournalSectionState extends ConsumerState<JournalSection> {
  final _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadJournal();
  }

  @override
  void didUpdateWidget(JournalSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _loadJournal();
    }
  }

  void _loadJournal() {
    final entry = ref.read(dayEntriesNotifier).getDayEntry(widget.date);
    _controller.text = entry?.journalText ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts for today...',
                border: InputBorder.none,
              ),
              maxLines: 6,
              onChanged: (_) {
                if (!_isEditing) {
                  setState(() => _isEditing = true);
                }
              },
            ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _loadJournal();
                      setState(() => _isEditing = false);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saveJournal,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveJournal() async {
    await ref.read(dayEntriesNotifier).updateJournal(
          widget.date,
          _controller.text,
        );

    setState(() => _isEditing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal saved')),
      );
    }
  }
}
