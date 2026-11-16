import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_preferences.dart';
import 'cardio_activity_logger_screen.dart';
import 'walking_logger_screen.dart';

class CardioScreen extends StatelessWidget {
  final UserPreferences preferences;

  const CardioScreen({
    super.key,
    required this.preferences,
  });

  Future<void> _openActivity(
      BuildContext context,
      String activity,
      ) async {
    bool? saved;

    if (activity == 'Walking') {
      saved =
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              WalkingLoggerScreen(
                preferences: preferences,
              ),
        ),
      );
    } else {
      saved =
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              CardioActivityLoggerScreen(
                activity: activity,
                preferences: preferences,
              ),
        ),
      );
    }

    if (!context.mounted) return;

    if (saved == true) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = [
      const _CardioActivity(
        name: 'Walking',
        subtitle:
        'Distance • Time • Pace • Estimated Steps',
        icon: Icons.directions_walk,
      ),
      const _CardioActivity(
        name: 'Cycling',
        subtitle:
        'Distance • Time • Average Speed',
        icon: Icons.directions_bike,
      ),
      const _CardioActivity(
        name: 'StairMaster',
        subtitle:
        'Time • Level • Floors',
        icon: Icons.stairs,
      ),
      const _CardioActivity(
        name: 'Elliptical',
        subtitle:
        'Distance • Time • Pace',
        icon: Icons.directions_run,
      ),
      const _CardioActivity(
        name: 'Rowing',
        subtitle:
        'Distance • Time • /500m Pace',
        icon: Icons.rowing,
      ),
      const _CardioActivity(
        name: 'SkiErg',
        subtitle:
        'Distance • Time • /500m Pace',
        icon: Icons.fitness_center,
      ),
      const _CardioActivity(
        name: 'Swimming',
        subtitle:
        'Distance • Time • Pace',
        icon: Icons.pool,
      ),
      const _CardioActivity(
        name: 'Jump Rope',
        subtitle:
        'Time • Reps • Rounds',
        icon: Icons.timer_outlined,
      ),
      const _CardioActivity(
        name: 'Hiking',
        subtitle:
        'Distance • Time • Pace',
        icon: Icons.hiking,
      ),
      const _CardioActivity(
        name: 'Other Cardio',
        subtitle:
        'Create your own cardio activity',
        icon: Icons.add,
      ),
    ];

    return Scaffold(
      backgroundColor:
      ShubXColors.black,
      appBar: AppBar(
        backgroundColor:
        ShubXColors.black,
        title: const Text(
          'CARDIO',
          style: TextStyle(
            color:
            ShubXColors.white,
            fontWeight:
            FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
      ),
      body: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          14,
          20,
          40,
        ),
        children: [
          const Text(
            'CHOOSE ACTIVITY',
            style: TextStyle(
              color:
              ShubXColors.gold,
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Choose the cardio work you completed.',
            style: TextStyle(
              color:
              ShubXColors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 22),

          ...activities.map(
                (activity) {
              return Padding(
                padding:
                const EdgeInsets
                    .only(
                  bottom: 10,
                ),
                child: InkWell(
                  onTap: () {
                    _openActivity(
                      context,
                      activity.name,
                    );
                  },
                  borderRadius:
                  BorderRadius
                      .circular(17),
                  child: Container(
                    padding:
                    const EdgeInsets
                        .all(17),
                    decoration:
                    BoxDecoration(
                      color:
                      ShubXColors.card,
                      borderRadius:
                      BorderRadius
                          .circular(
                        17,
                      ),
                      border:
                      Border.all(
                        color:
                        ShubXColors
                            .darkGrey,
                        width: 0.7,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration:
                          BoxDecoration(
                            color:
                            ShubXColors
                                .gold
                                .withValues(
                              alpha:
                              0.10,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              13,
                            ),
                          ),
                          child: Icon(
                            activity.icon,
                            color:
                            ShubXColors
                                .gold,
                          ),
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
                                activity.name,
                                style:
                                const TextStyle(
                                  color:
                                  ShubXColors
                                      .white,
                                  fontSize:
                                  16,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                activity
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

                        const Icon(
                          Icons
                              .chevron_right,
                          color:
                          ShubXColors
                              .darkGrey,
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
    );
  }
}

class _CardioActivity {
  final String name;
  final String subtitle;
  final IconData icon;

  const _CardioActivity({
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}