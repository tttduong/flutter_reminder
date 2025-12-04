import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/bottom_navbar_screen.dart';
import 'package:flutter_to_do_app/ui/screens/detail_task.dart';
import 'package:flutter_to_do_app/ui/widgets/gradient_bg.dart';
import 'package:get/get.dart';
import 'package:flutter_to_do_app/consts.dart';
import '../../controller/task_controller.dart';
import 'package:intl/intl.dart';

class CategoryTasksPage extends StatefulWidget {
  final Category? category;
  final VoidCallback? onBackPressed;
  const CategoryTasksPage({
    super.key,
    required this.category,
    this.onBackPressed,
  });

  @override
  State<CategoryTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<CategoryTasksPage> {
  final TaskController taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    if (widget.category?.id != null) {
      taskController.getTasksByCategory(widget.category!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category == null) {
      return const Center(
        child: Text('No category selected'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () {
            if (widget.onBackPressed != null) {
              widget.onBackPressed!();
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      BottomNavBarScreen(key: AppNavigation.bottomNavKey),
                ),
              );
            }
          },
        ),
        title: Text(
          widget.category!.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const GradientBackground(),
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _showTasksByCategory(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget chính - Tách incomplete và completed tasks
  Widget _showTasksByCategory() {
    return Obx(() {
      final allTasks = taskController.taskListByCategory;
      final incompleteTasks =
          allTasks.where((task) => !task.isCompleted).toList();
      final completedTasks =
          allTasks.where((task) => task.isCompleted).toList();

      if (allTasks.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: Text(
              'No tasks yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Tasks Section
          if (incompleteTasks.isNotEmpty)
            _buildTaskSection("Active Tasks", incompleteTasks, false),

          if (incompleteTasks.isNotEmpty && completedTasks.isNotEmpty)
            const SizedBox(height: 24),

          // Completed Tasks Section
          if (completedTasks.isNotEmpty)
            _buildTaskSection("Completed Tasks", completedTasks, true),
        ],
      );
    });
  }

  // Widget hiển thị section tasks với UI đẹp
  Widget _buildTaskSection(String title, List<Task> tasks, bool isCompleted) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green[700] : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: Key('task_${task.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                            'Are you sure you want to delete this task?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  await taskController.deleteTask(taskId: task.id!);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    print("TaskController hash = ${taskController.hashCode}");

                    // Mở bottom sheet chi tiết task
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          TaskDetailBottomSheet(taskId: task.id!),
                    ).then((_) {
                      // Refresh tasks sau khi đóng bottom sheet
                      if (widget.category?.id != null) {
                        taskController.getTasksByCategory(widget.category!.id);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row (checkbox + title + description)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: taskController.isTaskPending(task.id!)
                                    ? null
                                    : () {
                                        taskController
                                            .toggleTaskCompletion(task);
                                      },
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  margin:
                                      const EdgeInsets.only(right: 10, top: 2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: task.isCompleted
                                          ? Colors.transparent
                                          : AppColors.primary,
                                      width: 2,
                                    ),
                                    color: task.isCompleted
                                        ? AppColors.primary
                                        : Colors.white,
                                  ),
                                  child: task.isCompleted
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: task.isCompleted
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (task.description?.isNotEmpty ==
                                        true) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        task.description!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: task.isCompleted
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Time & Date Row
                          if (_hasTime(task.date, task.dueDate))
                            Row(
                              children: [
                                const SizedBox(width: 30),
                                Icon(Icons.access_time,
                                    size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTimeRange(task.date, task.dueDate),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDateRange(task.date, task.dueDate),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                const SizedBox(width: 30),
                                Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDateRange(task.date, task.dueDate),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper functions
  bool _hasTime(DateTime? start, DateTime? end) {
    if (start == null) return false;
    final hasStartTime = start.hour != 0 || start.minute != 0;
    final hasEndTime = end != null && (end.hour != 0 || end.minute != 0);
    return hasStartTime || hasEndTime;
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    if (!_hasTime(start, end)) return '';
    final ctx = Get.context!;
    final startTime = TimeOfDay.fromDateTime(start!).format(ctx);
    final endTime = end != null ? TimeOfDay.fromDateTime(end).format(ctx) : '';
    return endTime.isNotEmpty ? '$startTime - $endTime' : startTime;
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return '';
    final startDate = DateFormat('d MMM yyyy').format(start);
    if (end != null && !isSameDay(start, end)) {
      final endDate = DateFormat('d MMM yyyy').format(end);
      return '$startDate - $endDate';
    }
    return startDate;
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
