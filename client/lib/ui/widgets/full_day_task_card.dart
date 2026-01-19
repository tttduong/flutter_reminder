import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/models/task.dart';

class FullDayTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const FullDayTaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: onToggleComplete,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  task.isCompleted == 1
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: task.categoryColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                      decoration: task.isCompleted == 1
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
