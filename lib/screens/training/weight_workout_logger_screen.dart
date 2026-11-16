import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../../models/workout.dart';
import '../../models/workout_exercise.dart';
import '../../services/database_service.dart';
import 'workout_complete_screen.dart';

enum WeightUnit {
  kg,
  lb,
}

class WeightWorkoutLoggerScreen extends StatefulWidget {
  final List<Exercise> exercises;

  const WeightWorkoutLoggerScreen({
    super.key,
    required this.exercises,
  });

  @override
  State<WeightWorkoutLoggerScreen> createState() =>
      _WeightWorkoutLoggerScreenState();
}

class _WeightWorkoutLoggerScreenState
    extends State<WeightWorkoutLoggerScreen> {
  late final Map<String, List<_SetEntry>> _entries;

  WeightUnit _weightUnit = WeightUnit.lb;

  bool _saving = false;

  static const double _poundsPerKg = 2.2046226218;

  @override
  void initState() {
    super.initState();

    _entries = {
      for (final exercise in widget.exercises)
        exercise.id: [
          _SetEntry(),
        ],
    };
  }

  @override
  void dispose() {
    for (final entries in _entries.values) {
      for (final entry in entries) {
        entry.dispose();
      }
    }

    super.dispose();
  }

  String get _weightLabel {
    return _weightUnit == WeightUnit.kg ? 'kg' : 'lb';
  }

  double _displayWeightToKg(double weight) {
    if (_weightUnit == WeightUnit.kg) {
      return weight;
    }

    return weight / _poundsPerKg;
  }

  void _changeWeightUnit(WeightUnit newUnit) {
    if (_weightUnit == newUnit) {
      return;
    }

    for (final entries in _entries.values) {
      for (final entry in entries) {
        final currentWeight = double.tryParse(
          entry.weightController.text.trim(),
        );

        if (currentWeight == null) {
          continue;
        }

        double converted;

        if (_weightUnit == WeightUnit.kg &&
            newUnit == WeightUnit.lb) {
          converted = currentWeight * _poundsPerKg;
        } else {
          converted = currentWeight / _poundsPerKg;
        }

        entry.weightController.text =
            _formatWeight(converted);
      }
    }

    setState(() {
      _weightUnit = newUnit;
    });
  }

  String _formatWeight(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  void _addSet(Exercise exercise) {
    setState(() {
      _entries[exercise.id]!.add(
        _SetEntry(),
      );
    });
  }

  void _removeSet(
      Exercise exercise,
      int index,
      ) {
    final entries = _entries[exercise.id]!;

    if (entries.length <= 1) {
      return;
    }

    entries[index].dispose();

    setState(() {
      entries.removeAt(index);
    });
  }

  bool _validateEntries() {
    for (final exercise in widget.exercises) {
      final entries = _entries[exercise.id]!;

      for (final entry in entries) {
        switch (exercise.trackingType) {
          case ExerciseTrackingType.weightAndReps:
            final weight = double.tryParse(
              entry.weightController.text.trim(),
            );

            final reps = int.tryParse(
              entry.repsController.text.trim(),
            );

            if (weight == null ||
                weight < 0 ||
                reps == null ||
                reps <= 0) {
              return false;
            }

          case ExerciseTrackingType.repsOnly:
            final reps = int.tryParse(
              entry.repsController.text.trim(),
            );

            if (reps == null || reps <= 0) {
              return false;
            }

          case ExerciseTrackingType.duration:
            final seconds = int.tryParse(
              entry.durationController.text.trim(),
            );

            if (seconds == null || seconds <= 0) {
              return false;
            }

          case ExerciseTrackingType.weightAndDistance:
            final weight = double.tryParse(
              entry.weightController.text.trim(),
            );

            final distance = double.tryParse(
              entry.distanceController.text.trim(),
            );

            if (weight == null ||
                weight < 0 ||
                distance == null ||
                distance <= 0) {
              return false;
            }
        }
      }
    }

    return true;
  }

  int get _totalSets {
    int count = 0;

    for (final entries in _entries.values) {
      count += entries.length;
    }

    return count;
  }

  Future<void> _completeWorkout() async {
    if (!_validateEntries()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete all set values before saving.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final now = DateTime.now();

      final muscles = widget.exercises
          .map((exercise) => exercise.primaryMuscle)
          .toSet()
          .join(' + ');

      final workoutTitle = muscles.isEmpty
          ? 'Weight Training'
          : muscles;

      final workout =
      await DatabaseService.instance.insertWorkout(
        Workout(
          type: 'Weight Training',
          title: workoutTitle,
          date: now,
          durationMinutes: 0,
          completed: true,
          createdAt: now,
        ),
      );

      if (workout.id == null) {
        throw Exception(
          'Workout ID was not created.',
        );
      }

      for (int exerciseIndex = 0;
      exerciseIndex < widget.exercises.length;
      exerciseIndex++) {
        final exercise =
        widget.exercises[exerciseIndex];

        final workoutExercise =
        await DatabaseService.instance
            .insertWorkoutExercise(
          WorkoutExercise(
            workoutId: workout.id!,
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            primaryMuscle: exercise.primaryMuscle,
            trackingType:
            exercise.trackingType.name,
            exerciseOrder: exerciseIndex,
          ),
        );

        if (workoutExercise.id == null) {
          throw Exception(
            'Exercise ID was not created.',
          );
        }

        final entries = _entries[exercise.id]!;

        for (int setIndex = 0;
        setIndex < entries.length;
        setIndex++) {
          final entry = entries[setIndex];

          final enteredWeight = double.tryParse(
            entry.weightController.text.trim(),
          );

          final storedWeightKg =
          enteredWeight == null
              ? null
              : _displayWeightToKg(
            enteredWeight,
          );

          await DatabaseService.instance
              .insertExerciseSet(
            ExerciseSet(
              workoutExerciseId:
              workoutExercise.id!,
              setNumber: setIndex + 1,
              weightKg: storedWeightKg,
              reps: int.tryParse(
                entry.repsController.text.trim(),
              ),
              durationSeconds: int.tryParse(
                entry.durationController.text.trim(),
              ),
              distanceMeters: double.tryParse(
                entry.distanceController.text.trim(),
              ),
            ),
          );
        }
      }

      if (!mounted) return;

      final done =
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => WorkoutCompleteScreen(
            workoutTitle: workoutTitle,
            exerciseCount: widget.exercises.length,
            setCount: _totalSets,
          ),
        ),
      );

      if (!mounted) return;

      if (done == true) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save workout: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShubXColors.black,
      appBar: AppBar(
        backgroundColor: ShubXColors.black,
        title: const Text(
          'LOG YOUR SETS',
          style: TextStyle(
            color: ShubXColors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              14,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEIGHT UNIT',
                        style: TextStyle(
                          color: ShubXColors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Switch anytime',
                        style: TextStyle(
                          color: ShubXColors.darkGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                _UnitButton(
                  label: 'KG',
                  selected:
                  _weightUnit == WeightUnit.kg,
                  onTap: () {
                    _changeWeightUnit(
                      WeightUnit.kg,
                    );
                  },
                ),

                const SizedBox(width: 8),

                _UnitButton(
                  label: 'LB',
                  selected:
                  _weightUnit == WeightUnit.lb,
                  onTap: () {
                    _changeWeightUnit(
                      WeightUnit.lb,
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                6,
                20,
                120,
              ),
              itemCount: widget.exercises.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final exercise =
                widget.exercises[index];

                return _ExerciseLoggerCard(
                  exercise: exercise,
                  entries:
                  _entries[exercise.id]!,
                  weightLabel: _weightLabel,
                  onAddSet: () =>
                      _addSet(exercise),
                  onRemoveSet: (setIndex) =>
                      _removeSet(
                        exercise,
                        setIndex,
                      ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: ShubXColors.black,
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            16,
          ),
          child: ElevatedButton(
            onPressed:
            _saving ? null : _completeWorkout,
            child: _saving
                ? const SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color: ShubXColors.black,
              ),
            )
                : const Text(
              'COMPLETE WORKOUT',
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UnitButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 160,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? ShubXColors.gold
              : ShubXColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? ShubXColors.gold
                : ShubXColors.darkGrey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? ShubXColors.black
                : ShubXColors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ExerciseLoggerCard extends StatelessWidget {
  final Exercise exercise;
  final List<_SetEntry> entries;
  final String weightLabel;
  final VoidCallback onAddSet;
  final void Function(int index) onRemoveSet;

  const _ExerciseLoggerCard({
    required this.exercise,
    required this.entries,
    required this.weightLabel,
    required this.onAddSet,
    required this.onRemoveSet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: const TextStyle(
              color: ShubXColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            exercise.primaryMuscle,
            style: const TextStyle(
              color: ShubXColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          for (int index = 0;
          index < entries.length;
          index++)
            Padding(
              padding:
              const EdgeInsets.only(
                bottom: 12,
              ),
              child: _SetRow(
                exercise: exercise,
                entry: entries[index],
                setNumber: index + 1,
                weightLabel: weightLabel,
                canDelete: entries.length > 1,
                onDelete: () =>
                    onRemoveSet(index),
              ),
            ),

          TextButton.icon(
            onPressed: onAddSet,
            icon: const Icon(
              Icons.add,
              color: ShubXColors.gold,
            ),
            label: const Text(
              'ADD SET',
              style: TextStyle(
                color: ShubXColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final Exercise exercise;
  final _SetEntry entry;
  final int setNumber;
  final String weightLabel;
  final bool canDelete;
  final VoidCallback onDelete;

  const _SetRow({
    required this.exercise,
    required this.entry,
    required this.setNumber,
    required this.weightLabel,
    required this.canDelete,
    required this.onDelete,
  });

  Widget _field(
      TextEditingController controller,
      String label,
      ) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType:
        const TextInputType.numberWithOptions(
          decimal: true,
        ),
        style: const TextStyle(
          color: ShubXColors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: ShubXColors.grey,
            fontSize: 12,
          ),
          filled: true,
          fillColor: ShubXColors.charcoal,
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[];

    switch (exercise.trackingType) {
      case ExerciseTrackingType.weightAndReps:
        fields.add(
          _field(
            entry.weightController,
            weightLabel,
          ),
        );

        fields.add(
          const SizedBox(width: 8),
        );

        fields.add(
          _field(
            entry.repsController,
            'reps',
          ),
        );

      case ExerciseTrackingType.repsOnly:
        fields.add(
          _field(
            entry.repsController,
            'reps',
          ),
        );

      case ExerciseTrackingType.duration:
        fields.add(
          _field(
            entry.durationController,
            'seconds',
          ),
        );

      case ExerciseTrackingType.weightAndDistance:
        fields.add(
          _field(
            entry.weightController,
            weightLabel,
          ),
        );

        fields.add(
          const SizedBox(width: 8),
        );

        fields.add(
          _field(
            entry.distanceController,
            'meters',
          ),
        );
    }

    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(
            'SET $setNumber',
            style: const TextStyle(
              color: ShubXColors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 8),

        ...fields,

        if (canDelete) ...[
          const SizedBox(width: 6),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.close,
              color: ShubXColors.grey,
              size: 18,
            ),
          ),
        ],
      ],
    );
  }
}

class _SetEntry {
  final TextEditingController weightController =
  TextEditingController();

  final TextEditingController repsController =
  TextEditingController();

  final TextEditingController durationController =
  TextEditingController();

  final TextEditingController distanceController =
  TextEditingController();

  void dispose() {
    weightController.dispose();
    repsController.dispose();
    durationController.dispose();
    distanceController.dispose();
  }
}