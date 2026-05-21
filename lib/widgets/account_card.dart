import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/statement.dart';
import '../theme/app_theme.dart';
import '../utils/account_utils.dart';
import '../utils/format.dart';
import 'currency_input.dart';
import 'fade_slide.dart';
import 'fintech_ui.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({
    super.key,
    required this.account,
    required this.statements,
    required this.onCommit,
    required this.onDelete,
    this.animationDelay = Duration.zero,
  });

  final Account account;
  final List<Statement> statements;
  final Future<void> Function(
    String accountId,
    double newBalance,
    double payment,
    String month,
  ) onCommit;
  final Future<void> Function(String accountId) onDelete;
  final Duration animationDelay;

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  double _newBalance = 0;
  double _payment = 0;
  String _month = currentMonthKey();
  bool _expanded = false;

  List<Statement> get _history => widget.statements
      .where((s) => s.accountId == widget.account.id)
      .toList()
    ..sort((a, b) => b.month.compareTo(a.month));

  Future<void> _pickMonth() async {
    final parts = _month.split('-');
    final initial = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _month =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    if (_newBalance <= 0) return;
    await widget.onCommit(
      widget.account.id,
      _newBalance,
      _payment,
      _month,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statement logged')),
      );
      setState(() {
        _newBalance = 0;
        _payment = 0;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: Text(
          'Remove ${widget.account.name} and all its statements?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await widget.onDelete(widget.account.id);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.account;
    final isCc = isCreditCard(a);
    final util = isCc && a.limit > 0 ? a.currentBalance / a.limit * 100 : 0.0;
    final paid = a.initialBalance - a.currentBalance;
    final pct = a.initialBalance > 0
        ? (paid / a.initialBalance * 100).clamp(0, 100)
        : 0.0;
    final progressColor =
        util > 80 ? AppColors.coral : AppColors.teal;

    return FadeSlide(
      delay: widget.animationDelay,
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isCc ? AppColors.coral : AppColors.violet)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCc ? Icons.credit_card_rounded : Icons.account_balance_rounded,
                    color: isCc ? AppColors.coral : AppColors.violet,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        isCc ? 'Credit card' : 'Loan',
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
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: _confirmDelete,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              formatLKR(a.currentBalance),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.teal,
                  ),
            ),
            const SizedBox(height: 10),
            if (isCc) ...[
              AnimatedProgressBar(
                value: util / 100,
                color: progressColor,
              ),
              const SizedBox(height: 6),
              Text(
                '${util.toStringAsFixed(0)}% of ${formatLKR(a.limit)} limit',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else ...[
              AnimatedProgressBar(
                value: pct / 100,
                color: AppColors.emerald,
              ),
              const SizedBox(height: 6),
              Text(
                '${pct.toStringAsFixed(0)}% paid down',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Log statement',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                        ),
                      ),
                      const Spacer(),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        child: const Icon(Icons.expand_more_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(formatMonthLabel(_month)),
                    subtitle: const Text('Statement month'),
                    trailing: const Icon(Icons.calendar_month_rounded),
                    onTap: _pickMonth,
                  ),
                  CurrencyInput(
                    label: 'New balance',
                    onChanged: (v) => _newBalance = v,
                  ),
                  const SizedBox(height: 8),
                  CurrencyInput(
                    label: 'Payment made',
                    onChanged: (v) => _payment = v,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Save statement'),
                    ),
                  ),
                ],
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
              sizeCurve: Curves.easeOutCubic,
            ),
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'History',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              ..._history.take(3).map(
                    (s) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(formatMonthLabel(s.month)),
                      subtitle: Text(
                        'Paid ${formatLKR(s.paymentMade)} · Interest ${formatLKR(s.interestCharged)}',
                      ),
                      trailing: Text(
                        formatLKR(s.newBalance),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
