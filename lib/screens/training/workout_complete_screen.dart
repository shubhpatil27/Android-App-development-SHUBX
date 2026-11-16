import 'package:flutter/material.dart';

import '../../app/theme.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  final String workoutTitle;
  final int exerciseCount;
  final int setCount;

  const WorkoutCompleteScreen({
    super.key,
    required this.workoutTitle,
    required this.exerciseCount,
    required this.setCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShubXColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: ShubXColors.gold.withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ShubXColors.gold,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: ShubXColors.gold,
                  size: 48,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'WORKOUT COMPLETE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ShubXColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Another step toward your X.',
                style: TextStyle(
                  color: ShubXColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 38),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: ShubXColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      workoutTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ShubXColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _SummaryMetric(
                            value: '$exerciseCount',
                            label: exerciseCount == 1
                                ? 'EXERCISE'
                                : 'EXERCISES',
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 50,
                          color: ShubXColors.darkGrey,
                        ),

                        Expanded(
                          child: _SummaryMetric(
                            value: '$setCount',
                            label: setCount == 1
                                ? 'SET'
                                : 'SETS',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: ShubXColors.gold.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ShubXColors.gold.withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: ShubXColors.gold,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        '+1 completed training session',
                        style: TextStyle(
                          color: ShubXColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('DONE'),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryMetric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: ShubXColors.gold,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            color: ShubXColors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
      ],
    );
  }
}