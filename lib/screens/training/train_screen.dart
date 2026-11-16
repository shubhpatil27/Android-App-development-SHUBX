import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';
import '../../models/workout.dart';
import '../../services/database_service.dart';
import 'log_training_screen.dart';
import 'training_history_screen.dart';
import 'workout_detail_screen.dart';

class TrainScreen extends StatefulWidget {
  final UserPreferences preferences;

  const TrainScreen({
    super.key,
    required this.preferences,
  });

  @override
  State<TrainScreen> createState() =>
      _TrainScreenState();
}

class _TrainScreenState
    extends State<TrainScreen> {
  bool _loading = true;

  List<Workout> _workouts = [];

  @override
  void initState() {
    super.initState();

    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workouts =
    await DatabaseService.instance
        .getAllWorkouts();

    if (!mounted) return;

    setState(() {
      _workouts = workouts;
      _loading = false;
    });
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

  DateTime _startOfWeek(
      DateTime date,
      ) {
    final clean =
    _dateOnly(date);

    return clean.subtract(
      Duration(
        days: clean.weekday - 1,
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

  List<Workout> get _thisWeekWorkouts {
    final now = DateTime.now();

    final start =
    _startOfWeek(now);

    final end =
    _endOfWeek(now);

    return _workouts.where(
          (workout) {
        return workout.completed &&
            !workout.date
                .isBefore(start) &&
            !workout.date
                .isAfter(end);
      },
    ).toList();
  }

  Future<void> _logTraining() async {
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
      await _loadWorkouts();

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
      await _loadWorkouts();
    }
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
        const TrainingHistoryScreen(),
      ),
    );

    // Something may have been edited/deleted
    // from Workout Details inside History.
    await _loadWorkouts();
  }

  IconData _iconForType(
      Workout workout,
      ) {
    switch (workout.type) {
      case 'Weight Training':
        return Icons.fitness_center;

      case 'Running':
        return Icons.directions_run;

      case 'HYROX':
        return Icons.bolt;

      case 'Cardio':
      case 'Cardio & Endurance':
        if (workout.title ==
            'Walking') {
          return Icons.directions_walk;
        }

        if (workout.title ==
            'Cycling') {
          return Icons.directions_bike;
        }

        if (workout.title ==
            'Swimming') {
          return Icons.pool;
        }

        if (workout.title ==
            'Hiking') {
          return Icons.hiking;
        }

        if (workout.title ==
            'Rowing') {
          return Icons.rowing;
        }

        return Icons.favorite_outline;

      default:
        return Icons.check_circle_outline;
    }
  }

  IconData _trainingTypeIcon(
      String type,
      ) {
    switch (type) {
      case 'Weight Training':
        return Icons.fitness_center;

      case 'Running':
        return Icons.directions_run;

      case 'HYROX':
        return Icons.bolt;

      case 'Cardio':
      case 'Cardio & Endurance':
        return Icons.favorite_outline;

      default:
        return Icons.check_circle_outline;
    }
  }

  String _dayLabel(
      DateTime date,
      ) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    final today =
    _dateOnly(DateTime.now());

    final workoutDay =
    _dateOnly(date);

    if (workoutDay == today) {
      return 'Today';
    }

    return days[
    date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final weeklyWorkouts =
        _thisWeekWorkouts;

    final target =
        widget.preferences.weeklyTarget;

    final completed =
        weeklyWorkouts.length;

    final remaining =
        target - completed;

    return Scaffold(
      backgroundColor:
      ShubXColors.black,
      body: SafeArea(
        child: RefreshIndicator(
          color: ShubXColors.gold,
          backgroundColor:
          ShubXColors.card,
          onRefresh: _loadWorkouts,
          child: ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(
              20,
              24,
              20,
              110,
            ),
            children: [
              const Text(
                'TRAIN',
                style: TextStyle(
                  color:
                  ShubXColors.white,
                  fontSize: 30,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Whatever your X is, log the work.',
                style: TextStyle(
                  color:
                  ShubXColors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _logTraining,
                icon:
                const Icon(Icons.add),
                label:
                const Text(
                  'LOG TRAINING',
                ),
              ),

              const SizedBox(height: 34),

              const Text(
                'YOUR TRAINING',
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

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget
                    .preferences
                    .trainingTypes
                    .map(
                      (type) {
                    return Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        ShubXColors.card,
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                        border:
                        Border.all(
                          color:
                          ShubXColors
                              .darkGrey,
                        ),
                      ),
                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Icon(
                            _trainingTypeIcon(
                              type,
                            ),
                            color:
                            ShubXColors
                                .gold,
                            size: 16,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            type,
                            style:
                            const TextStyle(
                              color:
                              ShubXColors
                                  .white,
                              fontSize:
                              12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),

              const SizedBox(height: 36),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'THIS WEEK — $completed/$target',
                      style:
                      const TextStyle(
                        color:
                        ShubXColors.gold,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w700,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed:
                    _openHistory,
                    child:
                    const Text(
                      'VIEW ALL',
                      style:
                      TextStyle(
                        color:
                        ShubXColors.gold,
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              if (!_loading) ...[
                const SizedBox(height: 2),

                if (remaining > 0)
                  Text(
                    '$remaining session${remaining == 1 ? '' : 's'} remaining this week',
                    style:
                    const TextStyle(
                      color:
                      ShubXColors.grey,
                      fontSize: 11,
                    ),
                  )
                else if (completed >= target)
                  const Text(
                    'Weekly target complete ✓',
                    style:
                    TextStyle(
                      color:
                      ShubXColors.grey,
                      fontSize: 11,
                    ),
                  ),
              ],

              const SizedBox(height: 14),

              if (_loading)
                const Padding(
                  padding:
                  EdgeInsets.all(30),
                  child: Center(
                    child:
                    CircularProgressIndicator(
                      color:
                      ShubXColors.gold,
                    ),
                  ),
                )
              else if (weeklyWorkouts
                  .isEmpty)
                _buildEmptyWeek()
              else
                ...weeklyWorkouts.map(
                      (workout) =>
                      _WeeklyWorkoutCard(
                        workout: workout,
                        icon:
                        _iconForType(
                          workout,
                        ),
                        dayLabel:
                        _dayLabel(
                          workout.date,
                        ),
                        onTap: () {
                          _openWorkout(
                            workout,
                          );
                        },
                      ),
                ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: _openHistory,
                icon: const Icon(
                  Icons
                      .calendar_month_outlined,
                ),
                label: const Text(
                  'OPEN TRAINING HISTORY',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWeek() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color:
            ShubXColors.darkGrey,
            size: 34,
          ),

          SizedBox(height: 12),

          Text(
            'No sessions this week yet.',
            style: TextStyle(
              color:
              ShubXColors.white,
              fontSize: 16,
              fontWeight:
              FontWeight.w600,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Your completed sessions will appear here.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color:
              ShubXColors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyWorkoutCard
    extends StatelessWidget {
  final Workout workout;
  final IconData icon;
  final String dayLabel;
  final VoidCallback onTap;

  const _WeeklyWorkoutCard({
    required this.workout,
    required this.icon,
    required this.dayLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 9,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Container(
          padding:
          const EdgeInsets.all(15),
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
              Container(
                width: 44,
                height: 44,
                decoration:
                BoxDecoration(
                  color:
                  ShubXColors.gold
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                  ShubXColors.gold,
                  size: 20,
                ),
              ),

              const SizedBox(width: 13),

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
                        fontSize: 14,
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
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                dayLabel,
                style: const TextStyle(
                  color:
                  ShubXColors.grey,
                  fontSize: 10,
                ),
              ),

              const SizedBox(width: 4),

              const Icon(
                Icons.chevron_right,
                color:
                ShubXColors.darkGrey,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}