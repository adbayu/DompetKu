class FinanceTransaction {
  const FinanceTransaction({
    this.id,
    required this.amount,
    required this.date,
    required this.notes,
    required this.type,
    required this.categoryId,
    required this.walletId,
    this.goalId,
  });

  final int? id;
  final double amount;
  final DateTime date;
  final String notes;
  final String type;
  final int categoryId;
  final int walletId;
  final int? goalId;

  FinanceTransaction copyWith({
    int? id,
    double? amount,
    DateTime? date,
    String? notes,
    String? type,
    int? categoryId,
    int? walletId,
    int? goalId,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      goalId: goalId ?? this.goalId,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'amount': amount,
    'date': date.toIso8601String(),
    'notes': notes,
    'type': type,
    'category_id': categoryId,
    'wallet_id': walletId,
    'goal_id': goalId,
  };

  factory FinanceTransaction.fromMap(Map<String, Object?> map) {
    return FinanceTransaction(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String,
      type: map['type'] as String,
      categoryId: map['category_id'] as int,
      walletId: map['wallet_id'] as int,
      goalId: map['goal_id'] as int?,
    );
  }
}
