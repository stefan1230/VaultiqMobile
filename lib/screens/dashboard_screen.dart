import 'package:flutter/material.dart';

import '../models/insights.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/fade_slide.dart';
import '../widgets/fintech_ui.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.insights,
    required this.onNavigate,
  });

  final Insights insights;
  final ValueChanged<int> onNavigate;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final insights = widget.insights;
    final net = insights.netPosition;
    final netPositive = net >= 0;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final debtRatio = insights.totalDebt + insights.totalSaved > 0
        ? insights.totalDebt / (insights.totalDebt + insights.totalSaved)
        : 0.0;
    final savingsRatio = 1 - debtRatio;

    return Container(
      color: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          FadeSlide(
            child: WelcomeHeader(
              onAdd: () => widget.onNavigate(1),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FadeSlide(
                  delay: const Duration(milliseconds: 60),
                  child: MetricSummaryCard(
                    label: 'Total debt',
                    value: formatLKRCompact(insights.totalDebt),
                    progress: debtRatio,
                    progressLabel: '${(debtRatio * 100).toStringAsFixed(0)}% of portfolio',
                    accent: AppColors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FadeSlide(
                  delay: const Duration(milliseconds: 120),
                  child: MetricSummaryCard(
                    label: 'Total saved',
                    value: formatLKRCompact(insights.totalSaved),
                    progress: savingsRatio,
                    progressLabel: '${insights.savingsProgress.toStringAsFixed(0)}% of goal',
                    accent: AppColors.lime,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FadeSlide(
            delay: const Duration(milliseconds: 160),
            child: HeroBalanceCard(
              label: 'Net position',
              valueText: formatLKR(net),
              subtitle: 'Savings minus total debt',
              accentIcon: netPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              trailing: StatusBadge(
                label: netPositive ? 'Healthy' : 'Watch',
                color: netPositive ? AppColors.lime : AppColors.orange,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlide(
            delay: const Duration(milliseconds: 200),
            child: FilterChipBar(
              labels: const ['All', 'Debts', 'Funds'],
              selectedIndex: _filter,
              onSelected: (i) {
                setState(() => _filter = i);
                if (i > 0) widget.onNavigate(i);
              },
            ),
          ),
          const SizedBox(height: 16),
          FadeSlide(
            delay: const Duration(milliseconds: 240),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                QuickActionTile(
                  icon: Icons.credit_card_rounded,
                  label: 'Debts',
                  onTap: () => widget.onNavigate(1),
                ),
                QuickActionTile(
                  icon: Icons.savings_rounded,
                  label: 'Funds',
                  onTap: () => widget.onNavigate(2),
                ),
                QuickActionTile(
                  icon: Icons.insights_rounded,
                  label: 'Insights',
                  onTap: () => widget.onNavigate(3),
                ),
              ],
            ),
          ),
          if (insights.recentActivity.isNotEmpty) ...[
            const SizedBox(height: 24),
            FadeSlide(
              delay: const Duration(milliseconds: 280),
              child: Text(
                'RECENT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            ...insights.recentActivity.take(5).toList().asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FadeSlide(
                      delay: Duration(milliseconds: 300 + e.key * 50),
                      child: _ActivityRow(
                        name: e.value.accountName,
                        month: formatMonthLabel(e.value.statement.month),
                        amount: formatLKR(e.value.statement.paymentMade),
                        paid: e.value.statement.paymentMade > 0,
                      ),
                    ),
                  ),
                ),
          ],
          if (insights.lastMonth != null) ...[
            const SizedBox(height: 8),
            FadeSlide(
              delay: const Duration(milliseconds: 380),
              child: _InsightTile(
                icon: Icons.payments_rounded,
                iconColor: AppColors.lime,
                title: 'Payments in ${formatMonthLabel(insights.lastMonth!)}',
                value: formatLKR(insights.lastMonthPayments),
              ),
            ),
          ],
          if (insights.topPerformer != null) ...[
            const SizedBox(height: 12),
            FadeSlide(
              delay: const Duration(milliseconds: 420),
              child: _InsightTile(
                icon: Icons.emoji_events_rounded,
                iconColor: AppColors.orange,
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

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.name,
    required this.month,
    required this.amount,
    required this.paid,
  });

  final String name;
  final String month;
  final String amount;
  final bool paid;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.cardDarkElevated,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.lime,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  month,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              StatusBadge(
                label: paid ? 'Paid' : 'Logged',
                color: paid ? AppColors.lime : AppColors.orange,
              ),
            ],
          ),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
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
                          color: AppColors.textMuted,
                        ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.lime,
                ),
          ),
        ],
      ),
    );
  }
}
