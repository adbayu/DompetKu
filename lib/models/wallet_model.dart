class WalletModel {
  const WalletModel({
    this.id,
    required this.name,
    required this.balance,
    required this.type,
  });

  final int? id;
  final String name;
  final double balance;
  final String type;

  WalletModel copyWith({int? id, String? name, double? balance, String? type}) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'balance': balance,
    'type': type,
  };

  factory WalletModel.fromMap(Map<String, Object?> map) => WalletModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    balance: (map['balance'] as num).toDouble(),
    type: map['type'] as String,
  );
}
