import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class TaskTile extends StatelessWidget {
  final Task? task;
  final Function()? onTap;
  const TaskTile({Key? key, required this.task, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Expanded(
          child: Row(
        children: [
          Column(
            children: [
              Text(task?.title ??
                  "No title"), // Nếu null thì hiển thị "No title"
              Text(
                  "${task?.startTime ?? 'N/A'} - ${task?.endTime ?? 'N/A'}"), // Xử lý giá trị null
              Text(
                  task?.note ?? "No notes"), // Nếu null thì hiển thị "No notes"
            ],
          )
        ],
      )),
    );
  }
}
