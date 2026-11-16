import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'hyrox_logger_screen.dart';
import 'hyrox_training_logger_screen.dart';

class HyroxScreen extends StatelessWidget {
  const HyroxScreen({
    super.key,
  });

  Future<void> _openFullSimulation(
      BuildContext context,
      ) async {
    final saved =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
        const HyroxLoggerScreen(),
      ),
    );

    if (!context.mounted) return;

    if (saved == true) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _openTraining(
      BuildContext context,
      ) async {
    final saved =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
        const HyroxTrainingLoggerScreen(),
      ),
    );

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
          'HYROX',
          style: TextStyle(
            color: ShubXColors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          40,
        ),
        children: [
          const Text(
            'CHOOSE SESSION',
            style: TextStyle(
              color: ShubXColors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Race simulation or focused HYROX training.',
            style: TextStyle(
              color: ShubXColors.grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 28),

          _HyroxModeCard(
            icon: Icons.flag_outlined,
            title: 'Full Simulation',
            subtitle:
            '8 × 1 km runs • All 8 stations • Full race order',
            badge: 'FULL HYROX',
            onTap: () {
              _openFullSimulation(context);
            },
          ),

          const SizedBox(height: 14),

          _HyroxModeCard(
            icon: Icons.tune,
            title: 'Training Session',
            subtitle:
            'Choose runs and stations • Set your own order',
            badge: 'CUSTOM',
            onTap: () {
              _openTraining(context);
            },
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ShubXColors.card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: ShubXColors.gold,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Full Simulation follows the standard HYROX race structure. Training Session lets you build the workout you are actually doing today.',
                    style: TextStyle(
                      color: ShubXColors.grey,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HyroxModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  const _HyroxModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ShubXColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ShubXColors.darkGrey,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: ShubXColors.gold.withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: ShubXColors.gold,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    badge,
                    style: const TextStyle(
                      color: ShubXColors.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    title,
                    style: const TextStyle(
                      color: ShubXColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: ShubXColors.grey,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: ShubXColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}