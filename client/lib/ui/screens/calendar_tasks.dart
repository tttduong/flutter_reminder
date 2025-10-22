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
//   DateTime _selectedDate = DateTime.now();
//   DateTime _focusedMonth = DateTime.now();
//   final _taskController = Get.put(TaskController());
//   bool _showFullCalendar = false;
//   int _shownWeeks = 1;
//   double _dragOffset = 0;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDate =
//         DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
//     _loadTasksForDate(_selectedDate);
//   }

//   Future<void> _loadTasksForDate(DateTime date) async {
//     _taskController.isLoading.value = true;
//     await _taskController.getTasksByDate(date);
//     if (mounted) {
//       setState(() {
//         _selectedDate = date;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           // Calendar section với fixed height
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: _buildCalendarGrid(),
//           ),

//           const SizedBox(height: 16),

//           // Tasks section - sử dụng Expanded để tránh overflow
//           Expanded(
//             child: _buildTasksSection(),
//           ),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: const Color(0xFFF5F7FA),
//       elevation: 0,
//       title: Row(
//         children: [
//           Text(
//             DateFormat('MMM').format(_focusedMonth),
//             style: GoogleFonts.inter(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             _isToday(_selectedDate)
//                 ? 'Today'
//                 : DateFormat('EEEE').format(_selectedDate),
//             style: GoogleFonts.inter(
//               fontSize: 20,
//               fontWeight: FontWeight.w400,
//               color: Colors.black54,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.view_list_outlined, color: Colors.black54),
//           onPressed: () {
//             // Switch to list view
//           },
//         ),
//         IconButton(
//           icon: const Icon(Icons.calendar_view_month_outlined,
//               color: Colors.black54),
//           onPressed: () {
//             // Switch to month view
//           },
//         ),
//         IconButton(
//           icon: const Icon(Icons.more_vert, color: Colors.black54),
//           onPressed: () {
//             // More options
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildCalendarGrid() {
//     const double weekHeight = 50;

//     // Tạo dayWidgets
//     final firstDayOfMonth =
//         DateTime(_focusedMonth.year, _focusedMonth.month, 1);
//     final lastDayOfMonth =
//         DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
//     final firstDayWeekday = firstDayOfMonth.weekday % 7;

//     final previousMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 0);
//     final daysFromPreviousMonth = firstDayWeekday;

//     final totalCells = 42; // 6 tuần × 7 ngày
//     final daysInCurrentMonth = lastDayOfMonth.day;
//     final daysFromNextMonth =
//         totalCells - daysFromPreviousMonth - daysInCurrentMonth;

//     List<Widget> dayWidgets = [];

//     // Previous month days
//     for (int i = daysFromPreviousMonth; i > 0; i--) {
//       final day = previousMonth.day - i + 1;
//       final date = DateTime(previousMonth.year, previousMonth.month, day);
//       dayWidgets.add(_buildDayWidget(day, date, isCurrentMonth: false));
//     }

//     // Current month days
//     for (int day = 1; day <= daysInCurrentMonth; day++) {
//       final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
//       dayWidgets.add(_buildDayWidget(day, date, isCurrentMonth: true));
//     }

//     // Next month days
//     for (int day = 1; day <= daysFromNextMonth; day++) {
//       final nextMonth =
//           DateTime(_focusedMonth.year, _focusedMonth.month + 1, day);
//       dayWidgets.add(_buildDayWidget(day, nextMonth, isCurrentMonth: false));
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min, // Quan trọng: giới hạn kích thước
//       children: [
//         _buildWeekdayHeaders(),
//         const SizedBox(height: 8),

//         // Drag gesture detector với ClipRect để tránh overflow
//         ClipRect(
//           child: GestureDetector(
//             onVerticalDragUpdate: (details) {
//               setState(() {
//                 _dragOffset += details.delta.dy;
//                 _dragOffset = _dragOffset.clamp(-150.0, 150.0);
//               });
//             },
//             onVerticalDragEnd: (details) {
//               setState(() {
//                 if (_dragOffset < -50) {
//                   _shownWeeks = 1;
//                 } else if (_dragOffset > 50) {
//                   _shownWeeks = 6;
//                 }
//                 _dragOffset = 0;
//               });
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               height: (_shownWeeks * weekHeight + _dragOffset)
//                   .clamp(weekHeight, 6 * weekHeight),
//               child: SingleChildScrollView(
//                 physics: const NeverScrollableScrollPhysics(),
//                 child: Column(
//                   children: [
//                     for (int week = 0; week < 6; week++)
//                       SizedBox(
//                         height: weekHeight,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: dayWidgets.skip(week * 7).take(7).toList(),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildWeekdayHeaders() {
//     const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: weekdays
//           .map((day) => SizedBox(
//                 width: 40,
//                 child: Text(
//                   day,
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.inter(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildDayWidget(int day, DateTime date,
//       {required bool isCurrentMonth}) {
//     final isSelected = _isSameDay(date, _selectedDate);
//     final isToday = _isToday(date);

//     return GestureDetector(
//       onTap: () async {
//         if (isCurrentMonth) {
//           await _loadTasksForDate(date);
//         } else {
//           setState(() {
//             _focusedMonth = DateTime(date.year, date.month);
//           });
//           await _loadTasksForDate(date);
//         }
//       },
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: isSelected
//               ? const Color(0xFF4285F4)
//               : isToday
//                   ? const Color(0xFF4285F4).withOpacity(0.1)
//                   : Colors.transparent,
//           shape: BoxShape.circle,
//         ),
//         child: Center(
//           child: Text(
//             day.toString(),
//             style: GoogleFonts.inter(
//               fontSize: 14,
//               fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
//               color: isSelected
//                   ? Colors.white
//                   : isToday
//                       ? const Color(0xFF4285F4)
//                       : isCurrentMonth
//                           ? Colors.black87
//                           : Colors.grey[400],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTasksSection() {
//     return Obx(() {
//       if (_taskController.isLoading.value) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       if (_taskController.taskList.isEmpty) {
//         return _buildEmptyState();
//       }

//       return Container(
//         margin: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 children: [
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       "All day",
//                       style: GoogleFonts.inter(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Task list với Expanded để tránh overflow
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _taskController.taskList.length,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 8),
//                     child: TaskTile(
//                       task: _taskController.taskList[index],
//                       onTap: () => null,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Calendar illustration
//           Container(
//             width: 120,
//             height: 120,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Main calendar
//                 Container(
//                   width: 100,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey[300]!),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       // Calendar header
//                       Container(
//                         height: 20,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF4285F4),
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(8),
//                             topRight: Radius.circular(8),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Container(
//                                 width: 12, height: 3, color: Colors.white),
//                             Container(
//                                 width: 12, height: 3, color: Colors.white),
//                           ],
//                         ),
//                       ),
//                       // Calendar grid
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: List.generate(
//                                     7,
//                                     (index) => Container(
//                                           width: 6,
//                                           height: 6,
//                                           decoration: BoxDecoration(
//                                             color: Colors.grey[300],
//                                             shape: BoxShape.circle,
//                                           ),
//                                         )),
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 children: List.generate(
//                                     7,
//                                     (index) => Container(
//                                           width: 6,
//                                           height: 6,
//                                           decoration: BoxDecoration(
//                                             color: index == 2
//                                                 ? const Color(0xFF4285F4)
//                                                 : Colors.grey[300],
//                                             shape: BoxShape.circle,
//                                           ),
//                                         )),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Decorative elements
//                 Positioned(
//                   top: 10,
//                   right: 15,
//                   child: Container(
//                     width: 4,
//                     height: 4,
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF4285F4),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 15,
//                   left: 10,
//                   child: Container(
//                     width: 3,
//                     height: 3,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[400],
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           Text(
//             "You have a free day",
//             style: GoogleFonts.inter(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),

//           const SizedBox(height: 8),

//           Text(
//             "Take it easy",
//             style: GoogleFonts.inter(
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   bool _isSameDay(DateTime date1, DateTime date2) {
//     return date1.year == date2.year &&
//         date1.month == date2.month &&
//         date1.day == date2.day;
//   }

//   bool _isToday(DateTime date) {
//     final now = DateTime.now();
//     return _isSameDay(date, now);
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/base_app.dart';
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
  final _taskController = Get.put(TaskController());
  final ScrollController _scrollController = ScrollController();

  // Danh sách 3 ngày hiển thị
  late List<DateTime> _displayedDays;
  // Chiều cao của 1 giờ (pixels)
  static const double hourHeight = 80.0; // Tăng từ 60 lên 80

  // Task? _draggingTask;
  double? _hoverHour; // 👉 lưu slot giờ đang hover
  final List<Task> _multiDayTasks = [];

  // Lấy multi-day tasks (task > 1 ngày)
  List<Task> _getMultiDayTasks() {
    return _taskController.taskList.where((task) {
      if (task.date == null || task.dueDate == null) return false;

      // Parse dates
      final startDate = task.date!;
      final endDate = task.dueDate!;

      // Tính số ngày
      final dayDiff = endDate.difference(startDate).inDays;

      // Task nhiều ngày nếu >= 1 ngày
      return dayDiff >= 1;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    // Đảm bảo selectedDate chỉ lấy ngày (ko có giờ phút)
    _selectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    _updateDisplayedDays();

    // Lấy controller
    final taskController = Get.find<TaskController>();

    // 🧠 Gọi API thật để lấy tasks
    taskController.getTasks();

    // 🌀 Lắng nghe khi danh sách task thay đổi
    ever(taskController.taskList, (_) {
      if (!mounted) return;
      setState(() {
        _multiDayTasks
          ..clear()
          ..addAll(_getMultiDayTasks());
      });
    });

    // Cuộn đến 7 giờ sáng sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(7 * hourHeight);
    });
  }

  void _updateDisplayedDays() {
    _displayedDays = [
      _selectedDate.subtract(const Duration(days: 1)),
      _selectedDate,
      _selectedDate.add(const Duration(days: 1)),
    ];
  }

  Future<void> _loadTasksForDisplayedDays() async {
    _taskController.isLoading.value = true;
    // Load tasks cho cả 3 ngày
    await _taskController.getTasksByDate(_selectedDate);
    _taskController.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    // return BaseAppScreen(
    //   showAppBar: false, // không hiện appbar chung
    // appBar: _buildAppBar(),
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppColors.primary),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // 👈 Mở drawer
            },
          ),
        ),
      ),
      body: Column(
        children: [
          _buildMiniCalendar(),
          _buildMultiDayBanner(),
          Expanded(
            child: _buildWeeklyCalendar(),
          ),
        ],
      ),
      // body: CalendarView(), // phần nội dung riêng
    );

    // return Scaffold(
    //   backgroundColor: Colors.white,

    // );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: () {},
      ),
      title: Text(
        DateFormat('MMMM').format(_selectedDate),
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMiniCalendar() {
    // Lấy tên thứ động từ date
    final weekdayNames =
        _displayedDays.map((date) => DateFormat('E').format(date)).toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekdayNames.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final date = _displayedDays[index];
          final isSelected = index == 1; // Ngày giữa được chọn

          return GestureDetector(
            onTap: () async {
              setState(() {
                _selectedDate = date;
                _updateDisplayedDays();
              });
              await _loadTasksForDisplayedDays();
            },
            child: Column(
              children: [
                Text(
                  day,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4285F4)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    return Obx(() {
      if (_taskController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          height: 24 * hourHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeColumn(),
              Expanded(
                child: Row(
                  children: _displayedDays.map((date) {
                    return Expanded(
                      child: _buildDayColumn(date),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTimeColumn() {
    return Container(
      width: 50,
      color: Colors.white,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: List.generate(24, (hour) {
            return Container(
              height: hourHeight,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: Text(
                '${hour.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDayColumn(DateTime date) {
    final tasksForDay = _taskController.taskList.where((task) {
      if (task.date == null || task.dueDate == null) return false;

      final isSameDay = task.date!.year == date.year &&
          task.date!.month == date.month &&
          task.date!.day == date.day;

      // ✅ Loại bỏ task nhiều ngày
      final isMultiDay = task.dueDate!.difference(task.date!).inDays >= 1;

      return isSameDay && !isMultiDay;
    }).toList();

    // Sort: dài trước, ngắn sau => khi render, ngắn sẽ được vẽ sau cùng => nằm trên
    tasksForDay.sort((a, b) {
      final durA = a.dueDate?.difference(a.date!).inMinutes ?? 60;
      final durB = b.dueDate?.difference(b.date!).inMinutes ?? 60;
      return durB.compareTo(durA); // dài lớn trước
    });

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return DragTarget<Task>(
            onAcceptWithDetails: (details) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox == null) return;
              final localOffset = renderBox.globalToLocal(details.offset);
              final dy = localOffset.dy;

              final newHour = dy / hourHeight;
              final hour = newHour.floor();
              final minutes = ((newHour - hour) * 60).round();

              final newStart = DateTime(
                date.year,
                date.month,
                date.day,
                hour,
                minutes,
              );

              final task = details.data;
              final duration = task.dueDate?.difference(task.date!) ??
                  const Duration(hours: 1);
              final newEnd = newStart.add(duration);

              setState(() {
                task.date = newStart;
                task.dueDate = newEnd;
              });
            },
            onMove: (details) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox == null) return;
              final localOffset = renderBox.globalToLocal(details.offset);
              final dy = localOffset.dy;

              final newHour = dy / hourHeight;
              final slot = (newHour * 12).floor() / 12;

              setState(() {
                _hoverHour = slot;
              });
            },
            onLeave: (data) => setState(() => _hoverHour = null),
            builder: (context, candidateData, rejectedData) {
              return Stack(
                children: [
                  // background trắng (hoặc grid nếu muốn)
                  Container(color: Colors.white),
                  CustomPaint(
                    size: Size.infinite,
                    painter: _GridPainter(hourHeight: hourHeight),
                  ),

                  // render tasks theo thứ tự đã sort
                  ...tasksForDay.map((t) => _buildTaskBlock(t)).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskBlock(Task task) {
    final categoryController = Get.find<CategoryController>();
    final category = categoryController.categoryList.firstWhereOrNull(
      (c) => c.id == task.categoryId,
    );

    final startHour = task.date!.hour + task.date!.minute / 60.0;
    final duration = task.dueDate != null
        ? task.dueDate!.difference(task.date!).inMinutes / 60.0
        : 1.0;

    final top = startHour * hourHeight;
    const double minHeight = 70.0;
    final height = (duration * hourHeight).clamp(minHeight, double.infinity);

    final color = pastelColor(category?.color ?? Colors.red[200]!);

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      child: LongPressDraggable<Task>(
        data: task,
        feedback: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 120,
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        childWhenDragging: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title ?? '',
                style: TextStyle(fontSize: 11),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${DateFormat('HH:mm').format(task.date!)}'
                '${task.dueDate != null ? '-${DateFormat('HH:mm').format(task.dueDate!)}' : ''}',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color pastelColor(Color color) {
    return Color.lerp(color, Colors.white, 0.4)!; // 0.0 = đậm, 1.0 = trắng
  }

  Color extraPastelColor(Color color) {
    // mix 70% white
    return Color.lerp(color, Colors.white, 0.7)!;
  }

  Widget _buildMultiDayBanner() {
    // 👉 Lọc chỉ những multi-day task có liên quan tới ngày đang chọn
    final tasksForSelectedDate = _multiDayTasks.where((task) {
      if (task.date == null || task.dueDate == null) return false;

      final startDate =
          DateTime(task.date!.year, task.date!.month, task.date!.day);
      final endDate =
          DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      final selected =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

      // Chỉ hiển thị nếu ngày được chọn nằm trong khoảng start → end
      return !selected.isBefore(startDate) && !selected.isAfter(endDate);
    }).toList();

    if (tasksForSelectedDate.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: tasksForSelectedDate.length,
        itemBuilder: (context, index) {
          final task = tasksForSelectedDate[index];
          return _buildMultiDayCard(task);
        },
      ),
    );
  }

  Widget _buildMultiDayCard(Task task) {
    final categoryController = Get.find<CategoryController>();
    final category = categoryController.categoryList.firstWhereOrNull(
      (c) => c.id == task.categoryId,
    );

    final startDate = task.date!;
    final endDate = task.dueDate!;
    final totalDays = endDate.difference(startDate).inDays + 1;
    final currentDay = DateTime.now().difference(startDate).inDays +
        1; // Ngày hiện tại trong chuỗi
    // final progress = (currentDay / totalDays).clamp(0, 1);
    final double progress = (currentDay / totalDays).clamp(0.0, 1.0);
    final remainingDays = (totalDays - currentDay).clamp(0, totalDays);

    // Màu có thể tùy theo category hoặc random
    final baseColor = category?.color ?? Colors.blueAccent;
    final pastelColor = extraPastelColor(baseColor);

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: pastelColor.withOpacity(0.5), // nền dịu mắt hơn
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
          // Title row
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: baseColor.withOpacity(0.8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.title,
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

          // Date range
          Text(
            '${startDate.toString().split(' ')[0]} → ${endDate.toString().split(' ')[0]}',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),

          // Progress info
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

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  AlwaysStoppedAnimation<Color>(baseColor.withOpacity(0.8)),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _GridPainter extends CustomPainter {
  final double hourHeight;
  _GridPainter({required this.hourHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]! // màu của đường kẻ
      ..strokeWidth = 0.5;

    // vẽ từng dòng theo mỗi giờ
    for (double y = 0; y < size.height; y += hourHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
