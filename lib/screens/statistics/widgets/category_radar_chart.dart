import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lockin/models/life_category.dart';

class CategoryRadarChart extends StatelessWidget {
  final Map<String, double> categoryLevels;

  const CategoryRadarChart({super.key, required this.categoryLevels});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: 1.3,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              tickCount: 5,
              ticksTextStyle:
                  const TextStyle(fontSize: 10, color: Colors.transparent),
              tickBorderData: BorderSide(color: Colors.grey[300]!),
              gridBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
              radarBorderData: BorderSide(color: Colors.grey[400]!, width: 2),
              titleTextStyle: const TextStyle(fontSize: 12),
              titlePositionPercentageOffset: 0.15,
              getTitle: (index, angle) {
                final category = LifeCategory.values[index];
                // Shorten labels for better display
                final label = _getShortLabel(category);
                return RadarChartTitle(text: label);
              },
              dataSets: [
                RadarDataSet(
                  fillColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  borderColor: Theme.of(context).colorScheme.primary,
                  borderWidth: 2,
                  dataEntries: LifeCategory.values.map((category) {
                    final value = categoryLevels[category.name] ?? 0.0;
                    return RadarEntry(value: value);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getShortLabel(LifeCategory category) {
    switch (category) {
      case LifeCategory.sport:
        return 'Sport';
      case LifeCategory.learning:
        return 'Learning';
      case LifeCategory.discipline:
        return 'Discipline';
      case LifeCategory.order:
        return 'Order';
      case LifeCategory.social:
        return 'Social';
      case LifeCategory.nutrition:
        return 'Nutrition';
      case LifeCategory.career:
        return 'Career';
    }
  }
}
