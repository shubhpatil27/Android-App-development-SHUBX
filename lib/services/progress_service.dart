import '../models/progress_analytics.dart';
import '../models/user_preferences.dart';
import '../models/workout.dart';
import 'database_service.dart';

class ProgressService {
  ProgressService._();

  static final ProgressService instance =
  ProgressService._();

  static const List<String> _hyroxStations = [
    'SkiErg',
    'Sled Push',
    'Sled Pull',
    'Burpee Broad Jumps',
    'Rowing',
    'Farmers Carry',
    'Sandbag Lunges',
    'Wall Balls',
  ];

  Future<ProgressAnalytics> calculate(
      UserPreferences preferences,
      ) async {
    final workouts =
    await DatabaseService.instance
        .getAllWorkouts();

    final completed = workouts
        .where(
          (workout) => workout.completed,
    )
        .toList();

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    // Current Progress = last 14 days.
    final recentStart = today.subtract(
      const Duration(days: 13),
    );

    // Previous equivalent 14-day window.
    final previousStart = today.subtract(
      const Duration(days: 27),
    );

    final previousEnd = today.subtract(
      const Duration(days: 14),
    );

    final recent = completed.where(
          (workout) {
        final date = _dateOnly(
          workout.date,
        );

        return !date.isBefore(
          recentStart,
        );
      },
    ).toList();

    final previous = completed.where(
          (workout) {
        final date = _dateOnly(
          workout.date,
        );

        return !date.isBefore(
          previousStart,
        ) &&
            !date.isAfter(
              previousEnd,
            );
      },
    ).toList();

    final recentByType =
    _countByType(recent);

    final overallByType =
    _countByType(completed);

    final streaks =
    _calculateStreaks(
      completed,
      today,
    );

    // ==============================================
    // RUNNING
    // ==============================================

    double totalRunningMeters = 0;
    double recentRunningMeters = 0;

    final recentRunPaces =
    <double>[];

    final previousRunPaces =
    <double>[];

    final allRunPaces =
    <double>[];

    for (final workout in completed) {
      if (workout.id == null ||
          workout.type != 'Running') {
        continue;
      }

      final session =
      await DatabaseService.instance
          .getRunningSessionForWorkout(
        workout.id!,
      );

      if (session == null ||
          session.distanceMeters <= 0) {
        continue;
      }

      totalRunningMeters +=
          session.distanceMeters;

      final km =
          session.distanceMeters / 1000;

      final paceSecondsPerKm =
          session.durationSeconds / km;

      allRunPaces.add(
        paceSecondsPerKm,
      );

      final date =
      _dateOnly(workout.date);

      if (!date.isBefore(
        recentStart,
      )) {
        recentRunningMeters +=
            session.distanceMeters;

        recentRunPaces.add(
          paceSecondsPerKm,
        );
      }

      if (!date.isBefore(
        previousStart,
      ) &&
          !date.isAfter(
            previousEnd,
          )) {
        previousRunPaces.add(
          paceSecondsPerKm,
        );
      }
    }

    // ==============================================
    // WALKING
    // ==============================================

    double totalWalkingMeters = 0;
    int totalEstimatedSteps = 0;

    for (final workout in completed) {
      if (workout.id == null ||
          workout.type != 'Cardio' ||
          workout.title != 'Walking') {
        continue;
      }

      final session =
      await DatabaseService.instance
          .getWalkingSessionForWorkout(
        workout.id!,
      );

      if (session == null) {
        continue;
      }

      totalWalkingMeters +=
          session.distanceMeters;

      totalEstimatedSteps +=
          session.estimatedSteps;
    }

    // ==============================================
    // WEIGHT TRAINING
    // ==============================================

    int weightSessions = 0;
    int weightExercises = 0;
    int weightSets = 0;

    double totalVolumeKg = 0;

    for (final workout in completed) {
      if (workout.id == null ||
          workout.type !=
              'Weight Training') {
        continue;
      }

      weightSessions++;

      final exercises =
      await DatabaseService.instance
          .getExercisesForWorkout(
        workout.id!,
      );

      weightExercises +=
          exercises.length;

      for (final exercise in exercises) {
        if (exercise.id == null) {
          continue;
        }

        final sets =
        await DatabaseService.instance
            .getSetsForWorkoutExercise(
          exercise.id!,
        );

        weightSets += sets.length;

        for (final set in sets) {
          final weight =
              set.weightKg;

          final reps =
              set.reps;

          if (weight != null &&
              reps != null) {
            totalVolumeKg +=
                weight * reps;
          }
        }
      }
    }

    // ==============================================
    // HYROX
    // ==============================================

    int hyroxSessions = 0;

    int? bestHyroxSeconds;
    int? latestHyroxSeconds;

    DateTime? latestHyroxDate;

    final bestStations =
    <String, int>{};

    for (final workout in completed) {
      if (workout.id == null ||
          workout.type != 'HYROX') {
        continue;
      }

      hyroxSessions++;

      // Full simulation first.
      final full =
      await DatabaseService.instance
          .getHyroxSessionForWorkout(
        workout.id!,
      );

      if (full != null) {
        final total =
            full.totalSeconds;

        if (bestHyroxSeconds == null ||
            total <
                bestHyroxSeconds) {
          bestHyroxSeconds =
              total;
        }

        if (latestHyroxDate == null ||
            workout.date.isAfter(
              latestHyroxDate,
            )) {
          latestHyroxDate =
              workout.date;

          latestHyroxSeconds =
              total;
        }

        for (int i = 0;
        i <
            full.stationTimesSeconds
                .length;
        i++) {
          final station =
          _hyroxStations[i];

          final time =
          full.stationTimesSeconds[i];

          final existing =
          bestStations[station];

          if (existing == null ||
              time < existing) {
            bestStations[station] =
                time;
          }
        }

        continue;
      }

      // Custom training still counts as HYROX
      // sessions, but not toward full-race PB.
      await DatabaseService.instance
          .getHyroxTrainingSessionForWorkout(
        workout.id!,
      );
    }

    // ==============================================
    // TOTAL TRAINING TIME
    // ==============================================

    final totalMinutes =
    completed.fold<int>(
      0,
          (sum, workout) =>
      sum + workout.durationMinutes,
    );

    // Weekly target × 2 because current
    // progress covers 14 days.
    final recentTarget =
        preferences.weeklyTarget * 2;

    return ProgressAnalytics(
      recentSessions:
      recent.length,
      recentTarget:
      recentTarget,
      previousSessions:
      previous.length,

      totalSessions:
      completed.length,
      totalMinutes:
      totalMinutes,

      currentStreak:
      streaks.current,
      longestStreak:
      streaks.longest,

      recentByType:
      recentByType,
      overallByType:
      overallByType,

      totalRunningKm:
      totalRunningMeters / 1000,
      recentRunningKm:
      recentRunningMeters / 1000,

      recentAverageRunPaceSecondsPerKm:
      _average(
        recentRunPaces,
      ),

      previousAverageRunPaceSecondsPerKm:
      _average(
        previousRunPaces,
      ),

      bestRunPaceSecondsPerKm:
      allRunPaces.isEmpty
          ? null
          : allRunPaces.reduce(
            (a, b) =>
        a < b ? a : b,
      ),

      totalWalkingKm:
      totalWalkingMeters / 1000,

      totalEstimatedSteps:
      totalEstimatedSteps,

      totalWeightSessions:
      weightSessions,
      totalWeightExercises:
      weightExercises,
      totalWeightSets:
      weightSets,
      totalWeightVolumeKg:
      totalVolumeKg,

      hyroxSessions:
      hyroxSessions,
      bestHyroxSeconds:
      bestHyroxSeconds,
      latestHyroxSeconds:
      latestHyroxSeconds,

      bestHyroxStationSeconds:
      bestStations,
    );
  }

