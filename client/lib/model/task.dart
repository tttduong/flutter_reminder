class Task {
  String? id;
  String? title;
  String? note;
  // String? isCompleted;
  String? date;
  String? startTime;
  String? endTime;
  // String? color;
  // String? remind;
  // String? repeat;
  bool? is_deleted;

  Task(
      {this.id,
      this.title,
      this.note,
      // this.isCompleted,
      this.date,
      this.startTime,
      this.endTime,
      // this.color,
      // this.remind,
      // this.repeat,
      this.is_deleted});

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    note = json['note'];
    // isCompleted = json['isCompleted'];
    date = json['date'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    // color = json['color'];
    // remind = json['remind'];
    // repeat = json['repeat'];
    is_deleted = json['is_deleted'] ?? false;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['date'] = this.date;
    data['note'] = this.note;
    // data['isCompleted'] = this.isCompleted;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    // data['color'] = this.color;
    // data['remind'] = this.remind;
    // data['repeat'] = this.repeat;
    data['is_deleted'] = this.is_deleted;
    return data;
  }
}
