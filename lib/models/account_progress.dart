import 'account.dart';

class AccountProgress {
  AccountProgress({
    required this.account,
    required this.pct,
    required this.label,
  });

  final Account account;
  final double pct;
  final String label;
}