  DateTime _dateOnly(
      DateTime date,
      ) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  Map<String, int> _countByType(
      List<Workout> workouts,
      ) {
    final result =
    <String, int>{};

    for (final workout in workouts) {
      String type =
          workout.type;

      if (type ==
          'Cardio & Endurance') {
        type = 'Cardio';
      }

      result[type] =
          (result[type] ?? 0) + 1;
    }

    return result;
  }

  double? _average(
      List<double> values,
      ) {
    if (values.isEmpty) {
      return null;
    }

    final total =
    values.fold<double>(
      0,
          (sum, value) =>
      sum + value,
    );

    return total / values.length;
  }

  _StreakResult _calculateStreaks(
      List<Workout> workouts,
      DateTime today,
      ) {
    if (workouts.isEmpty) {
      return const _StreakResult(
        current: 0,
        longest: 0,
      );
    }

    final dates = workouts
        .map(
          (workout) =>
          _dateOnly(
            workout.date,
          ),
    )
        .toSet()
        .toList()
      ..sort();

    int longest = 1;
    int running = 1;

    for (int i = 1;
    i < dates.length;
    i++) {
      final difference =
          dates[i]
              .difference(
            dates[i - 1],
          )
              .inDays;

      if (difference == 1) {
        running++;

        if (running > longest) {
          longest = running;
        }
      } else {
        running = 1;
      }
    }

    // Current streak may continue from today
    // OR yesterday.
    final set = dates.toSet();

    DateTime cursor = today;

    if (!set.contains(cursor)) {
      cursor = today.subtract(
        const Duration(days: 1),
      );

      if (!set.contains(cursor)) {
        return _StreakResult(
          current: 0,
          longest: longest,
        );
      }
    }

    int current = 0;

    while (set.contains(cursor)) {
      current++;

      cursor = cursor.subtract(
        const Duration(days: 1),
      );
    }

    return _StreakResult(
      current: current,
      longest: longest,
    );
  }
}

class _StreakResult {
  final int current;
  final int longest;

  const _StreakResult({
    required this.current,
    required this.longest,
  });
}