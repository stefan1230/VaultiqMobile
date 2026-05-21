import 'dart:math';

import '../models/account.dart';

const strategyColors = {
  'blue': '#3b82f6',
  'green': '#22c55e',
  'orange': '#f97316',
  'amber': '#f59e0b',
  'purple': '#a855f7',
  'red': '#ef4444',
};

Account createAccount({
  required String name,
  required String type,
  required double limit,
  required double currentBalance,
  String strategy = 'Paydown',
  String strategyColor = 'blue',
}) {
  return Account(
    id: 'acc_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}',
    name: name.trim(),
    type: type == 'loan' ? 'loan' : 'credit_card',
    limit: limit,
    currentBalance: currentBalance,
    initialBalance: currentBalance,
    strategy: strategy,
    strategyColor: strategyColor,
  );
}

String strategyColorHex(String key) =>
    strategyColors[key] ?? strategyColors['blue']!;

bool isCreditCard(Account a) => a.type == 'credit_card';

bool isLoan(Account a) => a.type == 'loan';
