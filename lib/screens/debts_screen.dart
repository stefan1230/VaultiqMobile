import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/portfolio_provider.dart';
import '../widgets/account_card.dart';
import '../widgets/add_debt_sheet.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key, this.userId});

  final String? userId;

  void _showAdd(BuildContext context) {
    final portfolio = context.read<PortfolioProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AddDebtSheet(
        onSubmit: ({required name, required type, required limit, required currentBalance}) =>
            portfolio.createAccount(
          name: name,
          type: type,
          limit: limit,
          currentBalance: currentBalance,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, _) {
        final accounts = portfolio.accounts;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debts',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${accounts.length} accounts',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showAdd(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
            if (accounts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No debts yet. Tap Add to create one.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => AccountCard(
                      account: accounts[i],
                      statements: portfolio.statements,
                      onCommit: (id, bal, pay, month) => portfolio
                          .commitStatement(
                        accountId: id,
                        newBalance: bal,
                        paymentMade: pay,
                        month: month,
                        userId: userId,
                      ),
                      onDelete: (id) =>
                          portfolio.deleteAccount(id, userId: userId),
                    ),
                    childCount: accounts.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
