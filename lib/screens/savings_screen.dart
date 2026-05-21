import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/portfolio_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/currency_input.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key, this.userId});

  final String? userId;

  Future<void> _addGoal(BuildContext context) async {
    final nameCtrl = TextEditingController();
    double target = 0;
    final portfolio = context.read<PortfolioProvider>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New savings goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal name'),
            ),
            const SizedBox(height: 12),
            CurrencyInput(
              label: 'Target amount',
              onChanged: (v) => target = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (ok == true && nameCtrl.text.trim().isNotEmpty && context.mounted) {
      await portfolio.createSavingsGoal(
        nameCtrl.text.trim(),
        target,
        userId: userId,
      );
    }
    nameCtrl.dispose();
  }

  Future<void> _mutate(
    BuildContext context,
    int index,
    String action,
  ) async {
    double amount = 0;
    final portfolio = context.read<PortfolioProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(action == 'add' ? 'Add funds' : 'Withdraw'),
        content: CurrencyInput(
          label: 'Amount',
          onChanged: (v) => amount = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (ok == true && amount > 0 && context.mounted) {
      await portfolio.mutateSavings(index, amount, action, userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, _) {
        final goals = portfolio.savings;
        final insights = portfolio.insights;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Savings & goals',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => _addGoal(context),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatLKR(insights.totalSaved),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.teal,
                          ),
                    ),
                    Text(
                      'of ${formatLKR(insights.totalSavingsTarget)} target',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (insights.savingsProgress / 100).clamp(0, 1),
                      color: AppColors.teal,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(goals.length, (i) {
              final g = goals[i];
              final pct =
                  g.target > 0 ? (g.current / g.target * 100).clamp(0, 100) : 0.0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              g.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => portfolio.deleteSavings(
                              i,
                              userId: userId,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${formatLKR(g.current)} / ${formatLKR(g.target)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: pct / 100),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _mutate(context, i, 'add'),
                              child: const Text('Add'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _mutate(context, i, 'subtract'),
                              child: const Text('Withdraw'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
