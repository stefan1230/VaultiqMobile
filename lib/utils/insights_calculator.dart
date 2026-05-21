import '../models/account.dart';
import '../models/account_progress.dart';
import '../models/insights.dart';
import '../models/portfolio_data.dart';
import '../models/statement.dart';
import 'account_utils.dart';

Insights computeInsights(PortfolioData data) {
  final accounts = data.accounts;
  final statements = data.statements;
  final savings = data.savings;

  final totalDebt =
      accounts.fold<double>(0, (s, a) => s + a.currentBalance);
  final totalSaved =
      savings.fold<double>(0, (s, g) => s + g.current);
  final totalSavingsTarget =
      savings.fold<double>(0, (s, g) => s + g.target);
  final totalInterest =
      statements.fold<double>(0, (s, st) => s + st.interestCharged);
  final totalPayments =
      statements.fold<double>(0, (s, st) => s + st.paymentMade);
  final totalPaydown =
      statements.fold<double>(0, (s, st) => s + st.balanceDrop);

  final ccAccounts =
      accounts.where((a) => isCreditCard(a)).toList();
  final loanAccounts = accounts.where((a) => isLoan(a)).toList();
  final ccDebt =
      ccAccounts.fold<double>(0, (s, a) => s + a.currentBalance);
  final loanDebt =
      loanAccounts.fold<double>(0, (s, a) => s + a.currentBalance);

  final months = statements.map((s) => s.month).toSet().toList()..sort();
  final lastMonth = months.isNotEmpty ? months.last : null;
  final lastMonthPayments = lastMonth == null
      ? 0.0
      : statements
          .where((s) => s.month == lastMonth)
          .fold<double>(0, (sum, s) => sum + s.paymentMade);

  final savingsProgress = totalSavingsTarget > 0
      ? (totalSaved / totalSavingsTarget * 100).clamp(0, 100)
      : 0.0;

  final ccUtil = ccAccounts
      .where((a) => a.limit > 0)
      .map((a) => a.currentBalance / a.limit * 100)
      .toList();
  final avgCcUtilization = ccUtil.isEmpty
      ? 0.0
      : ccUtil.reduce((a, b) => a + b) / ccUtil.length;

  final accountProgress = accounts.map((account) {
    final paid = account.initialBalance - account.currentBalance;
    final pct = account.initialBalance > 0
        ? (paid / account.initialBalance * 100).clamp(0, 100)
        : 0.0;
    return AccountProgress(
      account: account,
      pct: pct.toDouble(),
      label: isCreditCard(account) ? 'utilization' : 'paid down',
    );
  }).toList()
    ..sort((a, b) => b.pct.compareTo(a.pct));

  final recentActivity = List<Statement>.from(statements)
    ..sort((a, b) => b.month.compareTo(a.month));
  final recent = recentActivity.take(8).map((st) {
    final acc = accounts.cast<Account?>().firstWhere(
          (a) => a?.id == st.accountId,
          orElse: () => null,
        );
    return StatementActivity(
      statement: st,
      accountName: acc?.name ?? 'Unknown',
    );
  }).toList();

  return Insights(
    totalDebt: totalDebt,
    totalSaved: totalSaved,
    totalSavingsTarget: totalSavingsTarget,
    totalInterest: totalInterest,
    totalPayments: totalPayments,
    totalPaydown: totalPaydown,
    netPosition: totalSaved - totalDebt,
    ccDebt: ccDebt,
    loanDebt: loanDebt,
    ccCount: ccAccounts.length,
    loanCount: loanAccounts.length,
    savingsGoalCount: savings.length,
    distinctMonths: months.length,
    lastMonthPayments: lastMonthPayments,
    savingsProgress: savingsProgress.toDouble(),
    avgCcUtilization: avgCcUtilization,
    accountProgress: accountProgress,
    recentActivity: recent,
    lastMonth: lastMonth,
    topPerformer:
        accountProgress.isNotEmpty ? accountProgress.first : null,
    highestBalance: accounts.isEmpty
        ? null
        : accounts.reduce(
            (a, b) => a.currentBalance >= b.currentBalance ? a : b,
          ),
    debtToSavingsRatio:
        totalSaved > 0 ? totalDebt / totalSaved : null,
  );
}
