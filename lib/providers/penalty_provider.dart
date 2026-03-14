import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/providers/profile_provider.dart';
import 'package:lockin/providers/tasks_provider.dart';
import 'package:lockin/services/penalty_service.dart';

final penaltyProvider = Provider<PenaltyNotifier>((ref) {
  return PenaltyNotifier(ref);
});

class PenaltyNotifier {
  final Ref ref;

  PenaltyNotifier(this.ref);

  Future<PenaltyResult> checkAndApplyPenalties() async {
    final penaltiesByDate = await PenaltyService.processAllPendingPenalties();

    final rescheduledCount = await PenaltyService.rescheduleOverdueOnceTasks();
    if (rescheduledCount > 0) {
      ref.read(tasksProvider.notifier).reload();
    }

    if (penaltiesByDate.isEmpty) {
      return PenaltyResult(totalPenalty: 0, penaltiesByDate: {});
    }

    int totalPenalty = penaltiesByDate.values
        .fold(0, (sum, day) => sum + day.totalPenalty);

    if (totalPenalty > 0) {
      await ref.read(profileProvider.notifier).removeXp(totalPenalty);

      // Reduce category levels for penalized tasks
      for (final day in penaltiesByDate.values) {
        for (final entry in day.categoryReductions.entries) {
          await ref
              .read(profileProvider.notifier)
              .updateCategoryLevel(entry.key, -entry.value);
        }
      }
    }

    return PenaltyResult(
      totalPenalty: totalPenalty,
      penaltiesByDate: {
        for (final e in penaltiesByDate.entries) e.key: e.value.totalPenalty,
      },
    );
  }

  Future<int> checkYesterdayPenalties() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final normalizedYesterday = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );

    if (PenaltyService.arePenaltiesAppliedForDate(normalizedYesterday)) {
      return 0;
    }

    final result =
        await PenaltyService.processPenaltiesForDate(normalizedYesterday);

    if (result.totalPenalty > 0) {
      await ref.read(profileProvider.notifier).removeXp(result.totalPenalty);
      for (final entry in result.categoryReductions.entries) {
        await ref
            .read(profileProvider.notifier)
            .updateCategoryLevel(entry.key, -entry.value);
      }
    }

    return result.totalPenalty;
  }

  int getTotalPenaltyForPeriod(DateTime start, DateTime end) {
    return PenaltyService.getTotalPenaltyForPeriod(start, end);
  }
}

class PenaltyResult {
  final int totalPenalty;
  final Map<DateTime, int> penaltiesByDate;

  PenaltyResult({
    required this.totalPenalty,
    required this.penaltiesByDate,
  });

  bool get hasPenalties => totalPenalty > 0;

  String formatMessage() {
    if (!hasPenalties) {
      return 'No penalties! All tasks completed!';
    }

    final buffer = StringBuffer();
    buffer.writeln('Penalties for incomplete tasks: -$totalPenalty XP');
    if (penaltiesByDate.length == 1) {
      buffer.writeln('For 1 missed day');
    } else if (penaltiesByDate.length > 1) {
      buffer.writeln('For ${penaltiesByDate.length} missed days');
    }

    return buffer.toString().trim();
  }
}
