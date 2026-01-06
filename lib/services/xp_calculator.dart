import 'dart:math';

/// Service for calculating XP and level progression
class XPCalculator {
  // Base XP values
  static const int baseXp = 10;
  static const int xpPerMinute = 2;

  // Difficulty multipliers
  static const Map<int, double> difficultyMultipliers = {
    1: 0.5, // Very easy
    2: 1.0, // Easy
    3: 1.5, // Medium
    4: 2.0, // Hard
    5: 3.0, // Very hard
  };

  // Streak bonuses
  static const Map<int, double> streakBonuses = {
    7: 1.1, // +10% at 7 days
    14: 1.2, // +20% at 14 days
    30: 1.3, // +30% at 30 days
    60: 1.4, // +40% at 60 days
    100: 1.5, // +50% at 100 days
  };

  /// Calculate XP earned for completing a task
  static int calculateTaskXp({
    required int difficulty,
    int? durationMinutes,
    int currentStreak = 0,
  }) {
    // Base XP from difficulty
    final difficultyMultiplier = difficultyMultipliers[difficulty] ?? 1.0;
    double xp = baseXp * difficultyMultiplier;

    // Add XP for time spent
    if (durationMinutes != null && durationMinutes > 0) {
      xp += durationMinutes * xpPerMinute;
    }

    // Apply streak bonus
    final streakMultiplier = _getStreakMultiplier(currentStreak);
    xp *= streakMultiplier;

    return xp.round().clamp(1, 10000);
  }

  /// Calculate XP penalty for missing a planned task
  static int calculateMissedTaskPenalty(int difficulty) {
    final difficultyMultiplier = difficultyMultipliers[difficulty] ?? 1.0;
    final penalty = (baseXp * difficultyMultiplier * 0.5).round();
    return penalty.clamp(1, 100);
  }

  /// Calculate category progress points (0-100 scale)
  static double calculateCategoryProgress({
    required int difficulty,
    int? durationMinutes,
  }) {
    final difficultyMultiplier = difficultyMultipliers[difficulty] ?? 1.0;
    double points = 1.0 * difficultyMultiplier;

    // Additional points for longer activities
    if (durationMinutes != null && durationMinutes > 0) {
      points += durationMinutes / 60.0; // 1 point per hour
    }

    return points.clamp(0.1, 10.0);
  }

  /// Get streak multiplier based on current streak
  static double _getStreakMultiplier(int streak) {
    double multiplier = 1.0;

    for (final entry in streakBonuses.entries) {
      if (streak >= entry.key) {
        multiplier = entry.value;
      }
    }

    return multiplier;
  }

  /// Get level from total XP
  /// Formula: level = floor(sqrt(totalXp / 100)) + 1
  static int calculateLevel(int totalXp) {
    if (totalXp < 100) return 1;
    return (sqrt(totalXp / 100)).floor() + 1;
  }

  /// Get XP required for a specific level
  static int getXpForLevel(int level) {
    if (level <= 1) return 0;
    return ((level - 1) * (level - 1)) * 100;
  }

  /// Get XP range for current level
  static ({int current, int next}) getXpRange(int level) {
    return (
      current: getXpForLevel(level),
      next: getXpForLevel(level + 1),
    );
  }
}
