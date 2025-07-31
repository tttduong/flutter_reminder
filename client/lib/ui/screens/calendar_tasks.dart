// import 'package:date_picker_timeline/date_picker_timeline.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_to_do_app/consts.dart';
// import 'package:flutter_to_do_app/controller/task_controller.dart';
// import 'package:flutter_to_do_app/data/models/task.dart';
// import 'package:flutter_to_do_app/ui/widgets/button_add_task.dart';
// import 'package:flutter_to_do_app/ui/widgets/task_tile.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

// class CalendarTasks extends StatefulWidget {
//   const CalendarTasks({Key? key}) : super(key: key);

//   @override
//   State<CalendarTasks> createState() => _CalendarTasksState();
// }

// class _CalendarTasksState extends State<CalendarTasks> {
//   late Future<List<Task>> futureTasks;
//   DateTime _selectedDate = DateTime.now();
//   final _taskController = Get.put(TaskController());

//   @override
//   void initState() {
//     super.initState();
//     _taskController.getTasksByDate(_selectedDate);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.green,
//       // appBar: _appBar(),
//       body: Column(
//         children: [
//           _addTaskBar(),
//           _addDateBar(),
//           _showTasks(),
//         ],
//       ),
//       floatingActionButton: const ButtonAddTask(),
//     );
//   }

//   // _showTasks() {
//   //   return Obx(() {
//   //     if (_taskController.taskList.isEmpty) {
//   //       return Center(child: Text("Không có task nào!"));
//   //     }
//   //     return Column(
//   //       children: [
//   //         SizedBox(
//   //           height: 300,
//   //           child: ListView.builder(
//   //             itemCount: _taskController.taskList.length,
//   //             itemBuilder: (context, index) {
//   //               return TaskTile(
//   //                 task: _taskController.taskList[index],
//   //                 onTap: () => null,
//   //               );
//   //             },
//   //           ),
//   //         ),
//   //       ],
//   //     );
//   //   });
//   // }
//   _showTasks() {
//     return Obx(() {
//       // Hiển thị loading khi đang fetch data
//       if (_taskController.isLoading.value) {
//         return Center(child: CircularProgressIndicator());
//       }

//       if (_taskController.taskList.isEmpty) {
//         return Center(
//             child: Text(
//                 "No tasks on ${DateFormat('dd/MM/yyyy').format(_selectedDate)}!"));
//       }

//       return Column(
//         children: [
//           SizedBox(
//             height: 300,
//             child: ListView.builder(
//               itemCount: _taskController.taskList.length,
//               itemBuilder: (context, index) {
//                 return TaskTile(
//                   task: _taskController.taskList[index],
//                   onTap: () => null,
//                 );
//               },
//             ),
//           ),
//         ],
//       );
//     });
//   }

//   _addDateBar() {
//     return Container(
//       margin: EdgeInsets.only(top: 5, left: 20),
//       child: DatePicker(DateTime.now(),
//           height: 100,
//           width: 60,
//           initialSelectedDate: DateTime.now(),
//           selectionColor: AppColors.primary,
//           selectedTextColor: Colors.white,
//           dateTextStyle: GoogleFonts.lato(
//               fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
//           dayTextStyle: GoogleFonts.lato(
//               fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
//           monthTextStyle: GoogleFonts.lato(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey), onDateChange: (date) {
//         setState(() {
//           _selectedDate = date;
//         });
//         _taskController.getTasksByDate(date);
//       }),
//     );
//   }

//   _addTaskBar() {
//     return Container(
//       margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             margin: const EdgeInsets.only(left: 0, right: 0, top: 5),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Today",
//                   // style: headingStyle,
//                 ),
//                 Text(
//                   DateFormat.yMMMMd().format(DateTime.now()),
//                   // style: subHeadingStyle
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   _appBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: context.theme.scaffoldBackgroundColor,
//       leading: IconButton(
//         icon: Icon(
//           Icons.arrow_back_ios,
//           size: 20,
//           color: Get.isDarkMode ? Colors.white : Colors.black,
//         ),
//         onPressed: () {
//           Get.back();
//         },
//       ),
//       // leading: GestureDetector(
//       //   onTap: () {
//       //     ThemeService().switchTheme();
//       //   },
//       //   child: Icon(
//       //     Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
//       //     size: 20,
//       //     color: Get.isDarkMode ? Colors.white : Colors.black,
//       //   ),
//       // ),
//       // actions: [
//       //   CircleAvatar(
//       //     backgroundImage: AssetImage("images/profile.jpg"),
//       //   ),
//       //   SizedBox(
//       //     width: 20,
//       //   )
//       // ],
//     );
//   }
// }
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/widgets/button_add_task.dart';
import 'package:flutter_to_do_app/ui/widgets/task_tile.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarTasks extends StatefulWidget {
  const CalendarTasks({Key? key}) : super(key: key);

  @override
  State<CalendarTasks> createState() => _CalendarTasksState();
}

