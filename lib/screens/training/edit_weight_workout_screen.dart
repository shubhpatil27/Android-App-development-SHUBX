import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/exercise_set.dart';
import '../../models/workout.dart';
import '../../models/workout_exercise.dart';
import '../../services/database_service.dart';

enum EditWeightUnit {
  kg,
  lb,
}

class EditWeightWorkoutScreen
    extends StatefulWidget {
  final Workout workout;

  const EditWeightWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  State<EditWeightWorkoutScreen>
  createState() =>
      _EditWeightWorkoutScreenState();
}

class _EditWeightWorkoutScreenState
    extends State<EditWeightWorkoutScreen> {
  static const double _poundsPerKg =
  2.2046226218;

  bool _loading = true;
  bool _saving = false;

  EditWeightUnit _weightUnit =
      EditWeightUnit.lb;

  final List<_EditableExercise>
  _exercises = [];

  @override
  void initState() {
    super.initState();

    _loadWorkout();
  }

  @override
  void dispose() {
    for (final exercise in _exercises) {
      exercise.dispose();
    }

    super.dispose();
  }

  Future<void> _loadWorkout() async {
    final workoutId = widget.workout.id;

    if (workoutId == null) {
      setState(() {
        _loading = false;
      });

      return;
    }

    final workoutExercises =
    await DatabaseService.instance
        .getExercisesForWorkout(
      workoutId,
    );

    final loaded =
    <_EditableExercise>[];

    for (final workoutExercise
    in workoutExercises) {
      if (workoutExercise.id == null) {
        continue;
      }

      final sets =
      await DatabaseService.instance
          .getSetsForWorkoutExercise(
        workoutExercise.id!,
      );

      loaded.add(
        _EditableExercise(
          exerciseId:
          workoutExercise.exerciseId,
          exerciseName:
          workoutExercise.exerciseName,
          primaryMuscle:
          workoutExercise.primaryMuscle,
          trackingType:
          workoutExercise.trackingType,
          sets: sets
              .map(
                (set) =>
                _EditableSet.fromStoredSet(
                  set,
                  displayUnit:
                  _weightUnit,
                ),
          )
              .toList(),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _exercises.addAll(
        loaded,
      );

      _loading = false;
    });
  }

  String get _weightLabel {
    return _weightUnit ==
        EditWeightUnit.kg
        ? 'kg'
        : 'lb';
  }

  void _changeUnit(
      EditWeightUnit newUnit,
      ) {
    if (_weightUnit == newUnit) {
      return;
    }

    for (final exercise
    in _exercises) {
      for (final set in exercise.sets) {
        final value =
        double.tryParse(
          set.weightController.text
              .trim(),
        );

        if (value == null) {
          continue;
        }

        final converted =
        _weightUnit ==
            EditWeightUnit.kg &&
            newUnit ==
                EditWeightUnit.lb
            ? value * _poundsPerKg
            : value /
            _poundsPerKg;

        set.weightController.text =
            _cleanNumber(
              converted,
            );
      }
    }

    setState(() {
      _weightUnit = newUnit;
    });
  }

  String _cleanNumber(
      double value,
      ) {
    if ((value - value.round())
        .abs() <
        0.05) {
      return value
          .round()
          .toString();
    }

    return value.toStringAsFixed(1);
  }

  double _enteredWeightToKg(
      double weight,
      ) {
    if (_weightUnit ==
        EditWeightUnit.kg) {
      return weight;
    }

    return weight /
        _poundsPerKg;
  }

  void _addSet(
      _EditableExercise exercise,
      ) {
    setState(() {
      exercise.sets.add(
        _EditableSet.empty(),
      );
    });
  }

  void _removeSet(
      _EditableExercise exercise,
      int index,
      ) {
    if (exercise.sets.length <= 1) {
      return;
    }

    exercise.sets[index].dispose();

    setState(() {
      exercise.sets.removeAt(
        index,
      );
    });
  }

  Future<void> _removeExercise(
      int index,
      ) async {
    if (_exercises.length <= 1) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'A weight workout needs at least one exercise.',
          ),
        ),
      );

      return;
    }

    final exercise =
    _exercises[index];

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
          ShubXColors.card,
          title: const Text(
            'Remove exercise?',
            style: TextStyle(
              color:
              ShubXColors.white,
            ),
          ),
          content: Text(
            'Remove ${exercise.exerciseName} and all of its sets from this workout?',
            style: const TextStyle(
              color:
              ShubXColors.grey,
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
                  color:
                  ShubXColors.grey,
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
                'REMOVE',
                style: TextStyle(
                  color:
                  Colors.redAccent,
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

    exercise.dispose();

    setState(() {
      _exercises.removeAt(index);
    });
  }

  bool _validate() {
    for (final exercise
    in _exercises) {
      if (exercise.sets.isEmpty) {
        return false;
      }

      for (final set
      in exercise.sets) {
        switch (
        exercise.trackingType) {
          case 'weightAndReps':
            final weight =
            double.tryParse(
              set.weightController.text
                  .trim(),
            );

            final reps =
            int.tryParse(
              set.repsController.text
                  .trim(),
            );

            if (weight == null ||
                weight < 0 ||
                reps == null ||
                reps <= 0) {
              return false;
            }

          case 'repsOnly':
            final reps =
            int.tryParse(
              set.repsController.text
                  .trim(),
            );

            if (reps == null ||
                reps <= 0) {
              return false;
            }

          case 'duration':
            final seconds =
            int.tryParse(
              set.durationController
                  .text
                  .trim(),
            );

            if (seconds == null ||
                seconds <= 0) {
              return false;
            }

          case 'weightAndDistance':
            final weight =
            double.tryParse(
              set.weightController.text
                  .trim(),
            );

            final distance =
            double.tryParse(
              set.distanceController
                  .text
                  .trim(),
            );

            if (weight == null ||
                weight < 0 ||
                distance == null ||
                distance <= 0) {
              return false;
            }

          default:
            return false;
        }
      }
    }

    return true;
  }

  Future<void> _saveChanges() async {
    if (!_validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
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
      final muscles = _exercises
          .map(
            (exercise) =>
        exercise.primaryMuscle,
      )
          .toSet()
          .join(' + ');

      final updatedWorkout =
      widget.workout.copyWith(
        title: muscles.isEmpty
            ? 'Weight Training'
            : muscles,
      );

      final editData =
      <WorkoutExerciseEditData>[];

      for (final exercise
      in _exercises) {
        final setData =
        <ExerciseSetEditData>[];

        for (final set
        in exercise.sets) {
          final enteredWeight =
          double.tryParse(
            set.weightController.text
                .trim(),
          );

          setData.add(
            ExerciseSetEditData(
              weightKg:
              enteredWeight ==
                  null
                  ? null
                  : _enteredWeightToKg(
                enteredWeight,
              ),
              reps: int.tryParse(
                set.repsController.text
                    .trim(),
              ),
              durationSeconds:
              int.tryParse(
                set.durationController
                    .text
                    .trim(),
              ),
              distanceMeters:
              double.tryParse(
                set.distanceController
                    .text
                    .trim(),
              ),
            ),
          );
        }

        editData.add(
          WorkoutExerciseEditData(
            exerciseId:
            exercise.exerciseId,
            exerciseName:
            exercise.exerciseName,
            primaryMuscle:
            exercise.primaryMuscle,
            trackingType:
            exercise.trackingType,
            sets: setData,
          ),
        );
      }

      await DatabaseService.instance
          .replaceWeightWorkoutDetails(
        workout: updatedWorkout,
        exercises: editData,
      );

      if (!mounted) return;

      Navigator.of(context).pop(
        true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not save changes: $error',
          ),
        ),
      );
    }
  }

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
        title: const Text(
          'EDIT WORKOUT',
          style: TextStyle(
            color:
            ShubXColors.white,
            fontWeight:
            FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: _loading
          ? const Center(
        child:
        CircularProgressIndicator(
          color:
          ShubXColors.gold,
        ),
      )
          : Column(
        children: [
          Padding(
            padding:
            const EdgeInsets
                .fromLTRB(
              20,
              4,
              20,
              12,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'WEIGHT UNIT',
                    style:
                    TextStyle(
                      color:
                      ShubXColors
                          .grey,
                      fontSize: 11,
                      fontWeight:
                      FontWeight
                          .w700,
                      letterSpacing:
                      1.2,
                    ),
                  ),
                ),
                _UnitButton(
                  label: 'KG',
                  selected:
                  _weightUnit ==
                      EditWeightUnit
                          .kg,
                  onTap: () =>
                      _changeUnit(
                        EditWeightUnit
                            .kg,
                      ),
                ),
                const SizedBox(
                  width: 8,
                ),
                _UnitButton(
                  label: 'LB',
                  selected:
                  _weightUnit ==
                      EditWeightUnit
                          .lb,
                  onTap: () =>
                      _changeUnit(
                        EditWeightUnit
                            .lb,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
            ListView.separated(
              padding:
              const EdgeInsets
                  .fromLTRB(
                20,
                8,
                20,
                120,
              ),
              itemCount:
              _exercises.length,
              separatorBuilder:
                  (_, __) =>
              const SizedBox(
                height: 16,
              ),
              itemBuilder:
                  (context, index) {
                final exercise =
                _exercises[
                index];

                return _EditExerciseCard(
                  exercise:
                  exercise,
                  weightLabel:
                  _weightLabel,
                  onAddSet: () =>
                      _addSet(
                        exercise,
                      ),
                  onRemoveSet:
                      (setIndex) =>
                      _removeSet(
                        exercise,
                        setIndex,
                      ),
                  onRemoveExercise:
                      () =>
                      _removeExercise(
                        index,
                      ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar:
      _loading
          ? null
          : SafeArea(
        child: Container(
          color:
          ShubXColors
              .black,
          padding:
          const EdgeInsets
              .fromLTRB(
            20,
            10,
            20,
            16,
          ),
          child:
          ElevatedButton(
            onPressed: _saving
                ? null
                : _saveChanges,
            child: _saving
                ? const SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                strokeWidth:
                2,
                color:
                ShubXColors
                    .black,
              ),
            )
                : const Text(
              'SAVE CHANGES',
            ),
          ),
        ),
      ),
    );
  }
}

class _EditExerciseCard
    extends StatelessWidget {
  final _EditableExercise exercise;
  final String weightLabel;
  final VoidCallback onAddSet;
  final void Function(int)
  onRemoveSet;
  final VoidCallback
  onRemoveExercise;

  const _EditExerciseCard({
    required this.exercise,
    required this.weightLabel,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onRemoveExercise,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShubXColors.card,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      exercise
                          .exerciseName,
                      style:
                      const TextStyle(
                        color:
                        ShubXColors
                            .white,
                        fontSize: 17,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      exercise
                          .primaryMuscle,
                      style:
                      const TextStyle(
                        color:
                        ShubXColors
                            .gold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed:
                onRemoveExercise,
                icon: const Icon(
                  Icons.delete_outline,
                  color:
                  Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          for (int index = 0;
          index <
              exercise.sets.length;
          index++)
            Padding(
              padding:
              const EdgeInsets.only(
                bottom: 10,
              ),
              child: _EditSetRow(
                trackingType:
                exercise
                    .trackingType,
                entry:
                exercise.sets[
                index],
                setNumber:
                index + 1,
                weightLabel:
                weightLabel,
                canDelete:
                exercise.sets
                    .length >
                    1,
                onDelete: () =>
                    onRemoveSet(
                      index,
                    ),
              ),
            ),

          TextButton.icon(
            onPressed: onAddSet,
            icon: const Icon(
              Icons.add,
              color:
              ShubXColors.gold,
            ),
            label: const Text(
              'ADD SET',
              style: TextStyle(
                color:
                ShubXColors.gold,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditSetRow
    extends StatelessWidget {
  final String trackingType;
  final _EditableSet entry;
  final int setNumber;
  final String weightLabel;
  final bool canDelete;
  final VoidCallback onDelete;

  const _EditSetRow({
    required this.trackingType,
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
        const TextInputType
            .numberWithOptions(
          decimal: true,
        ),
        style: const TextStyle(
          color:
          ShubXColors.white,
        ),
        decoration:
        InputDecoration(
          labelText: label,
          labelStyle:
          const TextStyle(
            color:
            ShubXColors.grey,
            fontSize: 12,
          ),
          filled: true,
          fillColor:
          ShubXColors.charcoal,
          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              12,
            ),
            borderSide:
            BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final fields = <Widget>[];

    switch (trackingType) {
      case 'weightAndReps':
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
        break;

      case 'repsOnly':
        fields.add(
          _field(
            entry.repsController,
            'reps',
          ),
        );
        break;

      case 'duration':
        fields.add(
          _field(
            entry.durationController,
            'seconds',
          ),
        );
        break;

      case 'weightAndDistance':
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
        break;
    }

    return Row(
      children: [
        SizedBox(
          width: 42,
          child: Text(
            'SET $setNumber',
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
        const SizedBox(width: 8),
        ...fields,
        if (canDelete) ...[
          const SizedBox(width: 4),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.close,
              color:
              ShubXColors.grey,
              size: 18,
            ),
          ),
        ],
      ],
    );
  }
}

class _UnitButton
    extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UnitButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(12),
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected
              ? ShubXColors.gold
              : ShubXColors.card,
          borderRadius:
          BorderRadius.circular(12),
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
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EditableExercise {
  final String exerciseId;
  final String exerciseName;
  final String primaryMuscle;
  final String trackingType;
  final List<_EditableSet> sets;

  _EditableExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscle,
    required this.trackingType,
    required this.sets,
  });

  void dispose() {
    for (final set in sets) {
      set.dispose();
    }
  }
}

class _EditableSet {
  final TextEditingController
  weightController;
  final TextEditingController
  repsController;
  final TextEditingController
  durationController;
  final TextEditingController
  distanceController;

  _EditableSet({
    required this.weightController,
    required this.repsController,
    required this.durationController,
    required this.distanceController,
  });

  factory _EditableSet.empty() {
    return _EditableSet(
      weightController:
      TextEditingController(),
      repsController:
      TextEditingController(),
      durationController:
      TextEditingController(),
      distanceController:
      TextEditingController(),
    );
  }

  factory _EditableSet.fromStoredSet(
      ExerciseSet set, {
        required EditWeightUnit
        displayUnit,
      }) {
    const poundsPerKg =
    2.2046226218;

    String weight = '';

    if (set.weightKg != null) {
      final displayed =
      displayUnit ==
          EditWeightUnit.kg
          ? set.weightKg!
          : set.weightKg! *
          poundsPerKg;

      weight =
      (displayed -
          displayed
              .round())
          .abs() <
          0.05
          ? displayed
          .round()
          .toString()
          : displayed
          .toStringAsFixed(
        1,
      );
    }

    return _EditableSet(
      weightController:
      TextEditingController(
        text: weight,
      ),
      repsController:
      TextEditingController(
        text: set.reps
            ?.toString() ??
            '',
      ),
      durationController:
      TextEditingController(
        text: set.durationSeconds
            ?.toString() ??
            '',
      ),
      distanceController:
      TextEditingController(
        text: set.distanceMeters
            ?.toString() ??
            '',
      ),
    );
  }

  void dispose() {
    weightController.dispose();
    repsController.dispose();
    durationController.dispose();
    distanceController.dispose();
  }
}