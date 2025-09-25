import 'package:flutter/material.dart';

class CategoryStat {
  final int categoryId;
  final String name;
  final String color; // vẫn giữ raw string để debug
  final int completed;

  CategoryStat({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.completed,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      color: json['color'] ?? '#000000',
      completed: json['completed'] ?? 0,
    );
  }

  /// tiện dụng: trả về Color luôn
  Color get colorValue => _hexToColor(color);
}

Color _hexToColor(String code) {
  code = code.replaceAll("#", "");
  if (code.length == 6) {
    code = "FF$code"; // add alpha nếu thiếu
  }
  return Color(int.parse(code, radix: 16));
}
