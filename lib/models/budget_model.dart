class BudgetModel {
  const BudgetModel({
    this.id,
    required this.categoryId,
    required this.month,
    required this.year,
    required this.limitAmount,
  });

  final int? id;
  final int categoryId;
  final int month;
  final int year;
  final double limitAmount;

  BudgetModel copyWith({
    int? id,
    int? categoryId,
    int? month,
    int? year,
    double? limitAmount,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      year: year ?? this.year,
      limitAmount: limitAmount ?? this.limitAmount,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'category_id': categoryId,
    'month': month,
    'year': year,
    'limit_amount': limitAmount,
  };

  factory BudgetModel.fromMap(Map<String, Object?> map) => BudgetModel(
    id: map['id'] as int?,
    categoryId: map['category_id'] as int,
    month: map['month'] as int,
    year: map['year'] as int,
    limitAmount: (map['limit_amount'] as num).toDouble(),
  );
}
