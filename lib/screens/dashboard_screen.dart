import 'package:flutter/material.dart';

import '../models/insights.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
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
    final netColor = net >= 0 ? Colors.green : Colors.orange;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your financial snapshot',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 16),
        StatCard(
          label: 'Net position',
          value: net,
          subtitle: 'Savings minus total debt',
          accent: netColor,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total debt',
                value: insights.totalDebt,
                accent: Colors.orange,
                compact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Total saved',
                value: insights.totalSaved,
                accent: AppColors.teal,
                compact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.credit_card, size: 18),
                      label: const Text('Debts'),
                      onPressed: () => onNavigate(1),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.savings, size: 18),
                      label: const Text('Funds'),
                      onPressed: () => onNavigate(2),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.insights, size: 18),
                      label: const Text('Insights'),
                      onPressed: () => onNavigate(3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (insights.lastMonth != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments, color: AppColors.teal),
              title: Text('Payments in ${formatMonthLabel(insights.lastMonth!)}'),
              trailing: Text(
                formatLKR(insights.lastMonthPayments),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        if (insights.topPerformer != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: const Text('Top progress'),
              subtitle: Text(insights.topPerformer!.account.name),
              trailing: Text(
                '${insights.topPerformer!.pct.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
