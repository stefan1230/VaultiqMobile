import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';
import '../models/portfolio_data.dart';
import '../models/savings_goal.dart';

const _storageKey = 'vaultiq_portfolio_v1';

PortfolioData defaultPortfolio() {
  return PortfolioData(
    accounts: [
      Account(
        id: 'dfcc',
        name: 'DFCC Credit Card',
        type: 'credit_card',
        limit: 300000,
        currentBalance: 269405,
        initialBalance: 300000,
        strategy: 'attack first',
        strategyColor: 'amber',
      ),
      Account(
        id: 'hnb',
        name: 'HNB Credit Card',
        type: 'credit_card',
        limit: 150000,
        currentBalance: 139175,
        initialBalance: 150000,
        strategy: 'minimums for now',
        strategyColor: 'blue',
      ),
    ],
    statements: [],
    savings: [
      SavingsGoal(name: 'Emergency Fund', target: 250000, current: 0),
    ],
  );
}

class LocalStore {
  Future<PortfolioData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      final seed = defaultPortfolio();
      await save(seed);
      return seed;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final data = PortfolioData.fromJson(map);
      if (data.accounts.isEmpty) return defaultPortfolio();
      return data;
    } catch (_) {
      return defaultPortfolio();
    }
  }

  Future<void> save(PortfolioData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(data.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
