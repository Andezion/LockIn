import 'package:flutter/material.dart';
import 'package:lockin/models/life_category.dart';

class CategoryLevelsList extends StatelessWidget {
  final Map<String, double> categoryLevels;

  const CategoryLevelsList({super.key, required this.categoryLevels});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: LifeCategory.values.map((category) {
        final level = categoryLevels[category.name] ?? 0.0;
        final color = _getCategoryColor(category);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${level.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: level / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(LifeCategory category) {
    switch (category) {
      case LifeCategory.sport:
        return Colors.red;
      case LifeCategory.learning:
        return Colors.blue;
      case LifeCategory.discipline:
        return Colors.purple;
      case LifeCategory.order:
        return Colors.green;
      case LifeCategory.social:
        return Colors.orange;
      case LifeCategory.nutrition:
        return Colors.teal;
      case LifeCategory.career:
        return Colors.indigo;
    }
  }
}
