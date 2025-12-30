import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controller/category_controller.dart';
import '../../data/models/category.dart';

class TaskTile extends StatelessWidget {
  final Task? task;
  final Function()? onTap;
  // final Category? category;

  const TaskTile({Key? key, required this.task, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();
    final CategoryController categoryController = Get.find();
    // 👈 Tìm category từ task.categoryId
    Category? category = categoryController.categoryList.firstWhereOrNull(
      (cat) => cat.id == task?.categoryId,
    );
    bool isSameDay = (task?.date != null) &&
        (task?.dueDate != null) &&
        (task!.date!.year == task!.dueDate!.year) &&
        (task!.date!.month == task!.dueDate!.month) &&
        (task!.date!.day == task!.dueDate!.day);

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              // color: category?.color.withOpacity(0.2) ??
              //     Colors.blueAccent.withOpacity(0.2), // Màu nền nhẹ
              // Kiểm tra cùng ngày

              // Dynamic opacity
              color: (category?.color ?? Colors.blueAccent)
                  .withOpacity(isSameDay ? 0.5 : 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Căn trái
                    children: [
                      // Checkbox(
                      //   value: task!.isCompleted == 1,
                      //   onChanged: (bool? newValue) {
                      //     final newStatus = (newValue ?? false) ? 1 : 0;
                      //     // taskController.updateTaskStatus(task.id, newStatus);
                      //   },
                      // ),

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
                // IconButton(
                //   icon: Icon(Icons.delete, color: Colors.red),
                //   onPressed: () async {
                //     // if (task?.id != null) {
                //     //   await taskController.deleteTask(task!.id!);
                //     // } else {
                //     //   print("Task ID is null");
                //     // }
                //   },
                // ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8), // Khoảng trắng giữa các TaskTile
      ],
    );
  }
}
