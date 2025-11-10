import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/bottom_navbar_screen.dart';
import 'package:flutter_to_do_app/ui/widgets/task_tile.dart';

// class EisenhowerMatrix extends StatefulWidget {
//   @override
//   _EisenhowerMatrixState createState() => _EisenhowerMatrixState();
// }

// class _EisenhowerMatrixState extends State<EisenhowerMatrix> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text('Eisenhower Matrix'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.more_vert),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: Row(
//                 children: [
//                   // Quadrant 1: Urgent & Important
//                   Expanded(
//                     child: QuadrantWidget(
//                       title: 'Urgent & Important',
//                       color: Colors.red,
//                       // icon: Icons.error,
//                       tasks: [
//                         TaskItem(
//                           title: 'Create tasks, free up your mind',
//                           isCompleted: true,
//                           icon: Icons.check_circle,
//                         ),
//                         TaskItem(
//                           title: 'Use lists to manage tasks',
//                           isCompleted: false,
//                           icon: Icons.list,
//                         ),
//                         TaskItem(
//                           title: 'Use lists to manage tasks',
//                           isCompleted: false,
//                           icon: Icons.list,
//                         ),
//                         TaskItem(
//                           title: 'Use lists to manage tasks',
//                           isCompleted: false,
//                           icon: Icons.list,
//                         ),
//                         TaskItem(
//                           title: 'Use lists to manage tasks',
//                           isCompleted: false,
//                           icon: Icons.list,
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   // Quadrant 2: Not Urgent & Important
//                   Expanded(
//                     child: QuadrantWidget(
//                       title: 'Not Urgent & Important',
//                       color: Colors.orange,
//                       // icon: Icons.warning,
//                       tasks: [
//                         TaskItem(
//                           title: 'Calendar: Check your schedule',
//                           isCompleted: false,
//                           icon: Icons.calendar_today,
//                         ),
//                         TaskItem(
//                           title: 'Premium',
//                           isCompleted: false,
//                           icon: Icons.diamond,
//                           iconColor: Colors.blue,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 8),
//             Expanded(
//               child: Row(
//                 children: [
//                   // Quadrant 3: Urgent & Unimportant
//                   Expanded(
//                     child: QuadrantWidget(
//                       title: 'Urgent & Unimportant',
//                       color: Colors.blue,
//                       // icon: Icons.info,
//                       tasks: [
//                         TaskItem(
//                           title: 'Eisenhower Matrix: Prioritize tas...',
//                           isCompleted: false,
//                           icon: Icons.grid_view,
//                         ),
//                         TaskItem(
//                           title: 'Pomo: Beat procrastination',
//                           isCompleted: false,
//                           icon: Icons.timer,
//                         ),
//                         TaskItem(
//                           title: 'Habit: Visualize your efforts',
//                           isCompleted: false,
//                           icon: Icons.bar_chart,
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   // Quadrant 4: Not Urgent & Unimportant
//                   Expanded(
//                     child: QuadrantWidget(
//                       title: 'Not Urgent & Unimport...',
//                       color: Colors.green,
//                       // icon: Icons.check_circle,
//                       tasks: [
//                         TaskItem(
//                           title: 'Jdjd',
//                           subtitle: 'Aug 6',
//                           isCompleted: false,
//                           icon: Icons.circle_outlined,
//                         ),
//                         TaskItem(
//                           title: 'More amazing features',
//                           isCompleted: false,
//                           icon: Icons.star,
//                         ),
//                         TaskItem(
//                           title: 'Follow us',
//                           isCompleted: false,
//                           icon: Icons.favorite,
//                           iconColor: Colors.yellow,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class QuadrantWidget extends StatelessWidget {
//   final String title;
//   final Color color;
//   // final IconData icon;
//   final List<TaskItem> tasks;

//   const QuadrantWidget({
//     Key? key,
//     required this.title,
//     required this.color,
//     // required this.icon,
//     required this.tasks,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Container(
//             padding: EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Container(
//                   width: 20,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: color,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   // child: Icon(
//                   //   icon,
//                   //   color: Colors.white,
//                   //   size: 12,
//                   // ),
//                 ),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Tasks
//           Expanded(
//             child: ListView.builder(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               itemCount: tasks.length,
//               itemBuilder: (context, index) {
//                 return TaskItemWidget(task: tasks[index]);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TaskItem {
//   final String title;
//   final String? subtitle;
//   final bool isCompleted;
//   final IconData icon;
//   final Color? iconColor;

