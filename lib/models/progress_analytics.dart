class ProgressAnalytics {
  final int recentSessions;
  final int recentTarget;
  final int previousSessions;

  final int totalSessions;
  final int totalMinutes;

  final int currentStreak;
  final int longestStreak;

  final Map<String, int> recentByType;
  final Map<String, int> overallByType;

  final double totalRunningKm;
  final double recentRunningKm;

  final double? recentAverageRunPaceSecondsPerKm;
  final double? previousAverageRunPaceSecondsPerKm;
  final double? bestRunPaceSecondsPerKm;

  final double totalWalkingKm;
  final int totalEstimatedSteps;

  final int totalWeightSessions;
  final int totalWeightExercises;
  final int totalWeightSets;
  final double totalWeightVolumeKg;

  final int hyroxSessions;
  final int? bestHyroxSeconds;
  final int? latestHyroxSeconds;

  final Map<String, int> bestHyroxStationSeconds;

  const ProgressAnalytics({
    required this.recentSessions,
    required this.recentTarget,
    required this.previousSessions,
    required this.totalSessions,
    required this.totalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.recentByType,
    required this.overallByType,
    required this.totalRunningKm,
    required this.recentRunningKm,
    required this.recentAverageRunPaceSecondsPerKm,
    required this.previousAverageRunPaceSecondsPerKm,
    required this.bestRunPaceSecondsPerKm,
    required this.totalWalkingKm,
    required this.totalEstimatedSteps,
    required this.totalWeightSessions,
    required this.totalWeightExercises,
    required this.totalWeightSets,
    required this.totalWeightVolumeKg,
    required this.hyroxSessions,
    required this.bestHyroxSeconds,
    required this.latestHyroxSeconds,
    required this.bestHyroxStationSeconds,
  });

  double get recentTargetCompletion {
    if (recentTarget <= 0) {
      return 0;
    }

    return recentSessions / recentTarget;
  }

  int get sessionChange {
    return recentSessions - previousSessions;
  }

  double? get runningPaceImprovement {
    final recent = recentAverageRunPaceSecondsPerKm;
    final previous = previousAverageRunPaceSecondsPerKm;

    if (recent == null || previous == null) {
      return null;
    }

    if (previous <= 0) {
      return null;
    }

    // Positive = faster.
    return ((previous - recent) / previous) * 100;
  }
}