import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/calendar_controller.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/detail_task.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class TaskWidget extends StatelessWidget {
  final Task task;
  final DateTime date;
  final CalendarController controller;
  final double hourHeight;

  const TaskWidget({
    Key? key,
    required this.task,
    required this.date,
    required this.controller,
    required this.hourHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final category = categoryController.categoryList
        .firstWhereOrNull((c) => c.id == task.categoryId);

    final startHour = task.date!.hour + task.date!.minute / 60.0;
    final duration = task.dueDate != null
        ? task.dueDate!.difference(task.date!).inMinutes / 60.0
        : 1.0;

    final top = startHour * hourHeight;
    const double minHeight = 70.0;
    final height = (duration * hourHeight).clamp(minHeight, double.infinity);
    final color = _pastelColor(category?.color ?? Colors.red[200]!);
    final hasChanges = controller.hasTaskChanges(task.id!);

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      child: LongPressDraggable<Task>(
        data: task,
        onDragStarted: () => controller.saveOriginalPosition(task),
        feedback: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
          child: Container(
            width: 120,
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        childWhenDragging: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: GestureDetector(
          onTap: () => _showTaskDetail(context),
          child: Container(
            height: height,
            // decoration: BoxDecoration(
            //   color: hasChanges ? color.withOpacity(0.7) : color,
            //   borderRadius: BorderRadius.circular(8),
            //   border: hasChanges
            //       ? Border.all(color: AppColors.primary, width: 2)
            //       : null,
            // ),
            decoration: BoxDecoration(
              // ✅ Check changes từ controller
              color: controller.hasTaskChanges(task.id!)
                  ? color.withOpacity(0.7)
                  : color,
              borderRadius: BorderRadius.circular(8),
              border: controller.hasTaskChanges(task.id!)
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title ?? '',
                        style: const TextStyle(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // if (hasChanges)
                    //   Container(
                    //     width: 8,
                    //     height: 8,
                    //     decoration: const BoxDecoration(
                    //       color: AppColors.primary,
                    //       shape: BoxShape.circle,
                    //     ),
                    //   ),
                    // ✅ Indicator cho changed tasks
                    if (controller.hasTaskChanges(task.id!))
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Text(
                  '${DateFormat('HH:mm').format(task.date!)}'
                  '${task.dueDate != null ? '-${DateFormat('HH:mm').format(task.dueDate!)}' : ''}',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailBottomSheet(taskId: task.id!),
    ).then((_) {
      controller.loadTasksForDisplayedDays();
    });
  }

  Color _pastelColor(Color color) {
    return Color.lerp(color, Colors.white, 0.4)!;
  }
}
