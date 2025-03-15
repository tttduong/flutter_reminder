// Model cho danh mục
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/model/task.dart';

class Category {
  final String title;
  final Color color;
  final IconData icon;
  final List<Task> tasks;

  Category({
    required this.title,
    required this.color,
    required this.icon,
    required this.tasks,
  });
}
