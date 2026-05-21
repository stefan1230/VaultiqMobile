import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/portfolio_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/stat_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final insights = context.watch<PortfolioProvider>().insights;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Insights',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Interest paid',
                value: insights.totalInterest,
                compact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Total paydown',
                value: insights.totalPaydown,
                accent: Colors.green,
                compact: true,
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
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Loan debt',
                value: insights.loanDebt,
                subtitle: '${insights.loanCount} loans',
                compact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Avg. CC utilization'),
            trailing: Text(
              '${insights.avgCcUtilization.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
          ),
        ),
        if (insights.debtToSavingsRatio != null)
          Card(
            child: ListTile(
              title: const Text('Debt to savings ratio'),
              trailing: Text(
                insights.debtToSavingsRatio!.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Recent activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        if (insights.recentActivity.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No statements logged yet.'),
            ),
          )
        else
          ...insights.recentActivity.map(
            (a) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(a.accountName),
                subtitle: Text(formatMonthLabel(a.statement.month)),
                trailing: Text(
                  formatLKR(a.statement.paymentMade),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
