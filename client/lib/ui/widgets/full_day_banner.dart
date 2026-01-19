import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/calendar_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/detail_task.dart';
import 'package:flutter_to_do_app/ui/widgets/full_day_banner_header.dart';
import 'package:flutter_to_do_app/ui/widgets/full_day_task_list.dart';
import 'package:get/get.dart';

class FullDayBanner extends StatelessWidget {
  final CalendarController controller;

  const FullDayBanner({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Obx(() {
      final fullDayTasks = taskController.getFullDayTasksForDate(
        controller.selectedDate.value,
      );

      if (fullDayTasks.isEmpty) {
        return const SizedBox.shrink();
      }

      final isExpanded = taskController.isFullDayExpanded.value;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FullDayBannerHeader(
              taskCount: fullDayTasks.length,
              isExpanded: isExpanded,
              onToggle: () => taskController.isFullDayExpanded.toggle(),
            ),
            if (isExpanded) const Divider(height: 1),
            if (isExpanded)
              FullDayTaskList(
                tasks: fullDayTasks,
                onTaskTap: (task) => _showTaskDetail(context, task),
                onToggleComplete: (task) =>
                    controller.toggleTaskCompletion(task),
              ),
          ],
        ),
      );
    });
  }

  void _showTaskDetail(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailBottomSheet(taskId: task.id!),
    ).then((_) {
      controller.loadTasksForDisplayedDays();
    });
  }
}
