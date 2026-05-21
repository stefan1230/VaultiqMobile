import 'account.dart';
import 'savings_goal.dart';
import 'statement.dart';

class PortfolioData {
  PortfolioData({
    required this.accounts,
    required this.statements,
    required this.savings,
  });

  final List<Account> accounts;
  final List<Statement> statements;
  final List<SavingsGoal> savings;

  factory PortfolioData.empty() => PortfolioData(
        accounts: [],
        statements: [],
        savings: [],
      );

  Map<String, dynamic> toJson() => {
        'accounts': accounts.map((a) => a.toJson()).toList(),
        'statements': statements.map((s) => s.toJson()).toList(),
        'savings': savings.map((s) => s.toJson()).toList(),
      };

  static PortfolioData fromJson(Map<String, dynamic> json) {
    return PortfolioData(
      accounts: (json['accounts'] as List<dynamic>? ?? [])
          .map((e) => Account.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      statements: (json['statements'] as List<dynamic>? ?? [])
          .map((e) => Statement.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      savings: (json['savings'] as List<dynamic>? ?? [])
          .map((e) => SavingsGoal.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
