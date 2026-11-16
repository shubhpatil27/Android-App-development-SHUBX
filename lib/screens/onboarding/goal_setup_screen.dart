import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';
import '../../services/preferences_service.dart';
import '../main/main_shell.dart';

class GoalSetupScreen extends StatefulWidget {
  final Set<String> selectedTrainingTypes;

  const GoalSetupScreen({
    super.key,
    required this.selectedTrainingTypes,
  });

  @override
  State<GoalSetupScreen> createState() =>
      _GoalSetupScreenState();
}

class _GoalSetupScreenState
    extends State<GoalSetupScreen> {
  int sessionsPerWeek = 4;

  final Set<String> selectedGoals = {};

  bool _saving = false;

  final Map<String, List<String>>
  _goalsByTrainingType = {
    'Weight Training': [
      'Build Muscle',
      'Get Stronger',
      'Improve Strength Endurance',
      'Stay Consistent',
    ],
    'Running': [
      'Run Faster',
      'Run Further',
      'Improve Endurance',
      'Race Preparation',
      'Stay Consistent',
    ],
    'HYROX': [
      'Improve HYROX Time',
      'Improve Station Performance',
      'Improve Running',
      'Race Preparation',
      'Stay Consistent',
    ],
    'Cardio': [
      'Improve Endurance',
      'Improve Conditioning',
      'Increase Training Duration',
      'Stay Consistent',
    ],
    'Cardio & Endurance': [
      'Improve Endurance',
      'Improve Conditioning',
      'Increase Training Duration',
      'Stay Consistent',
    ],
    'General Fitness': [
      'Stay Active',
      'Improve Overall Fitness',
      'Build Consistency',
    ],
    'Custom': [
      'Custom Goal',
    ],
  };

  List<String> get availableGoals {
    final goals = <String>[];

    for (final trainingType
    in widget.selectedTrainingTypes) {
      final matchingGoals =
      _goalsByTrainingType[
      trainingType];

      if (matchingGoals != null) {
        for (final goal
        in matchingGoals) {
          if (!goals.contains(goal)) {
            goals.add(goal);
          }
        }
      }
    }

    if (!goals.contains(
      'Custom Goal',
    )) {
      goals.add('Custom Goal');
    }

    return goals;
  }

  Future<void> _createMyX() async {
    if (selectedGoals.isEmpty) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final preferences =
    UserPreferences(
      trainingTypes:
      Set<String>.from(
        widget.selectedTrainingTypes,
      ),
      goals:
      Set<String>.from(
        selectedGoals,
      ),
      weeklyTarget:
      sessionsPerWeek,
      weightUnit: 'lb',
      distanceUnit: 'mi',
    );

    await PreferencesService.instance
        .savePreferences(
      preferences,
    );

    if (!mounted) return;

    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainShell(
          initialPreferences:
          preferences,
        ),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      ShubXColors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
              SingleChildScrollView(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  24,
                  28,
                  24,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(
                            context,
                          ),
                      padding:
                      EdgeInsets.zero,
                      alignment:
                      Alignment
                          .centerLeft,
                      icon: const Icon(
                        Icons.arrow_back,
                        color:
                        ShubXColors
                            .white,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    const Text(
                      'SET YOUR GOALS',
                      style:
                      TextStyle(
                        color:
                        ShubXColors
                            .white,
                        fontSize: 30,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Your X can be more than one thing.',
                      style:
                      TextStyle(
                        color:
                        ShubXColors
                            .grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                      height: 38,
                    ),

                    const Text(
                      'WEEKLY TRAINING TARGET',
                      style:
                      TextStyle(
                        color:
                        ShubXColors
                            .gold,
                        fontSize: 13,
                        fontWeight:
                        FontWeight
                            .w700,
                        letterSpacing:
                        1.5,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        ShubXColors
                            .card,
                        borderRadius:
                        BorderRadius
                            .circular(
                          18,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          _CounterButton(
                            icon:
                            Icons.remove,
                            onPressed:
                            sessionsPerWeek >
                                1
                                ? () {
                              setState(
                                    () {
                                  sessionsPerWeek--;
                                },
                              );
                            }
                                : null,
                          ),

                          Column(
                            children: [
                              Text(
                                '$sessionsPerWeek',
                                style:
                                const TextStyle(
                                  color:
                                  ShubXColors
                                      .white,
                                  fontSize:
                                  38,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),
                              const Text(
                                'sessions / week',
                                style:
                                TextStyle(
                                  color:
                                  ShubXColors
                                      .grey,
                                  fontSize:
                                  13,
                                ),
                              ),
                            ],
                          ),

                          _CounterButton(
                            icon:
                            Icons.add,
                            onPressed:
                            sessionsPerWeek <
                                14
                                ? () {
                              setState(
                                    () {
                                  sessionsPerWeek++;
                                },
                              );
                            }
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 38,
                    ),

                    const Text(
                      'YOUR GOALS',
                      style:
                      TextStyle(
                        color:
                        ShubXColors
                            .gold,
                        fontSize: 13,
                        fontWeight:
                        FontWeight
                            .w700,
                        letterSpacing:
                        1.5,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Choose everything you want SHUBX to help you work toward.',
                      style:
                      TextStyle(
                        color:
                        ShubXColors
                            .grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      '${selectedGoals.length} selected',
                      style:
                      const TextStyle(
                        color:
                        ShubXColors
                            .gold,
                        fontSize: 12,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    ...availableGoals.map(
                          (goal) {
                        final selected =
                        selectedGoals
                            .contains(
                          goal,
                        );

                        return Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            bottom: 10,
                          ),
                          child: InkWell(
                            borderRadius:
                            BorderRadius
                                .circular(
                              16,
                            ),
                            onTap: () {
                              setState(
                                    () {
                                  if (selected) {
                                    selectedGoals
                                        .remove(
                                      goal,
                                    );
                                  } else {
                                    selectedGoals
                                        .add(
                                      goal,
                                    );
                                  }
                                },
                              );
                            },
                            child:
                            AnimatedContainer(
                              duration:
                              const Duration(
                                milliseconds:
                                180,
                              ),
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal:
                                18,
                                vertical:
                                17,
                              ),
                              decoration:
                              BoxDecoration(
                                color: selected
                                    ? ShubXColors
                                    .gold
                                    .withValues(
                                  alpha:
                                  0.10,
                                )
                                    : ShubXColors
                                    .card,
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  16,
                                ),
                                border:
                                Border.all(
                                  color: selected
                                      ? ShubXColors
                                      .gold
                                      : ShubXColors
                                      .darkGrey,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child:
                                    Text(
                                      goal,
                                      style:
                                      TextStyle(
                                        color:
                                        ShubXColors
                                            .white,
                                        fontSize:
                                        16,
                                        fontWeight: selected
                                            ? FontWeight
                                            .w700
                                            : FontWeight
                                            .w500,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(
                                      Icons
                                          .check_circle,
                                      color:
                                      ShubXColors
                                          .gold,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                20,
                10,
                20,
                20,
              ),
              child:
              ElevatedButton(
                onPressed:
                selectedGoals
                    .isEmpty ||
                    _saving
                    ? null
                    : _createMyX,
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
                  'CREATE MY X',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return IconButton(
      onPressed: onPressed,
      style:
      IconButton.styleFrom(
        backgroundColor:
        ShubXColors.charcoal,
        disabledBackgroundColor:
        ShubXColors.charcoal,
        minimumSize:
        const Size(48, 48),
      ),
      icon: Icon(
        icon,
        color: onPressed == null
            ? ShubXColors.darkGrey
            : ShubXColors.gold,
      ),
    );
  }
}