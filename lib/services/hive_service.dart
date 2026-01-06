import 'package:hive_flutter/hive_flutter.dart';
import 'package:lockin/models/action_log.dart';
import 'package:lockin/models/day_entry.dart';
import 'package:lockin/models/life_category.dart';
import 'package:lockin/models/recurrence.dart';
import 'package:lockin/models/task.dart';
import 'package:lockin/models/user_profile.dart';

/// Service for managing Hive database operations
class HiveService {
  static const String tasksBox = 'tasks';
  static const String actionLogsBox = 'action_logs';
  static const String dayEntriesBox = 'day_entries';
  static const String profileBox = 'profile';

  static const String profileKey = 'user_profile';

  /// Initialize Hive and register adapters
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(LifeCategoryAdapter());
    Hive.registerAdapter(RecurrenceTypeAdapter());
    Hive.registerAdapter(RecurrenceAdapter());
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(ActionLogAdapter());
    Hive.registerAdapter(DayEntryAdapter());
    Hive.registerAdapter(UserProfileAdapter());

    // Open boxes
    await Hive.openBox<Task>(tasksBox);
    await Hive.openBox<ActionLog>(actionLogsBox);
    await Hive.openBox<DayEntry>(dayEntriesBox);
    await Hive.openBox<UserProfile>(profileBox);

    // Initialize profile if it doesn't exist
    await _initializeProfile();
  }

  static Future<void> _initializeProfile() async {
    final box = Hive.box<UserProfile>(profileBox);
    if (box.get(profileKey) == null) {
      final profile = UserProfile(
        userId: 'default_user',
        createdAt: DateTime.now(),
      );
      await box.put(profileKey, profile);
    }
  }

  // Task operations
  static Box<Task> get tasks => Hive.box<Task>(tasksBox);

  static Future<void> saveTask(Task task) async {
    await tasks.put(task.id, task);
  }

  static Task? getTask(String id) {
    return tasks.get(id);
  }

  static List<Task> getAllActiveTasks() {
    return tasks.values.where((task) => task.isActive).toList();
  }

  static List<Task> getTasksForDate(DateTime date) {
    return getAllActiveTasks()
        .where((task) => task.recurrence.shouldOccurOn(date, task.createdAt))
        .toList();
  }

  static Future<void> deleteTask(String id) async {
    final task = tasks.get(id);
    if (task != null) {
      task.isActive = false;
      await task.save();
    }
  }

  // Action log operations
  static Box<ActionLog> get actionLogs => Hive.box<ActionLog>(actionLogsBox);

  static Future<void> saveActionLog(ActionLog log) async {
    await actionLogs.put(log.id, log);
  }

  static List<ActionLog> getActionLogsForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return actionLogs.values
        .where((log) => _isSameDay(log.completedAt, targetDate))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  static List<ActionLog> getActionLogsInRange(DateTime start, DateTime end) {
    return actionLogs.values
        .where((log) =>
            log.completedAt.isAfter(start.subtract(const Duration(days: 1))) &&
            log.completedAt.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  static List<ActionLog> getAllActionLogs() {
    return actionLogs.values.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  // Day entry operations
  static Box<DayEntry> get dayEntries => Hive.box<DayEntry>(dayEntriesBox);

  static DayEntry? getDayEntry(DateTime date) {
    final key = _dateKey(date);
    return dayEntries.get(key);
  }

  static Future<void> saveDayEntry(DayEntry entry) async {
    final key = _dateKey(entry.date);
    await dayEntries.put(key, entry);
  }

  static Future<void> updateJournal(DateTime date, String text) async {
    final key = _dateKey(date);
    var entry = dayEntries.get(key);

    if (entry == null) {
      entry = DayEntry(
        date: DayEntry.normalizeDate(date),
        journalText: text,
        lastModified: DateTime.now(),
      );
    } else {
      entry.updateJournal(text);
    }

    await dayEntries.put(key, entry);
  }

  // Profile operations
  static Box<UserProfile> get userProfileBox =>
      Hive.box<UserProfile>(profileBox);

  static UserProfile getProfile() {
    return userProfileBox.get(profileKey)!;
  }

  static Future<void> saveProfile(UserProfile profile) async {
    await userProfileBox.put(profileKey, profile);
  }

  // Utility methods
  static String _dateKey(DateTime date) {
    final normalized = DayEntry.normalizeDate(date);
    return '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    await tasks.clear();
    await actionLogs.clear();
    await dayEntries.clear();
    await _initializeProfile();
  }
}
