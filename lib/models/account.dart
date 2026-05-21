class Account {
  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.limit,
    required this.currentBalance,
    required this.initialBalance,
    required this.strategy,
    required this.strategyColor,
  });

  final String id;
  final String name;
  final String type;
  final double limit;
  final double currentBalance;
  final double initialBalance;
  final String strategy;
  final String strategyColor;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] == 'loan' ? 'loan' : 'credit_card',
        limit: (json['limit'] as num).toDouble(),
        currentBalance: (json['currentBalance'] as num).toDouble(),
        initialBalance: (json['initialBalance'] as num).toDouble(),
        strategy: json['strategy'] as String? ?? 'Paydown',
        strategyColor: json['strategyColor'] as String? ?? 'blue',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'limit': limit,
        'currentBalance': currentBalance,
        'initialBalance': initialBalance,
        'strategy': strategy,
        'strategyColor': strategyColor,
      };

  Account copyWith({
    double? currentBalance,
  }) =>
      Account(
        id: id,
        name: name,
        type: type,
        limit: limit,
        currentBalance: currentBalance ?? this.currentBalance,
        initialBalance: initialBalance,
        strategy: strategy,
        strategyColor: strategyColor,
      );
}
