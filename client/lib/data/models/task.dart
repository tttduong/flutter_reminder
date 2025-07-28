// import 'dart:convert';

class Task {
  int? id;
  int? userId;
  int? categoryId;
  String title;
  String? description;
  bool isCompleted;
  String? dueDate;
  String? time;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isDeleted;

  Task({
    this.id,
    required this.title,
    this.userId,
    this.categoryId,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    this.time,
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
      isCompleted: json['completed'] == true ||
          json['completed'] == 1 ||
          json['completed'] == 'true',

      // isCompleted: json['is_completed'] ?? false,
      // dueDate:
      //     json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      dueDate: json['due_date'],
      time: json['time'], // dạng chuỗi, ví dụ: "08:30"
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
      'is_complete': isCompleted,
      // 'due_date': dueDate?.toIso8601String(),
      'due_date': dueDate,
      'time': time,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  Task copyWith(
      {int? id,
      int? categoryId,
      String? title,
      String? description,
      required bool isCompleted,
      s}) {
    return Task(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: this.isCompleted,
    );
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

class UpdateTaskStatusDto {
  final bool isCompleted;

  UpdateTaskStatusDto({required this.isCompleted});

  Map<String, dynamic> toJson() {
    return {
      "is_completed": isCompleted,
    };
  }
}
