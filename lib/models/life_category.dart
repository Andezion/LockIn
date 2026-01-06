import 'package:hive/hive.dart';

part 'life_category.g.dart';

/// Represents the main life areas that the user wants to track
@HiveType(typeId: 0)
enum LifeCategory {
  @HiveField(0)
  sport,

  @HiveField(1)
  learning,

  @HiveField(2)
  discipline,

  @HiveField(3)
  order,

  @HiveField(4)
  social,

  @HiveField(5)
  nutrition,

  @HiveField(6)
  career;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case LifeCategory.sport:
        return 'Sport / Physical';
      case LifeCategory.learning:
        return 'Learning / Knowledge';
      case LifeCategory.discipline:
        return 'Discipline / Focus';
      case LifeCategory.order:
        return 'Order / Household';
      case LifeCategory.social:
        return 'Social / Relationships';
      case LifeCategory.nutrition:
        return 'Nutrition / Supplements';
      case LifeCategory.career:
        return 'Career / Future';
    }
  }

  /// Keywords for automatic categorization
  List<String> get keywords {
    switch (this) {
      case LifeCategory.sport:
        return [
          'gym',
          'run',
          'workout',
          'exercise',
          'sport',
          'swim',
          'yoga',
          'fitness',
          'training',
          'cardio'
        ];
      case LifeCategory.learning:
        return [
          'study',
          'read',
          'book',
          'course',
          'learn',
          'udemy',
          'tutorial',
          'research',
          'practice',
          'coding'
        ];
      case LifeCategory.discipline:
        return [
          'meditate',
          'meditation',
          'focus',
          'plan',
          'organize',
          'schedule',
          'routine',
          'habit'
        ];
      case LifeCategory.order:
        return [
          'clean',
          'tidy',
          'organize',
          'laundry',
          'dishes',
          'vacuum',
          'household',
          'chore',
          'declutter'
        ];
      case LifeCategory.social:
        return [
          'call',
          'meet',
          'friend',
          'family',
          'date',
          'party',
          'social',
          'visit',
          'hangout',
          'chat'
        ];
      case LifeCategory.nutrition:
        return [
          'meal',
          'cook',
          'eat',
          'vitamin',
          'supplement',
          'nutrition',
          'diet',
          'food',
          'healthy'
        ];
      case LifeCategory.career:
        return [
          'work',
          'project',
          'career',
          'job',
          'business',
          'portfolio',
          'resume',
          'interview',
          'networking'
        ];
    }
  }
}
