// Model cho danh mục
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/model/task.dart';

class Category {
  final String title;
  final Color color;
  final IconData icon;
  final List<Task>? tasks;

  Category({
    required this.title,
    required this.color,
    required this.icon,
    this.tasks,
  });

  // Phương thức chuyển đổi từ JSON sang Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'] ?? '',
      color:
          Color(int.parse(json['color'].replaceFirst('#', '0xFF'), radix: 16)),
      icon: IconData(int.tryParse(json['icon'].toString()) ?? 0,
          fontFamily: 'MaterialIcons'),
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((taskJson) => Task.fromJson(taskJson))
              .toList() ??
          [],
    );
  }
}
