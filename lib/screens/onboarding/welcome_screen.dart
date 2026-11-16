import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'training_goals_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShubXColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          child: Column(
            children: [
              const Spacer(),

              const Text(
                'SHUBX',
                style: TextStyle(
                  color: ShubXColors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'DEFINE YOUR X.',
                style: TextStyle(
                  color: ShubXColors.gold,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 50),

              const Text(
                'Your training.\nYour goals.\nYour progress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ShubXColors.white,
                  fontSize: 28,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'SHUBX adapts to the way you train.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ShubXColors.grey,
                  fontSize: 15,
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TrainingGoalsScreen(),
                    ),
                  );
                },
                child: const Text('DEFINE MY X'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}