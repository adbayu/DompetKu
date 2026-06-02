import 'package:flutter/material.dart';

class IconConstants {
  /// List of available category icons with Indonesian labels
  static const List<IconOption> availableIcons = [
    IconOption('restaurant', 'Makanan & Minuman'),
    IconOption('shopping_cart', 'Belanja'),
    IconOption('directions_bus', 'Transportasi'),
    IconOption('savings', 'Tabungan'),
    IconOption('local_activity', 'Hiburan'),
    IconOption('medical_services', 'Kesehatan'),
    IconOption('school', 'Pendidikan'),
    IconOption('card_giftcard', 'Hadiah'),
    IconOption('home', 'Rumah & Utilitas'),
    IconOption('work', 'Pekerjaan & Gaji'),
  ];

  /// Get IconData from icon name string
  static IconData getIcon(String iconName) {
    return _iconMap[iconName] ?? Icons.category;
  }

  /// Get label for icon name
  static String getLabel(String iconName) {
    try {
      return availableIcons.firstWhere((icon) => icon.name == iconName).label;
    } catch (e) {
      return iconName;
    }
  }

  /// Internal mapping from icon name to IconData
  static final Map<String, IconData> _iconMap = {
    'restaurant': Icons.restaurant,
    'shopping_cart': Icons.shopping_cart,
    'directions_bus': Icons.directions_bus,
    'savings': Icons.savings,
    'local_activity': Icons.local_activity,
    'medical_services': Icons.medical_services,
    'school': Icons.school,
    'card_giftcard': Icons.card_giftcard,
    'home': Icons.home,
    'work': Icons.work,
  };
}

/// Represents a selectable icon option
class IconOption {
  final String name;
  final String label;

  const IconOption(this.name, this.label);
}
