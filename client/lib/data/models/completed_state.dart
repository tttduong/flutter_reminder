class CompletedStat {
  final String day;
  final int completed;

  CompletedStat({required this.day, required this.completed});

  factory CompletedStat.fromJson(Map<String, dynamic> json) {
    return CompletedStat(
      day: json['day'] ?? 'None',
      completed: json['completed'] ?? 0,
    );
  }
}
