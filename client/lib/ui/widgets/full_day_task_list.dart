import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/widgets/full_day_task_card.dart';

class FullDayTaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final Function(Task) onToggleComplete;

  const FullDayTaskList({
    Key? key,
    required this.tasks,
    required this.onTaskTap,
    required this.onToggleComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 180,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          return FullDayTaskCard(
            task: tasks[index],
            onTap: () => onTaskTap(tasks[index]),
            onToggleComplete: () => onToggleComplete(tasks[index]),
          );
        },
      ),
    );
  }
}
