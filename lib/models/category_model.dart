class CategoryModel {
  const CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.type = 'expense',
  });

  final int? id;
  final String name;
  final String icon;
  final int color;
  final String type;

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    int? color,
    String? type,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
    'type': type,
  };

  factory CategoryModel.fromMap(Map<String, Object?> map) => CategoryModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    icon: map['icon'] as String,
    color: (map['color'] as num).toInt(),
    type: (map['type'] as String?) ?? 'expense',
  );
}
