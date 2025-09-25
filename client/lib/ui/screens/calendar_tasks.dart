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
//     _selectedDate =
//         DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
//     _loadTasksForDate(_selectedDate);
//   }

//   // Method riêng để load tasks và đồng bộ UI
//   Future<void> _loadTasksForDate(DateTime date) async {
//     // Đảm bảo loading state được hiển thị
//     _taskController.isLoading.value = true;

//     // Load tasks cho ngày được chọn
//     await _taskController.getTasksByDate(date);

//     // Force UI update
//     if (mounted) {
//       setState(() {
//         _selectedDate = date;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Column(
//         children: [
//           _addDateBar(),
//           _showTasks(),
//         ],
//       ),
//       floatingActionButton: const ButtonAddTask(),
//     );
//   }

//   _showTasks() {
//     return Obx(() {
//       // Hiển thị loading khi đang fetch data
//       if (_taskController.isLoading.value) {
//         return const Expanded(
//           child: Center(child: CircularProgressIndicator()),
//         );
//       }

//       if (_taskController.taskList.isEmpty) {
//         return Expanded(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.event_busy,
//                   size: 80,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "No tasks on ${DateFormat('dd/MM/yyyy').format(_selectedDate)}!",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Tap + to add a new task",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[500],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }

//       // Phân chia tasks thành 2 nhóm: có time và không có time
//       List<Task> tasksWithTime = [];
//       List<Task> tasksWithoutTime = [];

//       for (Task task in _taskController.taskList) {
//         if (task.date != null) {
//           tasksWithTime.add(task);
//         } else {
//           tasksWithoutTime.add(task);
//         }
//       }

//       // Sắp xếp tasks có time theo thời gian
//       tasksWithTime.sort((a, b) => a.date!.compareTo(b.date!));

//       return Expanded(
//         child: RefreshIndicator(
//           onRefresh: () => _loadTasksForDate(_selectedDate),
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header với thông tin ngày đã chọn
//                 Container(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.event,
//                         color: AppColors.primary,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         "Tasks for ${DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate)}",
//                         style: GoogleFonts.lato(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Timeline cho tasks có time
//                 if (tasksWithTime.isNotEmpty) ...[
//                   Text(
//                     "Scheduled Tasks",
//                     style: GoogleFonts.lato(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTimeline(tasksWithTime),
//                 ],

//                 // Danh sách tasks không có time
//                 if (tasksWithoutTime.isNotEmpty) ...[
//                   const SizedBox(height: 30),
//                   Text(
//                     "Other Tasks",
//                     style: GoogleFonts.lato(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ...tasksWithoutTime
//                       .map((task) => Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             child: TaskTile(
//                               task: task,
//                               onTap: () => null,
//                             ),
//                           ))
//                       .toList(),
//                 ],

//                 // Add some bottom padding
//                 const SizedBox(height: 100),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildTimeline(List<Task> tasks) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: tasks.length,
//       itemBuilder: (context, index) {
//         final task = tasks[index];
//         final isLast = index == tasks.length - 1;

//         return _buildTimelineItem(task, isLast);
//       },
//     );
//   }

//   Widget _buildTimelineItem(Task task, bool isLast) {
//     final timeFormat = DateFormat('HH:mm');
//     final startTime = task.date != null ? timeFormat.format(task.date!) : '';
//     final endTime =
//         task.dueDate != null ? timeFormat.format(task.dueDate!) : '';

