import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/bottom_navbar_screen.dart';
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
  bool showCompletedTasks = false;
  // late final TaskController taskController;
  final TaskController taskController = Get.find<TaskController>();
  final Map<int?, bool> _pendingUpdates = {};
  int? currentCategoryId;
  // final _taskController = Get.put(TaskController());
  @override
  void initState() {
    super.initState();

    // if (widget.category?.id != null) {
    //   // Load tasks ngay khi vào trang
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     taskController.getTasksByCategory(widget.category!.id);
    //   });
    // }

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
              //tam thoi de click back thì nav to home, lam back bth kho quaa
              //
              // if (Navigator.of(context).canPop()) {
              //   Navigator.of(context).pop();
              // } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) =>
                        BottomNavBarScreen(key: AppNavigation.bottomNavKey)),
              );
              // }
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
      extendBodyBehindAppBar: true, // Nếu bạn có gradient nền phía sau
      body: Stack(
        children: [
          const GradientBackground(),
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _showTasksByCategory(),
                const SizedBox(height: 16),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> _toggleTaskStatus(Task task, bool newStatus) async {
  //   final taskId = task.id;

  //   // 1. Update local state immediately
  //   setState(() {
  //     task.isCompleted = newStatus;
  //     _pendingUpdates[taskId] = newStatus; // Mark as pending
  //   });

  //   try {
  //     // 2. Call API
  //     await taskController.updateTaskStatus(task, newStatus);

  //     // 3. Remove from pending after success
  //     setState(() {
  //       _pendingUpdates.remove(taskId);
  //     });
  //   } catch (e) {
  //     // 4. Revert on error
  //     setState(() {
  //       task.isCompleted = !newStatus;
  //       _pendingUpdates.remove(taskId);
  //     });

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Failed to update task'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

// 2. Improved Widget with better state management
  Widget _showTasksByCategory() {
    // Fetch data khi widget init
    // taskController.getTasksByCategory(widget.category?.id);

    return Obx(() {
      print("Selected Category 3: ${widget.category.toString()}");
      print("Selected Category ID: ${widget.category?.id}");
      if (taskController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (taskController.taskList.isEmpty) {
        return const Center(child: Text("No tasks"));
      }

      final allTasks = taskController.taskList;
      final incompleteTasks = allTasks.where((t) => !t.isCompleted).toList();
      final completedTasks = allTasks.where((t) => t.isCompleted).toList();

      return RefreshIndicator(
        onRefresh: () async {
          await taskController.refreshTasks(widget.category?.id);
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
    });
  }

// // 3. Reusable task section builder
// 🧩 Reusable Task Section
  Widget _buildTaskSection(String title, List<Task> tasks, bool isCompleted) {
    if (tasks.isEmpty && !isCompleted) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        if (isCompleted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  await taskController.deleteTask(task.id);
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
                        // 🟢 Header row (checkbox + title)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: taskController.isTaskPending(task.id!)
                                  ? null
                                  : () {
                                      taskController.toggleTaskStatus(
                                          task, !task.isCompleted);
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
                                  if (task.description?.isNotEmpty == true) ...[
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

                        // 🕒 Time & Date Row (ẩn nếu không có time)
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
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateRange(task.date, task.dueDate),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
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
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                      ],
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

  bool _hasTime(DateTime? start, DateTime? end) {
    if (start == null) return false;
    // Nếu cả giờ và phút = 0 → xem như không có thời gian
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

  // Widget _buildTaskSection(String title, List<Task> tasks, bool isCompleted) {
  //   if (tasks.isEmpty && !isCompleted) return const SizedBox.shrink();

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       if (isCompleted) ...[
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  //           child: Text(
  //             title,
  //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //       ],
  //       ListView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         padding: const EdgeInsets.symmetric(horizontal: 2),
  //         itemCount: tasks.length,
  //         itemBuilder: (context, index) {
  //           final task = tasks[index];

  //           return AnimatedContainer(
  //             duration: const Duration(milliseconds: 300),
  //             margin: const EdgeInsets.only(bottom: 12),
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(12),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.05),
  //                     blurRadius: 8,
  //                     offset: const Offset(0, 2),
  //                   ),
  //                 ],
  //               ),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(8),
  //                 child: Column(
  //                   children: [
  //                     Row(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         // Task content
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 task.title,
  //                                 style: TextStyle(
  //                                   fontSize: 14,
  //                                   fontWeight: FontWeight.w600,
  //                                   decoration: task.isCompleted
  //                                       ? TextDecoration.lineThrough
  //                                       : TextDecoration.none,
  //                                   color: task.isCompleted
  //                                       ? Colors.grey
  //                                       : Colors.black87,
  //                                 ),
  //                               ),
  //                               if (task.description?.isNotEmpty == true) ...[
  //                                 const SizedBox(height: 4),
  //                                 Text(
  //                                   task.description!,
  //                                   style: TextStyle(
  //                                     fontSize: 14,
  //                                     color: task.isCompleted
  //                                         ? Colors.grey.shade400
  //                                         : Colors.grey.shade600,
  //                                   ),
  //                                   maxLines: 2,
  //                                   overflow: TextOverflow.ellipsis,
  //                                 ),
  //                               ],
  //                               const SizedBox(height: 8),
  //                             ],
  //                           ),
  //                         ),
  //                         // Delete button
  //                         // IconButton(
  //                         //   icon: const Icon(Icons.delete_outline,
  //                         //       color: Colors.red),
  //                         //   iconSize: 20,
  //                         //   onPressed: taskController.isTaskPending(task.id!)
  //                         //       ? null
  //                         //       : () async {
  //                         //           await taskController.deleteTask(task.id);
  //                         //         },
  //                         // ),
  //                       ],
  //                     ),
  //                     Row(
  //                       children: [
  //                         // Date and time row
  //                         Row(
  //                           children: [
  //                             Icon(
  //                               Icons.access_time,
  //                               size: 14,
  //                               color: Colors.grey.shade500,
  //                             ),
  //                             const SizedBox(width: 4),
  //                             Text(
  //                               '8:00 AM - 5:30 PM',
  //                               style: TextStyle(
  //                                 fontSize: 12,
  //                                 color: Colors.grey.shade600,
  //                               ),
  //                             ),
  //                             const SizedBox(width: 16),
  //                             Icon(
  //                               Icons.calendar_today,
  //                               size: 14,
  //                               color: Colors.grey.shade500,
  //                             ),
  //                             const SizedBox(width: 4),
  //                             Text(
  //                               '25 August 2021',
  //                               style: TextStyle(
  //                                 fontSize: 12,
  //                                 color: Colors.grey.shade600,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 8),
  //                     // Complete button
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       crossAxisAlignment: CrossAxisAlignment.end,
  //                       children: [
  //                         TextButton(
  //                           onPressed: taskController.isTaskPending(task.id!)
  //                               ? null
  //                               : () {
  //                                   taskController.toggleTaskStatus(
  //                                       task, !task.isCompleted);
  //                                 },
  //                           style: TextButton.styleFrom(
  //                             backgroundColor: Colors.green,
  //                             foregroundColor: Colors.white,
  //                             minimumSize: Size.zero,
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 6, vertical: 4),
  //                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                           ),
  //                           child: const Text('Complete'),
  //                         ),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

  _handleSearchChanged(String p1) {}

  void _handleNotificationTap() {}

  void _handleMoreTap() {}
}
// import 'package:flutter/material.dart';
// import 'package:flutter_to_do_app/data/models/category.dart';
// import 'package:flutter_to_do_app/data/models/task.dart';
// import 'package:flutter_to_do_app/ui/screens/add_task.dart';
// import 'package:get/get.dart';
// import 'package:flutter_to_do_app/consts.dart';
// import '../../controller/task_controller.dart';

// class CategoryTasksPage extends StatefulWidget {
//   final Category? category;
//   final VoidCallback? onBackPressed; // 👈 Callback để quay về HomePage

//   const CategoryTasksPage({
//     super.key,
//     required this.category,
//     this.onBackPressed,
//   });

//   @override
//   State<CategoryTasksPage> createState() => _CategoryTasksPageState();
// }

// class _CategoryTasksPageState extends State<CategoryTasksPage> {
//   bool showCompletedTasks = false;
//   late final TaskController taskController;
//   final Map<int?, bool> _pendingUpdates = {};
//   int? currentCategoryId;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.category == null) return;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       taskController = Get.find<TaskController>();
//       taskController.getTasksByCategory(widget.category!.id!);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 👈 Không dùng Scaffold riêng nữa, để BottomNavBarScreen quản lý
//     return Container(
//       color: Colors.white,
//       child: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 👈 Category Header với thông tin đẹp hơn
//             _buildCategoryHeader(),

//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 children: [
//                   _showTasksByCategory(),
//                   const SizedBox(height: 16),
//                   const SizedBox(
//                       height: 80), // Để tránh bottom nav che nội dung
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 👈 Header đẹp cho category
//   Widget _buildCategoryHeader() {
//     if (widget.category == null) return const SizedBox.shrink();

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             widget.category!.color.withOpacity(0.1),
//             Colors.white,
//           ],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Row(
//         children: [
//           // Category Icon
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: widget.category!.color,
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: widget.category!.color.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Icon(
//               widget.category!.icon,
//               color: Colors.white,
//               size: 30,
//             ),
//           ),
//           const SizedBox(width: 16),

//           // Category Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.category!.title,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Obx(() {
//                   final taskCount = taskController.taskList.length;
//                   final completedCount = taskController.taskList
//                       .where((task) => task.isCompleted)
//                       .length;
//                   return Text(
//                     '$taskCount tasks • $completedCount completed',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),

//           // Add Task Button
//           Container(
//             decoration: BoxDecoration(
//               color: widget.category!.color,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: IconButton(
//               onPressed: () {
//                 Get.to(
//                     () => AddTaskPage(
//                         // initialCategory: widget.category, // Pass category if needed
//                         ),
//                     preventDuplicates: false);
//               },
//               icon: const Icon(Icons.add, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _toggleTaskStatus(Task task, bool newStatus) async {
//     final taskId = task.id;

//     setState(() {
//       task.isCompleted = newStatus;
//       _pendingUpdates[taskId] = newStatus;
//     });

//     try {
//       await taskController.updateTaskStatus(task, newStatus);
//       setState(() {
//         _pendingUpdates.remove(taskId);
//       });
//     } catch (e) {
//       setState(() {
//         task.isCompleted = !newStatus;
//         _pendingUpdates.remove(taskId);
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to update task'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Widget _showTasksByCategory() {
//     return Obx(() {
//       if (taskController.isLoading.value) {
//         return const Center(
//           child: Padding(
//             padding: EdgeInsets.all(40),
//             child: CircularProgressIndicator(),
//           ),
//         );
//       }

//       if (taskController.taskList.isEmpty) {
//         return _buildEmptyState();
//       }

//       final allTasks = taskController.taskList;
//       final incompleteTasks = allTasks.where((t) => !t.isCompleted).toList();
//       final completedTasks = allTasks.where((t) => t.isCompleted).toList();

//       return RefreshIndicator(
//         onRefresh: () async {
//           await taskController.refreshTasks(widget.category!.id);
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Incomplete Tasks Section
//             if (incompleteTasks.isNotEmpty)
//               _buildTaskSection("Active Tasks", incompleteTasks, false),

//             if (incompleteTasks.isNotEmpty && completedTasks.isNotEmpty)
//               const SizedBox(height: 24),

//             // Completed Tasks Section
//             if (completedTasks.isNotEmpty)
//               _buildTaskSection("Completed Tasks", completedTasks, true),
//           ],
//         ),
//       );
//     });
//   }

//   // 👈 Empty state đẹp hơn
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               widget.category!.icon,
//               size: 80,
//               color: Colors.grey[300],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No tasks yet',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Add your first task to get started',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[500],
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 Get.to(() => const AddTaskPage(), preventDuplicates: false);
//               },
//               icon: const Icon(Icons.add),
//               label: const Text('Add Task'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: widget.category!.color,
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTaskSection(String title, List<Task> tasks, bool isCompleted) {
//     if (tasks.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Section Header
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: isCompleted
//                       ? Colors.green[100]
//                       : widget.category!.color.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '${tasks.length}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: isCompleted
//                         ? Colors.green[700]
//                         : widget.category!.color,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Tasks List
//         ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: tasks.length,
//           separatorBuilder: (context, index) => const SizedBox(height: 8),
//           itemBuilder: (context, index) {
//             final task = tasks[index];
//             return _buildTaskTile(task);
//           },
//         ),
//       ],
//     );
//   }

//   // 👈 Task tile đẹp hơn
//   Widget _buildTaskTile(Task task) {
//     return Container(
//       decoration: BoxDecoration(
//         color: task.isCompleted ? Colors.grey[50] : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: task.isCompleted ? Colors.grey[200]! : Colors.grey[100]!,
//           width: 1,
//         ),
//         boxShadow: [
//           if (!task.isCompleted)
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         leading: Checkbox(
//           value: task.isCompleted,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(4),
//           ),
//           onChanged: taskController.isTaskPending(task.id!)
//               ? null
//               : (bool? newValue) {
//                   final newStatus = newValue ?? false;
//                   taskController.toggleTaskStatus(task, newStatus);
//                 },
//         ),
//         title: Text(
//           task.title,
//           style: TextStyle(
//             decoration: task.isCompleted
//                 ? TextDecoration.lineThrough
//                 : TextDecoration.none,
//             color: task.isCompleted ? Colors.grey[600] : Colors.black87,
//             fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
//           ),
//         ),
//         subtitle: task.description?.isNotEmpty == true
//             ? Text(
//                 task.description!,
//                 style: TextStyle(
//                   color: task.isCompleted ? Colors.grey[500] : Colors.grey[600],
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               )
//             : null,
//         trailing: taskController.isTaskPending(task.id!)
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               )
//             : IconButton(
//                 icon: const Icon(Icons.delete_outline, color: Colors.red),
//                 onPressed: () async {
//                   // Show confirmation dialog
//                   final confirm = await showDialog<bool>(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Delete Task'),
//                       content: const Text(
//                           'Are you sure you want to delete this task?'),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, false),
//                           child: const Text('Cancel'),
//                         ),
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, true),
//                           child: const Text('Delete',
//                               style: TextStyle(color: Colors.red)),
//                         ),
//                       ],
//                     ),
//                   );

//                   if (confirm == true) {
//                     await taskController.deleteTask(task.id);
//                   }
//                 },
//               ),
//       ),
//     );
//   }
// }
