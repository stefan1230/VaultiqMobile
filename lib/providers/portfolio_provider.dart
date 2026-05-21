import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../models/insights.dart';
import '../models/portfolio_data.dart';
import '../models/savings_goal.dart';
import '../models/statement.dart';
import '../services/cloud_sync.dart';
import '../services/local_store.dart';
import '../utils/account_utils.dart' as account_utils;
import '../utils/insights_calculator.dart';

enum SyncStatus { idle, syncing, synced, error }

class PortfolioProvider extends ChangeNotifier {
  PortfolioProvider(this._local, this._cloud);

  final LocalStore _local;
  final CloudSync _cloud;

  PortfolioData _data = PortfolioData.empty();
  Insights? _insights;
  bool _ready = false;
  SyncStatus syncStatus = SyncStatus.idle;

  List<Account> get accounts => _data.accounts;
  List<Statement> get statements => _data.statements;
  List<SavingsGoal> get savings => _data.savings;
  Insights get insights => _insights ?? computeInsights(_data);
  bool get ready => _ready;

  Future<void> initLocal() async {
    _data = await _local.load();
    _recompute();
    _ready = true;
    notifyListeners();
  }

  Future<void> initFromCloud(String userId) async {
    final remote = await _cloud.pull(userId);
    if (remote != null && remote.accounts.isNotEmpty) {
      _data = remote;
      await _local.save(_data);
    }
    _recompute();
    _ready = true;
    notifyListeners();
  }

  Future<void> syncToCloud(String userId) async {
    syncStatus = SyncStatus.syncing;
    notifyListeners();
    try {
      await _cloud.push(userId, _data);
      syncStatus = SyncStatus.synced;
    } catch (_) {
      syncStatus = SyncStatus.error;
    }
    notifyListeners();
  }

  Future<void> _persist({String? userId}) async {
    await _local.save(_data);
    _recompute();
    notifyListeners();
    if (userId != null) await syncToCloud(userId);
  }

  void _recompute() {
    _insights = computeInsights(_data);
  }

  Future<({double interest, double drop})?> commitStatement({
    required String accountId,
    required double newBalance,
    required double paymentMade,
    required String month,
    String? userId,
  }) async {
    final idx = _data.accounts.indexWhere((a) => a.id == accountId);
    if (idx < 0) return null;
    final account = _data.accounts[idx];
    final prev = account.currentBalance;
    final interest = (newBalance - (prev - paymentMade))
        .clamp(0.0, double.infinity)
        .toDouble();
    final drop = (prev - newBalance).clamp(0.0, double.infinity).toDouble();
    final updated = account.copyWith(currentBalance: newBalance);
    final stmt = Statement(
      accountId: accountId,
      month: month,
      newBalance: newBalance,
      paymentMade: paymentMade,
      interestCharged: interest,
      balanceDrop: drop,
    );
    _data = PortfolioData(
      accounts: [
        ..._data.accounts.sublist(0, idx),
        updated,
        ..._data.accounts.sublist(idx + 1),
      ],
      statements: [..._data.statements, stmt],
      savings: _data.savings,
    );
    await _persist(userId: userId);
    return (interest: interest, drop: drop);
  }

  Future<void> createAccount({
    required String name,
    required String type,
    required double limit,
    required double currentBalance,
    String? userId,
  }) async {
    final acc = account_utils.createAccount(
      name: name,
      type: type,
      limit: limit,
      currentBalance: currentBalance,
    );
    _data = PortfolioData(
      accounts: [..._data.accounts, acc],
      statements: _data.statements,
      savings: _data.savings,
    );
    await _persist(userId: userId);
  }

  Future<void> deleteAccount(String accountId, {String? userId}) async {
    _data = PortfolioData(
      accounts: _data.accounts.where((a) => a.id != accountId).toList(),
      statements:
          _data.statements.where((s) => s.accountId != accountId).toList(),
      savings: _data.savings,
    );
    await _persist(userId: userId);
  }

  Future<void> createSavingsGoal(String name, double target, {String? userId}) async {
    _data = PortfolioData(
      accounts: _data.accounts,
      statements: _data.statements,
      savings: [
        ..._data.savings,
        SavingsGoal(name: name, target: target, current: 0),
      ],
    );
    await _persist(userId: userId);
  }

  Future<void> mutateSavings(
    int index,
    double amount,
    String action, {
    String? userId,
  }) async {
    if (index < 0 || index >= _data.savings.length) return;
    final goal = _data.savings[index];
    final next = action == 'add'
        ? goal.current + amount
        : (goal.current - amount).clamp(0, double.infinity);
    final updated = [..._data.savings];
    updated[index] = goal.copyWith(current: next.toDouble());
    _data = PortfolioData(
      accounts: _data.accounts,
      statements: _data.statements,
      savings: updated,
    );
    await _persist(userId: userId);
  }

  Future<void> deleteSavings(int index, {String? userId}) async {
    if (index < 0 || index >= _data.savings.length) return;
    final updated = [..._data.savings]..removeAt(index);
    _data = PortfolioData(
      accounts: _data.accounts,
      statements: _data.statements,
      savings: updated,
    );
    await _persist(userId: userId);
  }

  Future<void> importJson(String json, {String? userId}) async {
    final parsed = jsonDecode(json);
    Map<String, dynamic> map;
    if (parsed is Map<String, dynamic>) {
      map = parsed;
    } else {
      throw const FormatException('Invalid backup');
    }
    if (map['accounts'] == null && map['debts'] != null) {
      map = _legacyImport(map);
    }
    _data = PortfolioData.fromJson(map);
    await _persist(userId: userId);
  }

  Map<String, dynamic> _legacyImport(Map<String, dynamic> parsed) {
    final accounts = defaultPortfolio().accounts.map((a) => a.toJson()).toList();
    for (final d in parsed['debts'] as List<dynamic>) {
      final debt = Map<String, dynamic>.from(d as Map);
      final name = (debt['name'] as String? ?? '').toLowerCase();
      final id = name.contains('hnb') ? 'hnb' : 'dfcc';
      final idx = accounts.indexWhere((a) => a['id'] == id);
      if (idx >= 0) {
        accounts[idx]['currentBalance'] = debt['balance'];
      }
    }
    return {'accounts': accounts, 'statements': [], 'savings': []};
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert(_data.toJson());
}
