// import 'dart:convert';

class Task {
  String? id;
  String? userId;
  String? categoryId;
  String title;
  String? description;
  int status; // 0: Chưa hoàn thành, 1: Đã hoàn thành
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isDeleted;

  Task({
    this.id,
    required this.title,
    this.userId,
    this.categoryId,
    this.description,
    this.status = 0,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  /// Chuyển đổi từ JSON sang `Task` object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  // set is_deleted(bool is_deleted) {
  //   return is_deleted = 'true';
  // }

  /// Chuyển đổi từ `Task` object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  // /// Chuyển đổi danh sách JSON sang danh sách `Task`
  // static List<Task> listFromJson(List<dynamic> jsonList) {
  //   return jsonList.map((json) => Task.fromJson(json)).toList();
  // }

  // /// Chuyển đổi danh sách `Task` sang danh sách JSON
  // static String listToJson(List<Task> tasks) {
  //   return jsonEncode(tasks.map((task) => task.toJson()).toList());
  // }
}
