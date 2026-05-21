import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.accent,
    this.compact = false,
  });

  final String label;
  final num value;
  final String? subtitle;
  final Color? accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.teal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              compact ? formatLKRCompact(value) : formatLKR(value),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