//   TaskItem({
//     required this.title,
//     this.subtitle,
//     required this.isCompleted,
//     required this.icon,
//     this.iconColor,
//   });
// }

// class TaskItemWidget extends StatelessWidget {
//   final TaskItem task;

//   const TaskItemWidget({Key? key, required this.task}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       padding: EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           // Checkbox or Icon
//           Container(
//             width: 20,
//             height: 20,
//             decoration: BoxDecoration(
//               color: task.isCompleted ? Colors.green : Colors.transparent,
//               border: Border.all(
//                 color: task.isCompleted ? Colors.green : Colors.grey,
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: task.isCompleted
//                 ? Icon(Icons.check, color: Colors.white, size: 14)
//                 : null,
//           ),
//           SizedBox(width: 8),
//           // Task Icon
//           Icon(
//             task.icon,
//             size: 16,
//             color: task.iconColor ?? Colors.grey[600],
//           ),
//           SizedBox(width: 8),
//           // Task Text
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   task.title,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.black87,
//                     decoration: task.isCompleted
//                         ? TextDecoration.lineThrough
//                         : TextDecoration.none,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 if (task.subtitle != null)
//                   Text(
//                     task.subtitle!,
//                     style: TextStyle(
//                       fontSize: 9,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EisenhowerMatrix extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const EisenhowerMatrix({super.key, this.onBackPressed});
  @override
  _EisenhowerMatrixState createState() => _EisenhowerMatrixState();
}

