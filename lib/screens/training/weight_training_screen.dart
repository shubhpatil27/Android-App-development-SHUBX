import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/exercise_library.dart';
import '../../models/exercise.dart';
import 'weight_workout_logger_screen.dart';

class WeightTrainingScreen extends StatefulWidget {
  const WeightTrainingScreen({
    super.key,
  });

  @override
  State<WeightTrainingScreen> createState() =>
      _WeightTrainingScreenState();
}

class _WeightTrainingScreenState
    extends State<WeightTrainingScreen> {
  String _selectedMuscle = 'Chest';

  final Set<String> _selectedExerciseIds = {};

  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Exercise> get _visibleExercises {
    if (_searchQuery.trim().isNotEmpty) {
      return ExerciseLibrary.search(
        _searchQuery,
      );
    }

    return ExerciseLibrary.forMuscle(
      _selectedMuscle,
    );
  }

  List<Exercise> get _selectedExercises {
    return ExerciseLibrary.exercises
        .where(
          (exercise) =>
          _selectedExerciseIds.contains(
            exercise.id,
          ),
    )
        .toList();
  }

  Future<void> _continueToLogger() async {
    final saved =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            WeightWorkoutLoggerScreen(
              exercises: _selectedExercises,
            ),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShubXColors.black,
      appBar: AppBar(
        backgroundColor: ShubXColors.black,
        elevation: 0,
        title: const Text(
          'WEIGHT TRAINING',
          style: TextStyle(
            color: ShubXColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                12,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: const TextStyle(
                  color: ShubXColors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Search exercises',
                  hintStyle: const TextStyle(
                    color: ShubXColors.grey,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: ShubXColors.gold,
                  ),
                  suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController
                          .clear();

                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                      color:
                      ShubXColors.grey,
                    ),
                  )
                      : null,
                  filled: true,
                  fillColor: ShubXColors.card,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            if (_searchQuery.isEmpty)
              SizedBox(
                height: 52,
                child: ListView.separated(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: ExerciseLibrary
                      .muscleGroups.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final muscle =
                    ExerciseLibrary
                        .muscleGroups[index];

                    final selected =
                        _selectedMuscle == muscle;

                    return ChoiceChip(
                      label: Text(muscle),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedMuscle = muscle;
                        });
                      },
                      backgroundColor:
                      ShubXColors.card,
                      selectedColor:
                      ShubXColors.gold
                          .withValues(
                        alpha: 0.15,
                      ),
                      side: BorderSide(
                        color: selected
                            ? ShubXColors.gold
                            : ShubXColors.darkGrey,
                      ),
                      labelStyle: TextStyle(
                        color: selected
                            ? ShubXColors.gold
                            : ShubXColors.grey,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchQuery.isEmpty
                        ? _selectedMuscle
                        .toUpperCase()
                        : 'SEARCH RESULTS',
                    style: const TextStyle(
                      color: ShubXColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '${_selectedExerciseIds.length} selected',
                    style: const TextStyle(
                      color: ShubXColors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _visibleExercises.isEmpty
                  ? const Center(
                child: Text(
                  'No exercises found.',
                  style: TextStyle(
                    color: ShubXColors.grey,
                  ),
                ),
              )
                  : ListView.separated(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  110,
                ),
                itemCount:
                _visibleExercises.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final exercise =
                  _visibleExercises[index];

                  return _ExerciseCard(
                    exercise: exercise,
                    selected:
                    _selectedExerciseIds
                        .contains(
                      exercise.id,
                    ),
                    onTap: () {
                      setState(() {
                        if (_selectedExerciseIds
                            .contains(
                          exercise.id,
                        )) {
                          _selectedExerciseIds
                              .remove(
                            exercise.id,
                          );
                        } else {
                          _selectedExerciseIds
                              .add(
                            exercise.id,
                          );
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
            _selectedExerciseIds.isEmpty
                ? null
                : _continueToLogger,
            child: Text(
              _selectedExerciseIds.isEmpty
                  ? 'SELECT EXERCISES'
                  : 'ADD ${_selectedExerciseIds.length} EXERCISE${_selectedExerciseIds.length == 1 ? '' : 'S'}',
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool selected;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? ShubXColors.gold.withValues(
            alpha: 0.08,
          )
              : ShubXColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? ShubXColors.gold
                : ShubXColors.darkGrey,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: ShubXColors.charcoal,
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: const Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.accessibility_new,
                    color: ShubXColors.gold,
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'VISUAL',
                    style: TextStyle(
                      color: ShubXColors.grey,
                      fontSize: 8,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: ShubXColors.white,
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    exercise.equipment,
                    style: const TextStyle(
                      color: ShubXColors.grey,
                      fontSize: 12,
                    ),
                  ),

                  if (exercise
                      .secondaryMuscles
                      .isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Also: ${exercise.secondaryMuscles.join(', ')}',
                      style: const TextStyle(
                        color:
                        ShubXColors.darkGrey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.add_circle_outline,
              color: selected
                  ? ShubXColors.gold
                  : ShubXColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}