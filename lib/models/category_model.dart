class CategoryModel {
  const CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final int? id;
  final String name;
  final String icon;
  final int color;

  CategoryModel copyWith({int? id, String? name, String? icon, int? color}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
  };

  factory CategoryModel.fromMap(Map<String, Object?> map) => CategoryModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    icon: map['icon'] as String,
    color: map['color'] as int,
  );
}
