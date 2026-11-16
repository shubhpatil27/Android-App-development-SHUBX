import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';
import '../../services/preferences_service.dart';

class EditXScreen extends StatefulWidget {
  final UserPreferences preferences;

  const EditXScreen({
    super.key,
    required this.preferences,
  });

  @override
  State<EditXScreen> createState() =>
      _EditXScreenState();
}

class _EditXScreenState
    extends State<EditXScreen> {
  late Set<String> _trainingTypes;
  late Set<String> _goals;
  late int _weeklyTarget;

  bool _saving = false;

  final List<_TrainingTypeOption>
  _trainingOptions = const [
    _TrainingTypeOption(
      name: 'Weight Training',
      subtitle:
      'Strength, muscle and gym training',
      icon: Icons.fitness_center,
    ),
    _TrainingTypeOption(
      name: 'Running',
      subtitle:
      'Distance, pace and running performance',
      icon: Icons.directions_run,
    ),
    _TrainingTypeOption(
      name: 'HYROX',
      subtitle:
      'Running and functional fitness',
      icon: Icons.bolt,
    ),
    _TrainingTypeOption(
      name: 'Cardio',
      subtitle:
      'Walking, cycling and endurance',
      icon:
      Icons.favorite_outline,
    ),
    _TrainingTypeOption(
      name: 'Custom',
      subtitle:
      'Your own training style',
      icon: Icons.add,
    ),
  ];

  final Map<String, List<String>>
  _goalsByType = {
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
    'Custom': [
      'Custom Goal',
    ],
  };

  @override
  void initState() {
    super.initState();

    _trainingTypes =
    Set<String>.from(
      widget.preferences.trainingTypes,
    );

    // Migrate old Cardio name.
    if (_trainingTypes.remove(
      'Cardio & Endurance',
    )) {
      _trainingTypes.add('Cardio');
    }

    _goals =
    Set<String>.from(
      widget.preferences.goals,
    );

    _weeklyTarget =
        widget.preferences.weeklyTarget;
  }

  Set<String> get _availableGoals {
    final result = <String>{};

    for (final type
    in _trainingTypes) {
      result.addAll(
        _goalsByType[type] ?? [],
      );
    }

    result.add('Custom Goal');

    return result;
  }

  void _cleanGoals() {
    final available =
        _availableGoals;

    _goals.removeWhere(
          (goal) =>
      !available.contains(goal),
    );
  }

  Future<void> _save() async {
    if (_trainingTypes.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Select at least one training type.',
          ),
        ),
      );
      return;
    }

    if (_goals.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Select at least one goal.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    final updated =
    widget.preferences.copyWith(
      trainingTypes:
      Set<String>.from(
        _trainingTypes,
      ),
      goals:
      Set<String>.from(
        _goals,
      ),
      weeklyTarget:
      _weeklyTarget,
    );

    await PreferencesService.instance
        .savePreferences(updated);

    if (!mounted) return;

    Navigator.of(context).pop(
      updated,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final availableGoals =
    _availableGoals.toList();

    return Scaffold(
      backgroundColor:
      ShubXColors.black,
      appBar: AppBar(
        backgroundColor:
        ShubXColors.black,
        title: const Text(
          'EDIT YOUR X',
          style: TextStyle(
            color:
            ShubXColors.white,
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          120,
        ),
        children: [
          const Text(
            'TRAINING',
            style: TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          ..._trainingOptions.map(
                (option) {
              final selected =
              _trainingTypes
                  .contains(
                option.name,
              );

              return Padding(
                padding:
                const EdgeInsets
                    .only(
                  bottom: 10,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _trainingTypes
                            .remove(
                          option.name,
                        );
                      } else {
                        _trainingTypes
                            .add(
                          option.name,
                        );
                      }

                      _cleanGoals();
                    });
                  },
                  borderRadius:
                  BorderRadius
                      .circular(16),
                  child: Container(
                    padding:
                    const EdgeInsets
                        .all(16),
                    decoration:
                    BoxDecoration(
                      color: selected
                          ? ShubXColors
                          .gold
                          .withValues(
                        alpha:
                        0.08,
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
                        Icon(
                          option.icon,
                          color: selected
                              ? ShubXColors
                              .gold
                              : ShubXColors
                              .grey,
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                option
                                    .name,
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
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                option
                                    .subtitle,
                                style:
                                const TextStyle(
                                  color:
                                  ShubXColors
                                      .grey,
                                  fontSize:
                                  11,
                                ),
                              ),
                            ],
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

          const SizedBox(height: 28),

          const Text(
            'GOALS',
            style: TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          ...availableGoals.map(
                (goal) {
              final selected =
              _goals.contains(goal);

              return CheckboxListTile(
                value: selected,
                activeColor:
                ShubXColors.gold,
                checkColor:
                ShubXColors.black,
                contentPadding:
                EdgeInsets.zero,
                title: Text(
                  goal,
                  style:
                  const TextStyle(
                    color:
                    ShubXColors.white,
                  ),
                ),
                onChanged: (_) {
                  setState(() {
                    if (selected) {
                      _goals.remove(goal);
                    } else {
                      _goals.add(goal);
                    }
                  });
                },
              );
            },
          ),

          const SizedBox(height: 28),

          const Text(
            'WEEKLY TARGET',
            style: TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            decoration:
            BoxDecoration(
              color: ShubXColors.card,
              borderRadius:
              BorderRadius.circular(
                16,
              ),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                IconButton(
                  onPressed:
                  _weeklyTarget > 1
                      ? () {
                    setState(
                          () {
                        _weeklyTarget--;
                      },
                    );
                  }
                      : null,
                  icon: const Icon(
                    Icons.remove,
                  ),
                ),

                Text(
                  '$_weeklyTarget sessions / week',
                  style:
                  const TextStyle(
                    color:
                    ShubXColors.white,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                IconButton(
                  onPressed:
                  _weeklyTarget < 14
                      ? () {
                    setState(
                          () {
                        _weeklyTarget++;
                      },
                    );
                  }
                      : null,
                  icon: const Icon(
                    Icons.add,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
      SafeArea(
        child: Container(
          color:
          ShubXColors.black,
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
            onPressed:
            _saving ? null : _save,
            child: _saving
                ? const SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color:
                ShubXColors.black,
              ),
            )
                : const Text(
              'SAVE MY X',
            ),
          ),
        ),
      ),
    );
  }
}

class _TrainingTypeOption {
  final String name;
  final String subtitle;
  final IconData icon;

  const _TrainingTypeOption({
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}