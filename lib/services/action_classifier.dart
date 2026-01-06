import 'package:lockin/models/life_category.dart';

class ActionClassifier {
  static LifeCategory? classify(String text) {
    final lowerText = text.toLowerCase();

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

    if (scores.isEmpty) return null;

    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static LifeCategory classifyWithDefault(
      String text, LifeCategory defaultCategory) {
    return classify(text) ?? defaultCategory;
  }

  static int getConfidence(String text, LifeCategory category) {
    final lowerText = text.toLowerCase();
    int matches = 0;

    for (final keyword in category.keywords) {
      if (lowerText.contains(keyword)) {
        matches++;
      }
    }

    return (matches * 20).clamp(0, 100);
  }
}