//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Timeline indicator
//           Column(
//             children: [
//               // Time label
//               Container(
//                 width: 60,
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: Text(
//                   startTime,
//                   style: GoogleFonts.lato(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.primary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               // Timeline dot
//               Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: _getTaskColor(task),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.white,
//                     width: 2,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.3),
//                       spreadRadius: 1,
//                       blurRadius: 2,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//               ),
//               // Timeline line
//               if (!isLast)
//                 Container(
//                   width: 2,
//                   height: 80,
//                   color: Colors.grey[300],
//                 ),
//             ],
//           ),

//           const SizedBox(width: 16),

//           // Task content
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Task tile
//                   TaskTile(
//                     task: task,
//                     onTap: () => null,
//                   ),

//                   // Duration info (nếu có end time)
//                   if (endTime.isNotEmpty && startTime != endTime) ...[
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.only(left: 16),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.schedule,
//                             size: 14,
//                             color: Colors.grey[600],
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             "Until $endTime",
//                             style: GoogleFonts.lato(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getTaskColor(Task task) {
//     // Bạn có thể customize màu sắc based on task properties
//     if (task.dueDate != null && task.dueDate!.isBefore(DateTime.now())) {
//       return Colors.red; // Overdue
//     } else if (task.date != null && _isTaskNow(task.date!)) {
//       return Colors.green; // Current time
//     } else {
//       return AppColors.primary; // Default
//     }
//   }

//   bool _isTaskNow(DateTime taskTime) {
//     final now = DateTime.now();
//     final taskStart = taskTime;
//     final taskEnd =
//         taskTime.add(const Duration(hours: 1)); // Giả sử task kéo dài 1h

//     return now.isAfter(taskStart) && now.isBefore(taskEnd);
//   }

//   // Method để hiển thị full calendar picker - ĐÃ SỬA
//   Future<void> _showFullCalendar() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020, 1, 1),
//       lastDate: DateTime(2030, 12, 31),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.primary,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != _selectedDate) {
//       // Normalize ngày được chọn (loại bỏ thời gian)
//       final normalizedDate = DateTime(picked.year, picked.month, picked.day);

//       // Load tasks và đồng bộ UI
//       await _loadTasksForDate(normalizedDate);
//     }
//   }

//   _addDateBar() {
//     // Set range rất rộng để có thể xem tất cả các ngày
//     DateTime startDate = DateTime(2020, 1, 1);
//     DateTime endDate = DateTime(2030, 12, 31);

//     return Container(
//       margin: const EdgeInsets.only(top: 5),
//       child: Column(
//         children: [
//           // Header với tháng/năm hiện tại
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   DateFormat('MMMM yyyy').format(_selectedDate),
//                   style: GoogleFonts.lato(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//                 // Quick navigation buttons
//                 Row(
//                   children: [
//                     IconButton(
//                       onPressed: () async {
//                         DateTime yesterday =
//                             _selectedDate.subtract(const Duration(days: 1));
//                         await _loadTasksForDate(yesterday);
//                       },
//                       icon: const Icon(Icons.chevron_left),
//                       iconSize: 20,
//                     ),
//                     TextButton(
//                       onPressed: () async {
//                         DateTime today = DateTime.now();
//                         final normalizedToday =
//                             DateTime(today.year, today.month, today.day);
//                         await _loadTasksForDate(normalizedToday);
//                       },
//                       child: Text(
//                         "Today",
//                         style: GoogleFonts.lato(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () async {
//                         DateTime tomorrow =
//                             _selectedDate.add(const Duration(days: 1));
//                         await _loadTasksForDate(tomorrow);
//                       },
//                       icon: const Icon(Icons.chevron_right),
//                       iconSize: 20,
//                     ),
//                     // Thêm button mở calendar picker
//                     IconButton(
//                       onPressed: _showFullCalendar,
//                       icon: const Icon(Icons.calendar_month),
//                       iconSize: 20,
//                       tooltip: "Open Calendar",
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Date picker timeline với range rộng - ĐÃ SỬA
//           Container(
//             margin: const EdgeInsets.only(left: 20),
//             child: DatePicker(
//               startDate,
//               height: 100,
//               width: 60,
//               initialSelectedDate: _selectedDate,
//               selectionColor: AppColors.primary,
//               selectedTextColor: Colors.white,
//               dateTextStyle: GoogleFonts.lato(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//               dayTextStyle: GoogleFonts.lato(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//               monthTextStyle: GoogleFonts.lato(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//               daysCount: 3650, // 10 năm = 3650 ngày
//               locale: "en_US",
//               onDateChange: (date) async {
//                 // Normalize ngày được chọn
//                 final normalizedDate =
//                     DateTime(date.year, date.month, date.day);

//                 // Load tasks và đồng bộ UI
//                 await _loadTasksForDate(normalizedDate);
//               },
//             ),
//           ),
//         ],
//       ),
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
// }

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
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  final _taskController = Get.put(TaskController());
  bool _showFullCalendar = false;
  int _shownWeeks = 1;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    _loadTasksForDate(_selectedDate);
  }

  Future<void> _loadTasksForDate(DateTime date) async {
    _taskController.isLoading.value = true;
    await _taskController.getTasksByDate(date);
    if (mounted) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Calendar section với fixed height
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildCalendarGrid(),
          ),

          const SizedBox(height: 16),

          // Tasks section - sử dụng Expanded để tránh overflow
          Expanded(
            child: _buildTasksSection(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF5F7FA),
      elevation: 0,
      title: Row(
        children: [
          Text(
            DateFormat('MMM').format(_focusedMonth),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isToday(_selectedDate)
                ? 'Today'
                : DateFormat('EEEE').format(_selectedDate),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.view_list_outlined, color: Colors.black54),
          onPressed: () {
            // Switch to list view
          },
        ),
        IconButton(
          icon: const Icon(Icons.calendar_view_month_outlined,
              color: Colors.black54),
          onPressed: () {
            // Switch to month view
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black54),
          onPressed: () {
            // More options
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    const double weekHeight = 50;

    // Tạo dayWidgets
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;

    final previousMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 0);
    final daysFromPreviousMonth = firstDayWeekday;

    final totalCells = 42; // 6 tuần × 7 ngày
    final daysInCurrentMonth = lastDayOfMonth.day;
    final daysFromNextMonth =
        totalCells - daysFromPreviousMonth - daysInCurrentMonth;

    List<Widget> dayWidgets = [];

    // Previous month days
    for (int i = daysFromPreviousMonth; i > 0; i--) {
      final day = previousMonth.day - i + 1;
      final date = DateTime(previousMonth.year, previousMonth.month, day);
      dayWidgets.add(_buildDayWidget(day, date, isCurrentMonth: false));
    }

    // Current month days
    for (int day = 1; day <= daysInCurrentMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      dayWidgets.add(_buildDayWidget(day, date, isCurrentMonth: true));
    }

    // Next month days
    for (int day = 1; day <= daysFromNextMonth; day++) {
      final nextMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1, day);
      dayWidgets.add(_buildDayWidget(day, nextMonth, isCurrentMonth: false));
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Quan trọng: giới hạn kích thước
      children: [
        _buildWeekdayHeaders(),
        const SizedBox(height: 8),

        // Drag gesture detector với ClipRect để tránh overflow
        ClipRect(
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _dragOffset += details.delta.dy;
                _dragOffset = _dragOffset.clamp(-150.0, 150.0);
              });
            },
            onVerticalDragEnd: (details) {
              setState(() {
                if (_dragOffset < -50) {
                  _shownWeeks = 1;
                } else if (_dragOffset > 50) {
                  _shownWeeks = 6;
                }
                _dragOffset = 0;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: (_shownWeeks * weekHeight + _dragOffset)
                  .clamp(weekHeight, 6 * weekHeight),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    for (int week = 0; week < 6; week++)
                      SizedBox(
                        height: weekHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: dayWidgets.skip(week * 7).take(7).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map((day) => SizedBox(
                width: 40,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDayWidget(int day, DateTime date,
      {required bool isCurrentMonth}) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isToday(date);

    return GestureDetector(
      onTap: () async {
        if (isCurrentMonth) {
          await _loadTasksForDate(date);
        } else {
          setState(() {
            _focusedMonth = DateTime(date.year, date.month);
          });
          await _loadTasksForDate(date);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4285F4)
              : isToday
                  ? const Color(0xFF4285F4).withOpacity(0.1)
                  : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? Colors.white
                  : isToday
                      ? const Color(0xFF4285F4)
                      : isCurrentMonth
                          ? Colors.black87
                          : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksSection() {
    return Obx(() {
      if (_taskController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_taskController.taskList.isEmpty) {
        return _buildEmptyState();
      }

      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "All day",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Task list với Expanded để tránh overflow
            Expanded(
              child: ListView.builder(
                itemCount: _taskController.taskList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: TaskTile(
                      task: _taskController.taskList[index],
                      onTap: () => null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Calendar illustration
          Container(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main calendar
                Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Calendar header
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                width: 12, height: 3, color: Colors.white),
                            Container(
                                width: 12, height: 3, color: Colors.white),
                          ],
                        ),
                      ),
                      // Calendar grid
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                    7,
                                    (index) => Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                          ),
                                        )),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                    7,
                                    (index) => Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: index == 2
                                                ? const Color(0xFF4285F4)
                                                : Colors.grey[300],
                                            shape: BoxShape.circle,
                                          ),
                                        )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Decorative elements
                Positioned(
                  top: 10,
                  right: 15,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4285F4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 10,
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            "You have a free day",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Take it easy",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }
}
