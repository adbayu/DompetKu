class DebtModel {
  const DebtModel({
    this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.dueDate,
    required this.status,
  });

  final int? id;
  final String personName;
  final double amount;
  final String type;
  final DateTime dueDate;
  final String status;

  DebtModel copyWith({
    int? id,
    String? personName,
    double? amount,
    String? type,
    DateTime? dueDate,
    String? status,
  }) {
    return DebtModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'person_name': personName,
    'amount': amount,
    'type': type,
    'due_date': dueDate.toIso8601String(),
    'status': status,
  };

  factory DebtModel.fromMap(Map<String, Object?> map) => DebtModel(
    id: map['id'] as int?,
    personName: map['person_name'] as String,
    amount: (map['amount'] as num).toDouble(),
    type: map['type'] as String,
    dueDate: DateTime.parse(map['due_date'] as String),
    status: map['status'] as String,
  );
}
