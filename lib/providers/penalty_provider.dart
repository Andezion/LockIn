import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/providers/profile_provider.dart';
import 'package:lockin/services/penalty_service.dart';

final penaltyProvider = Provider<PenaltyNotifier>((ref) {
  return PenaltyNotifier(ref);
});

class PenaltyNotifier {
  final Ref ref;

  PenaltyNotifier(this.ref);

  Future<PenaltyResult> checkAndApplyPenalties() async {
    final penalties = await PenaltyService.processAllPendingPenalties();

    if (penalties.isEmpty) {
      return PenaltyResult(totalPenalty: 0, penaltiesByDate: {});
    }

    int totalPenalty =
        penalties.values.fold(0, (sum, penalty) => sum + penalty);

    if (totalPenalty > 0) {
      await ref.read(profileProvider.notifier).removeXp(totalPenalty);
    }

    return PenaltyResult(
      totalPenalty: totalPenalty,
      penaltiesByDate: penalties,
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

    final penalty =
        await PenaltyService.processPenaltiesForDate(normalizedYesterday);

    if (penalty > 0) {
      await ref.read(profileProvider.notifier).removeXp(penalty);
    }

    return penalty;
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
      return 'No penalties! All tasks completed! 🎉';
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
