import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';
import 'cardio_screen.dart';
import 'hyrox_screen.dart';
import 'running_logger_screen.dart';
import 'weight_training_screen.dart';

class LogTrainingScreen extends StatelessWidget {
  final UserPreferences preferences;

  const LogTrainingScreen({
    super.key,
    required this.preferences,
  });

  List<_TrainingOption> get _availableOptions {
    final options = <_TrainingOption>[];

    if (preferences.trainingTypes.contains(
      'Weight Training',
    )) {
      options.add(
        const _TrainingOption(
          type: 'Weight Training',
          subtitle:
          'Exercises • Sets • Reps • Weight',
          icon: Icons.fitness_center,
        ),
      );
    }

    if (preferences.trainingTypes.contains(
      'Running',
    )) {
      options.add(
        const _TrainingOption(
          type: 'Running',
          subtitle:
          'Distance • Time • Pace',
          icon: Icons.directions_run,
        ),
      );
    }

    if (preferences.trainingTypes.contains(
      'HYROX',
    )) {
      options.add(
        const _TrainingOption(
          type: 'HYROX',
          subtitle:
          'Full Simulation • Custom Training',
          icon: Icons.bolt,
        ),
      );
    }

    if (preferences.trainingTypes.contains(
      'Cardio',
    ) ||
        preferences.trainingTypes.contains(
          'Cardio & Endurance',
        )) {
      options.add(
        const _TrainingOption(
          type: 'Cardio',
          subtitle:
          'Walking • Cycling • Rowing • More',
          icon: Icons.favorite_outline,
        ),
      );
    }

    options.add(
      const _TrainingOption(
        type: 'Custom',
        subtitle:
        'Log any other activity',
        icon: Icons.add,
      ),
    );

    return options;
  }

  Future<void> _openType(
      BuildContext context,
      String type,
      ) async {
    bool? saved;

    switch (type) {
      case 'Weight Training':
        saved =
        await Navigator.of(context)
            .push<bool>(
          MaterialPageRoute(
            builder: (_) =>
            const WeightTrainingScreen(),
          ),
        );
        break;

      case 'Running':
        saved =
        await Navigator.of(context)
            .push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                RunningLoggerScreen(
                  preferences: preferences,
                ),
          ),
        );
        break;

      case 'HYROX':
        saved =
        await Navigator.of(context)
            .push<bool>(
          MaterialPageRoute(
            builder: (_) =>
            const HyroxScreen(),
          ),
        );
        break;

      case 'Cardio':
        saved =
        await Navigator.of(context)
            .push<bool>(
          MaterialPageRoute(
            builder: (_) =>
                CardioScreen(
                  preferences: preferences,
                ),
          ),
        );
        break;

      case 'Custom':
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Custom activity logging is coming later.',
            ),
          ),
        );

        return;
    }

    if (!context.mounted) return;

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
        title: const Text(
          'LOG TRAINING',
          style: TextStyle(
            color: ShubXColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            40,
          ),
          children: [
            const Text(
              'WHAT ARE YOU TRAINING TODAY?',
              style: TextStyle(
                color: ShubXColors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Choose an activity.',
              style: TextStyle(
                color: ShubXColors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 28),

            ..._availableOptions.map(
                  (option) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: InkWell(
                  onTap: () {
                    _openType(
                      context,
                      option.type,
                    );
                  },
                  borderRadius:
                  BorderRadius.circular(18),
                  child: Container(
                    padding:
                    const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: ShubXColors.card,
                      borderRadius:
                      BorderRadius.circular(18),
                      border: Border.all(
                        color:
                        ShubXColors.darkGrey,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: ShubXColors.gold
                                .withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              14,
                            ),
                          ),
                          child: Icon(
                            option.icon,
                            color:
                            ShubXColors.gold,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                option.type,
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

                              const SizedBox(height: 5),

                              Text(
                                option.subtitle,
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

                        const Icon(
                          Icons.chevron_right,
                          color:
                          ShubXColors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingOption {
  final String type;
  final String subtitle;
  final IconData icon;

  const _TrainingOption({
    required this.type,
    required this.subtitle,
    required this.icon,
  });
}