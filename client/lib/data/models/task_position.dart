class TaskPosition {
  final DateTime date;
  final DateTime dueDate;

  TaskPosition({
    required this.date,
    required this.dueDate,
  });

  TaskPosition copyWith({
    DateTime? date,
    DateTime? dueDate,
  }) {
    return TaskPosition(
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
