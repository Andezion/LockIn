import 'package:hive/hive.dart';

part 'day_entry.g.dart';

@HiveType(typeId: 5)
class DayEntry extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String? journalText;

  @HiveField(2)
  DateTime? lastModified;

  @HiveField(3)
  double? wellnessScore;

  DayEntry({
    required this.date,
    this.journalText,
    this.lastModified,
    this.wellnessScore,
  });

  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void updateJournal(String text) {
    journalText = text;
    lastModified = DateTime.now();
  }

  void updateWellness(double score) {
    wellnessScore = score;
    lastModified = DateTime.now();
  }
}
