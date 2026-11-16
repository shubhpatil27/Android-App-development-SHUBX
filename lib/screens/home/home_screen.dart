import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';
import '../../models/workout.dart';
import '../../services/database_service.dart';
import '../../widgets/stat_card.dart';
import '../training/log_training_screen.dart';
import '../training/workout_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserPreferences preferences;

  const HomeScreen({
    super.key,
    required this.preferences,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  bool _loading = true;

  List<Workout> _allWorkouts = [];

  int _sessionsThisWeek = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  DateTime _startOfWeek(
      DateTime date,
      ) {
    final cleanDate =
    _dateOnly(date);

    return cleanDate.subtract(
      Duration(
        days: cleanDate.weekday - 1,
      ),
    );
  }

  DateTime _endOfWeek(
      DateTime date,
      ) {
    final start =
    _startOfWeek(date);

    return DateTime(
      start.year,
      start.month,
      start.day,
      23,
      59,
      59,
      999,
    ).add(
      const Duration(days: 6),
    );
  }

  int _calculateStreak(
      List<Workout> workouts,
      ) {
    final dates = workouts
        .where(
          (workout) =>
      workout.completed,
    )
        .map(
          (workout) =>
          _dateOnly(workout.date),
    )
        .toSet()
        .toList()
      ..sort(
            (a, b) => b.compareTo(a),
      );

    if (dates.isEmpty) {
      return 0;
    }

    int streak = 1;

    for (int i = 1;
    i < dates.length;
    i++) {
      if (dates[i - 1]
          .difference(dates[i])
          .inDays ==
          1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<void> _loadDashboard() async {
    final workouts =
    await DatabaseService.instance
        .getAllWorkouts();

    final now = DateTime.now();

    final start =
    _startOfWeek(now);

    final end =
    _endOfWeek(now);

    final weekly =
        workouts.where((workout) {
          return workout.completed &&
              !workout.date
                  .isBefore(start) &&
              !workout.date
                  .isAfter(end);
        }).length;

    if (!mounted) return;

    setState(() {
      _allWorkouts = workouts;
      _sessionsThisWeek = weekly;
      _currentStreak =
          _calculateStreak(
            workouts,
          );
      _loading = false;
    });
  }

  Future<void>
  _openTrainingLogger() async {
    final saved =
    await Navigator.of(context)
        .push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            LogTrainingScreen(
              preferences:
              widget.preferences,
            ),
      ),
    );

    if (saved == true) {
      await _loadDashboard();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Training saved.',
          ),
        ),
      );
    }
  }

  Future<void> _openWorkout(
      Workout workout,
      ) async {
    final changed =
    await Navigator.of(context)
        .push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            WorkoutDetailScreen(
              workout: workout,
            ),
      ),
    );

    if (changed == true) {
      await _loadDashboard();
    }
  }

  String _formatDate(
      DateTime date,
      ) {
    final today =
    _dateOnly(DateTime.now());

    final workoutDay =
    _dateOnly(date);

    if (workoutDay == today) {
      return 'Today';
    }

    if (workoutDay ==
        today.subtract(
          const Duration(days: 1),
        )) {
      return 'Yesterday';
    }

    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      ShubXColors.black,
      body: SafeArea(
        child: RefreshIndicator(
          color: ShubXColors.gold,
          backgroundColor:
          ShubXColors.card,
          onRefresh: _loadDashboard,
          child:
          SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              110,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'SHUBX',
                  style: TextStyle(
                    color:
                    ShubXColors.white,
                    fontSize: 26,
                    fontWeight:
                    FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  'DEFINE YOUR X.',
                  style: TextStyle(
                    color:
                    ShubXColors.gold,
                    fontSize: 9,
                    fontWeight:
                    FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(
                    24,
                  ),
                  decoration: BoxDecoration(
                    color:
                    ShubXColors.card,
                    borderRadius:
                    BorderRadius.circular(
                      22,
                    ),
                    border: Border.all(
                      color:
                      ShubXColors.gold,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            Icons
                                .local_fire_department,
                            color:
                            ShubXColors
                                .gold,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'CURRENT STREAK',
                            style:
                            TextStyle(
                              color:
                              ShubXColors
                                  .gold,
                              fontSize: 12,
                              fontWeight:
                              FontWeight
                                  .w700,
                              letterSpacing:
                              1.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        _loading
                            ? '--'
                            : '$_currentStreak',
                        style:
                        const TextStyle(
                          color:
                          ShubXColors
                              .white,
                          fontSize: 62,
                          height: 1,
                          fontWeight:
                          FontWeight
                              .w900,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'TRAINING DAYS',
                        style: TextStyle(
                          color:
                          ShubXColors.grey,
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                StatCard(
                  title: 'THIS WEEK',
                  value:
                  '$_sessionsThisWeek/${widget.preferences.weeklyTarget}',
                  subtitle:
                  'completed sessions',
                  icon: Icons
                      .calendar_today_outlined,
                  highlighted: true,
                ),

                const SizedBox(height: 32),

                const Text(
                  'YOUR X',
                  style: TextStyle(
                    color:
                    ShubXColors.gold,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),
                  decoration: BoxDecoration(
                    color:
                    ShubXColors.card,
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Text(
                        'TRAINING',
                        style: TextStyle(
                          color:
                          ShubXColors.grey,
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget
                            .preferences
                            .trainingTypes
                            .map(
                              (type) => _Tag(
                            label: type,
                          ),
                        )
                            .toList(),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'GOALS',
                        style: TextStyle(
                          color:
                          ShubXColors.grey,
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget
                            .preferences.goals
                            .map(
                              (goal) => _Tag(
                            label: goal,
                            highlighted:
                            true,
                          ),
                        )
                            .toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed:
                  _openTrainingLogger,
                  icon:
                  const Icon(Icons.add),
                  label: const Text(
                    'LOG TRAINING',
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'RECENT ACTIVITY',
                  style: TextStyle(
                    color:
                    ShubXColors.gold,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                if (_loading)
                  const Center(
                    child:
                    CircularProgressIndicator(
                      color:
                      ShubXColors.gold,
                    ),
                  )
                else if (_allWorkouts
                    .isEmpty)
                  const Text(
                    'Your journey starts here.',
                    style: TextStyle(
                      color:
                      ShubXColors.grey,
                    ),
                  )
                else
                  ..._allWorkouts
                      .take(5)
                      .map(
                        (workout) =>
                        _RecentWorkoutCard(
                          workout: workout,
                          dateLabel:
                          _formatDate(
                            workout.date,
                          ),
                          onTap: () {
                            _openWorkout(
                              workout,
                            );
                          },
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool highlighted;

  const _Tag({
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? ShubXColors.gold
            .withValues(alpha: 0.10)
            : ShubXColors.charcoal,
        borderRadius:
        BorderRadius.circular(20),
        border: highlighted
            ? Border.all(
          color:
          ShubXColors.gold,
        )
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: highlighted
              ? ShubXColors.gold
              : ShubXColors.grey,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _RecentWorkoutCard
    extends StatelessWidget {
  final Workout workout;
  final String dateLabel;
  final VoidCallback onTap;

  const _RecentWorkoutCard({
    required this.workout,
    required this.dateLabel,
    required this.onTap,
  });

  IconData get icon {
    switch (workout.type) {
      case 'Weight Training':
        return Icons.fitness_center;

      case 'Running':
        return Icons.directions_run;

      case 'HYROX':
        return Icons.bolt;

      case 'Cardio':
        return workout.title == 'Walking'
            ? Icons.directions_walk
            : Icons.favorite_outline;

      default:
        return Icons
            .check_circle_outline;
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Container(
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
            ShubXColors.card,
            borderRadius:
            BorderRadius.circular(
              16,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                ShubXColors.gold,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      workout.title,
                      style:
                      const TextStyle(
                        color:
                        ShubXColors
                            .white,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      workout.durationMinutes >
                          0
                          ? '${workout.type} • ${workout.durationMinutes} min'
                          : workout.type,
                      style:
                      const TextStyle(
                        color:
                        ShubXColors
                            .grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Text(
                    dateLabel,
                    style:
                    const TextStyle(
                      color:
                      ShubXColors.grey,
                      fontSize: 11,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color:
                    ShubXColors
                        .darkGrey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}