import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/portfolio_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/fade_slide.dart';
import '../widgets/fintech_ui.dart';
import '../widgets/stat_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final insights = context.watch<PortfolioProvider>().insights;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(gradient: AppColors.meshBackground(dark)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const SectionHeader(
            title: 'Insights',
            subtitle: 'Spending, paydown, and utilization',
          ),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Interest paid',
                  value: insights.totalInterest,
                  compact: true,
                  delay: const Duration(milliseconds: 60),
                  icon: Icons.percent_rounded,
                  accent: AppColors.coral,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Total paydown',
                  value: insights.totalPaydown,
                  accent: AppColors.emerald,
                  compact: true,
                  delay: const Duration(milliseconds: 120),
                  icon: Icons.trending_down_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'CC debt',
                  value: insights.ccDebt,
                  subtitle: '${insights.ccCount} cards',
                  compact: true,
                  delay: const Duration(milliseconds: 180),
                  icon: Icons.credit_card_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Loan debt',
                  value: insights.loanDebt,
                  subtitle: '${insights.loanCount} loans',
                  compact: true,
                  delay: const Duration(milliseconds: 240),
                  icon: Icons.account_balance_rounded,
                  accent: AppColors.violet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FadeSlide(
            delay: const Duration(milliseconds: 300),
            child: GlassCard(
              child: Row(
                children: [
                  _MetricIcon(
                    icon: Icons.pie_chart_rounded,
                    color: AppColors.teal,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Avg. CC utilization',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    '${insights.avgCcUtilization.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.teal,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (insights.debtToSavingsRatio != null) ...[
            const SizedBox(height: 12),
            FadeSlide(
              delay: const Duration(milliseconds: 360),
              child: GlassCard(
                child: Row(
                  children: [
                    _MetricIcon(
                      icon: Icons.balance_rounded,
                      color: AppColors.amber,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Debt to savings ratio',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      insights.debtToSavingsRatio!.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FadeSlide(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Recent activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          if (insights.recentActivity.isEmpty)
            FadeSlide(
              delay: const Duration(milliseconds: 440),
              child: GlassCard(
                child: Text(
                  'No statements logged yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                ),
              ),
            )
          else
            ...insights.recentActivity.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FadeSlide(
                      delay: Duration(milliseconds: 460 + e.key * 60),
                      child: GlassCard(
                        child: Row(
                          children: [
                            _MetricIcon(
                              icon: Icons.receipt_long_rounded,
                              color: AppColors.violet,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.value.accountName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    formatMonthLabel(e.value.statement.month),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatLKR(e.value.statement.paymentMade),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _MetricIcon extends StatelessWidget {
  const _MetricIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
