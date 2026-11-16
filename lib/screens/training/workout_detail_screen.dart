import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/cardio_session.dart';
import '../../models/exercise_set.dart';
import '../../models/hyrox_session.dart';
import '../../models/hyrox_training_session.dart';
import '../../models/running_session.dart';
import '../../models/user_preferences.dart';
import '../../models/walking_session.dart';
import '../../models/workout.dart';
import '../../models/workout_exercise.dart';

import '../../services/database_service.dart';
import '../../services/preferences_service.dart';

import 'cardio_activity_logger_screen.dart';
import 'edit_weight_workout_screen.dart';
import 'hyrox_logger_screen.dart';
import 'hyrox_training_logger_screen.dart';
import 'running_logger_screen.dart';
import 'walking_logger_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState
    extends State<WorkoutDetailScreen> {
  bool _loading = true;
  bool _deleting = false;

  UserPreferences? _preferences;

  List<_ExerciseWithSets> _exerciseDetails = [];

  WalkingSession? _walkingSession;
  RunningSession? _runningSession;
  CardioSession? _cardioSession;
  HyroxSession? _hyroxSession;
  HyroxTrainingSession? _hyroxTrainingSession;

  static const double _poundsPerKg = 2.2046226218;
  static const double _metersPerMile = 1609.344;

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

  bool get _isWalking =>
      widget.workout.type == 'Cardio' &&
          widget.workout.title == 'Walking';

  bool get _isRunning =>
      widget.workout.type == 'Running';

  bool get _isHyrox =>
      widget.workout.type == 'HYROX';

  bool get _isWeightTraining =>
      widget.workout.type == 'Weight Training';

  bool get _isGeneralCardio =>
      (widget.workout.type == 'Cardio' ||
          widget.workout.type == 'Cardio & Endurance') &&
          !_isWalking;

  @override
  void initState() {
    super.initState();

    _loadWorkoutDetails();
  }

  // ==================================================
  // LOAD
  // ==================================================

  Future<void> _loadWorkoutDetails() async {
    final workoutId = widget.workout.id;

    if (workoutId == null) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      _preferences =
      await PreferencesService.instance
          .loadPreferences();

      // Reset previous data before reload.
      _exerciseDetails = [];
      _walkingSession = null;
      _runningSession = null;
      _cardioSession = null;
      _hyroxSession = null;
      _hyroxTrainingSession = null;

      if (_isWalking) {
        _walkingSession =
        await DatabaseService.instance
            .getWalkingSessionForWorkout(
          workoutId,
        );
      } else if (_isRunning) {
        _runningSession =
        await DatabaseService.instance
            .getRunningSessionForWorkout(
          workoutId,
        );
      } else if (_isHyrox) {
        _hyroxSession =
        await DatabaseService.instance
            .getHyroxSessionForWorkout(
          workoutId,
        );

        if (_hyroxSession == null) {
          _hyroxTrainingSession =
          await DatabaseService.instance
              .getHyroxTrainingSessionForWorkout(
            workoutId,
          );
        }
      } else if (_isGeneralCardio) {
        _cardioSession =
        await DatabaseService.instance
            .getCardioSessionForWorkout(
          workoutId,
        );
      } else if (_isWeightTraining) {
        await _loadWeightTraining(
          workoutId,
        );
      }

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load workout details: $error',
          ),
        ),
      );
    }
  }

  Future<void> _loadWeightTraining(
      int workoutId,
      ) async {
    final exercises =
    await DatabaseService.instance
        .getExercisesForWorkout(
      workoutId,
    );

    final details = <_ExerciseWithSets>[];

    for (final exercise in exercises) {
      if (exercise.id == null) {
        continue;
      }

      final sets =
      await DatabaseService.instance
          .getSetsForWorkoutExercise(
        exercise.id!,
      );

      details.add(
        _ExerciseWithSets(
          exercise: exercise,
          sets: sets,
        ),
      );
    }

    _exerciseDetails = details;
  }

  // ==================================================
  // UNIVERSAL EDIT
  // ==================================================

  Future<void> _editWorkout() async {
    bool? changed;

    // ----------------------------------------------
    // WEIGHT TRAINING
    // ----------------------------------------------

    if (_isWeightTraining) {
      changed =
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              EditWeightWorkoutScreen(
                workout: widget.workout,
              ),
        ),
      );
    }

    // ----------------------------------------------
    // RUNNING
    // ----------------------------------------------

    else if (_isRunning) {
      if (_preferences == null ||
          _runningSession == null) {
        _showEditUnavailable();
        return;
      }

      changed =
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              RunningLoggerScreen(
                preferences: _preferences!,
                workout: widget.workout,
                session: _runningSession!,
              ),
        ),
      );
    }

    // ----------------------------------------------
    // WALKING
    // ----------------------------------------------

    else if (_isWalking) {
      if (_preferences == null ||
          _walkingSession == null) {
        _showEditUnavailable();
        return;
      }

      changed =
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              WalkingLoggerScreen(
                preferences: _preferences!,
                workout: widget.workout,
                session: _walkingSession!,
              ),
        ),
      );
    }

    // ----------------------------------------------
    // GENERAL CARDIO
    // ----------------------------------------------

    else if (_isGeneralCardio) {
      if (_preferences == null ||
          _cardioSession == null) {
        _showEditUnavailable();
        return;
      }

      changed =
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              CardioActivityLoggerScreen(
                activity:
                _cardioSession!.activityType,
                preferences: _preferences!,
                workout: widget.workout,
                session: _cardioSession!,
              ),
        ),
      );
    }

    // ----------------------------------------------
    // HYROX
    // ----------------------------------------------

    else if (_isHyrox) {
      if (_hyroxSession != null) {
        changed =
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                HyroxLoggerScreen(
                  workout: widget.workout,
                  session: _hyroxSession!,
                ),
          ),
        );
      } else if (_hyroxTrainingSession != null) {
        changed =
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                HyroxTrainingLoggerScreen(
                  workout: widget.workout,
                  session:
                  _hyroxTrainingSession!,
                ),
          ),
        );
      } else {
        _showEditUnavailable();
        return;
      }
    }

    if (changed == true) {
      await _loadWorkoutDetails();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Workout updated.',
          ),
        ),
      );
    }
  }

  void _showEditUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This workout could not be loaded for editing.',
        ),
      ),
    );
  }

  // ==================================================
  // DELETE
  // ==================================================

  Future<void> _confirmDelete() async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ShubXColors.card,
          title: const Text(
            'Delete workout?',
            style: TextStyle(
              color: ShubXColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'This will permanently remove this workout and all of its recorded data.',
            style: TextStyle(
              color: ShubXColors.grey,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: ShubXColors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'DELETE',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _deleteWorkout();
  }

  Future<void> _deleteWorkout() async {
    final workoutId = widget.workout.id;

    if (workoutId == null) {
      return;
    }

    setState(() {
      _deleting = true;
    });

    try {
      await DatabaseService.instance
          .deleteWorkout(
        workoutId,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _deleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete workout: $error',
          ),
        ),
      );
    }
  }

  // ==================================================
  // GENERAL HELPERS
  // ==================================================

  String _formatDate(
      DateTime date,
      ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _cleanNumber(
      double value,
      ) {
    if ((value - value.round()).abs() < 0.05) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }

  String _formatDuration(
      int seconds,
      ) {
    final hours = seconds ~/ 3600;

    final minutes =
        (seconds % 3600) ~/ 60;

    final remaining =
        seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
    }

    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  String _formatPaceSeconds(
      double totalSeconds,
      ) {
    int minutes =
        totalSeconds ~/ 60;

    int seconds =
    (totalSeconds % 60).round();

    if (seconds == 60) {
      minutes++;
      seconds = 0;
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatSteps(
      int steps,
      ) {
    final text = steps.toString();

    final buffer = StringBuffer();

    for (int i = 0;
    i < text.length;
    i++) {
      final remaining =
          text.length - i;

      buffer.write(
        text[i],
      );

      if (remaining > 1 &&
          remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  // ==================================================
  // WEIGHT HELPERS
  // ==================================================

  int get _totalSets {
    int total = 0;

    for (final detail
    in _exerciseDetails) {
      total += detail.sets.length;
    }

    return total;
  }

  Set<String> get _muscles {
    return _exerciseDetails
        .map(
          (detail) =>
      detail.exercise.primaryMuscle,
    )
        .toSet();
  }

  String _formatWeight(
      double kg,
      ) {
    final lb =
        kg * _poundsPerKg;

    return '${_cleanNumber(kg)} kg / ${_cleanNumber(lb)} lb';
  }

  String _setDescription(
      WorkoutExercise exercise,
      ExerciseSet set,
      ) {
    switch (exercise.trackingType) {
      case 'weightAndReps':
        final weight =
        set.weightKg == null
            ? '--'
            : _formatWeight(
          set.weightKg!,
        );

        return '$weight × ${set.reps ?? '--'} reps';

      case 'repsOnly':
        return '${set.reps ?? '--'} reps';

      case 'duration':
        return '${set.durationSeconds ?? '--'} sec';

      case 'weightAndDistance':
        final weight =
        set.weightKg == null
            ? '--'
            : _formatWeight(
          set.weightKg!,
        );

        final distance =
        set.distanceMeters == null
            ? '--'
            : _cleanNumber(
          set.distanceMeters!,
        );

        return '$weight • $distance m';

      default:
        return 'Set recorded';
    }
  }

  // ==================================================
  // SCREEN
  // ==================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      ShubXColors.black,

      appBar: AppBar(
        backgroundColor:
        ShubXColors.black,
        elevation: 0,

        title: const Text(
          'WORKOUT DETAILS',
          style: TextStyle(
            color:
            ShubXColors.white,
            fontSize: 17,
            fontWeight:
            FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            color: ShubXColors.card,

            icon: const Icon(
              Icons.more_vert,
              color: ShubXColors.white,
            ),

            onSelected: (value) {
              if (value == 'edit') {
                _editWorkout();
              }

              if (value == 'delete') {
                _confirmDelete();
              }
            },

            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color:
                        ShubXColors.white,
                        size: 20,
                      ),

                      SizedBox(width: 12),

                      Text(
                        'Edit Workout',
                        style: TextStyle(
                          color:
                          ShubXColors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color:
                        Colors.redAccent,
                        size: 20,
                      ),

                      SizedBox(width: 12),

                      Text(
                        'Delete Workout',
                        style: TextStyle(
                          color:
                          Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),

      body: _deleting
          ? const Center(
        child:
        CircularProgressIndicator(
          color:
          ShubXColors.gold,
        ),
      )
          : _loading
          ? const Center(
        child:
        CircularProgressIndicator(
          color:
          ShubXColors.gold,
        ),
      )
          : ListView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          40,
        ),
        children: [
          Text(
            widget.workout.title
                .toUpperCase(),
            style:
            const TextStyle(
              color:
              ShubXColors.white,
              fontSize: 28,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _formatDate(
              widget.workout.date,
            ),
            style:
            const TextStyle(
              color:
              ShubXColors.grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.workout.type,
            style:
            const TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 28),

          _buildWorkoutBody(),
        ],
      ),
    );
  }

  Widget _buildWorkoutBody() {
    if (_isWeightTraining) {
      return _buildWeightDetails();
    }

    if (_isWalking) {
      return _buildWalkingDetails();
    }

    if (_isRunning) {
      return _buildRunningDetails();
    }

    if (_isHyrox) {
      if (_hyroxSession != null) {
        return _buildFullHyroxDetails();
      }

      if (_hyroxTrainingSession != null) {
        return _buildHyroxTrainingDetails();
      }

      return _buildNoDetails();
    }

    if (_isGeneralCardio) {
      return _buildCardioDetails();
    }

    return _buildNoDetails();
  }

  // ==================================================
  // RUNNING
  // ==================================================

  Widget _buildRunningDetails() {
    final run = _runningSession;

    if (run == null) {
      return _buildNoDetails();
    }

    final km =
        run.distanceMeters / 1000;

    final miles =
        run.distanceMeters /
            _metersPerMile;

    final secondsPerKm =
        run.durationSeconds / km;

    final secondsPerMile =
        run.durationSeconds / miles;

    return Column(
      children: [
        const _ActivityHero(
          icon: Icons.directions_run,
          title: 'RUN',
        ),

        const SizedBox(height: 14),

        _MetricsCard(
          children: [
            _MetricRow(
              label: 'DISTANCE',
              value:
              '${_cleanNumber(km)} km / ${_cleanNumber(miles)} mi',
            ),

            const _MetricDivider(),

            _MetricRow(
              label: 'TIME',
              value:
              _formatDuration(
                run.durationSeconds,
              ),
            ),

            const _MetricDivider(),

            _MetricRow(
              label: 'PACE',
              value:
              '${_formatPaceSeconds(secondsPerKm)} /km\n'
                  '${_formatPaceSeconds(secondsPerMile)} /mi',
            ),
          ],
        ),
      ],
    );
  }

  // ==================================================
  // WALKING
  // ==================================================

  Widget _buildWalkingDetails() {
    final walk = _walkingSession;

    if (walk == null) {
      return _buildNoDetails();
    }

    final km =
        walk.distanceMeters / 1000;

    final miles =
        walk.distanceMeters /
            _metersPerMile;

    final secondsPerKm =
        walk.durationSeconds / km;

    final secondsPerMile =
        walk.durationSeconds / miles;

    return Column(
      children: [
        const _ActivityHero(
          icon: Icons.directions_walk,
          title: 'WALKING',
        ),

        const SizedBox(height: 14),

        _MetricsCard(
          children: [
            _MetricRow(
              label: 'DISTANCE',
              value:
              '${_cleanNumber(km)} km / ${_cleanNumber(miles)} mi',
            ),

            const _MetricDivider(),

            _MetricRow(
              label: 'TIME',
              value:
              _formatDuration(
                walk.durationSeconds,
              ),
            ),

            const _MetricDivider(),

            _MetricRow(
              label: 'PACE',
              value:
              '${_formatPaceSeconds(secondsPerKm)} /km\n'
                  '${_formatPaceSeconds(secondsPerMile)} /mi',
            ),
          ],
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(
            20,
          ),
          decoration:
          BoxDecoration(
            color:
            ShubXColors.gold
                .withValues(
              alpha: 0.07,
            ),
            borderRadius:
            BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color:
              ShubXColors.gold
                  .withValues(
                alpha: 0.35,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              const Text(
                'ESTIMATED STEP COUNT',
                style: TextStyle(
                  color:
                  ShubXColors.gold,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '~${_formatSteps(walk.estimatedSteps)} steps',
                style:
                const TextStyle(
                  color:
                  ShubXColors.white,
                  fontSize: 30,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                walk.heightCm == null
                    ? 'Estimated using an average walking step length.'
                    : 'Estimated using your profile height of ${_cleanNumber(walk.heightCm!)} cm.',
                style:
                const TextStyle(
                  color:
                  ShubXColors.grey,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================================================
  // GENERAL CARDIO
  // ==================================================

  Widget _buildCardioDetails() {
    final cardio = _cardioSession;

    if (cardio == null) {
      return _buildNoDetails();
    }

    return Column(
      children: [
        _ActivityHero(
          icon: _cardioIcon(
            cardio.activityType,
          ),
          title:
          cardio.activityType
              .toUpperCase(),
        ),

        const SizedBox(height: 14),

        _MetricsCard(
          children:
          _cardioMetrics(cardio),
        ),
      ],
    );
  }

  IconData _cardioIcon(
      String activity,
      ) {
    switch (activity) {
      case 'Cycling':
        return Icons.directions_bike;

      case 'StairMaster':
        return Icons.stairs;

      case 'Rowing':
        return Icons.rowing;

      case 'Swimming':
        return Icons.pool;

      case 'Hiking':
        return Icons.hiking;

      case 'Jump Rope':
        return Icons.timer_outlined;

      default:
        return Icons.favorite_outline;
    }
  }

  List<Widget> _cardioMetrics(
      CardioSession cardio,
      ) {
    final metrics = <Widget>[];

    void addMetric(
        String label,
        String value,
        ) {
      if (metrics.isNotEmpty) {
        metrics.add(
          const _MetricDivider(),
        );
      }

      metrics.add(
        _MetricRow(
          label: label,
          value: value,
        ),
      );
    }

    final distance =
        cardio.distanceMeters;

    if (distance != null) {
      if (cardio.activityType ==
          'Rowing' ||
          cardio.activityType ==
              'SkiErg') {
        addMetric(
          'DISTANCE',
          '${_cleanNumber(distance)} m',
        );
      } else {
        final km =
            distance / 1000;

        final miles =
            distance /
                _metersPerMile;

        addMetric(
          'DISTANCE',
          '${_cleanNumber(km)} km / ${_cleanNumber(miles)} mi',
        );
      }
    }

    addMetric(
      'TIME',
      _formatDuration(
        cardio.durationSeconds,
      ),
    );

    if (distance != null &&
        distance > 0) {
      if (cardio.activityType ==
          'Cycling') {
        final hours =
            cardio.durationSeconds /
                3600;

        final km =
            distance / 1000;

        final miles =
            distance /
                _metersPerMile;

        addMetric(
          'AVERAGE SPEED',
          '${(km / hours).toStringAsFixed(1)} km/h\n'
              '${(miles / hours).toStringAsFixed(1)} mph',
        );
      }

      if (cardio.activityType ==
          'Rowing' ||
          cardio.activityType ==
              'SkiErg') {
        final secondsPer500 =
            cardio.durationSeconds /
                (distance / 500);

        addMetric(
          'AVERAGE PACE',
          '${_formatPaceSeconds(secondsPer500)} /500m',
        );
      }

      if (cardio.activityType ==
          'Hiking' ||
          cardio.activityType ==
              'Elliptical' ||
          cardio.activityType ==
              'Swimming') {
        final km =
            distance / 1000;

        final miles =
            distance /
                _metersPerMile;

        addMetric(
          'AVERAGE PACE',
          '${_formatPaceSeconds(cardio.durationSeconds / km)} /km\n'
              '${_formatPaceSeconds(cardio.durationSeconds / miles)} /mi',
        );
      }
    }

    if (cardio.level != null) {
      addMetric(
        'LEVEL',
        _cleanNumber(
          cardio.level!,
        ),
      );
    }

    if (cardio.floors != null) {
      addMetric(
        'FLOORS',
        '${cardio.floors}',
      );
    }

    if (cardio.reps != null) {
      addMetric(
        'REPS',
        '${cardio.reps}',
      );
    }

    if (cardio.rounds != null) {
      addMetric(
        'ROUNDS',
        '${cardio.rounds}',
      );
    }

    return metrics;
  }

  // ==================================================
  // FULL HYROX
  // ==================================================

  Widget _buildFullHyroxDetails() {
    final hyrox = _hyroxSession;

    if (hyrox == null) {
      return _buildNoDetails();
    }

    final fastestRun =
    hyrox.runTimesSeconds.reduce(
          (a, b) => a < b ? a : b,
    );

    final slowestRun =
    hyrox.runTimesSeconds.reduce(
          (a, b) => a > b ? a : b,
    );

    return Column(
      children: [
        const _ActivityHero(
          icon: Icons.bolt,
          title: 'FULL SIMULATION',
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(
            20,
          ),
          decoration:
          BoxDecoration(
            color:
            ShubXColors.gold
                .withValues(
              alpha: 0.07,
            ),
            borderRadius:
            BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color:
              ShubXColors.gold
                  .withValues(
                alpha: 0.4,
              ),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'OVERALL TIME',
                style: TextStyle(
                  color:
                  ShubXColors.gold,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _formatDuration(
                  hyrox.totalSeconds,
                ),
                style:
                const TextStyle(
                  color:
                  ShubXColors.white,
                  fontSize: 36,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child:
                    _HyroxSummaryValue(
                      label: 'RUNNING',
                      value:
                      _formatDuration(
                        hyrox
                            .totalRunSeconds,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                    _HyroxSummaryValue(
                      label: 'STATIONS',
                      value:
                      _formatDuration(
                        hyrox
                            .totalStationSeconds,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child:
                    _HyroxSummaryValue(
                      label:
                      'FASTEST RUN',
                      value:
                      _formatDuration(
                        fastestRun,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                    _HyroxSummaryValue(
                      label:
                      'SLOWEST RUN',
                      value:
                      _formatDuration(
                        slowestRun,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Align(
          alignment:
          Alignment.centerLeft,
          child: Text(
            'SPLITS',
            style: TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 11,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 12),

        for (int i = 0;
        i < 8;
        i++)
          _HyroxSplitCard(
            number: i + 1,
            station:
            _hyroxStations[i],
            runTime:
            _formatDuration(
              hyrox.runTimesSeconds[i],
            ),
            stationTime:
            _formatDuration(
              hyrox
                  .stationTimesSeconds[i],
            ),
          ),
      ],
    );
  }

  // ==================================================
  // CUSTOM HYROX
  // ==================================================

  Widget _buildHyroxTrainingDetails() {
    final session =
        _hyroxTrainingSession;

    if (session == null) {
      return _buildNoDetails();
    }

    int runSeconds = 0;
    int stationSeconds = 0;

    for (final segment
    in session.segments) {
      if (segment.segmentType ==
          'run') {
        runSeconds +=
            segment.durationSeconds;
      } else {
        stationSeconds +=
            segment.durationSeconds;
      }
    }

    return Column(
      children: [
        const _ActivityHero(
          icon: Icons.bolt,
          title: 'TRAINING SESSION',
        ),

        const SizedBox(height: 14),

        _MetricsCard(
          children: [
            _MetricRow(
              label: 'TOTAL',
              value:
              _formatDuration(
                session.totalSeconds,
              ),
            ),

            const _MetricDivider(),

            _MetricRow(
              label: 'RUNNING',
              value:
              _formatDuration(
                runSeconds,
              ),
            ),

            const _MetricDivider(),

            _MetricRow(
              label: 'STATIONS',
              value:
              _formatDuration(
                stationSeconds,
              ),
            ),

            const _MetricDivider(),

            _MetricRow(
              label: 'SEGMENTS',
              value:
              '${session.segments.length}',
            ),
          ],
        ),

        const SizedBox(height: 24),

        const Align(
          alignment:
          Alignment.centerLeft,
          child: Text(
            'SESSION ORDER',
            style: TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 11,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 12),

        ...List.generate(
          session.segments.length,
              (index) {
            final segment =
            session.segments[index];

            return Container(
              margin:
              const EdgeInsets.only(
                bottom: 9,
              ),
              padding:
              const EdgeInsets.all(
                15,
              ),
              decoration:
              BoxDecoration(
                color:
                ShubXColors.card,
                borderRadius:
                BorderRadius
                    .circular(
                  15,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 31,
                    height: 31,
                    alignment:
                    Alignment.center,
                    decoration:
                    BoxDecoration(
                      color:
                      ShubXColors
                          .gold
                          .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        9,
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      style:
                      const TextStyle(
                        color:
                        ShubXColors
                            .gold,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Icon(
                    segment.segmentType ==
                        'run'
                        ? Icons
                        .directions_run
                        : Icons
                        .fitness_center,
                    color:
                    ShubXColors.grey,
                    size: 19,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Text(
                      segment.segmentName,
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
                  ),

                  Text(
                    _formatDuration(
                      segment
                          .durationSeconds,
                    ),
                    style:
                    const TextStyle(
                      color:
                      ShubXColors
                          .gold,
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ==================================================
  // WEIGHT TRAINING
  // ==================================================

  Widget _buildWeightDetails() {
    if (_exerciseDetails.isEmpty) {
      return _buildNoDetails();
    }

    return Column(
      children: [
        ..._exerciseDetails.map(
          _buildExerciseCard,
        ),

        const SizedBox(height: 8),

        _buildWeightSummary(),
      ],
    );
  }

  Widget _buildExerciseCard(
      _ExerciseWithSets detail,
      ) {
    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            detail.exercise.exerciseName,
            style:
            const TextStyle(
              color:
              ShubXColors.white,
              fontSize: 18,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            detail.exercise.primaryMuscle,
            style:
            const TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 16),

          ...detail.sets.map(
                (set) => Container(
              margin:
              const EdgeInsets.only(
                bottom: 8,
              ),
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration:
              BoxDecoration(
                color:
                ShubXColors
                    .charcoal,
                borderRadius:
                BorderRadius
                    .circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 55,
                    child: Text(
                      'SET ${set.setNumber}',
                      style:
                      const TextStyle(
                        color:
                        ShubXColors
                            .grey,
                        fontSize: 10,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      _setDescription(
                        detail.exercise,
                        set,
                      ),
                      style:
                      const TextStyle(
                        color:
                        ShubXColors
                            .white,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSummary() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
        ShubXColors.gold
            .withValues(
          alpha: 0.07,
        ),
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'WORKOUT SUMMARY',
            style: TextStyle(
              color:
              ShubXColors.gold,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            '${_exerciseDetails.length} exercises • $_totalSets sets',
            style:
            const TextStyle(
              color:
              ShubXColors.white,
              fontSize: 16,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children:
            _muscles.map(
                  (muscle) {
                return Chip(
                  label:
                  Text(muscle),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDetails() {
    return Container(
      padding:
      const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: const Text(
        'No detailed data was recorded for this workout.',
        textAlign:
        TextAlign.center,
        style: TextStyle(
          color: ShubXColors.grey,
        ),
      ),
    );
  }
}

// ====================================================
// SHARED UI
// ====================================================

class _ActivityHero
    extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ActivityHero({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        vertical: 22,
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color:
            ShubXColors.gold,
            size: 38,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color:
              ShubXColors.white,
              fontSize: 17,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsCard
    extends StatelessWidget {
  final List<Widget> children;

  const _MetricsCard({
    required this.children,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _MetricRow
    extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style:
            const TextStyle(
              color:
              ShubXColors.grey,
              fontSize: 10,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign:
            TextAlign.right,
            style:
            const TextStyle(
              color:
              ShubXColors.white,
              fontSize: 16,
              fontWeight:
              FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricDivider
    extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Padding(
      padding:
      EdgeInsets.symmetric(
        vertical: 17,
      ),
      child: Divider(
        color:
        ShubXColors.darkGrey,
      ),
    );
  }
}

class _HyroxSummaryValue
    extends StatelessWidget {
  final String label;
  final String value;

  const _HyroxSummaryValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      children: [
        Text(
          label,
          style:
          const TextStyle(
            color:
            ShubXColors.grey,
            fontSize: 9,
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style:
          const TextStyle(
            color:
            ShubXColors.white,
            fontSize: 16,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HyroxSplitCard
    extends StatelessWidget {
  final int number;
  final String station;
  final String runTime;
  final String stationTime;

  const _HyroxSplitCard({
    required this.number,
    required this.station,
    required this.runTime,
    required this.stationTime,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment:
                Alignment.center,
                decoration:
                BoxDecoration(
                  color:
                  ShubXColors.gold
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(9),
                ),
                child: Text(
                  '$number',
                  style:
                  const TextStyle(
                    color:
                    ShubXColors.gold,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Text(
                  station,
                  style:
                  const TextStyle(
                    color:
                    ShubXColors.white,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child:
                _SmallSplitValue(
                  label: '1 KM RUN',
                  value: runTime,
                ),
              ),

              Expanded(
                child:
                _SmallSplitValue(
                  label: station
                      .toUpperCase(),
                  value: stationTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallSplitValue
    extends StatelessWidget {
  final String label;
  final String value;

  const _SmallSplitValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
          const TextStyle(
            color:
            ShubXColors.grey,
            fontSize: 8,
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style:
          const TextStyle(
            color:
            ShubXColors.white,
            fontSize: 15,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ExerciseWithSets {
  final WorkoutExercise exercise;
  final List<ExerciseSet> sets;

  const _ExerciseWithSets({
    required this.exercise,
    required this.sets,
  });
}