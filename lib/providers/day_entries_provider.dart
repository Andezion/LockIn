import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/day_entry.dart';
import 'package:lockin/services/hive_service.dart';

final dayEntryProvider = Provider.family<DayEntry?, DateTime>((ref, date) {
  return HiveService.getDayEntry(date);
});

final dayEntriesNotifier = Provider<DayEntriesNotifier>((ref) {
  return DayEntriesNotifier(ref);
});

class DayEntriesNotifier {
  final Ref ref;

  DayEntriesNotifier(this.ref);

  Future<void> updateJournal(DateTime date, String text) async {
    await HiveService.updateJournal(date, text);
    ref.invalidate(dayEntryProvider(date));
  }

  Future<void> updateWellness(DateTime date, double score) async {
    await HiveService.updateWellness(date, score);
    ref.invalidate(dayEntryProvider(date));
  }

  DayEntry? getDayEntry(DateTime date) {
    return HiveService.getDayEntry(date);
  }
}
