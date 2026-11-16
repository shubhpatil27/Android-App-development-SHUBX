import 'package:flutter/material.dart';

import '../app/theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool highlighted;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: highlighted
            ? ShubXColors.gold.withValues(alpha: 0.10)
            : ShubXColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted
              ? ShubXColors.gold
              : ShubXColors.darkGrey,
          width: highlighted ? 1.2 : 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: highlighted
                    ? ShubXColors.gold
                    : ShubXColors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: highlighted
                        ? ShubXColors.gold
                        : ShubXColors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            value,
            style: const TextStyle(
              color: ShubXColors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              color: ShubXColors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}