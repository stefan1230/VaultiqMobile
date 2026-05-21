import 'package:flutter/material.dart';

import '../models/insights.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/fade_slide.dart';
import '../widgets/fintech_ui.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.insights,
    required this.onNavigate,
  });

  final Insights insights;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final net = insights.netPosition;
    final netPositive = net >= 0;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(gradient: AppColors.meshBackground(dark)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          FadeSlide(
            child: SectionHeader(
              title: 'Overview',
              subtitle: 'Your financial snapshot',
            ),
          ),
          FadeSlide(
            delay: const Duration(milliseconds: 80),
            child: HeroBalanceCard(
              label: 'Net position',
              valueText: formatLKR(net),
              subtitle: 'Savings minus total debt',
              accentIcon: netPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      netPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      netPositive ? 'Positive' : 'Watch',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total debt',
                  value: insights.totalDebt,
                  accent: AppColors.coral,
                  compact: true,
                  delay: const Duration(milliseconds: 140),
                  icon: Icons.credit_card_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Total saved',
                  value: insights.totalSaved,
                  accent: AppColors.emerald,
                  compact: true,
                  delay: const Duration(milliseconds: 200),
                  icon: Icons.savings_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FadeSlide(
            delay: const Duration(milliseconds: 260),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick actions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        QuickActionTile(
                          icon: Icons.credit_card_rounded,
                          label: 'Debts',
                          color: AppColors.coral,
                          onTap: () => onNavigate(1),
                        ),
                        const SizedBox(width: 10),
                        QuickActionTile(
                          icon: Icons.savings_rounded,
                          label: 'Funds',
                          color: AppColors.emerald,
                          onTap: () => onNavigate(2),
                        ),
                        const SizedBox(width: 10),
                        QuickActionTile(
                          icon: Icons.insights_rounded,
                          label: 'Insights',
                          color: AppColors.violet,
                          onTap: () => onNavigate(3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (insights.lastMonth != null) ...[
            const SizedBox(height: 12),
            FadeSlide(
              delay: const Duration(milliseconds: 320),
              child: _InsightTile(
                icon: Icons.payments_rounded,
                iconColor: AppColors.teal,
                title: 'Payments in ${formatMonthLabel(insights.lastMonth!)}',
                value: formatLKR(insights.lastMonthPayments),
              ),
            ),
          ],
          if (insights.topPerformer != null) ...[
            const SizedBox(height: 12),
            FadeSlide(
              delay: const Duration(milliseconds: 380),
              child: _InsightTile(
                icon: Icons.emoji_events_rounded,
                iconColor: AppColors.amber,
                title: 'Top progress',
                subtitle: insights.topPerformer!.account.name,
                value: '${insights.topPerformer!.pct.toStringAsFixed(0)}%',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (subtitle != null)
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
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.teal,
                ),
          ),
        ],
      ),
    );
  }
}
