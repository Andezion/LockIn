import 'dart:math';

class XPCalculator {
  static const int baseXp = 10;
  static const int xpPerMinute = 2;

  static const Map<int, double> difficultyMultipliers = {
    1: 0.5,
    2: 1.0,
    3: 1.5,
    4: 2.0,
    5: 3.0,
  };

  static const Map<int, double> streakBonuses = {
    7: 1.1,
    14: 1.2,
    30: 1.3,
    60: 1.4,
    100: 1.5,
  };

  static int calculateTaskXp({
    required int difficulty,
    int? durationMinutes,
    int currentStreak = 0,
  }) {
    final difficultyMultiplier = difficultyMultipliers[difficulty] ?? 1.0;
    double xp = baseXp * difficultyMultiplier;

    if (durationMinutes != null && durationMinutes > 0) {
      xp += durationMinutes * xpPerMinute;
    }

    final streakMultiplier = _getStreakMultiplier(currentStreak);
    xp *= streakMultiplier;

    return xp.round().clamp(1, 10000);
  }

  static int calculateMissedTaskPenalty(int difficulty) {
    final difficultyMultiplier = difficultyMultipliers[difficulty] ?? 1.0;
    final penalty = (baseXp * difficultyMultiplier * 0.5).round();
    return penalty.clamp(1, 100);
  }

  static double calculateCategoryProgress({
    required int difficulty,
    int? durationMinutes,
  }) {
    final difficultyMultiplier = difficultyMultipliers[difficulty] ?? 1.0;
    double points = 1.0 * difficultyMultiplier;

    if (durationMinutes != null && durationMinutes > 0) {
      points += durationMinutes / 60.0;
    }

    return points.clamp(0.1, 10.0);
  }

  static double _getStreakMultiplier(int streak) {
    double multiplier = 1.0;

    for (final entry in streakBonuses.entries) {
      if (streak >= entry.key) {
        multiplier = entry.value;
      }
    }

    return multiplier;
  }

  static int calculateLevel(int totalXp) {
    if (totalXp < 100) return 1;
    return (sqrt(totalXp / 100)).floor() + 1;
  }

  static int getXpForLevel(int level) {
    if (level <= 1) return 0;
    return ((level - 1) * (level - 1)) * 100;
  }

  static ({int current, int next}) getXpRange(int level) {
    return (
      current: getXpForLevel(level),
      next: getXpForLevel(level + 1),
    );
  }
}
