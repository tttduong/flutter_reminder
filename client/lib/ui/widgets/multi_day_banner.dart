import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/calendar_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/detail_task.dart';
import 'package:flutter_to_do_app/ui/widgets/multi_day_task_card.dart';
import 'package:get/get.dart';

class MultiDayBanner extends StatelessWidget {
  final CalendarController controller;

  const MultiDayBanner({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasksForSelectedDate = controller.getMultiDayTasksForSelectedDate();

      if (tasksForSelectedDate.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 105,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: tasksForSelectedDate.length,
          itemBuilder: (context, index) {
            return MultiDayTaskCard(
              task: tasksForSelectedDate[index],
              onTap: () =>
                  _showTaskDetail(context, tasksForSelectedDate[index]),
            );
          },
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
