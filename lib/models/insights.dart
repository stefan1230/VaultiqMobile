import 'account.dart';
import 'account_progress.dart';
import 'statement.dart';

class Insights {
  Insights({
    required this.totalDebt,
    required this.totalSaved,
    required this.totalSavingsTarget,
    required this.totalInterest,
    required this.totalPayments,
    required this.totalPaydown,
    required this.netPosition,
    required this.ccDebt,
    required this.loanDebt,
    required this.ccCount,
    required this.loanCount,
    required this.savingsGoalCount,
    required this.distinctMonths,
    required this.lastMonthPayments,
    required this.savingsProgress,
    required this.avgCcUtilization,
    required this.accountProgress,
    required this.recentActivity,
    this.lastMonth,
    this.topPerformer,
    this.highestBalance,
    this.debtToSavingsRatio,
  });

  final double totalDebt;
  final double totalSaved;
  final double totalSavingsTarget;
  final double totalInterest;
  final double totalPayments;
  final double totalPaydown;
  final double netPosition;
  final double ccDebt;
  final double loanDebt;
  final int ccCount;
  final int loanCount;
  final int savingsGoalCount;
  final int distinctMonths;
  final double lastMonthPayments;
  final double savingsProgress;
  final double avgCcUtilization;
  final List<AccountProgress> accountProgress;
  final List<StatementActivity> recentActivity;
  final String? lastMonth;
  final AccountProgress? topPerformer;
  final Account? highestBalance;
  final double? debtToSavingsRatio;
}

class StatementActivity {
  StatementActivity({
    required this.statement,
    required this.accountName,
  });

  final Statement statement;
  final String accountName;
}
