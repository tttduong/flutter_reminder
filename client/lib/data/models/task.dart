import 'dart:ui';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Task {
  int? id;
  int? userId;
  int? categoryId;
  String title;
  String? description;
  bool isCompleted;
  DateTime? date;
  DateTime? dueDate;
  String? time;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isDeleted;
  int? priority;
  DateTime? completedAt;
  DateTime? reminderTime;
  Color? categoryColor;

  Task({
    this.id,
    required this.title,
    this.userId,
    this.categoryId,
    this.description,
    this.isCompleted = false,
    this.date,
    this.dueDate,
    this.time,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.priority,
    this.completedAt,
    this.reminderTime,
    this.categoryColor,
  });

  //  Chuyển đổi từ JSON sang `Task` object
  factory Task.fromJson(Map<String, dynamic> json) {
    Color? categoryColor;
    if (json['category_id'] != null) {
      try {
        final category = Get.find<CategoryController>()
            .categoryList
            .firstWhereOrNull((c) => c.id == json['category_id']);
        categoryColor = category?.color;
      } catch (e) {
        // CategoryController chưa được khởi tạo
        categoryColor = null;
      }
    }

    return Task(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['completed'] == true ||
          json['completed'] == 1 ||
          json['completed'] == 'true',

      // date: json['date'] != null ? DateTime.parse(json['date']) : null,
      // dueDate:
      //     json['due_date'] != null ? DateTime.parse(json['due_date']) : null,

      date:
          json['date'] != null ? DateTime.parse(json['date']).toLocal() : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date']).toLocal()
          : null,

      time: json['time'], // dạng chuỗi, ví dụ: "08:30"
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at']).toLocal()
          : null,
      priority: json['priority'],

      isDeleted: json['is_deleted'] ?? false,
      categoryColor: categoryColor,
    );
  }

  /// Chuyển đổi từ `Task` object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'is_complete': isCompleted,
      // 'due_date': dueDate?.toIso8601String(),
      'date': date,
      'due_date': dueDate,
      'completed_at': completedAt,
      'time': time,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'priority': priority,
      'is_deleted': isDeleted,
      "reminder_time": reminderTime?.toUtc().toIso8601String(),
    };
  }
}

class UpdateTaskStatusDto {
  final bool isCompleted;

  UpdateTaskStatusDto({required this.isCompleted});

  Map<String, dynamic> toJson() {
    return {
      "is_completed": isCompleted,
    };
  }
}
