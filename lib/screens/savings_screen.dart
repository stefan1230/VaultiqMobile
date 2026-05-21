import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/portfolio_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/currency_input.dart';
import '../widgets/fade_slide.dart';
import '../widgets/fintech_ui.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, _) {
        final goals = portfolio.savings;
        final insights = portfolio.insights;

        return Container(
          color: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              SectionHeader(
                title: 'Savings & goals',
                subtitle: '${goals.length} active goals',
                trailing: IconButton.filledTonal(
                  onPressed: () => _addGoal(context),
                  icon: const Icon(Icons.add_rounded),
                ),
              ),
              FadeSlide(
                child: HeroBalanceCard(
                  label: 'Total saved',
                  valueText: formatLKR(insights.totalSaved),
                  subtitle:
                      'of ${formatLKR(insights.totalSavingsTarget)} target',
                  accentIcon: Icons.savings_rounded,
                  trailing: Text(
                    '${insights.savingsProgress.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeSlide(
                delay: const Duration(milliseconds: 80),
                child: GlassCard(
                  child: AnimatedProgressBar(
                    value: (insights.savingsProgress / 100).clamp(0, 1),
                    color: AppColors.lime,
                    height: 10,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(goals.length, (i) {
                final g = goals[i];
                final pct = g.target > 0
                    ? (g.current / g.target * 100).clamp(0, 100)
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FadeSlide(
                    delay: Duration(milliseconds: 120 + i * 70),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.lime.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.flag_rounded,
                                  color: AppColors.lime,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  g.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: () => portfolio.deleteSavings(
                                  i,
                                  userId: userId,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${formatLKR(g.current)} / ${formatLKR(g.target)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          AnimatedProgressBar(
                            value: pct / 100,
                            color: AppColors.lime,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _mutate(context, i, 'add'),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Add'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _mutate(context, i, 'subtract'),
                                  icon: const Icon(Icons.remove, size: 18),
                                  label: const Text('Withdraw'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
