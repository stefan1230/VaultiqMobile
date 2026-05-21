import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/portfolio_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/account_card.dart';
import '../widgets/add_debt_sheet.dart';
import '../widgets/fintech_ui.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key, this.userId});

  final String? userId;

  void _showAdd(BuildContext context) {
    final portfolio = context.read<PortfolioProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: AddDebtSheet(
              onSubmit: ({
                required name,
                required type,
                required limit,
                required currentBalance,
              }) =>
                  portfolio.createAccount(
                name: name,
                type: type,
                limit: limit,
                currentBalance: currentBalance,
                userId: userId,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, _) {
        final accounts = portfolio.accounts;
        return Container(
          color: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SectionHeader(
                    title: 'Debts',
                    subtitle: '${accounts.length} accounts tracked',
                    trailing: FilledButton.icon(
                      onPressed: () => _showAdd(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add'),
                    ),
                  ),
                ),
              ),
              if (accounts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.credit_card_off_rounded,
                    title: 'No debts yet',
                    message:
                        'Add a credit card or loan to start tracking balances and payments.',
                    action: FilledButton.icon(
                      onPressed: () => _showAdd(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add your first account'),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AccountCard(
                        account: accounts[i],
                        statements: portfolio.statements,
                        animationDelay: Duration(milliseconds: 60 * i),
                        onCommit: (id, bal, pay, month) =>
                            portfolio.commitStatement(
                          accountId: id,
                          newBalance: bal,
                          paymentMade: pay,
                          month: month,
                          userId: userId,
                        ),
                        onDelete: (id) =>
                            portfolio.deleteAccount(id, userId: userId),
                      ),
                      ),
                      childCount: accounts.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
