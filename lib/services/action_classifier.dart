import 'package:lockin/models/life_category.dart';

/// Service for automatically classifying actions into categories
class ActionClassifier {
  /// Classify text into a life category based on keywords
  /// Returns null if no confident match is found
  static LifeCategory? classify(String text) {
    final lowerText = text.toLowerCase();

    // Count keyword matches for each category
    final Map<LifeCategory, int> scores = {};

    for (final category in LifeCategory.values) {
      int score = 0;
      for (final keyword in category.keywords) {
        if (lowerText.contains(keyword)) {
          score++;
        }
      }
      if (score > 0) {
        scores[category] = score;
      }
    }

    // Return category with highest score, or null if no matches
    if (scores.isEmpty) return null;

    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Classify with a suggested category as fallback
  static LifeCategory classifyWithDefault(
      String text, LifeCategory defaultCategory) {
    return classify(text) ?? defaultCategory;
  }

  /// Get match confidence score (0-100)
  static int getConfidence(String text, LifeCategory category) {
    final lowerText = text.toLowerCase();
    int matches = 0;

    for (final keyword in category.keywords) {
      if (lowerText.contains(keyword)) {
        matches++;
      }
    }

    // Confidence based on number of keyword matches
    return (matches * 20).clamp(0, 100);
  }
}
