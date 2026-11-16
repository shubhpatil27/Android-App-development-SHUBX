import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'goal_setup_screen.dart';

class TrainingGoalsScreen extends StatefulWidget {
  const TrainingGoalsScreen({super.key});

  @override
  State<TrainingGoalsScreen> createState() =>
      _TrainingGoalsScreenState();
}

class _TrainingGoalsScreenState extends State<TrainingGoalsScreen> {
  final Set<String> _selectedGoals = {};

  final List<TrainingGoal> _goals = const [
    TrainingGoal(
      name: 'Weight Training',
      subtitle: 'Strength, muscle and gym training',
      icon: Icons.fitness_center,
    ),
    TrainingGoal(
      name: 'Running',
      subtitle: 'Distance, pace and running performance',
      icon: Icons.directions_run,
    ),
    TrainingGoal(
      name: 'HYROX',
      subtitle: 'Running and functional fitness',
      icon: Icons.bolt,
    ),
    TrainingGoal(
      name: 'Cardio & Endurance',
      subtitle: 'Build your conditioning',
      icon: Icons.favorite_outline,
    ),
    TrainingGoal(
      name: 'General Fitness',
      subtitle: 'Stay active and consistent',
      icon: Icons.monitor_heart_outlined,
    ),
    TrainingGoal(
      name: 'Custom',
      subtitle: 'Define your own X',
      icon: Icons.add,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShubXColors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "WHAT'S YOUR X?",
                    style: TextStyle(
                      color: ShubXColors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose everything that represents how you train.',
                    style: TextStyle(
                      color: ShubXColors.grey,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedGoals.length} selected',
                    style: const TextStyle(
                      color: ShubXColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _goals.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final selected =
                  _selectedGoals.contains(goal.name);

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedGoals.remove(goal.name);
                        } else {
                          _selectedGoals.add(goal.name);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: selected
                            ? ShubXColors.gold.withValues(alpha: 0.10)
                            : ShubXColors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? ShubXColors.gold
                              : ShubXColors.darkGrey,
                          width: selected ? 1.5 : 0.7,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: selected
                                  ? ShubXColors.gold
                                  : ShubXColors.charcoal,
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            child: Icon(
                              goal.icon,
                              color: selected
                                  ? ShubXColors.black
                                  : ShubXColors.white,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style: const TextStyle(
                                    color: ShubXColors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  goal.subtitle,
                                  style: const TextStyle(
                                    color: ShubXColors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (selected)
                            const Icon(
                              Icons.check_circle,
                              color: ShubXColors.gold,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _selectedGoals.isEmpty
                    ? null
                    : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GoalSetupScreen(
                        selectedTrainingTypes:
                        Set<String>.from(_selectedGoals),
                      ),
                    ),
                  );
                },
                child: const Text('CONTINUE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrainingGoal {
  final String name;
  final String subtitle;
  final IconData icon;

  const TrainingGoal({
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}