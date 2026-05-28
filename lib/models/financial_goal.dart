class FinancialGoal {
  const FinancialGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
  });

  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;

  FinancialGoal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'target_amount': targetAmount,
    'current_amount': currentAmount,
    'deadline': deadline.toIso8601String(),
  };

  factory FinancialGoal.fromMap(Map<String, Object?> map) => FinancialGoal(
    id: map['id'] as int?,
    title: map['title'] as String,
    targetAmount: (map['target_amount'] as num).toDouble(),
    currentAmount: (map['current_amount'] as num).toDouble(),
    deadline: DateTime.parse(map['deadline'] as String),
  );
}
