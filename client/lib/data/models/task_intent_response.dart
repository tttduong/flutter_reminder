class TaskIntentResponse {
  final String intent;
  final String title;
  final String description;
  final int categoryId;
  final DateTime date;
  final DateTime? dueDate;

  TaskIntentResponse({
    required this.intent,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.date,
    this.dueDate,
  });

  /// Parse từ JSON
  factory TaskIntentResponse.fromJson(Map<String, dynamic> json) {
    return TaskIntentResponse(
      intent: json['intent'] ?? "small_talk",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      categoryId: json['category_id'] ?? 0,
      date: DateTime.tryParse(json['date'] ?? "") ?? DateTime.now(),
      dueDate: json['due_date'] != null && json['due_date'] != ""
          ? DateTime.tryParse(json['due_date'])
          : null,
    );
  }

  /// Convert ngược sang JSON
  Map<String, dynamic> toJson() {
    return {
      "intent": intent,
      "title": title,
      "description": description,
      "category_id": categoryId,
      "date": date.toIso8601String(),
      "due_date": dueDate?.toIso8601String(),
    };
  }
}
