import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/ui/widgets/task_tile.dart';

class EisenhowerMatrix extends StatefulWidget {
  @override
  _EisenhowerMatrixState createState() => _EisenhowerMatrixState();
}

class _EisenhowerMatrixState extends State<EisenhowerMatrix> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Eisenhower Matrix'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Quadrant 1: Urgent & Important
                  Expanded(
                    child: QuadrantWidget(
                      title: 'Urgent & Important',
                      color: Colors.red,
                      // icon: Icons.error,
                      tasks: [
                        TaskItem(
                          title: 'Create tasks, free up your mind',
                          isCompleted: true,
                          icon: Icons.check_circle,
                        ),
                        TaskItem(
                          title: 'Use lists to manage tasks',
                          isCompleted: false,
                          icon: Icons.list,
                        ),
                        TaskItem(
                          title: 'Use lists to manage tasks',
                          isCompleted: false,
                          icon: Icons.list,
                        ),
                        TaskItem(
                          title: 'Use lists to manage tasks',
                          isCompleted: false,
                          icon: Icons.list,
                        ),
                        TaskItem(
                          title: 'Use lists to manage tasks',
                          isCompleted: false,
                          icon: Icons.list,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  // Quadrant 2: Not Urgent & Important
                  Expanded(
                    child: QuadrantWidget(
                      title: 'Not Urgent & Important',
                      color: Colors.orange,
                      // icon: Icons.warning,
                      tasks: [
                        TaskItem(
                          title: 'Calendar: Check your schedule',
                          isCompleted: false,
                          icon: Icons.calendar_today,
                        ),
                        TaskItem(
                          title: 'Premium',
                          isCompleted: false,
                          icon: Icons.diamond,
                          iconColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Row(
                children: [
                  // Quadrant 3: Urgent & Unimportant
                  Expanded(
                    child: QuadrantWidget(
                      title: 'Urgent & Unimportant',
                      color: Colors.blue,
                      // icon: Icons.info,
                      tasks: [
                        TaskItem(
                          title: 'Eisenhower Matrix: Prioritize tas...',
                          isCompleted: false,
                          icon: Icons.grid_view,
                        ),
                        TaskItem(
                          title: 'Pomo: Beat procrastination',
                          isCompleted: false,
                          icon: Icons.timer,
                        ),
                        TaskItem(
                          title: 'Habit: Visualize your efforts',
                          isCompleted: false,
                          icon: Icons.bar_chart,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  // Quadrant 4: Not Urgent & Unimportant
                  Expanded(
                    child: QuadrantWidget(
                      title: 'Not Urgent & Unimport...',
                      color: Colors.green,
                      // icon: Icons.check_circle,
                      tasks: [
                        TaskItem(
                          title: 'Jdjd',
                          subtitle: 'Aug 6',
                          isCompleted: false,
                          icon: Icons.circle_outlined,
                        ),
                        TaskItem(
                          title: 'More amazing features',
                          isCompleted: false,
                          icon: Icons.star,
                        ),
                        TaskItem(
                          title: 'Follow us',
                          isCompleted: false,
                          icon: Icons.favorite,
                          iconColor: Colors.yellow,
                        ),
                      ],
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

class QuadrantWidget extends StatelessWidget {
  final String title;
  final Color color;
  // final IconData icon;
  final List<TaskItem> tasks;

  const QuadrantWidget({
    Key? key,
    required this.title,
    required this.color,
    // required this.icon,
    required this.tasks,
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
                  // child: Icon(
                  //   icon,
                  //   color: Colors.white,
                  //   size: 12,
                  // ),
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
              ],
            ),
          ),
          // Tasks
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskItemWidget(task: tasks[index]);
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

  TaskItem({
    required this.title,
    this.subtitle,
    required this.isCompleted,
    required this.icon,
    this.iconColor,
  });
}

class TaskItemWidget extends StatelessWidget {
  final TaskItem task;

  const TaskItemWidget({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
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
    );
  }
}
