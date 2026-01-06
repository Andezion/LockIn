import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/providers/day_entries_provider.dart';

class WellnessSection extends ConsumerStatefulWidget {
  final DateTime date;

  const WellnessSection({super.key, required this.date});

  @override
  ConsumerState<WellnessSection> createState() => _WellnessSectionState();
}

class _WellnessSectionState extends ConsumerState<WellnessSection> {
  double _energyLevel = 3.0;
  double _moodLevel = 3.0;
  double _stressLevel = 3.0;
  double _sleepQuality = 3.0;

  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadWellness();
  }

  @override
  void didUpdateWidget(WellnessSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _loadWellness();
    }
  }

  void _loadWellness() {
    final entry = ref.read(dayEntriesNotifier).getDayEntry(widget.date);
    if (entry?.wellnessScore != null) {
      final avg = entry!.wellnessScore!;
      setState(() {
        _energyLevel = avg;
        _moodLevel = avg;
        _stressLevel = avg;
        _sleepQuality = avg;
        _hasUnsavedChanges = false;
      });
    } else {
      setState(() {
        _energyLevel = 3.0;
        _moodLevel = 3.0;
        _stressLevel = 3.0;
        _sleepQuality = 3.0;
        _hasUnsavedChanges = false;
      });
    }
  }

  double get _averageScore =>
      (_energyLevel + _moodLevel + (6 - _stressLevel) + _sleepQuality) / 4;

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(dayEntryProvider(widget.date));
    final hasScore = entry?.wellnessScore != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (hasScore && !_hasUnsavedChanges)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(entry!.wellnessScore!),
                      borderRadius: BorderRadius.circular(12),
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
              ],
            ),
            const SizedBox(height: 16),
            _buildSlider(
              'Energy Level',
              '⚡',
              _energyLevel,
              (value) => setState(() {
                _energyLevel = value;
                _hasUnsavedChanges = true;
              }),
            ),
            const SizedBox(height: 12),
            _buildSlider(
              'Mood',
              '😊',
              _moodLevel,
              (value) => setState(() {
                _moodLevel = value;
                _hasUnsavedChanges = true;
              }),
            ),
            const SizedBox(height: 12),
            _buildSlider(
              'Stress Level',
              '😰',
              _stressLevel,
              (value) => setState(() {
                _stressLevel = value;
                _hasUnsavedChanges = true;
              }),
              isInverted: true,
            ),
            const SizedBox(height: 12),
            _buildSlider(
              'Sleep Quality',
              '😴',
              _sleepQuality,
              (value) => setState(() {
                _sleepQuality = value;
                _hasUnsavedChanges = true;
              }),
            ),
            if (_hasUnsavedChanges) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _loadWellness();
                        setState(() => _hasUnsavedChanges = false);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saveWellness,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    String emoji,
    double value,
    ValueChanged<double> onChanged, {
    bool isInverted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              '${value.toInt()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: isInverted
                ? _getStressColor(value)
                : Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: isInverted
                ? _getStressColor(value)
                : Theme.of(context).colorScheme.primary,
            overlayColor: (isInverted
                    ? _getStressColor(value)
                    : Theme.of(context).colorScheme.primary)
                .withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.blue;
    if (score >= 2.0) return Colors.orange;
    return Colors.red;
  }

  Color _getStressColor(double stress) {
    if (stress <= 2.0) return Colors.green;
    if (stress <= 3.0) return Colors.blue;
    if (stress <= 4.0) return Colors.orange;
    return Colors.red;
  }

  void _saveWellness() async {
    final score = _averageScore;

    await ref.read(dayEntriesNotifier).updateWellness(widget.date, score);

    setState(() => _hasUnsavedChanges = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Wellness saved: ${score.toStringAsFixed(1)}/5 ${_getScoreEmoji(score)}',
          ),
        ),
      );
    }
  }

  String _getScoreEmoji(double score) {
    if (score >= 4.0) return '🌟';
    if (score >= 3.0) return '😊';
    if (score >= 2.0) return '😐';
    return '😔';
  }
}
