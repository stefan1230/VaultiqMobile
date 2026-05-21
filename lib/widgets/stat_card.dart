import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'animated_counter.dart';
import 'fade_slide.dart';
import 'fintech_ui.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.accent,
    this.compact = false,
    this.delay = Duration.zero,
    this.icon,
  });

  final String label;
  final num value;
  final String? subtitle;
  final Color? accent;
  final bool compact;
  final Duration delay;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.teal;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return FadeSlide(
      delay: delay,
      child: GlassCard(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedCounter(
              value: value,
              format: (v) =>
                  compact ? formatLKRCompact(v.round()) : formatLKR(v.round()),
              style: (compact
                      ? Theme.of(context).textTheme.titleLarge
                      : Theme.of(context).textTheme.headlineSmall)!
                  .copyWith(
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: dark ? 0.45 : 0.5),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
