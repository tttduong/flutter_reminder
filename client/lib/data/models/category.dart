// Model cho danh mục
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/models/task.dart';

class Category {
  final int id;
  final String title;
  final Color color;
  final IconData icon;
  final int? ownerId;
  final bool? isDefault;
  final List<Task>? tasks;

  Category({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    this.ownerId,
    this.isDefault,
    this.tasks,
  });

  // Phương thức chuyển đổi từ JSON sang Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      color: _parseColor(json['color']),
      icon: _parseIcon(json['icon']),
      ownerId: json['owner_id'],
      isDefault: json['is_default'],
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((taskJson) => Task.fromJson(taskJson))
              .toList() ??
          [],
    );
  }

// Chuyển đổi chuỗi hex thành Color an toàn
  static Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey; // Mặc định

    // Xử lý các trường hợp hexColor có thể bị lỗi định dạng
    hexColor = hexColor.toUpperCase().replaceAll("#", "").trim();

    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // Thêm alpha nếu thiếu
    }

    if (hexColor.length != 8) {
      return Colors.grey; // Nếu không đúng 8 ký tự, trả về màu mặc định
    }

    try {
      return Color(int.parse("0x$hexColor")); // Chuyển đổi an toàn
    } catch (e) {
      return Colors.grey; // Nếu lỗi, trả về màu mặc định
    }
  }

// Chuyển đổi icon từ JSON
  static IconData _parseIcon(dynamic icon) {
    if (icon == null) return const IconData(0, fontFamily: 'MaterialIcons');
    return IconData(int.tryParse(icon.toString()) ?? 0,
        fontFamily: 'MaterialIcons');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'color': color.value.toRadixString(16), // Chuyển về chuỗi hex
      'icon': icon.codePoint, // IconData => int
      'owner_id': ownerId,
      'is_default': isDefault,
    };
  }
}
