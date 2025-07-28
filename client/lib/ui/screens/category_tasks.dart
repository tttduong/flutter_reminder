// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/add_task.dart';
import 'package:get/get.dart';
import 'package:flutter_to_do_app/consts.dart';

import '../../controller/category_controller.dart';
import '../../controller/task_controller.dart';
import '../../data/services/task_service.dart';

class CategoryTasksPage extends StatefulWidget {
  final Category? category;

  const CategoryTasksPage({super.key, this.category});

  @override
  State<CategoryTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<CategoryTasksPage> {
  bool showCompletedTasks = false;
  late final TaskController taskController;
  final Map<int?, bool> _pendingUpdates = {};
  // final _taskController = Get.put(TaskController());
  @override
  void initState() {
    super.initState();
    // Khởi tạo controller
    taskController = Get.put(TaskController());
    // Gọi hàm fetch task nếu cần
    taskController.getTasks();
    // _taskController.getTasksByCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                widget.category!.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _showTasksByCategory(),

                  // Expanded(
                  //   child: Obx(() => _showTasksByCategory()),
                  // ),
                  // Danh sách công việc chưa hoàn thành
                  // ...widget.category.tasks
                  //         ?.where((task) => !task.isCompleted)
                  //         .map(_buildTaskItem)
                  //         .toList() ??
                  //     [],

                  const SizedBox(height: 16),

                  // Nút ẩn/hiện công việc đã hoàn thành
                  // TextButton.icon(
                  //   onPressed: () {
                  //     setState(() {
                  //       showCompletedTasks = !showCompletedTasks;
                  //     });
                  //   },
                  //   icon: Icon(
                  //     showCompletedTasks
                  //         ? Icons.keyboard_arrow_up
                  //         : Icons.keyboard_arrow_down,
                  //     color: AppColors.buttonWhiteText,
                  //   ),
                  //   label: Text(
                  //     'Hide completed tasks',
                  //     style: TextStyle(
                  //       color: AppColors.buttonWhiteText,
                  //     ),
                  //   ),
                  //   style: TextButton.styleFrom(
                  //     backgroundColor: AppColors.secondary,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //   ),
                  // ),

                  // Công việc đã hoàn thành
                  // if (showCompletedTasks) ...[
                  //   const SizedBox(height: 16),
                  //   ...widget.category.tasks
                  //           ?.where((task) => task.isCompleted)
                  //           .map(_buildCompletedTaskItem)
                  //           .toList() ??
                  //       []
                  // ],

                  const SizedBox(height: 80), // Để tránh FAB che nội dung
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => AddTaskPage());
        },
        shape: const CircleBorder(),
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _toggleTaskStatus(Task task, bool newStatus) async {
    final taskId = task.id;

    // 1. Update local state immediately
    setState(() {
      task.isCompleted = newStatus;
      _pendingUpdates[taskId] = newStatus; // Mark as pending
    });

    try {
      // 2. Call API
      await taskController.updateTaskStatus(task, newStatus);

      // 3. Remove from pending after success
      setState(() {
        _pendingUpdates.remove(taskId);
      });
    } catch (e) {
      // 4. Revert on error
      setState(() {
        task.isCompleted = !newStatus;
        _pendingUpdates.remove(taskId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// 2. Improved Widget with better state management
  Widget _showTasksByCategory() {
    return FutureBuilder<List<Task>>(
      future: taskController.getTasksByCategory(widget.category?.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No tasks"));
        }

        final allTasks = snapshot.data!;
        final incompleteTasks = allTasks.where((t) => !t.isCompleted).toList();
        final completedTasks = allTasks.where((t) => t.isCompleted).toList();

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {}); // Refresh the FutureBuilder
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Incomplete Tasks Section
                _buildTaskSection("Active Tasks", incompleteTasks, false),

                const SizedBox(height: 16),

                // Completed Tasks Section
                if (completedTasks.isNotEmpty)
                  _buildTaskSection("Completed Tasks", completedTasks, true),
              ],
            ),
          ),
        );
      },
    );
  }

// 3. Reusable task section builder
  Widget _buildTaskSection(String title, List<Task> tasks, bool isCompleted) {
    if (tasks.isEmpty && !isCompleted) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompleted) ...[
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
        ],
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? newValue) {
                    final newStatus = newValue ?? false;
                    _toggleTaskStatus(task, newStatus);
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                ),
                subtitle: task.description?.isNotEmpty == true
                    ? Text(
                        task.description!,
                        style: TextStyle(
                          color: task.isCompleted ? Colors.grey : null,
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}
