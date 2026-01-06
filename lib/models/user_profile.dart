import 'dart:math';
import 'package:hive/hive.dart';
import 'life_category.dart';

/// User's progression and settings
@HiveType(typeId: 6)
class UserProfile extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  int totalXp; // Cumulative XP earned

  @HiveField(2)
  int level; // Current level (derived from XP)

  @HiveField(3)
  int currentStreak; // Days without missing planned tasks

  @HiveField(4)
  int longestStreak; // Best streak ever

  @HiveField(5)
  DateTime? lastActiveDate; // Last day user completed a task

  @HiveField(6)
  Map<String, double> categoryLevels; // Category -> level progress (0.0-100.0)

  @HiveField(7)
  DateTime createdAt;

  UserProfile({
    required this.userId,
    this.totalXp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    Map<String, double>? categoryLevels,
    required this.createdAt,
  }) : categoryLevels = categoryLevels ?? _initializeCategoryLevels();

  /// Initialize all categories to 0
  static Map<String, double> _initializeCategoryLevels() {
    return {
      for (var category in LifeCategory.values) category.name: 0.0,
    };
  }

  /// Calculate level from total XP
  /// Formula: level = floor(sqrt(totalXp / 100)) + 1
  /// Level 1: 0-99 XP
  /// Level 2: 100-399 XP
  /// Level 3: 400-899 XP
  /// etc.
  int calculateLevel() {
    if (totalXp < 100) return 1;
    return (sqrt(totalXp / 100)).floor() + 1;
  }

  /// XP needed for current level
  int get currentLevelXp {
    if (level == 1) return 0;
    return ((level - 1) * (level - 1)) * 100;
  }

  /// XP needed for next level
  int get nextLevelXp {
    return (level * level) * 100;
  }

  /// Progress percentage to next level (0-100)
  double get levelProgress {
    final currentLevelStart = currentLevelXp;
    final nextLevelStart = nextLevelXp;
    final range = nextLevelStart - currentLevelStart;
    final progress = totalXp - currentLevelStart;
    return (progress / range * 100).clamp(0.0, 100.0);
  }

  /// Add XP and update level
  void addXp(int xp) {
    totalXp += xp;
    level = calculateLevel();
  }

  /// Remove XP (for penalties) and update level
  void removeXp(int xp) {
    totalXp = (totalXp - xp).clamp(0, totalXp);
    level = calculateLevel();
  }

  /// Update category progress
  void updateCategoryLevel(LifeCategory category, double points) {
    final current = categoryLevels[category.name] ?? 0.0;
    categoryLevels[category.name] = (current + points).clamp(0.0, 100.0);
  }

  /// Update streak based on activity
  void updateStreak(DateTime activityDate) {
    final normalizedActivity =
        DateTime(activityDate.year, activityDate.month, activityDate.day);

    if (lastActiveDate == null) {
      // First ever activity
      currentStreak = 1;
      lastActiveDate = normalizedActivity;
    } else {
      final lastNormalized = DateTime(
          lastActiveDate!.year, lastActiveDate!.month, lastActiveDate!.day);
      final daysDiff = normalizedActivity.difference(lastNormalized).inDays;

      if (daysDiff == 0) {
        // Same day, no change
        return;
      } else if (daysDiff == 1) {
        // Consecutive day, increase streak
        currentStreak++;
        lastActiveDate = normalizedActivity;
      } else {
        // Streak broken
        currentStreak = 1;
        lastActiveDate = normalizedActivity;
      }
    }

    // Update longest streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }

  /// Check if streak should be broken (called when missing planned tasks)
  void checkStreakBreak() {
    if (lastActiveDate == null) return;

    final today = DateTime.now();
    final lastNormalized = DateTime(
        lastActiveDate!.year, lastActiveDate!.month, lastActiveDate!.day);
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final daysDiff = normalizedToday.difference(lastNormalized).inDays;

    if (daysDiff > 1) {
      // More than one day passed, break streak
      currentStreak = 0;
    }
  }
}
