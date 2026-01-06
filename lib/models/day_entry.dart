import 'package:hive/hive.dart';

/// Represents a single day's journal entry and metadata
@HiveType(typeId: 5)
class DayEntry extends HiveObject {
  @HiveField(0)
  DateTime date; // Normalized to start of day

  @HiveField(1)
  String? journalText; // Free-form diary text

  @HiveField(2)
  DateTime? lastModified;

  DayEntry({
    required this.date,
    this.journalText,
    this.lastModified,
  });

  /// Normalize date to start of day
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Create or update journal entry
  void updateJournal(String text) {
    journalText = text;
    lastModified = DateTime.now();
  }
}
