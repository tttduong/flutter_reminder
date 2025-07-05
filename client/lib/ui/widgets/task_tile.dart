import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskTile extends StatelessWidget {
  final Task? task;
  final Function()? onTap;
  const TaskTile({Key? key, required this.task, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2), // Màu nền nhẹ
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Căn trái
                    children: [
                      Checkbox(
                        value: task!.isCompleted == 1,
                        onChanged: (bool? newValue) {
                          final newStatus = (newValue ?? false) ? 1 : 0;
                          // taskController.updateTaskStatus(task.id, newStatus);
                        },
                      ),

                      Text(
                        task?.title ?? "No title",
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4), // Khoảng cách giữa các dòng
                      // Text(
                      //   "${task?.startTime ?? 'N/A'} - ${task?.endTime ?? 'N/A'}",
                      //   style: GoogleFonts.lato(
                      //       fontSize: 14, color: Colors.grey[700]),
                      // ),
                      SizedBox(height: 4),
                      Text(
                        task?.description ?? "",
                        style: GoogleFonts.lato(
                            fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // if (task?.id != null) {
                    //   await taskController.deleteTask(task!.id!);
                    // } else {
                    //   print("Task ID is null");
                    // }
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8), // Khoảng trắng giữa các TaskTile
      ],
    );
  }
}
