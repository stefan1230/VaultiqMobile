class SavingsGoal {
  SavingsGoal({
    this.id,
    required this.name,
    required this.target,
    required this.current,
  });

  final int? id;
  final String name;
  final double target;
  final double current;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
        id: json['id'] as int?,
        name: json['name'] as String,
        target: (json['target'] as num).toDouble(),
        current: (json['current'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'target': target,
        'current': current,
      };

  SavingsGoal copyWith({double? current}) => SavingsGoal(
        id: id,
        name: name,
        target: target,
        current: current ?? this.current,
      );
}
