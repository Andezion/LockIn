import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/models/day_entry.dart';
import 'package:lockin/services/hive_service.dart';

/// Provider for day entry on a specific date
final dayEntryProvider = Provider.family<DayEntry?, DateTime>((ref, date) {
  return HiveService.getDayEntry(date);
});

/// Provider for updating day entries
final dayEntriesNotifier = Provider<DayEntriesNotifier>((ref) {
  return DayEntriesNotifier(ref);
});

class DayEntriesNotifier {
  final Ref ref;

  DayEntriesNotifier(this.ref);

  /// Update journal text for a specific date
  Future<void> updateJournal(DateTime date, String text) async {
    await HiveService.updateJournal(date, text);
    ref.invalidate(dayEntryProvider(date));
  }

  /// Get day entry for a date
  DayEntry? getDayEntry(DateTime date) {
    return HiveService.getDayEntry(date);
  }
}
