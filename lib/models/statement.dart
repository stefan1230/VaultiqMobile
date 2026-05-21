class Statement {
  Statement({
    this.id,
    required this.accountId,
    required this.month,
    required this.newBalance,
    required this.paymentMade,
    required this.interestCharged,
    required this.balanceDrop,
  });

  final int? id;
  final String accountId;
  final String month;
  final double newBalance;
  final double paymentMade;
  final double interestCharged;
  final double balanceDrop;

  factory Statement.fromJson(Map<String, dynamic> json) => Statement(
        id: json['id'] as int?,
        accountId: json['accountId'] as String,
        month: json['month'] as String,
        newBalance: (json['newBalance'] as num).toDouble(),
        paymentMade: (json['paymentMade'] as num).toDouble(),
        interestCharged: (json['interestCharged'] as num).toDouble(),
        balanceDrop: (json['balanceDrop'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'accountId': accountId,
        'month': month,
        'newBalance': newBalance,
        'paymentMade': paymentMade,
        'interestCharged': interestCharged,
        'balanceDrop': balanceDrop,
      };
}
