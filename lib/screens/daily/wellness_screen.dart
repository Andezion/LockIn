import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockin/providers/day_entries_provider.dart';

class WellnessScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const WellnessScreen({super.key, required this.date});

  @override
  ConsumerState<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends ConsumerState<WellnessScreen> {
  double _energyLevel = 3.0;
  double _moodLevel = 3.0;
  double _stressLevel = 3.0;
  double _sleepQuality = 3.0;

  @override
  void initState() {
    super.initState();
    _loadWellness();
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
      });
    }
  }

  double get _averageScore =>
      (_energyLevel + _moodLevel + (6 - _stressLevel) + _sleepQuality) / 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wellness - ${DateFormat('MMM d, y').format(widget.date)}'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'How are you feeling today?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rate your well-being on a scale of 1-5',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSlider(
            'Energy Level',
            '⚡',
            'How energetic do you feel?',
            _energyLevel,
            (value) => setState(() => _energyLevel = value),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Mood',
            '😊',
            'How is your mood?',
            _moodLevel,
            (value) => setState(() => _moodLevel = value),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Stress Level',
            '😰',
            'How stressed do you feel?',
            _stressLevel,
            (value) => setState(() => _stressLevel = value),
            isInverted: true,
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Sleep Quality',
            '😴',
            'How well did you sleep?',
            _sleepQuality,
            (value) => setState(() => _sleepQuality = value),
          ),
          const SizedBox(height: 32),
          Card(
            color: _getScoreColor(_averageScore).withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Overall Score',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_averageScore.toStringAsFixed(1)}/5',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(_averageScore),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getScoreText(_averageScore),
                    style: TextStyle(
                      fontSize: 16,
                      color: _getScoreColor(_averageScore),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saveWellness,
            icon: const Icon(Icons.save),
            label: const Text('Save Wellness Check'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    String emoji,
    String description,
    double value,
    ValueChanged<double> onChanged, {
    bool isInverted = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isInverted
                        ? _getStressColor(value)
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${value.toInt()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                trackHeight: 6,
              ),
              child: Slider(
                value: value,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: onChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isInverted ? 'Low' : 'Poor',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  Text(
                    isInverted ? 'High' : 'Great',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  String _getScoreText(double score) {
    if (score >= 4.5) return 'Excellent! 🌟';
    if (score >= 4.0) return 'Great! 😊';
    if (score >= 3.0) return 'Good 👍';
    if (score >= 2.0) return 'Could be better 😐';
    return 'Take care of yourself 😔';
  }

  void _saveWellness() async {
    final score = _averageScore;

    await ref.read(dayEntriesNotifier).updateWellness(widget.date, score);

    if (mounted) {
      Navigator.pop(context);
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