class _EisenhowerMatrixState extends State<EisenhowerMatrix> {
  final TaskController taskController = Get.find<TaskController>();
  List<Task> matrixTasks = []; // Separate list for matrix
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatrixTasks();
  }

  // Load all tasks specifically for matrix
  Future<void> _loadMatrixTasks() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Call API to get all tasks
      await taskController.getTasks();

      // Filter only tasks with priority (not null)
      matrixTasks = taskController.taskList
          .where((task) => task.priority != null)
          .toList();

      print("Matrix tasks loaded: ${matrixTasks.length}");
      for (var task in matrixTasks) {
        print("Task: ${task.title}, Priority: ${task.priority}");
      }
    } catch (e) {
      print("Error loading matrix tasks: $e");
      matrixTasks = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  // Filter tasks by priority from matrix-specific list
  List<Task> getTasksByPriority(int priority) {
    return matrixTasks.where((task) => task.priority == priority).toList();
  }

  // Convert Task to TaskItem for display
  TaskItem convertToTaskItem(Task task) {
    return TaskItem(
      title: task.title,
      subtitle:
          task.date != null ? "${task.date!.day}/${task.date!.month}" : null,
      isCompleted: task.isCompleted ?? false,
      icon: _getTaskIcon(task),
      iconColor: _getTaskIconColor(task),
      task: task, // Pass the original task object
    );
  }

  IconData _getTaskIcon(Task task) {
    if (task.isCompleted == true) return Icons.check_circle;
    if (task.categoryId != null) return Icons.category;
    return Icons.circle_outlined;
  }

  Color _getTaskIconColor(Task task) {
    if (task.isCompleted == true) return Colors.green;
    return Colors.grey[600] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back_ios_new_rounded,
          //       color: Colors.black),
          //   onPressed: () {
          //     if (widget.onBackPressed != null) {
          //       widget.onBackPressed!();
          //     } else {
          //       //tam thoi de click back thì nav to home, lam back bth kho quaa
          //       //
          //       // if (Navigator.of(context).canPop()) {
          //       //   Navigator.of(context).pop();
          //       // } else {
          //       Navigator.of(context).pushReplacement(
          //         MaterialPageRoute(
          //             builder: (_) =>
          //                 BottomNavBarScreen(key: AppNavigation.bottomNavKey)),
          //       );
          //       // }
          //     }
          //   },
          // ),
          leadingWidth: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Eisenhower Matrix',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _loadMatrixTasks(); // Use matrix-specific reload
              },
            ),
          ],
        ),
        // appBar: AppBar(
        //   title: Text('Eisenhower Matrix'),
        //   backgroundColor: Colors.white,
        //   foregroundColor: Colors.black,
        //   elevation: 0,
        //   actions: [
        //     IconButton(
        //       icon: Icon(Icons.refresh),
        //       onPressed: () {
        //         _loadMatrixTasks(); // Use matrix-specific reload
        //       },
        //     ),
        //   ],
        // ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Quadrant 1: Urgent & Important (Priority 1)
                          Expanded(
                            child: QuadrantWidget(
                              title: 'Urgent & Important',
                              color: Colors.red,
                              tasks: getTasksByPriority(1)
                                  .map((task) => convertToTaskItem(task))
                                  .toList(),
                              onTaskTap: (taskItem) {
                                // Handle task tap - toggle completion
                                if (taskItem.task != null) {
                                  _toggleTaskCompletion(taskItem.task!);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          // Quadrant 2: Not Urgent & Important (Priority 2)
                          Expanded(
                            child: QuadrantWidget(
                              title: 'Not Urgent & Important',
                              color: Colors.orange,
                              tasks: getTasksByPriority(2)
                                  .map((task) => convertToTaskItem(task))
                                  .toList(),
                              onTaskTap: (taskItem) {
                                if (taskItem.task != null) {
                                  _toggleTaskCompletion(taskItem.task!);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: Row(
                        children: [
                          // Quadrant 3: Urgent & Unimportant (Priority 3)
                          Expanded(
                            child: QuadrantWidget(
                              title: 'Urgent & Unimportant',
                              color: Colors.blue,
                              tasks: getTasksByPriority(3)
                                  .map((task) => convertToTaskItem(task))
                                  .toList(),
                              onTaskTap: (taskItem) {
                                if (taskItem.task != null) {
                                  _toggleTaskCompletion(taskItem.task!);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          // Quadrant 4: Not Urgent & Unimportant (Priority 4)
                          Expanded(
                            child: QuadrantWidget(
                              title: 'Not Urgent & Unimportant',
                              color: Colors.green,
                              tasks: getTasksByPriority(4)
                                  .map((task) => convertToTaskItem(task))
                                  .toList(),
                              onTaskTap: (taskItem) {
                                if (taskItem.task != null) {
                                  _toggleTaskCompletion(taskItem.task!);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }

  void _toggleTaskCompletion(Task task) {
    // Toggle task completion
    Task updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      categoryId: task.categoryId,
      date: task.date,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: !(task.isCompleted ?? false),
    );

    // Update task via controller (you'll need to implement updateTask method)
    // taskController.updateTask(updatedTask);
  }
}

class QuadrantWidget extends StatelessWidget {
  final String title;
  final Color color;
  final List<TaskItem> tasks;
  final Function(TaskItem)? onTaskTap;

  const QuadrantWidget({
    Key? key,
    required this.title,
    required this.color,
    required this.tasks,
    this.onTaskTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Show task count
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tasks or Empty State
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No tasks',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskItemWidget(
                        task: tasks[index],
                        onTap: onTaskTap != null
                            ? () => onTaskTap!(tasks[index])
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TaskItem {
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final IconData icon;
  final Color? iconColor;
  final Task? task; // Add reference to original Task object

  TaskItem({
    required this.title,
    this.subtitle,
    required this.isCompleted,
    required this.icon,
    this.iconColor,
    this.task,
  });
}

class TaskItemWidget extends StatelessWidget {
  final TaskItem task;
  final VoidCallback? onTap;

  const TaskItemWidget({
    Key? key,
    required this.task,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox or Icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: task.isCompleted ? Colors.green : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted ? Colors.green : Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: task.isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            SizedBox(width: 8),
            // Task Icon
            Icon(
              task.icon,
              size: 16,
              color: task.iconColor ?? Colors.grey[600],
            ),
            SizedBox(width: 8),
            // Task Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.subtitle != null)
                    Text(
                      task.subtitle!,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