class _CalendarTasksState extends State<CalendarTasks> {
  late Future<List<Task>> futureTasks;
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());

  @override
  void initState() {
    super.initState();
    _selectedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    _loadTasksForDate(_selectedDate);
  }

  // Method riêng để load tasks và đồng bộ UI
  Future<void> _loadTasksForDate(DateTime date) async {
    // Đảm bảo loading state được hiển thị
    _taskController.isLoading.value = true;

    // Load tasks cho ngày được chọn
    await _taskController.getTasksByDate(date);

    // Force UI update
    if (mounted) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _addDateBar(),
          _showTasks(),
        ],
      ),
      floatingActionButton: const ButtonAddTask(),
    );
  }

  _showTasks() {
    return Obx(() {
      // Hiển thị loading khi đang fetch data
      if (_taskController.isLoading.value) {
        return const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (_taskController.taskList.isEmpty) {
        return Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "No tasks on ${DateFormat('dd/MM/yyyy').format(_selectedDate)}!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap + to add a new task",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Phân chia tasks thành 2 nhóm: có time và không có time
      List<Task> tasksWithTime = [];
      List<Task> tasksWithoutTime = [];

      for (Task task in _taskController.taskList) {
        if (task.date != null) {
          tasksWithTime.add(task);
        } else {
          tasksWithoutTime.add(task);
        }
      }

      // Sắp xếp tasks có time theo thời gian
      tasksWithTime.sort((a, b) => a.date!.compareTo(b.date!));

      return Expanded(
        child: RefreshIndicator(
          onRefresh: () => _loadTasksForDate(_selectedDate),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với thông tin ngày đã chọn
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Tasks for ${DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate)}",
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                // Timeline cho tasks có time
                if (tasksWithTime.isNotEmpty) ...[
                  Text(
                    "Scheduled Tasks",
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeline(tasksWithTime),
                ],

                // Danh sách tasks không có time
                if (tasksWithoutTime.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Text(
                    "Other Tasks",
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...tasksWithoutTime
                      .map((task) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: TaskTile(
                              task: task,
                              onTap: () => null,
                            ),
                          ))
                      .toList(),
                ],

                // Add some bottom padding
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTimeline(List<Task> tasks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isLast = index == tasks.length - 1;

        return _buildTimelineItem(task, isLast);
      },
    );
  }

  Widget _buildTimelineItem(Task task, bool isLast) {
    final timeFormat = DateFormat('HH:mm');
    final startTime = task.date != null ? timeFormat.format(task.date!) : '';
    final endTime =
        task.dueDate != null ? timeFormat.format(task.dueDate!) : '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              // Time label
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  startTime,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Timeline dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getTaskColor(task),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              // Timeline line
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  color: Colors.grey[300],
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Task content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task tile
                  TaskTile(
                    task: task,
                    onTap: () => null,
                  ),

                  // Duration info (nếu có end time)
                  if (endTime.isNotEmpty && startTime != endTime) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Until $endTime",
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(Task task) {
    // Bạn có thể customize màu sắc based on task properties
    if (task.dueDate != null && task.dueDate!.isBefore(DateTime.now())) {
      return Colors.red; // Overdue
    } else if (task.date != null && _isTaskNow(task.date!)) {
      return Colors.green; // Current time
    } else {
      return AppColors.primary; // Default
    }
  }

  bool _isTaskNow(DateTime taskTime) {
    final now = DateTime.now();
    final taskStart = taskTime;
    final taskEnd =
        taskTime.add(const Duration(hours: 1)); // Giả sử task kéo dài 1h

    return now.isAfter(taskStart) && now.isBefore(taskEnd);
  }

  // Method để hiển thị full calendar picker - ĐÃ SỬA
  Future<void> _showFullCalendar() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      // Normalize ngày được chọn (loại bỏ thời gian)
      final normalizedDate = DateTime(picked.year, picked.month, picked.day);

      // Load tasks và đồng bộ UI
      await _loadTasksForDate(normalizedDate);
    }
  }

  _addDateBar() {
    // Set range rất rộng để có thể xem tất cả các ngày
    DateTime startDate = DateTime(2020, 1, 1);
    DateTime endDate = DateTime(2030, 12, 31);

    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          // Header với tháng/năm hiện tại
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                // Quick navigation buttons
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        DateTime yesterday =
                            _selectedDate.subtract(const Duration(days: 1));
                        await _loadTasksForDate(yesterday);
                      },
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 20,
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime today = DateTime.now();
                        final normalizedToday =
                            DateTime(today.year, today.month, today.day);
                        await _loadTasksForDate(normalizedToday);
                      },
                      child: Text(
                        "Today",
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        DateTime tomorrow =
                            _selectedDate.add(const Duration(days: 1));
                        await _loadTasksForDate(tomorrow);
                      },
                      icon: const Icon(Icons.chevron_right),
                      iconSize: 20,
                    ),
                    // Thêm button mở calendar picker
                    IconButton(
                      onPressed: _showFullCalendar,
                      icon: const Icon(Icons.calendar_month),
                      iconSize: 20,
                      tooltip: "Open Calendar",
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Date picker timeline với range rộng - ĐÃ SỬA
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: DatePicker(
              startDate,
              height: 100,
              width: 60,
              initialSelectedDate: _selectedDate,
              selectionColor: AppColors.primary,
              selectedTextColor: Colors.white,
              dateTextStyle: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              dayTextStyle: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              monthTextStyle: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              daysCount: 3650, // 10 năm = 3650 ngày
              locale: "en_US",
              onDateChange: (date) async {
                // Normalize ngày được chọn
                final normalizedDate =
                    DateTime(date.year, date.month, date.day);

                // Load tasks và đồng bộ UI
                await _loadTasksForDate(normalizedDate);
              },
            ),
          ),
        ],
      ),
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 0, right: 0, top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today",
                  // style: headingStyle,
                ),
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  // style: subHeadingStyle
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
