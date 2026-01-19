import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MultiDayTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const MultiDayTaskCard({
    Key? key,
    required this.task,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final category = categoryController.categoryList
        .firstWhereOrNull((c) => c.id == task.categoryId);

    final startDate = task.date!;
    final endDate = task.dueDate!;
    final totalDays = endDate.difference(startDate).inDays + 1;
    final currentDay = DateTime.now().difference(startDate).inDays + 1;
    final double progress = (currentDay / totalDays).clamp(0.0, 1.0);
    final remainingDays = (totalDays - currentDay).clamp(0, totalDays);

    final baseColor = category?.color ?? Colors.blueAccent;
    final pastelColor = _extraPastelColor(baseColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: pastelColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: baseColor.withOpacity(0.8), width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: pastelColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: baseColor.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    task.title ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${startDate.toString().split(' ')[0]} → ${endDate.toString().split(' ')[0]}',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Ngày $currentDay/$totalDays',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  ' • Còn $remainingDays ngày',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: baseColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  baseColor.withOpacity(0.8),
                ),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _extraPastelColor(Color color) {
    return Color.lerp(color, Colors.white, 0.7)!;
  }
}
